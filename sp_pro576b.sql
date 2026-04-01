-- Insertando los valores de las cartas de Salud en emicartasal

-- Creado    : 15/07/2010 - Autor: Amado Perez M.
-- Modificado: 15/07/2010 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_pro576b;

CREATE PROCEDURE sp_pro576b(a_no_documento CHAR(20))

RETURNING dec(16,4) as Porcentaje_de_aumento;

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
DEFINE _porc_recargo        DEC(5,2);
DEFINE _porc_descuento      DEC(5,2);
DEFINE _fecha_poliza        DATE;
DEFINE _producto            VARCHAR(50);
DEFINE _porc_aumento        DEC(5,2);
DEFINE _cambio_edad         DEC(5,2);
DEFINE _edad2            	SMALLINT;
DEFINE _fecha_poliza2       DATE;
DEFINE _prima_edad          DEC(16,2);
DEFINE _cambio_edad_t       DEC(16,2);
DEFINE _prima_nueva         DEC(16,2);
DEFINE _prima_ant           dec(16,2);
define _porc_impuesto       dec(5,2);
define _letra               integer;
define _cod_perpago		char(3);
define _edad_desde, _edad_desde2 smallint;
define _prima_plan_t        dec(16,2);
define _prima_plan2_t        dec(16,2);
define _cambio              smallint;
define _periodo             char(7);
define _cod_prod_sav        char(5);
define _ano2                integer;
define _s_ano2              char(4);
define _periodo2            char(7);

define _prima_depend, _prima_aseg        dec(16,2);

if a_no_documento = '1801-00340-01' then
 set debug file to "sp_pro576b.trc";
 trace on;
end if

SET ISOLATION TO DIRTY READ;

BEGIN
ON EXCEPTION SET _error    		
 	--RETURN _error, "Error al Actualizar";         
END EXCEPTION 
 
