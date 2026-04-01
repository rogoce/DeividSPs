--Modificado por Armando Moreno 04/03/2002
--Modificado por Amado Perez    29/07/2003
--Modificado por Armando Moreno 23/03/2004
--Modificado por Armando Moreno 27/04/2004
DROP PROCEDURE sp_rec65;
CREATE PROCEDURE "informix".sp_rec65(
		a_compania 		CHAR(3), 
		a_agencia 		CHAR(3), 
		a_fecha_desde 	DATE, 
		a_fecha_hasta 	DATE, 
		a_opcion 		CHAR(1) DEFAULT "*", 
		a_sucursal 		CHAR(255) DEFAULT "*", 
		a_grupo 		CHAR(255) DEFAULT "*", 
		a_reaseguro		CHAR(255) DEFAULT "*", 
		a_agente		CHAR(255) DEFAULT "*", 
		a_cod_cliente   CHAR(255) DEFAULT "*", 
		a_cod_subramo	CHAR(255) DEFAULT "*", 
		a_no_documento	CHAR(255) DEFAULT "*", 
		a_marca	        CHAR(255) DEFAULT "*")
       RETURNING INT,       --ano_auto
       			 INT,       --pago1
       			 INT,       --pago2
       			 INT,       --pago3
       			 INT,       --pago4
       			 INT,       --pago5
       			 INT,       --pago6
       			 INT,       --pago8
       			 INT,       --pago9
                 INT,       --pago10
                 INT,       --pago12
                 INT,       --pago13
                 INT,       --pago14
                 INT,       --pago15
                 CHAR(50),  --cia
                 INT,	    --sub
                 INT,	    --ded
                 INT,	    --cnt_reclamos
                 INT,	    --vari
                 INT,	    --incu
                 INT,	    --gasto
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
                 CHAR(255),	--filtros
				 decimal(16,2);

DEFINE v_cod_ramo       CHAR(3);
DEFINE v_no_poliza      CHAR(10);
DEFINE v_no_reclamo     CHAR(10);
DEFINE v_no_motor       CHAR(30);
DEFINE v_cod_cobertura  CHAR(05) ;
DEFINE v_cod_marca      CHAR(05) ;
DEFINE v_deducible,v_deducible1,_prima_suscrita     DEC(16,2);
DEFINE v_no_tranrec     CHAR(10);
DEFINE v_filtros        CHAR(255);
DEFINE v_cod_tipotran   CHAR(3);
DEFINE v_monto          DEC(16,2);
DEFINE v_monto_pago     DEC(16,2);
DEFINE v_salvamento,v_recupero,v_variacion,x_variacion,
       x_salvamento     DEC(16,2);
DEFINE _tipo		    CHAR(1);
DEFINE v_descr_cia   CHAR(50);
DEFINE v_pago1,v_pago2,v_pago3,v_pago4,v_pago5,v_pago6,
       v_pago7,v_pago8,v_pago9,v_pago10,v_pago12,
       v_pago13,v_pago14,v_pago15,v_incurrido,
       v_gasto_real,v_subtotal,v_cont_poliza,v_contador INTEGER;
DEFINE v_cant1,v_cant2,v_cant3,v_cant4,v_cant5,v_cant6,
       v_cant8,v_cant9,v_cant10,v_cant12,v_cant13,v_cant14,v_cant15 INTEGER;
DEFINE _ano_actual      INTEGER;
DEFINE _cod_tipotran4 CHAR(3);
DEFINE _cod_tipotran5 CHAR(3);
DEFINE _cod_tipotran6 CHAR(3);
DEFINE _cod_tipotran7 CHAR(3);
DEFINE _cod_cober_int,_ano_auto,_valor,_cnt_uni,_buscar,_buscar_poliza INTEGER;
DEFINE v_saber		    CHAR(3);
DEFINE v_codigo		    CHAR(5);
DEFINE v_desc_marca	    CHAR(50);

LET v_deducible  = 0;
LET v_salvamento = 0;
LET v_incurrido  = 0;
LET v_descr_cia  = NULL;
LET v_variacion  = 0;

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

LET _ano_actual = YEAR(CURRENT);

