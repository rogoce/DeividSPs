--Rporte de Primas de auto por cobertura y marca de vehic.
--Creado por Armando Moreno 18/02/2002

DROP PROCEDURE sp_pro93;
CREATE PROCEDURE "informix".sp_pro93(
		a_compania      CHAR(3),
		a_agencia  		CHAR(3),
		a_fecha_desde 	DATE,
		a_fecha_hasta 	DATE,
		a_opcion 		CHAR(1)   DEFAULT '*',
		a_sucursal  	CHAR(255) DEFAULT "*",
		a_grupo    		CHAR(255) DEFAULT "*",
		a_reaseguro 	CHAR(255) DEFAULT "*",
		a_agente		CHAR(255) DEFAULT "*",
		a_cod_cliente   CHAR(255) DEFAULT "*",
		a_cod_subramo	CHAR(255) DEFAULT "*",
		a_no_documento	CHAR(255) DEFAULT "*",
		a_marca			CHAR(255) DEFAULT "*"
		)
       RETURNING CHAR(50),
       			 INT,
       			 INT,
       			 INT,
       			 INT,
       			 INT,
       			 INT,
       			 INT,
                 INT,
                 INT,
                 INT,
                 INT,
                 INT,
                 INT,
                 CHAR(50),
                 INT,
                 INT,
                 INT,
                 CHAR(255);

DEFINE v_no_poliza      CHAR(10);
DEFINE _tipo      		CHAR(1);
DEFINE v_cod_cobertura,v_cod_marca  CHAR(05);
DEFINE _no_unidad       CHAR(05);
DEFINE _no_motor   		CHAR(30);
DEFINE v_cod_ramo   	CHAR(3);
DEFINE v_descr_cia,v_deducible,v_nom_marca  CHAR(50);
DEFINE v_filtros	    CHAR(255);	
DEFINE _prima_neta      DEC(16,2);
DEFINE v_pago1,v_pago2,v_pago3,v_pago4,v_pago5,v_pago6,
       v_pago7,v_pago8,v_pago9,v_pago10,v_pago12,
       v_pago13,v_pago14,v_pago15,
       v_subtotal,_ano_auto,_valor,_cnt_uni,_deducible INTEGER;
DEFINE _cod_cober_int   INTEGER;
DEFINE _seleccionado    SMALLINT;

LET v_descr_cia = NULL;

CREATE TEMP TABLE tmp_marca(
    cod_marca            CHAR(5)   NOT NULL,
	deducible            INTEGER   DEFAULT 0,
	pagos01				 DECIMAL(16,2) DEFAULT 0,
	pagos02				 DECIMAL(16,2) DEFAULT 0,
	pagos03				 DECIMAL(16,2) DEFAULT 0,
	pagos04				 DECIMAL(16,2) DEFAULT 0,
	pagos05				 DECIMAL(16,2) DEFAULT 0,
	pagos06				 DECIMAL(16,2) DEFAULT 0,
	pagos08				 DECIMAL(16,2) DEFAULT 0,
	pagos09				 DECIMAL(16,2) DEFAULT 0,
	pagos10				 DECIMAL(16,2) DEFAULT 0,
	pagos12				 DECIMAL(16,2) DEFAULT 0,
	pagos13				 DECIMAL(16,2) DEFAULT 0,
	pagos14				 DECIMAL(16,2) DEFAULT 0,
	pagos15				 DECIMAL(16,2) DEFAULT 0,
	no_pol               CHAR(10),
	cnt_uni              INTEGER,
	seleccionado   		 SMALLINT  DEFAULT 1 NOT NULL,
	PRIMARY KEY (cod_marca)
	) WITH NO LOG;

LET v_descr_cia = sp_sis01(a_compania);
SET ISOLATION TO DIRTY READ;

--SELECT cod_ramo
--  INTO v_cod_ramo
--  FROM prdramo
-- WHERE ramo_sis = 1;

