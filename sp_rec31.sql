--Modificado por Armando Moreno 12/11/2001

DROP PROCEDURE sp_rec31;
CREATE PROCEDURE "informix".sp_rec31(
		a_compania CHAR(3),
		a_agencia CHAR(3),
		a_fecha_desde DATE,
		a_fecha_hasta DATE
		)
       RETURNING CHAR(50),INT,INT,INT,INT,INT,INT,INT,INT,INT,
                 INT,INT,INT,INT,CHAR(50),INT,INT,INT,INT,INT,INT,CHAR(10);

DEFINE v_cod_ramo       CHAR(03);
DEFINE v_no_poliza      CHAR(10);
DEFINE v_no_reclamo     CHAR(10);
DEFINE v_no_motor       CHAR(30);
DEFINE v_cod_cobertura  CHAR(05) ;
DEFINE v_cod_marca      CHAR(05) ;
DEFINE v_deducible,v_deducible1     DEC(16,2);
DEFINE v_no_tranrec     CHAR(10);
DEFINE v_cod_tipotran   CHAR(3);
DEFINE v_monto          DEC(16,2);
DEFINE v_monto_pago     DEC(16,2);
DEFINE v_salvamento,v_recupero,v_variacion,x_variacion,
       x_salvamento     DEC(16,2);
DEFINE v_nom_marca,v_descr_cia   CHAR(50);
DEFINE v_pago1,v_pago2,v_pago3,v_pago4,v_pago5,v_pago6,
       v_pago7,v_pago8,v_pago9,v_pago10,v_pago12,
       v_pago13,v_pago14,v_pago15,v_incurrido,
       v_gasto_real,v_subtotal,v_cont_poliza,v_contador INTEGER;

DEFINE _cod_tipotran4 CHAR(3);
DEFINE _cod_tipotran5 CHAR(3);
DEFINE _cod_tipotran6 CHAR(3);
DEFINE _cod_tipotran7 CHAR(3);
DEFINE _cod_cober_int INTEGER;

LET v_deducible  = 0;
LET v_salvamento = 0;
LET v_incurrido  = 0;
LET v_descr_cia = NULL;
LET v_nom_marca = NULL;
LET v_variacion = 0;

SELECT cod_tipotran
  INTO _cod_tipotran4
  FROM rectitra
 WHERE tipo_transaccion = 4; --Pago

SELECT cod_tipotran
  INTO _cod_tipotran5
  FROM rectitra
 WHERE tipo_transaccion = 5; --Salvamento

SELECT cod_tipotran
  INTO _cod_tipotran6
  FROM rectitra
 WHERE tipo_transaccion = 6; --Recupero

SELECT cod_tipotran
  INTO _cod_tipotran7
  FROM rectitra
 WHERE tipo_transaccion = 7; --Deducible

CREATE TEMP TABLE tmp_marca(
    cod_marca            CHAR(5)   NOT NULL,
    variacion            DECIMAL(16,2) DEFAULT 0,
    salvamento           DECIMAL(16,2) DEFAULT 0,
	deducible            DECIMAL(16,2) DEFAULT 0,
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
	nombre_marca		 CHAR(50),
	no_rec               CHAR(10),
	PRIMARY KEY (cod_marca)
	) WITH NO LOG;
CREATE INDEX i1_tmp_marca ON tmp_marca(nombre_marca);

CREATE TEMP TABLE tmp_poliza(
    cod_marca            CHAR(5)   NOT NULL,
    no_reclamo           CHAR(10)  ,
    contador             INTEGER,
    PRIMARY KEY (cod_marca,no_reclamo)) ;

SELECT cod_ramo
  INTO v_cod_ramo
  FROM prdramo
 WHERE ramo_sis = 1;

LET v_descr_cia = sp_sis01(a_compania);
SET ISOLATION TO DIRTY READ;

-- Carga las Polizas

SELECT no_poliza
  FROM emipomae
 WHERE cod_compania   = a_compania
   AND cod_ramo       = v_cod_ramo
   AND nueva_renov    = "N"
   AND vigencia_final >= a_fecha_desde 
   AND vigencia_final <= a_fecha_hasta
   AND actualizado    = 1
  INTO TEMP npoliza;

-- Todas las Polizas Seleccionadas