CREATE TEMP TABLE tmp_marca(
    ano_auto             INTEGER   NOT NULL,
    cod_marca            CHAR(5),
    salvamento           DECIMAL(16,2) DEFAULT 0,
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
    cant01               INTEGER DEFAULT 0,
    cant02               INTEGER DEFAULT 0,
    cant03               INTEGER DEFAULT 0,
    cant04               INTEGER DEFAULT 0,
    cant05               INTEGER DEFAULT 0,
    cant06               INTEGER DEFAULT 0,
    cant08               INTEGER DEFAULT 0,
    cant09               INTEGER DEFAULT 0,
    cant10               INTEGER DEFAULT 0,
    cant12               INTEGER DEFAULT 0,
    cant13               INTEGER DEFAULT 0,
    cant14               INTEGER DEFAULT 0,
    cant15               INTEGER DEFAULT 0,
	no_rec               CHAR(10),
	seleccionado   		 SMALLINT  DEFAULT 1 NOT NULL,
	PRIMARY KEY (ano_auto,cod_marca)
	) WITH NO LOG;

CREATE TEMP TABLE tmp_poliza(
    ano_auto             INTEGER NOT NULL,
    variacion            DECIMAL(16,2) DEFAULT 0,
	cod_marca			 CHAR(5),
    contador             INTEGER,
	deducible            DECIMAL(16,2) DEFAULT 0,
	seleccionado   		 SMALLINT DEFAULT 1 NOT NULL,
    no_poliza	         CHAR(10),
	prima_suscrita		 DECIMAL(16,2) DEFAULT 0
    );

SET ISOLATION TO DIRTY READ;

SELECT cod_ramo
  INTO v_cod_ramo
  FROM prdramo
 WHERE ramo_sis = 1;

LET v_descr_cia = sp_sis01(a_compania);