LET v_filtros = sp_pr91a(
a_compania,
a_agencia,
a_fecha_desde,
a_fecha_hasta,
a_opcion,
a_sucursal,
a_grupo,
a_reaseguro,
a_agente,
a_cod_cliente,
a_cod_subramo,
a_no_documento
);

-- Todas las Polizas Seleccionadas
FOREACH WITH HOLD
 SELECT no_poliza
   INTO v_no_poliza
   FROM tmp_prod
  WHERE seleccionado = 1

	-- Unidades de la poliza
	FOREACH
		 SELECT no_unidad
		   INTO _no_unidad
		   FROM emipouni
		  WHERE no_poliza = v_no_poliza

         SELECT no_motor
           INTO _no_motor
           FROM emiauto
          WHERE no_poliza = v_no_poliza
            AND no_unidad = _no_unidad;

		 IF _no_motor IS NULL THEN
			CONTINUE FOREACH;
		 END IF

                    
         SELECT ano_auto,
				cod_marca
           INTO _ano_auto,
				v_cod_marca
           FROM emivehic
          WHERE no_motor = _no_motor;

		 IF v_cod_marca IS NULL THEN
			CONTINUE FOREACH;
		 END IF

		 IF _ano_auto IS NULL OR _ano_auto = 0 THEN
			CONTINUE FOREACH;
		 END IF

		-- Primas por Cobertura
			FOREACH
				 SELECT cod_cobertura,
				 		prima_neta,
						deducible
				   INTO v_cod_cobertura,
				   		_prima_neta,
						v_deducible
				   FROM emipocob
		          WHERE no_poliza = v_no_poliza
        		    AND no_unidad = _no_unidad

				LET v_pago1  = 0;LET v_pago2  = 0;LET v_pago3  = 0;LET v_pago4 = 0;
				LET v_pago5  = 0;LET v_pago6  = 0;LET v_pago8  = 0;
				LET v_pago9  = 0;LET v_pago10 = 0;LET v_pago12 = 0;
				LET v_pago13 = 0;LET v_pago14 = 0;LET v_pago15 = 0;
				
				{IF v_deducible IS NULL OR v_deducible = "" THEN
					LET _deducible = 0;
				ELSE
					LET _deducible = trim(v_deducible);
				END IF}

		        LET _cod_cober_int = v_cod_cobertura;

			    IF _cod_cober_int= 102 THEN
			       LET v_pago1 = _prima_neta;
			    END IF
			    IF _cod_cober_int= 113 THEN
			       LET v_pago2 = _prima_neta;
			    END IF
			    IF _cod_cober_int= 117 THEN
			       LET v_pago3 = _prima_neta;
			    END IF
			    IF _cod_cober_int= 118 THEN
			       LET v_pago4 = _prima_neta;
			    END IF
			    IF _cod_cober_int= 119 OR
			       _cod_cober_int = 121 THEN
			       LET v_pago5 = _prima_neta;
			    END IF;
			    IF _cod_cober_int= 120 THEN
			       LET v_pago6 = _prima_neta;
			    END IF;
			    IF _cod_cober_int= 104 THEN
			       LET v_pago8 = _prima_neta;
			    END IF;
			    IF _cod_cober_int= 123 THEN
			       LET v_pago9 = _prima_neta;
			    END IF;
			    IF _cod_cober_int= 103 THEN
			       LET v_pago10 = _prima_neta;
			    END IF;
			    IF _cod_cober_int= 105 THEN
			       LET v_pago12 = _prima_neta;
			    END IF;
			    IF _cod_cober_int= 106 THEN
			       LET v_pago13 = _prima_neta;
			    END IF;
			    IF _cod_cober_int= 107 THEN
			       LET v_pago14 = _prima_neta;
			    END IF;
			    IF _cod_cober_int= 108 THEN
			       LET v_pago15 = _prima_neta;
			    END IF;

			   	BEGIN
					ON EXCEPTION IN (-239)

					  UPDATE tmp_marca
				         SET pagos01   = pagos01 + v_pago1,
					   		 pagos02   = pagos02 + v_pago2,
					   		 pagos03   = pagos03 + v_pago3,
					   		 pagos04   = pagos04 + v_pago4,
					   		 pagos05   = pagos05 + v_pago5,
					   		 pagos06   = pagos06 + v_pago6,
					   		 pagos08   = pagos08 + v_pago8,
					   		 pagos09   = pagos09 + v_pago9,
					   		 pagos10   = pagos10 + v_pago10,
					   		 pagos12   = pagos12 + v_pago12,
					   		 pagos13   = pagos13 + v_pago13,
					   		 pagos14   = pagos14 + v_pago14,
					   		 pagos15   = pagos15 + v_pago15
					   		 --deducible = deducible + _deducible
				       WHERE cod_marca   = v_cod_marca;

					END EXCEPTION;

					  INSERT INTO tmp_marca(
					  cod_marca,
					  pagos01,
					  pagos02,
					  pagos03,
					  pagos04,
					  pagos05,
					  pagos06,
					  pagos08,
					  pagos09,
					  pagos10,
					  pagos12,
					  pagos13,
					  pagos14,
					  pagos15,
					  no_pol,
					  cnt_uni,
					  deducible,
					  seleccionado)
					  VALUES(
					  v_cod_marca,
					  v_pago1,
					  v_pago2,
					  v_pago3,
					  v_pago4,
					  v_pago5,
					  v_pago6,
					  v_pago8,
					  v_pago9,
					  v_pago10,
					  v_pago12,
					  v_pago13,
					  v_pago14,
					  v_pago15,
					  v_no_poliza,
					  0,
					  0,
					  1
					  );
				END;
            END FOREACH
			BEGIN
        		ON EXCEPTION IN (-239)

		          UPDATE tmp_marca
		             SET cnt_uni  = cnt_uni + 1
		           WHERE cod_marca = v_cod_marca;

	        	END EXCEPTION;

	           INSERT INTO tmp_marca(
			   cod_marca,
			   cnt_uni
			   )
	           VALUES(
			   v_cod_marca,
	           1
	           );

        	END;
	END FOREACH
