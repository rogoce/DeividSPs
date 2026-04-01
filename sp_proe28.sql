-- Polizas para Cartas de Aumento de Primas
--
-- Creado    : 11/07/2002 - Autor: Armando Moreno

-- SIS v.2.0 - d_prod_sp_pro62_dw1 - DEIVID, S.A.

--DROP PROCEDURE sp_proe28;

CREATE PROCEDURE "informix".sp_proe28(a_cia CHAR(3),a_agencia CHAR(3),a_periodo CHAR(7))
RETURNING CHAR(50),		--cia.
		  CHAR(20), 	--poliza
          CHAR(100),	--asegurado
          CHAR(3),		--cod_ramo
          CHAR(50),		--ramo
		  CHAR(3),		--cod_subramo
          CHAR(50),		--subramo
		  DEC(16,2),	--prima actual
		  INTEGER,		--dependientes
		  INTEGER,		--edad
          DEC(5,2),		--%extraprima(recargo)
          CHAR(50),		--formadepago
          CHAR(50),		--periododepago
		  CHAR(50),		--dir1
		  CHAR(50),		--dir2
		  CHAR(10),		--tel1
		  CHAR(10);		--tel2

DEFINE _no_poliza       CHAR(10); 
DEFINE _no_documento    CHAR(20);
DEFINE _direccion_1     CHAR(50);
DEFINE _direccion_2     CHAR(50);
DEFINE _telefono1       CHAR(10);
DEFINE _telefono2       CHAR(10);
DEFINE _cod_asegurado   CHAR(10); 
DEFINE _prima_asegurado DEC(16,2);
DEFINE v_desc_ramo,v_descr_cia      CHAR(50);
DEFINE _no_unidad       CHAR(5);
DEFINE _nombre_subramo,_nombre_formadepago,_nombre_perpago  CHAR(50); 
DEFINE _nombre_cliente  CHAR(100); 
DEFINE _fecha			DATE;
DEFINE _edad			INTEGER;
DEFINE _vigencia_inic   DATE;
DEFINE _fecha_hoy       DATE;
DEFINE _cod_ramo,_cod_formapag,_cod_perpago CHAR(3);
DEFINE _cod_subramo     CHAR(3);
DEFINE v_filtros        CHAR(255);
DEFINE _ano_vigenci,_dependientes    INTEGER;
DEFINE _porc_recargo    DEC(5,2);
DEFINE _ano_proceso     SMALLINT;
DEFINE _ano_vigencia    INTEGER;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\demrep41.trc";
--trace on;

SET ISOLATION TO DIRTY READ;
LET _fecha_hoy = TODAY;
LET _ano_proceso = a_periodo[1,4] - 1;
LET v_descr_cia = sp_sis01(a_cia);

--polizas vigentes a la fecha
CALL sp_pro03(a_cia,a_agencia,_fecha_hoy,'018;') RETURNING v_filtros;    

--polizas que cumplen aniversario para el
--periodo seleccionado.
FOREACH
 SELECT no_poliza,
		no_documento,
		cod_ramo,
		cod_subramo,
		vigencia_inic,
		YEAR(vigencia_inic)
   INTO _no_poliza,
		_no_documento,
		_cod_ramo,
		_cod_subramo,
		_vigencia_inic,
		_ano_vigencia
   FROM temp_perfil
  WHERE seleccionado         = 1
	AND MONTH(vigencia_inic) = a_periodo[6,7]
	--AND YEAR(vigencia_inic)  = _ano_proceso
  ORDER BY 6, 2

	SELECT nombre
	 INTO v_desc_ramo
	 FROM prdramo
	WHERE cod_ramo = _cod_ramo;

	SELECT nombre
	  INTO _nombre_subramo
	  FROM prdsubra
	 WHERE cod_ramo    = _cod_ramo
	   AND cod_subramo = _cod_subramo;

	SELECT cod_formapag,
		   cod_perpago	
	 INTO _cod_formapag,
		  _cod_perpago
	 FROM emipomae
	WHERE no_poliza = _no_poliza;

	--Lectura de la forma de pago
	SELECT nombre
	  INTO _nombre_formadepago
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

	--Lectura del modo de pago
	SELECT nombre
	  INTO _nombre_perpago
	  FROM cobperpa
	 WHERE cod_perpago = _cod_perpago;

   FOREACH	
		SELECT cod_asegurado,
			   prima_asegurado,
			   no_unidad
		  INTO _cod_asegurado,
			   _prima_asegurado,
			   _no_unidad
		  FROM emipouni
		 WHERE no_poliza = _no_poliza

		LET _dependientes = 0;

		SELECT COUNT(*)
		  INTO _dependientes
		  FROM emidepen
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad
		   AND activo = 1;

		IF _dependientes IS NULL THEN
			LET _dependientes = 0;
		END IF

		SELECT nombre,
			   fecha_aniversario,
			   direccion_1,
			   direccion_2,
			   telefono1,
			   telefono2
		  INTO _nombre_cliente,
			   _fecha,
			   _direccion_1,
			   _direccion_2,
			   _telefono1,
			   _telefono2
		  FROM cliclien
		 WHERE cod_cliente = _cod_asegurado;

		IF _direccion_1 IS NULL THEN
			LET _direccion_1 = "";
		END IF
		IF _direccion_2 IS NULL THEN
			LET _direccion_2 = "";
		END IF
		IF _telefono2 IS NULL THEN
			LET _direccion_2 = "";
		END IF
		IF _telefono1 IS NULL THEN
			LET _telefono1 = "";
		END IF

		LET _edad = YEAR(TODAY) - YEAR(_fecha);

		IF MONTH(TODAY) < MONTH(_fecha) THEN
			LET _edad = _edad - 1;
		ELIF MONTH(_fecha) = MONTH(TODAY) THEN
			IF DAY(TODAY) < DAY(_fecha) THEN
				LET _edad = _edad - 1;
			END IF
		END IF
		
		SELECT SUM(porc_recargo)
		  INTO _porc_recargo
		  FROM emiunire
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad;
	       
		RETURN v_descr_cia,
			   _no_documento,
			   _nombre_cliente,
			   _cod_ramo,
			   v_desc_ramo,
			   _cod_subramo,
			   _nombre_subramo,
			   _prima_asegurado,
			   _dependientes,
			   _edad,
			   _porc_recargo,
			   _nombre_formadepago,
			   _nombre_perpago,
			   _direccion_1,
			   _direccion_2,
			   _telefono1,
			   _telefono2
			   WITH RESUME;

	END FOREACH
END FOREACH
DROP TABLE temp_perfil;
END PROCEDURE;