FOREACH WITH HOLD
 SELECT no_poliza
   INTO v_no_poliza
   FROM npoliza

	-- Reclamos por Poliza

	FOREACH
		 SELECT no_reclamo,
		 	    no_motor
		   INTO v_no_reclamo,
		   		v_no_motor
		   FROM recrcmae
		  WHERE no_poliza   = v_no_poliza
		    AND actualizado = 1

        { IF v_no_motor IS NULL THEN
            CONTINUE FOREACH;
         END IF; }

         SELECT cod_marca
           INTO v_cod_marca
           FROM emivehic
          WHERE no_motor = v_no_motor;
                    
		 IF v_cod_marca IS NULL THEN
			CONTINUE FOREACH;
		 END IF

	     SELECT nombre
           INTO v_nom_marca
           FROM emimarca
		  WHERE cod_marca = v_cod_marca;

		-- Variacion por Reclamo

         LET v_variacion = 0;

         FOREACH
            SELECT variacion
	          INTO x_variacion
	          FROM rectrmae
             WHERE no_reclamo   = v_no_reclamo
	           AND actualizado  = 1

            IF x_variacion IS NULL THEN
     	       LET x_variacion = 0;
         	END IF
            LET v_variacion = v_variacion + x_variacion;
         END FOREACH

		-- Salvamento, Recupero, Deducible por Reclamo

        LET v_salvamento= 0;
        FOREACH
           SELECT monto
	         INTO x_salvamento
	         FROM rectrmae
	        WHERE no_reclamo    = v_no_reclamo
	          AND actualizado   = 1
              AND (cod_tipotran = _cod_tipotran5 OR	  --Salvamento
	               cod_tipotran = _cod_tipotran6 OR	  --Recupero
	               cod_tipotran = _cod_tipotran7)	  --Deducible

           IF x_salvamento IS NULL THEN
              LET x_salvamento = 0;
	       END IF
           LET v_salvamento = v_salvamento + x_salvamento;
        END FOREACH

        BEGIN
        	ON EXCEPTION IN (-239)

	          UPDATE tmp_marca
	             SET variacion  = variacion  + v_variacion,
	             	 salvamento = salvamento + v_salvamento
	           WHERE cod_marca  = v_cod_marca;

	        END EXCEPTION;

           INSERT INTO tmp_marca(
		   cod_marca,
		   variacion,
		   salvamento,
		   nombre_marca,
		   no_rec)
           VALUES(
           v_cod_marca,
           v_variacion,
           v_salvamento,
		   v_nom_marca,
		   v_no_reclamo
           );

        END;

		-- Transacciones de Pagos, recupero, salvamentos y deducible por Reclamo

		FOREACH
			 SELECT no_tranrec
			   INTO v_no_tranrec
			   FROM rectrmae
			  WHERE no_reclamo   = v_no_reclamo
			    AND actualizado  = 1
			    AND (cod_tipotran = _cod_tipotran4 OR --Pago
              	     cod_tipotran = _cod_tipotran5 OR --Salvamento
	                 cod_tipotran = _cod_tipotran6 OR --Recupero
	                 cod_tipotran = _cod_tipotran7)	  --Deducible


			-- Pagos por Cobertura

			FOREACH
				 SELECT cod_cobertura,
				 		monto
				   INTO v_cod_cobertura,
				   		v_monto_pago
				   FROM rectrcob
				  WHERE no_tranrec = v_no_tranrec
				    AND monto <> 0

				 LET v_pago1  = 0;LET v_pago2  = 0;LET v_pago3  = 0;LET v_pago4 = 0;
				 LET v_pago5  = 0;LET v_pago6  = 0;LET v_pago8  = 0;
				 LET v_pago9  = 0;LET v_pago10 = 0;LET v_pago12 = 0;
				 LET v_pago13 = 0;LET v_pago14 = 0;LET v_pago15 = 0;

				{SELECT deducible
				  INTO v_deducible
				  FROM recrccob
				 WHERE no_reclamo    = v_no_reclamo
				   AND cod_cobertura = v_cod_cobertura;

				IF v_deducible IS NULL THEN
				      LET v_deducible = 0;
				END IF;}

		        LET _cod_cober_int = v_cod_cobertura;

			    IF _cod_cober_int= 102 THEN
			       LET v_pago1 = v_monto_pago;
			    END IF
			    IF _cod_cober_int= 113 THEN
			       LET v_pago2 = v_monto_pago;
			    END IF
			    IF _cod_cober_int= 117 THEN
			       LET v_pago3 = v_monto_pago;
			    END IF
			    IF _cod_cober_int= 118 THEN
			       LET v_pago4 = v_monto_pago;
			    END IF
			    IF _cod_cober_int= 119 OR
			       _cod_cober_int = 121 THEN
			       LET v_pago5 = v_monto_pago;
			    END IF;
			    IF _cod_cober_int= 120 THEN
			       LET v_pago6 = v_monto_pago;
			    END IF;
			    IF _cod_cober_int= 104 THEN
			       LET v_pago8 = v_monto_pago;
			    END IF;
			    IF _cod_cober_int= 123 THEN
			       LET v_pago9 = v_monto_pago;
			    END IF;
			    IF _cod_cober_int= 103 THEN
			       LET v_pago10 = v_monto_pago;
			    END IF;
			    IF _cod_cober_int= 105 THEN
			       LET v_pago12 = v_monto_pago;
			    END IF;
			    IF _cod_cober_int= 106 THEN
			       LET v_pago13 = v_monto_pago;
			    END IF;
			    IF _cod_cober_int= 107 THEN
			       LET v_pago14 = v_monto_pago;
			    END IF;
			    IF _cod_cober_int= 108 THEN
			       LET v_pago15 = v_monto_pago;
			    END IF;

			   	BEGIN
					ON EXCEPTION IN (-239)

					  UPDATE tmp_marca
				         SET pagos01 = pagos01 + v_pago1,
					   		 pagos02 = pagos02 + v_pago2,
					   		 pagos03 = pagos03 + v_pago3,
					   		 pagos04 = pagos04 + v_pago4,
					   		 pagos05 = pagos05 + v_pago5,
					   		 pagos06 = pagos06 + v_pago6,
					   		 pagos08 = pagos08 + v_pago8,
					   		 pagos09 = pagos09 + v_pago9,
					   		 pagos10 = pagos10 + v_pago10,
					   		 pagos12 = pagos12 + v_pago12,
					   		 pagos13 = pagos13 + v_pago13,
					   		 pagos14 = pagos14 + v_pago14,
					   		 pagos15 = pagos15 + v_pago15
							 --deducible = deducible + v_deducible 
				       WHERE cod_marca     = v_cod_marca;

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
					  deducible,
					  nombre_marca)
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
					  0,
					  v_nom_marca
					  );

				END;
            END FOREACH
		END FOREACH

			-- Monto de deducible

		FOREACH
			SELECT deducible
			  INTO v_deducible
			  FROM recrccob
			 WHERE no_reclamo    = v_no_reclamo

			IF v_deducible IS NULL THEN
		      LET v_deducible = 0;
			END IF;

			UPDATE tmp_marca
			   SET deducible = deducible + v_deducible 
			 WHERE cod_marca = v_cod_marca;

		END FOREACH

		BEGIN
		    ON EXCEPTION IN (-239)
                     -- No hace nada
            END EXCEPTION;
            INSERT INTO tmp_poliza
            VALUES(
            	  v_cod_marca,
            	  v_no_reclamo,
            	  1
            	  );
        END; 
	END FOREACH