let _cambio_edad_t = 0;
let _prima_plan_t = 0.00;
let _prima_plan2_t = 0.00;
let _cambio = 0;
 
 SELECT fecha_aniv,
        cod_producto,
		cod_producto_ant,
		prima,
		prima_ant,
		periodo,
		cod_prod_sav,
		cod_subramo
   INTO _fecha_poliza,
        _cod_producto,
		_cod_producto2,
		_prima_nueva,
		_prima_ant,
		_periodo,
		_cod_prod_sav,
		_cod_subramo
   FROM emicartasal2
  WHERE no_documento = a_no_documento;
  
  let _ano2 = _periodo[1,4];  
  let _ano2 = _ano2 - 1;

  let _s_ano2 = _ano2;
  
  let _periodo2 = _s_ano2 || "-" || _periodo[6,7];
  
  
	-- Opcion de coberturas Asistencia de Viaje para julio y agosto 2018 Panamá Plus y Global
	if _periodo >= '2018-07' and _periodo <= '2018-08' and _cod_subramo in ('007','009') then
		let _cod_producto = _cod_prod_sav;
	end if

  CALL sp_sis21(a_no_documento) RETURNING _no_poliza;
  	
  LET _fecha_poliza2 = _fecha_poliza - 1 units year;
  
  if a_no_documento in ('1815-00027-03','1810-00872-01','1817-00198-01','1800-00502-01','1810-01877-01','1812-00457-01','1807-00778-01','1817-00386-01') then
	  foreach -- Se cambia ya que en el proceso de facturación mensual se tomaba la fecha en que se corria el proceso para verificar el cambio por edad hasta el periodo 2018-05
		select date_added
		  into _fecha_poliza2
		  from endedmae
		 where no_poliza = _no_poliza
		   and cod_endomov = '014'
		exit foreach;   
	  end foreach
  end if
  
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

	  LET _prima_depend = 0.00;	 
		 
	  SELECT SUM(prima)	 
	    INTO _prima_depend
		FROM emidepen
	   WHERE no_poliza = _no_poliza
	     AND no_unidad = _no_unidad;
		 
	  if _prima_depend is null then
		let _prima_depend = 0.00;
	  end if
		 
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

	  select prima, edad_desde       -- Prima con edad al día del aniversario
		  into _prima_plan, _edad_desde
		  from prdtaeda
		 where cod_producto = _cod_producto
		   and edad_desde   <= _edad
		   and edad_hasta   >= _edad;
		   
		if a_no_documento in ('1811-00020-03','1809-00231-01','1801-00340-01') then --Caso 30459 y 30452 pólizas que nunca habían tenido cambio de prima por cambio de edad
			let _prima_plan = _prima_aseg;
			select edad_desde          -- Prima con edad al día del aniversario
			  into _edad_desde
			  from prdtaeda
			 where cod_producto = _cod_producto2
			   and prima        = _prima_plan;			
		end if
		   
		if _prima_plan is null then
			let _prima_plan = 0;
		end if

		select prima, edad_desde     -- Prima con edad al día del aniversario anterior
		  into _prima_plan2, _edad_desde2
		  from prdtaeda
		 where cod_producto = _cod_producto
		   and edad_desde   <= _edad2
		   and edad_hasta   >= _edad2;
		  
		if _prima_plan2 is null then
			let _prima_plan2 = 0;
		end if
	  
		 let _prima_edad = 0;
		 LET _cambio_edad  = 0;
		 
      FOREACH  --Recargos 
		SELECT porc_recargo
		  INTO _porc_recargo
		  FROM emiunire
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad

        LET _prima_plan = _prima_plan + _prima_plan * _porc_recargo / 100;
        LET _prima_plan2 = _prima_plan2 + _prima_plan2 * _porc_recargo / 100;

	  END FOREACH
	  
	  if _edad_desde <> _edad_desde2 then
		let _cambio = 1;
	  end if
	  
	  
		LET _prima_plan_t = _prima_plan_t + _prima_plan; 
		LET _prima_plan2_t = _prima_plan2_t + _prima_plan2;

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
		 
		select prima, edad_desde          -- Prima con edad al día del aniversario
		  into _prima_plan, _edad_desde
		  from prdtaeda
		 where cod_producto = _cod_producto
		   and edad_desde   <= _edad
		   and edad_hasta   >= _edad;

		if _prima_plan is null then
			let _prima_plan = 0;
		end if
		
		if a_no_documento in ('1811-00020-03','1809-00231-01') then --Caso 30459 y 30452 hay polizas que no tuvieron cambio de prima por cambio de edad
			let _prima_plan = _prima_depend;
			select edad_desde          -- Prima con edad al día del aniversario
			  into _edad_desde
			  from prdtaeda
			 where cod_producto = _cod_producto2
			   and prima        = _prima_plan;			
		end if

		   
		select prima, edad_desde           -- Prima con edad al día del aniversario anterior
		  into _prima_plan2, _edad_desde2
		  from prdtaeda
		 where cod_producto = _cod_producto
		   and edad_desde   <= _edad2
		   and edad_hasta   >= _edad2;

		if _prima_plan2 is null then
			let _prima_plan2 = 0;
		end if
		   
		
		 let _prima_edad = 0;
		 LET _cambio_edad  = 0;
		  
		   
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
			let _cambio = 1;
        end if
		
		LET _prima_plan_t = _prima_plan_t + _prima_plan;
		LET _prima_plan2_t = _prima_plan2_t + _prima_plan2;
		
 	   
	  END FOREACH

  END FOREACH
  
  -- 23-03-2018 
  if _cambio = 1 then
	LET _cambio_edad_t = ((_prima_plan_t / _prima_plan2_t) - 1) * 100;
  else
    LET _cambio_edad_t = 0;
  end if
    

RETURN  _cambio_edad_t;
  
END

--RETURN 0, "Actualizacion Exitosa";

END PROCEDURE;