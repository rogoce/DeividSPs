-- Insertando los valores de las cartas de Salud en emicartasal2

-- Creado    : 15/07/2010 - Autor: Amado Perez M.
-- Modificado: 15/07/2010 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

--DROP PROCEDURE sp_pro503a;

CREATE PROCEDURE sp_pro503a(a_no_documento CHAR(20), a_periodo CHAR(7))

RETURNING dec(16,2);

DEFINE _error 				smallint; 
DEFINE _cod_subramo 		CHAR(3);
DEFINE _no_poliza			CHAR(10);
DEFINE _no_unidad, _cod_grupo        CHAR(5);
DEFINE _cod_producto, _cod_prod_ori,_cod_producto_new  CHAR(5);
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
	  INTO _cod_producto    --_cod_prod_ori
	  FROM emipouni
	 WHERE no_poliza = _no_poliza
	   AND activo = 1;

	SELECT producto_nuevo
	  INTO _cod_producto_new
	  FROM prdnewpro
	 WHERE cod_producto = _cod_producto
	   AND desde = '01/01/2012'
	   AND activo = 1;

	  IF _cod_producto_new IS NOT NULL THEN
	   IF _cod_producto_new <> _cod_producto THEN
	  	 let _cod_producto = _cod_producto_new;
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
	  	 LET _prima_plan = 0;
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
      --RETURN _nombre, _edad, _prima_plan WITH RESUME;

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