END FOREACH

FOREACH
 SELECT *
   INTO v_cod_marca,
        v_variacion,
        v_salvamento,
	    v_deducible,
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
	    v_nom_marca,
		v_no_reclamo
   FROM tmp_marca
 
  LET v_cont_poliza = 0;

  FOREACH
      SELECT contador
        INTO v_contador
        FROM tmp_poliza
       WHERE cod_marca = v_cod_marca

       LET v_cont_poliza = v_cont_poliza + v_contador;
  END FOREACH

     LET v_subtotal = v_pago1+v_pago2+v_pago3+v_pago4+v_pago5+v_pago6+
                      v_pago8+v_pago9+v_pago10+v_pago12+v_pago13+v_pago14+
                      v_pago15;

     LET v_incurrido  = v_subtotal  + v_variacion;
     LET v_gasto_real = v_incurrido + v_deducible;
     IF v_subtotal  = 0 AND
        v_variacion = 0 AND
        v_incurrido = 0 AND
        v_deducible = 0 THEN
        CONTINUE FOREACH;
     END IF;

     RETURN v_nom_marca,v_pago1,v_pago2,v_pago3,v_pago4,v_pago5,
            v_pago6,v_pago8,v_pago9,v_pago10,v_pago12,
            v_pago13,v_pago14,v_pago15,
            v_descr_cia,v_subtotal,v_variacion,
            v_incurrido,v_deducible,v_gasto_real,v_cont_poliza,v_no_reclamo
            WITH RESUME;

END FOREACH

DROP TABLE tmp_marca;
DROP TABLE npoliza;
DROP TABLE tmp_poliza;  

END PROCEDURE;