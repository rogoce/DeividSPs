-------------------------------------------------------------
---  Procedimiento para generacion de Contratos Virtual   ---
-------------------------------------------------------------

DROP procedure sp_rec701;
CREATE procedure "informix".sp_rec701(a_cia CHAR(03),a_agencia CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7), a_cod_ramo char(3))

--RETURNING CHAR(255);

    DEFINE v_cod_ramo,v_cod_subramo,v_cod_sucursal,v_cod_tipoprod  CHAR(3);
    DEFINE _no_poliza,_no_factura     CHAR(10);
    DEFINE _no_documento              CHAR(20);
    DEFINE v_cod_grupo, _no_endoso    CHAR(05);
    DEFINE v_contratante              CHAR(10);
    DEFINE v_prima_suscrita,v_prima_retenida,v_suma_asegurada DECIMAL(16,2);
    DEFINE v_vigencia_inic,v_vigencia_final,v_fecha_suscrip, _anos, _hoy   DATE;
    DEFINE v_filtros          CHAR(255);
    DEFINE v_porc_partic      DECIMAL(5,2);
    DEFINE _tipo              CHAR(01);
    DEFINE v_usuario          CHAR(08);
	DEFINE _i            	  INT;
	DEFINE _anos2			  INTEGER;
	DEFINE _cod_contrato      CHAR(5);
	DEFINE v_estatus,_estatus SMALLINT;
	DEFINE _porc_partic_prima DEC(9,6);

	   CREATE TEMP TABLE tmp_vigencias
             (no_poliza      	CHAR(10),
			  ano               smallint,
              vigencia_inic     DATE,
              vigencia_final    DATE,
              cod_contrato      CHAR(5) NOT NULL,
			  porc_partic_prima DEC(9,6),
              estatus			SMALLINT,
              PRIMARY KEY (no_poliza, ano))
              WITH NO LOG;

 --   CREATE INDEX j_perfil1 ON tmp_vigencias(no_poliza, ano);

    LET _no_poliza        = NULL;
	let _hoy 			  = current;

--SET DEBUG FILE TO "sp_pr982.trc";
--trace on;

    SET ISOLATION TO DIRTY READ;

   FOREACH
	 SELECT no_poliza
	   INTO _no_poliza
	   FROM tmp_sinis
	  WHERE seleccionado = 1
	  GROUP BY no_poliza
	  ORDER BY no_poliza

	  FOREACH WITH HOLD

	      SELECT d.vigencia_inic,
				 d.estatus_poliza,
				 d.cod_subramo
	        INTO v_vigencia_inic,
				 _estatus,
				 v_cod_subramo
	         FROM emipomae d
	        WHERE d.no_poliza = _no_poliza

		  LET v_vigencia_final =  v_vigencia_inic + 1 UNITS YEAR;
		  LET v_vigencia_final =  v_vigencia_final - 1 UNITS DAY; 

		  LET _anos2 = _hoy - v_vigencia_inic;
		  LET _anos2 = _anos2 /365;
		  LET _anos2 = _anos2 + 1;  

--		  BEGIN					  
		  LET v_estatus = 0;
		  FOR _i = 1 TO _anos2

			IF _i <> _anos2 THEN
				LET v_estatus = 0;
			ELSE
				LET v_estatus = _estatus;
			END IF

			SELECT cod_contrato
			  INTO _cod_contrato
			  FROM reacomae
			 WHERE vigencia_inic  <= v_vigencia_inic
			   AND vigencia_final >= v_vigencia_inic
			   AND tipo_reaseguro = 'O';

			IF v_vigencia_inic < '01/05/1998' THEN
				SELECT cod_contrato
				  INTO _cod_contrato
				  FROM reacomae
				 WHERE vigencia_inic  <= '01/05/1998'
				   AND vigencia_final >= '01/05/1998'
				   AND tipo_reaseguro = 'O';
			END IF

			SELECT porc_partic_prima
			  INTO _porc_partic_prima
			  FROM reasalud
			 WHERE cod_contrato = _cod_contrato
			   AND cod_ramo = a_cod_ramo
			   AND cod_subramo = v_cod_subramo;

			BEGIN
			ON EXCEPTION IN(-239)
 --			   CONTINUE FOREACH
			END EXCEPTION

		        INSERT INTO tmp_vigencias
		            VALUES(_no_poliza,
					       _i,
						   v_vigencia_inic,
		                   v_vigencia_final,
		                   _cod_contrato,
						   _porc_partic_prima,
		                   v_estatus);
			END

			LET v_vigencia_inic = v_vigencia_final + 1;
  		    LET v_vigencia_final =  v_vigencia_inic + 1 UNITS YEAR;
		  	LET v_vigencia_final =  v_vigencia_final - 1 UNITS DAY; 

		  END FOR;
--		 END

	  END FOREACH

  END FOREACH
--    RETURN v_filtros;
END PROCEDURE







										  