-- Carga las Polizas
LET v_filtros = sp_re65a(
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

	-- Reclamos por Poliza
	FOREACH
		 SELECT no_reclamo,
		 	    no_motor
		   INTO v_no_reclamo,
		   		v_no_motor
		   FROM recrcmae
		  WHERE no_poliza   = v_no_poliza
		    AND actualizado = 1
		    AND fecha_siniestro BETWEEN a_fecha_desde AND a_fecha_hasta

		 IF v_no_motor IS NULL THEN
			CONTINUE FOREACH;
		 END IF

         SELECT ano_auto,
				cod_marca
           INTO _ano_auto,
				v_cod_marca
           FROM emivehic
          WHERE no_motor = v_no_motor;
                    
		 IF v_cod_marca IS NULL THEN
			CONTINUE FOREACH;
		 END IF

		 IF _ano_auto IS NULL OR _ano_auto = 0 THEN
			CONTINUE FOREACH;
		 END IF

		 LET _valor = 0;
		 LET _valor = _ano_actual - _ano_auto + 1;

		 IF _ano_auto >	_ano_actual THEN --autos con ano mayor al ano actual se consideran como auto de un ano.
		 	LET _valor = 1;			
		 END IF

		 IF _valor = 0 THEN --autos de ano actual se consideran como auto de un ano.
		 	LET _valor = 1;
	     END IF

		 IF _valor > 10 THEN --autos con mas de 10 anos se consideran como de 10.
		 	LET _valor = 10;
	     END IF

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

                 LET v_cant1  = 0;LET v_cant2  = 0;LET v_cant3  = 0;LET v_cant4 = 0;
                 LET v_cant5  = 0;LET v_cant6  = 0;LET v_cant8  = 0;
                 LET v_cant9  = 0;LET v_cant10 = 0;LET v_cant12 = 0;
                 LET v_cant13 = 0;LET v_cant14 = 0;LET v_cant15	= 0;
                 	        
                LET _cod_cober_int = v_cod_cobertura;

			    IF _cod_cober_int = 102 THEN
			       LET v_pago1 = v_monto_pago;
				   LET v_cant1  = 1;
			    END IF
			    IF _cod_cober_int = 113 THEN
			       LET v_pago2 = v_monto_pago;
				   LET v_cant2  = 1;
			    END IF
			    IF _cod_cober_int = 117 THEN
			       LET v_pago3 = v_monto_pago;
				   LET v_cant3  = 1;
			    END IF
			    IF _cod_cober_int = 118 THEN
			       LET v_pago4 = v_monto_pago;
				   LET v_cant4 = 1;
			    END IF
			    IF _cod_cober_int = 119 OR
			       _cod_cober_int = 121 THEN
			       LET v_pago5 = v_monto_pago;
				   LET v_cant5  = 1;
			    END IF;
			    IF _cod_cober_int = 120 THEN
			       LET v_pago6 = v_monto_pago;
				   LET v_cant6  = 1;
			    END IF;
			    IF _cod_cober_int = 104 THEN
			       LET v_pago8 = v_monto_pago;
				   LET v_cant8  = 1;
			    END IF;
			    IF _cod_cober_int = 123 THEN
			       LET v_pago9 = v_monto_pago;
				   LET v_cant9  = 1;
			    END IF;
			    IF _cod_cober_int = 103 THEN
			       LET v_pago10 = v_monto_pago;
				   LET v_cant10 = 1;
			    END IF;
			    IF _cod_cober_int = 105 THEN
			       LET v_pago12 = v_monto_pago;
				   LET v_cant12 = 1;
			    END IF;
			    IF _cod_cober_int = 106 THEN
			       LET v_pago13 = v_monto_pago;
				   LET v_cant13 = 1;
			    END IF;
			    IF _cod_cober_int= 107 THEN
			       LET v_pago14 = v_monto_pago;
				   LET v_cant14 = 1;
			    END IF;
			    IF _cod_cober_int = 108 THEN
			       LET v_pago15 = v_monto_pago;
				   LET v_cant15	= 1;
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
					   		 pagos15 = pagos15 + v_pago15,
							 cant01	= cant01 + v_cant1,
							 cant02	= cant02 + v_cant2,
							 cant03	= cant03 + v_cant3,
							 cant04	= cant04 + v_cant4,
							 cant05	= cant05 + v_cant5,
							 cant06	= cant06 + v_cant6,
							 cant08	= cant08 + v_cant8,
							 cant09	= cant09 + v_cant9,
							 cant10	= cant10 + v_cant10,
							 cant12	= cant12 + v_cant12,
							 cant13	= cant13 + v_cant13,
							 cant14	= cant14 + v_cant14,
							 cant15	= cant15 + v_cant15
				       WHERE ano_auto = _valor
				         AND cod_marca = v_cod_marca;
				    END EXCEPTION;
		           INSERT INTO tmp_marca(
				   ano_auto,
				   cod_marca,
				   salvamento,
				   no_rec,
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
				   cant01,
				   cant02,
				   cant03,
				   cant04,
				   cant05,
				   cant06,
				   cant08,
				   cant09,
				   cant10,
				   cant12,
				   cant13,
				   cant14,
				   cant15,
				   seleccionado)
		           VALUES(
				   _valor,
		           v_cod_marca,
		           v_salvamento,
				   v_no_reclamo,
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
				   v_cant1,
				   v_cant2,
				   v_cant3,
				   v_cant4,
				   v_cant5,
				   v_cant6,
				   v_cant8,
				   v_cant9,
				   v_cant10,
				   v_cant12,
				   v_cant13,
				   v_cant14,
				   v_cant15,
				   1
		           );
		        END;
            END FOREACH
		END FOREACH

		-- Monto de deducible
		SELECT SUM(deducible)
		  INTO v_deducible
		  FROM recrccob
		 WHERE no_reclamo = v_no_reclamo;

		IF v_deducible IS NULL THEN
		     LET v_deducible = 0;
		END IF

         LET v_variacion = 0;

         SELECT SUM(variacion)
	       INTO v_variacion
	       FROM rectrmae
          WHERE no_reclamo   = v_no_reclamo
	        AND actualizado  = 1;

		 IF v_variacion IS NULL THEN
		     LET v_variacion = 0;
		 END IF

		let _buscar = 0;

		SELECT count(*)
		  INTO _buscar
		  FROM tmp_marca
		 WHERE cod_marca = v_cod_marca;

		SELECT count(*)
		  INTO _buscar_poliza
		  FROM tmp_poliza
		 WHERE no_poliza = v_no_poliza;

		if _buscar_poliza > 0 then
			let _prima_suscrita = 0;
		else
			SELECT sum(prima_suscrita)
			  INTO _prima_suscrita
			  FROM endedmae
			 WHERE no_poliza = v_no_poliza
			   and actualizado = 1;
		end if

		if _buscar > 0 then
			BEGIN
	           INSERT INTO tmp_poliza(
			   ano_auto,
			   variacion,
			   cod_marca,
			   contador,
			   deducible,
			   seleccionado,
			   no_poliza,
			   prima_suscrita
			   )
	           VALUES(
			   _valor,
			   v_variacion,
			   v_cod_marca,
			   1,
			   v_deducible,
	           1,
			   v_no_poliza,
			   _prima_suscrita
	           );
	    	END;
		end if
	END FOREACH
END FOREACH

--Filtro especial para marcas
IF a_marca <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Marca: "; --|| TRIM(a_marca);

	LET _tipo = sp_sis04(a_marca);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_marca
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_marca NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";

		UPDATE tmp_poliza
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_marca NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_marca
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_marca IN (SELECT codigo FROM tmp_codigos);
        LET v_saber = " Ex";

		UPDATE tmp_poliza
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_marca IN (SELECT codigo FROM tmp_codigos);

	END IF
	 FOREACH
		SELECT emimarca.nombre,tmp_codigos.codigo
          INTO v_desc_marca,v_codigo
          FROM emimarca,tmp_codigos
         WHERE emimarca.cod_marca = codigo
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_marca) || " " || TRIM(v_saber);
	 END FOREACH
	DROP TABLE tmp_codigos;

