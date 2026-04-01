-- Polizas para Cartas de Aumento de Primas
--
-- Creado    : 11/07/2002 - Autor: Armando Moreno

-- SIS v.2.0 - d_prod_sp_pro62_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_proe29;

CREATE PROCEDURE "informix".sp_proe29(a_cia CHAR(3),a_agencia CHAR(3),a_periodo CHAR(7))
RETURNING CHAR(20), 	--poliza
          CHAR(100),	--asegurado
          CHAR(3),		--cod_ramo
		  CHAR(3),		--cod_subramo
          CHAR(50),		--subramo
		  DEC(16,2),	--prima actual
		  INTEGER,		--dependientes
		  INTEGER,		--edad
          DEC(5,2),		--%extraprima(recargo)
          CHAR(50),		--formadepago
          CHAR(50),		--periododepago
		  INT,			--imprimir
		  DATE,			--vig_ini
		  DATE,			--fecha_aniversario
		  DEC(16,2),	--prima actual
		  DATE,			--fecha_efectividad
		  DATE,			--fecha hoy
		  CHAR(50);		--corredor

DEFINE _no_poliza       CHAR(10); 
DEFINE _no_documento    CHAR(20);
DEFINE _cod_asegurado   CHAR(10); 
DEFINE _prima_asegurado,_prima_nueva DEC(16,2);
DEFINE _no_unidad,_cod_agente       CHAR(5);
DEFINE _nombre_subramo,_nombre_formadepago,_nombre_perpago  CHAR(50); 
DEFINE _nombre_cliente  CHAR(100); 
DEFINE _fecha,_fecha_efectividad			DATE;
DEFINE _nombre_corredor CHAR(50);
DEFINE _edad			INTEGER;
DEFINE _vigencia_inic   DATE;
DEFINE _fecha_hoy       DATE;
DEFINE _cod_ramo,_cod_formapag,_cod_perpago CHAR(3);
DEFINE _cod_subramo     CHAR(3);
DEFINE v_filtros        CHAR(255);
DEFINE _ano_vigenci,_dependientes,_imprimir    INTEGER;
DEFINE _porc_recargo    DEC(5,2);
DEFINE _ano_proceso     SMALLINT;
DEFINE _ano_vigencia    INTEGER;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\demrep41.trc";
--trace on;

SET ISOLATION TO DIRTY READ;
LET _fecha_hoy = TODAY;
LET _imprimir = 0;
LET _prima_nueva = 0;
LET _ano_proceso = a_periodo[1,4] - 1;

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

-- Agente de la Poliza
  	FOREACH
  	 SELECT cod_agente
  	   INTO _cod_agente
  	   FROM emipoagt
  	  WHERE no_poliza = _no_poliza
		 
  	 SELECT nombre
  	   INTO _nombre_corredor
  	   FROM agtagent
  	  WHERE cod_agente = _cod_agente;
  	 EXIT FOREACH;
    END FOREACH

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
			   no_unidad,
			   vigencia_inic
		  INTO _cod_asegurado,
			   _prima_asegurado,
			   _no_unidad,
			   _fecha_efectividad
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
			   fecha_aniversario
		  INTO _nombre_cliente,
			   _fecha
		  FROM cliclien
		 WHERE cod_cliente = _cod_asegurado;

		--LET _edad = YEAR(TODAY) - YEAR(_fecha);

		{IF MONTH(TODAY) < MONTH(_fecha) THEN
			LET _edad = _edad - 1;
		ELIF MONTH(_fecha) = MONTH(TODAY) THEN
			IF DAY(TODAY) < DAY(_fecha) THEN
				LET _edad = _edad - 1;
			END IF
		END IF}
		LET _edad = YEAR(TODAY) - YEAR(_fecha);

		IF MONTH(_vigencia_inic) < MONTH(_fecha) THEN
			LET _edad = _edad - 1;
		ELIF MONTH(_fecha) = MONTH(_vigencia_inic) THEN
			IF DAY(_vigencia_inic) < DAY(_fecha) THEN
				LET _edad = _edad - 1;
			END IF
		END IF
		
		SELECT SUM(porc_recargo)
		  INTO _porc_recargo
		  FROM emiunire
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad;

		IF _porc_recargo IS NULL THEN
			LET _porc_recargo = 0;
		END IF
	       
		RETURN _no_documento,
			   _nombre_cliente,
			   _cod_ramo,
			   _cod_subramo,
			   _nombre_subramo,
			   _prima_asegurado,
			   _dependientes,
			   _edad,
			   _porc_recargo,
			   _nombre_formadepago,
			   _nombre_perpago,
			   _imprimir,
			   _vigencia_inic,
			   _fecha,
			   _prima_nueva,
			   _fecha_efectividad,
			   _fecha_hoy,
			   _nombre_corredor
			   WITH RESUME;

   END FOREACH
END FOREACH
DROP TABLE temp_perfil;
END PROCEDURE;
