-- Insertando los valores de las cartas de Salud en emicartasal

-- Creado    : 15/07/2010 - Autor: Amado Perez M.
-- Modificado: 15/07/2010 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_pro569;

CREATE PROCEDURE sp_pro569(a_no_documento CHAR(20))

RETURNING char(11) as Tipo_Asegurado,
          varchar(100) as Nombre,
		  smallint as Edad,
		  dec(16,2) as Prima_Anterior,
		  dec(16,2) as Prima_Actual,
		  dec(5,4) as Porcentaje_de_aumento,
		  dec(5,4) as Cambio_rango_de_edad,
		  dec(5,4) as Inflacion_Medica,
		  dec(5,4) as Suficiencia_de_prima;

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
DEFINE _porc_aumento        DEC(5,4);
DEFINE _cambio_edad         DEC(5,4);
DEFINE _edad2            	SMALLINT;
DEFINE _fecha_poliza2       DATE;
DEFINE _prima_edad          DEC(16,2);

--set debug file to "sp_pro569.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

BEGIN
ON EXCEPTION SET _error    		
 	--RETURN _error, "Error al Actualizar";         
END EXCEPTION 
 
 SELECT fecha_aniv,
        cod_producto,
		cod_producto_ant
   INTO _fecha_poliza,
        _cod_producto,
		_cod_producto2
   FROM emicartasal2
  WHERE no_documento = a_no_documento;

 CALL sp_sis21(a_no_documento) RETURNING _no_poliza;
  
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
	  SELECT cod_asegurado, no_unidad 
	    INTO _cod_asegurado, _no_unidad
		FROM emipouni
	   WHERE no_poliza = _no_poliza
	     AND activo = 1

	  SELECT nombre, fecha_aniversario
	    INTO _nombre, _fecha_aniversario
		FROM cliclien
	   WHERE cod_cliente = _cod_asegurado;

      LET _edad2 = sp_sis78(_fecha_aniversario, _fecha_poliza2);
	  LET _edad = sp_sis78(_fecha_aniversario, _fecha_poliza);
         
		select prima
		  into _prima_plan
		  from prdtaeda
		 where cod_producto = _cod_producto
		   and edad_desde   <= _edad
		   and edad_hasta   >= _edad;

		select prima
		  into _prima_plan2
		  from prdtaeda
		 where cod_producto = _cod_producto2
		   and edad_desde   <= _edad2
		   and edad_hasta   >= _edad2;
		  
	     LET _porc_aumento = ((_prima_plan / _prima_plan2) - 1);-- * 100;
	  
		 let _prima_edad = 0;
		 LET _cambio_edad  = 0;
		  
		 if _edad <> _edad2 then
			select prima
			  into _prima_edad
			  from prdtaeda
			 where cod_producto = _cod_producto
			   and edad_desde   <= _edad2
			   and edad_hasta   >= _edad2;			
			LET _cambio_edad  = (_prima_plan - _prima_edad) / _prima_edad; -- * 100;
         end if		 

      FOREACH
		SELECT porc_recargo
		  INTO _porc_recargo
		  FROM emiunire
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad

        LET _prima_plan = _prima_plan + _prima_plan * _porc_recargo / 100;
        LET _prima_plan2 = _prima_plan2 + _prima_plan2 * _porc_recargo / 100;

	  END FOREACH
	  

      RETURN  'Principal', _nombre, _edad, _prima_plan2, _prima_plan, _porc_aumento, _cambio_edad, .044, _porc_aumento - _cambio_edad - .044 WITH RESUME;

      FOREACH
		SELECT cod_cliente
		  INTO _cod_depend
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
         
		select prima
		  into _prima_plan
		  from prdtaeda
		 where cod_producto = _cod_producto
		   and edad_desde   <= _edad
		   and edad_hasta   >= _edad;

		select prima
		  into _prima_plan2
		  from prdtaeda
		 where cod_producto = _cod_producto2
		   and edad_desde   <= _edad2
		   and edad_hasta   >= _edad2;

		 LET _porc_aumento = ((_prima_plan / _prima_plan2) - 1); -- * 100;
		
		 let _prima_edad = 0;
		 LET _cambio_edad  = 0;
		  
		 if _edad <> _edad2 then
			select prima
			  into _prima_edad
			  from prdtaeda
			 where cod_producto = _cod_producto
			   and edad_desde   <= _edad2
			   and edad_hasta   >= _edad2;			
			LET _cambio_edad  = (_prima_plan - _prima_edad) / _prima_edad; -- * 100;
         end if		 
		   
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

        RETURN 'Dependiente', _nombre, _edad, _prima_plan2, _prima_plan, _porc_aumento, _cambio_edad, .044, _porc_aumento - _cambio_edad - 0.044  WITH RESUME;

	  END FOREACH

  END FOREACH

END

--RETURN 0, "Actualizacion Exitosa";

END PROCEDURE;