END FOREACH

--Filtro especial para marcas
IF a_marca <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Marca: " || TRIM(a_marca);

	LET _tipo = sp_sis04(a_marca);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_marca
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_marca NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_marca
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_marca IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

FOREACH
 SELECT *
   INTO v_cod_marca,
        _deducible,
	    v_pago1,
	    v_pago2,
	    v_pago3,
	    v_pago4,
	    v_pago5,
	    v_pago6,
	    v_pago8,
	    v_pago9,
	    v_pago10,
	    v_pago12,
	    v_pago13,
	    v_pago14,
	    v_pago15,
	    v_no_poliza,
		_cnt_uni,
		_seleccionado
   FROM tmp_marca
  WHERE seleccionado = 1

	 SELECT nombre
	   INTO v_nom_marca
	   FROM emimarca
	  WHERE cod_marca = v_cod_marca;

     LET v_subtotal = v_pago1+v_pago2+v_pago3+v_pago4+v_pago5+v_pago6+
                      v_pago8+v_pago9+v_pago10+v_pago12+v_pago13+v_pago14+
                      v_pago15;

     RETURN v_nom_marca,
		    v_pago1,
		    v_pago2,
		    v_pago3,
		    v_pago4,
		    v_pago5,
            v_pago6,
            v_pago8,
            v_pago9,
            v_pago10,
            v_pago12,
            v_pago13,
            v_pago14,
            v_pago15,
            v_descr_cia,
            v_subtotal,
		    _deducible,
            _cnt_uni,
			v_filtros
            WITH RESUME;

END FOREACH

DROP TABLE tmp_marca;
DROP TABLE tmp_prod;

END PROCEDURE;