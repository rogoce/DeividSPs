-- Insertando los valores de las cartas de Salud en emicartasal

-- Creado    : 15/07/2010 - Autor: Amado Perez M.
-- Modificado: 15/07/2010 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_pro503;

CREATE PROCEDURE sp_pro503(a_no_documento CHAR(20), a_periodo CHAR(7))

RETURNING dec(16,2);

DEFINE _error 				smallint; 
DEFINE _cod_subramo 		CHAR(3);
DEFINE _no_poliza			CHAR(10);
DEFINE _no_unidad, _cod_grupo        CHAR(5);
DEFINE _cod_producto, _cod_prod_ori  CHAR(5);
DEFINE _prima_plan 			DEC(16,2);
DEFINE _prima_plan_tot		DEC(16,2);
DEFINE _edad            	SMALLINT;
DEFINE _fecha_aniversario 	DATE;
DEFINE _nombre            	VARCHAR(100);
DEFINE _cod_asegurado       CHAR(10);
DEFINE _cod_depend       	CHAR(10);
DEFINE _porc_recargo        DEC(5,2);
DEFINE _porc_descuento      DEC(5,2);

--set debug file to "sp_pro503.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

LET _prima_plan_tot = 0.00;

BEGIN
ON EXCEPTION SET _error    		
 	--RETURN _error, "Error al Actualizar";         
END EXCEPTION 
 
 CALL sp_sis21(a_no_documento) RETURNING _no_poliza;
  
	SELECT cod_subramo, cod_grupo
	  INTO _cod_subramo, _cod_grupo 
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT cod_producto
	  INTO _cod_prod_ori
	  FROM emipouni
	 WHERE no_poliza = _no_poliza
	   AND activo = 1;

  IF _cod_grupo = '01007' AND a_periodo = '2011-04' THEN -- Grupo Apavimed
	 IF _cod_prod_ori IN ('00620') THEN
		LET _cod_producto = '01609';
	 ELIF _cod_prod_ori IN ('00621') THEN
		LET _cod_producto = '01610';
	 ELIF _cod_prod_ori IN ('00622') THEN
		LET _cod_producto = '01611';
	 END IF
  ELSE
      IF _cod_grupo not in ('01007') THEN
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
			 ELSE
			    LET _cod_producto = _cod_prod_ori;
			 END IF
		  ELIF _cod_subramo = '016' THEN -- Hosp plus
		     LET _cod_producto = '01502';
		  ELIF _cod_subramo = '008' THEN
		     LET _cod_producto = '01587';
		  ELIF _cod_subramo = '018' THEN
		     LET _cod_producto = '01586';
		  END IF
	   END IF  
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

      LET _edad = sp_sis78(_fecha_aniversario);
         
		select prima
		  into _prima_plan
		  from prdtaeda
		 where cod_producto = _cod_producto
		   and edad_desde   <= _edad
		   and edad_hasta   >= _edad;

      IF _prima_plan IS NULL THEN
	  	--LET _prima_plan = 0;
	  END IF

      FOREACH
		SELECT porc_recargo
		  INTO _porc_recargo
		  FROM emiunire
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad

        LET _prima_plan = _prima_plan + _prima_plan * _porc_recargo / 100;

	  END FOREACH

      LET _prima_plan_tot = _prima_plan;
	
      --RETURN  _nombre, _edad, _prima_plan WITH RESUME;

      FOREACH
		SELECT cod_cliente
		  INTO _cod_depend
		  FROM emidepen
		 WHERE no_poliza = _no_poliza
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

	      IF _prima_plan IS NULL THEN
		   --	LET _prima_plan = 0;
		  END IF

        LET _prima_plan_tot = _prima_plan_tot + _prima_plan;
        --RETURN _nombre, _edad, _prima_plan WITH RESUME;

	  END FOREACH

  END FOREACH

END

RETURN _prima_plan_tot;

END PROCEDURE;