END IF

FOREACH
	 SELECT ano_auto,
			sum(contador),
			sum(deducible),
			sum(variacion),
			sum(prima_suscrita)
	   INTO _ano_auto,
		    _cnt_uni,
			v_deducible,
			v_variacion,
			_prima_suscrita
	   FROM tmp_poliza
	  WHERE seleccionado = 1
   GROUP BY ano_auto
   ORDER BY ano_auto

	 SELECT sum(pagos01),
			sum(pagos02),
			sum(pagos03),
			sum(pagos04),
			sum(pagos05),
			sum(pagos06),
			sum(pagos08),				
			sum(pagos09),				
			sum(pagos10),				
			sum(pagos12),				
			sum(pagos13),				
			sum(pagos14),
			sum(pagos15),
			sum(cant01),
			sum(cant02),
			sum(cant03),
			sum(cant04),
			sum(cant05),
			sum(cant06),
			sum(cant08),
			sum(cant09),
			sum(cant10),
			sum(cant12),
			sum(cant13),
			sum(cant14),
			sum(cant15),
			sum(salvamento)
	   INTO v_pago1,
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
			v_cant1,
			v_cant2,
			v_cant3,
			v_cant4,
			v_cant5,
			v_cant6,
			v_cant8,
			v_cant9,
			v_cant10,
			v_cant12,
			v_cant13,
			v_cant14,
			v_cant15,
            v_salvamento
	   FROM tmp_marca
	  WHERE seleccionado = 1
	    AND ano_auto  = _ano_auto;

  LET v_subtotal   = 0;
  LET v_incurrido  = 0;
  LET v_gasto_real = 0;
  LET v_subtotal   = v_pago1+v_pago2+v_pago3+v_pago4+v_pago5+v_pago6+
                     v_pago8+v_pago9+v_pago10+v_pago12+v_pago13+v_pago14+
                     v_pago15;
if v_pago1 is null then
  LET v_subtotal = 0;
end if
  LET v_incurrido  = v_subtotal  + v_variacion;
  LET v_gasto_real = v_incurrido + v_deducible;

 { IF v_subtotal  = 0 AND
     v_variacion = 0 AND
     v_incurrido = 0 AND
     v_deducible = 0 THEN
     CONTINUE FOREACH;
  END IF;	}

     RETURN _ano_auto,
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
		    v_deducible,
            _cnt_uni,
			v_variacion,
            v_incurrido,
            v_gasto_real,
			v_cant1,
			v_cant2,
			v_cant3,
			v_cant4,
			v_cant5,
			v_cant6,
			v_cant8,
			v_cant9,
			v_cant10,
			v_cant12,
			v_cant13,
			v_cant14,
			v_cant15,
			v_filtros,
			_prima_suscrita
            WITH RESUME;
END FOREACH

DROP TABLE tmp_marca;
DROP TABLE tmp_prod;
DROP TABLE tmp_poliza;  

END PROCEDURE;