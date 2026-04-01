-- Insertando los valores de las cartas de Salud en emicartasal

-- Creado    : 15/07/2010 - Autor: Amado Perez M.
-- Modificado: 15/07/2010 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_pro576;

CREATE PROCEDURE sp_pro576(a_no_documento CHAR(20))

RETURNING varchar(100) as Nombre,
		  dec(16,4) as Porcentaje_de_aumento;

DEFINE _error 				smallint; 
DEFINE _cod_subramo 		CHAR(3);
DEFINE _no_poliza			CHAR(10);
DEFINE _no_unidad       	CHAR(5);
DEFINE _cod_producto        CHAR(5);
DEFINE _cod_producto2       CHAR(5);
DEFINE _cod_prod_ori        CHAR(5);
DEFINE _prima_plan 			DEC(16,2);
DEFINE _prima_plan2			DEC(16,2);
DEFINE _edad            	SMALLINT;
DEFINE _fecha_aniversario 	DATE;
DEFINE _nombre            	VARCHAR(100);
DEFINE _cod_asegurado       CHAR(10);
DEFINE _cod_depend       	CHAR(10);
DEFINE _porc_recargo        DEC(16,4);
DEFINE _porc_descuento      DEC(16,4);
DEFINE _fecha_poliza        DATE;
DEFINE _producto            VARCHAR(50);
DEFINE _porc_aumento        DEC(16,4);
DEFINE _cambio_edad         DEC(16,4);
DEFINE _edad2            	SMALLINT;
DEFINE _fecha_poliza2       DATE;
DEFINE _prima_edad          DEC(16,2);
DEFINE _prima_nueva         DEC(16,2);
DEFINE _prima_ant           dec(16,2);
define _porc_impuesto       dec(5,2);
define _letra               integer;
define _cod_perpago		char(3);
define _edad_desde, _edad_desde2, _cambio smallint;
define _prima_depend, _prima_aseg        dec(16,2);

--set debug file to "sp_pro571.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

BEGIN
ON EXCEPTION SET _error    		
 	--RETURN _error, "Error al Actualizar";         
END EXCEPTION 
 
 SELECT fecha_aniv,
        cod_producto,
		cod_producto_ant,
		prima,
		prima_ant
   INTO _fecha_poliza,
        _cod_producto,
		_cod_producto2,
		_prima_nueva,
		_prima_ant
   FROM emicartasal2
  WHERE no_documento = a_no_documento;
  
 CALL sp_sis21(a_no_documento) RETURNING _no_poliza;
 
 let _prima_nueva = sp_pro573(_no_poliza);
 
		SELECT cod_perpago
		  INTO _cod_perpago
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;
		 
	  if _cod_perpago = '008' then
	    let _letra = 12;
	  elif _cod_perpago = '001' then
	    let _letra = 1;
	  else
	    select meses 
		  into _letra
		  from cobperpa
		 where cod_perpago = _cod_perpago;
	  end if
	   
 --     let _prima = _prima * _letra;	  
	  
	  LET _prima_ant = 0;
 
 -- foreach
	select prima_neta
	  into _prima_ant
	  from emipomae
	 where no_poliza = _no_poliza;
--	   and activo = 1
--	exit foreach;
--  end foreach

	 if _prima_ant is null then
		LET _prima_ant = 0;
	 end if
	
	 LET _prima_ant = _prima_ant / _letra;
	
	-- impuesto	
	select sum(factor_impuesto)
	  into _porc_impuesto
	  from emipolim p, prdimpue i
	 where p.cod_impuesto = i.cod_impuesto
	   and p.no_poliza    = _no_poliza;

	if _porc_impuesto is null then
		let _porc_impuesto = 0;
	end if

	let _prima_ant = _prima_ant * (_porc_impuesto / 100) + _prima_ant; 
  
  let _porc_aumento = ((_prima_nueva / _prima_ant) - 1) * 100;
  let _porc_aumento = _porc_aumento - 6.5;
  
  LET _prima_nueva = _prima_nueva / 1.05;
  let _prima_nueva = _prima_nueva - _prima_nueva * 6.5 / 100;
 
  
	SELECT cod_producto
	  INTO _cod_prod_ori
	  FROM emipouni
	 WHERE no_poliza = _no_poliza
	   AND activo = 1;
	
  LET _fecha_poliza2 = _fecha_poliza - 1 units year;
  
 { FOREACH
	SELECT vigencia_inic
	  INTO _fecha_poliza2
	  FROM endedmae
	 WHERE no_poliza = _no_poliza
	   AND cod_endomov = '014'
	ORDER BY 1 DESC

	EXIT FOREACH;
  END FOREACH
 } 
  IF _fecha_poliza2 IS NULL THEN
	SELECT vigencia_inic
	  INTO _fecha_poliza2
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;
  END IF

  FOREACH
	  SELECT cod_asegurado, 
	         no_unidad,
             prima_asegurado			 
	    INTO _cod_asegurado, 
		     _no_unidad,
			 _prima_aseg
		FROM emipouni
	   WHERE no_poliza = _no_poliza
	     AND activo = 1

	  LET _prima_depend = 0; 
  	  LET _cambio = 0;
		 
	  SELECT SUM(prima)	 
	    INTO _prima_depend
		FROM emidepen
	   WHERE no_poliza = _no_poliza
	     AND no_unidad = _no_unidad;
		 
	  LET _prima_aseg = _prima_aseg - _prima_depend;
		 
		 
	  SELECT nombre, fecha_aniversario
	    INTO _nombre, _fecha_aniversario
		FROM cliclien
	   WHERE cod_cliente = _cod_asegurado;

      LET _edad2 = sp_sis78(_fecha_aniversario, _fecha_poliza2);
	  LET _edad = sp_sis78(_fecha_aniversario, _fecha_poliza);
 
	  IF _edad < 0 then
		LET _edad = 0;
      END IF	  
         
	  IF _edad2 < 0 then
		LET _edad2 = 0;
      END IF	  
 
		select prima, edad_desde
		  into _prima_plan, _edad_desde
		  from prdtaeda
		 where cod_producto = _cod_producto
		   and edad_desde   <= _edad
		   and edad_hasta   >= _edad;

		select prima, edad_desde
		  into _prima_plan2, _edad_desde2
		  from prdtaeda
		 where cod_producto = _cod_producto2
		   and edad_desde   <= _edad2
		   and edad_hasta   >= _edad2;
		  
	   if _prima_aseg <> _prima_plan then
		let _cambio = 1;
	   end if
	  
		 let _prima_edad = 0;
		 LET _cambio_edad  = 0;
		  
