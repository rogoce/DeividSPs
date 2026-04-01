-- Insertando los valores de las cartas de Salud en emicartasal

-- Creado    : 15/07/2010 - Autor: Amado Perez M.
-- Modificado: 15/07/2010 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_pro508;

CREATE PROCEDURE sp_pro508(a_no_documento CHAR(20))

RETURNING varchar(100),
		  smallint,
		  dec(16,2),
		  dec(16,2),
		  date,
		  varchar(50);

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

--set debug file to "sp_pro508.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

BEGIN
ON EXCEPTION SET _error    		
 	--RETURN _error, "Error al Actualizar";         
END EXCEPTION 
 
 SELECT fecha_aniv
   INTO _fecha_poliza
   FROM emicartasal
  WHERE no_documento = a_no_documento;

 CALL sp_sis21(a_no_documento) RETURNING _no_poliza;
  
	SELECT cod_subramo
	  INTO _cod_subramo
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT cod_producto
	  INTO _cod_prod_ori
	  FROM emipouni
	 WHERE no_poliza = _no_poliza;

  IF _cod_subramo = '007' THEN	 -- Panama plus
     LET _cod_producto = '01500';
  ELIF _cod_subramo = '009' THEN -- Global
     LET _cod_producto = '01501';
  ELIF _cod_subramo = '013' THEN -- Complementario
     IF _cod_prod_ori IN ('00382','00383','00384','00398','00399','00400') THEN -- Sin deducible  
     	LET _cod_producto = '01503';
     ELIF _cod_prod_ori IN ('00385','00401','00403') THEN -- Deducible 5000 
     	LET _cod_producto = '01525';
     ELIF _cod_prod_ori IN ('00406','00407','00408','00409','00411') THEN -- Deducible 10000 
     	LET _cod_producto = '01526';
	 END IF
  ELIF _cod_subramo = '016' THEN -- Hosp plus
     LET _cod_producto = '01502';
  ELIF _cod_subramo = '008' THEN -- Panama
     LET _cod_producto  = '01500';	--plus
     LET _cod_producto2 = '01587';	--ren
  ELIF _cod_subramo = '018' THEN
     LET _cod_producto  = '01520'; -- plus
     LET _cod_producto2 = '01586'; -- Salud Vital
  END IF

  FOREACH
	  SELECT cod_asegurado, no_unidad 
	    INTO _cod_asegurado, _no_unidad
		FROM emipouni
	   WHERE no_poliza = _no_poliza

	  SELECT nombre, fecha_aniversario
	    INTO _nombre, _fecha_aniversario
		FROM cliclien
	   WHERE cod_cliente = _cod_asegurado;

      LET _edad = sp_sis78(_fecha_aniversario);
         
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
		   and edad_desde   <= _edad
		   and edad_hasta   >= _edad;

      FOREACH
		SELECT porc_recargo
		  INTO _porc_recargo
		  FROM emiunire
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad

        LET _prima_plan = _prima_plan + _prima_plan * _porc_recargo / 100;
        LET _prima_plan2 = _prima_plan2 + _prima_plan2 * _porc_recargo / 100;

	  END FOREACH

      SELECT nombre 
	    INTO _producto
		FROM prdprod
	   WHERE cod_producto = _cod_producto;

      RETURN  _nombre, _edad, _prima_plan, _prima_plan2, _fecha_poliza, _producto WITH RESUME;

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

        LET _edad = sp_sis78(_fecha_aniversario);
         
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
		   and edad_desde   <= _edad
		   and edad_hasta   >= _edad;

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

      SELECT nombre 
	    INTO _producto
		FROM prdprod
	   WHERE cod_producto = _cod_producto;

        RETURN _nombre, _edad, _prima_plan, _prima_plan2, _fecha_poliza, _producto WITH RESUME;

	  END FOREACH

  END FOREACH

END

--RETURN 0, "Actualizacion Exitosa";

END PROCEDURE;