{		 if _edad <> _edad2 then
			select prima
			  into _prima_edad
			  from prdtaeda
			 where cod_producto = _cod_producto
			   and edad_desde   <= _edad2
			   and edad_hasta   >= _edad2;			
		--	LET _cambio_edad  = _prima_plan / _prima_edad - 1; -- * 100;
         end if		 
}
      FOREACH
		SELECT porc_recargo
		  INTO _porc_recargo
		  FROM emiunire
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad

        LET _prima_plan = _prima_plan + _prima_plan * _porc_recargo / 100;
        LET _prima_plan2 = _prima_plan2 + _prima_plan2 * _porc_recargo / 100;

	  END FOREACH

		 if _edad_desde <> _edad_desde2 then	  
		    LET _prima_plan = _prima_plan - (_prima_plan * 6.5 / 100);
			LET _cambio_edad = _prima_plan / _prima_nueva;
			LET _cambio_edad = _cambio_edad * _porc_aumento / 100;
			--LET _cambio_edad = ((_prima_plan / _prima_plan2) - 1);-- * 100;
		 else
		    if _cambio = 1 and a_no_documento in ('1811-00020-03','1809-00231-01') then
				LET _prima_aseg = _prima_aseg - (_prima_aseg * 6.5 / 100);
				LET _cambio_edad = _prima_aseg / _prima_nueva;
				LET _cambio_edad = _cambio_edad * _porc_aumento / 100;
			end if
		 end if
		 
      if _cambio_edad > 0 then
		RETURN  _nombre, _cambio_edad WITH RESUME;
	  end if

      FOREACH
		SELECT cod_cliente, 
		       prima
		  INTO _cod_depend,
		       _prima_depend
		  FROM emidepen
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad
		   AND activo = 1

		SELECT nombre, fecha_aniversario
		  INTO _nombre, _fecha_aniversario
		  FROM cliclien
		 WHERE cod_cliente = _cod_depend;

		  LET _edad2 = sp_sis78(_fecha_aniversario, _fecha_poliza2);
		  LET _edad = sp_sis78(_fecha_aniversario, _fecha_poliza);
         
		  IF _edad < 0 then
			LET _edad = 0;
		  END IF	  
			 
		  IF _edad2 < 0 then
			LET _edad2 = 0;
		  END IF	  
		  
		  LET _cambio = 0;
		 
		select prima, edad_desde
		  into _prima_plan, _edad_desde
		  from prdtaeda
		 where cod_producto = _cod_producto
		   and edad_desde   <= _edad
		   and edad_hasta   >= _edad;

		select prima, edad_desde
		  into _prima_plan2, _edad_desde2
		  from prdtaeda
		 where cod_producto = _cod_producto2
		   and edad_desde   <= _edad2
		   and edad_hasta   >= _edad2;

		-- LET _porc_aumento = ((_prima_plan / _prima_plan2) - 1); -- * 100;

	   if _prima_depend <> _prima_plan then
		let _cambio = 1;
	   end if
		
		 let _prima_edad = 0;
		 LET _cambio_edad  = 0;
		  
{		 if _edad <> _edad2 then
			select prima
			  into _prima_edad
			  from prdtaeda
			 where cod_producto = _cod_producto
			   and edad_desde   <= _edad2
			   and edad_hasta   >= _edad2;			
			LET _cambio_edad  = _prima_plan / _prima_edad - 1; -- * 100;
         end if		 
}		   
		FOREACH
			SELECT por_recargo
			  INTO _porc_recargo
			  FROM emiderec
			 WHERE no_poliza = _no_poliza  
			   AND no_unidad = _no_unidad
			   AND cod_cliente = _cod_depend

	        LET _prima_plan = _prima_plan + _prima_plan * _porc_recargo / 100;
	        LET _prima_plan2 = _prima_plan2 + _prima_plan2 * _porc_recargo / 100;
		END FOREACH

		 if _edad_desde <> _edad_desde2 then	  
		    LET _prima_plan = _prima_plan - (_prima_plan * 6.5 / 100);
			LET _cambio_edad = _prima_plan / _prima_nueva;
			LET _cambio_edad = _cambio_edad * _porc_aumento / 100;
			--LET _cambio_edad = ((_prima_plan / _prima_plan2) - 1);-- * 100;
		 else
			 if _cambio = 1 and a_no_documento in ('1811-00020-03','1809-00231-01') then
				LET _prima_depend = _prima_depend - (_prima_depend * 6.5 / 100);
				LET _cambio_edad = _prima_depend / _prima_nueva;
				LET _cambio_edad = _cambio_edad * _porc_aumento / 100;
			 end if
		 end if
		 
		 
		
       if _cambio_edad > 0 then
		RETURN  _nombre, _cambio_edad WITH RESUME;
	   end if

	  END FOREACH

  END FOREACH

END

--RETURN 0, "Actualizacion Exitosa";

END PROCEDURE;