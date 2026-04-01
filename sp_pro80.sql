-- Listado de Totales de Vencimientos para agrupacion por rango de saldos
--
-- Creado    : 26/10/2001 - Autor: Lic. Armando Moreno 
-- Modificado: 26/10/2001 - Autor: Lic. Armando Moreno
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro80;

CREATE PROCEDURE "informix".sp_pro80(
        a_compania  	CHAR(3), 
        a_agencia   	CHAR(3), 
        a_periodo1  	CHAR(7),
        a_periodo2  	CHAR(7),
		a_sucursal  	CHAR(255) DEFAULT "*",
		a_ramo      	CHAR(255) DEFAULT "*",
		a_grupo     	CHAR(255) DEFAULT "*",
		a_usuario   	CHAR(255) DEFAULT "*",
		a_reaseguro 	CHAR(255) DEFAULT "*",
		a_agente    	CHAR(255) DEFAULT "*",
		a_cod_cliente   CHAR(255) DEFAULT "*",
		a_no_documento  CHAR(255) DEFAULT "*",
		a_opcion_renovar SMALLINT DEFAULT 0,
		a_rango1		 SMALLINT DEFAULT 0,
		a_rango2		 SMALLINT DEFAULT 20,
		a_rango3		 SMALLINT DEFAULT 21,
		a_rango4		 SMALLINT DEFAULT 40,
		a_rango5		 SMALLINT DEFAULT 41,
		a_rango6		 SMALLINT DEFAULT 60
        ) RETURNING CHAR(255);

DEFINE _sucursal_origen  CHAR(3);
DEFINE _cod_subramo      CHAR(3);
DEFINE _cod_grupo  		 CHAR(5);
DEFINE _cod_agente       CHAR(5);
DEFINE _user_added       CHAR(8);
DEFINE _cod_ramo    	 CHAR(3);
DEFINE _no_documento     CHAR(20);
DEFINE _cod_contratante  CHAR(10);
DEFINE _no_poliza,_no_p	 CHAR(10);
DEFINE _vigencia_final   DATE;
DEFINE _prima_neta		 DECIMAL(16,2);
DEFINE _incurrido_bruto	 DECIMAL(16,2);
DEFINE _saldo_neto	   	 DECIMAL(16,2);
DEFINE _por_vencer_tot 	 DECIMAL(16,2);
DEFINE _exigible_tot 	 DECIMAL(16,2);
DEFINE _corriente_tot 	 DECIMAL(16,2);
DEFINE _monto_30_tot 	 DECIMAL(16,2);
DEFINE _monto_60_tot 	 DECIMAL(16,2);
DEFINE _monto_90_tot 	 DECIMAL(16,2);
DEFINE _prima_sus	 	 DECIMAL(16,2);
DEFINE _prima_bruta	 	 DECIMAL(16,2);
DEFINE _periodo      	 CHAR(7);
DEFINE v_desc_agente,v_desc_grupo,v_desc_ramo  CHAR(50);
DEFINE _cod_tipoprod     CHAR(3);
DEFINE _tipo_produccion  CHAR(1);
DEFINE _fecha1  		 DATE;
DEFINE _fecha2  		 DATE;
DEFINE _mes1     		 SMALLINT;
DEFINE _mes2     	     SMALLINT;
DEFINE _ano1     	     SMALLINT;
DEFINE _ano2     		 SMALLINT;
DEFINE v_filtros         CHAR(255);
DEFINE _tipo,_estatus    CHAR(1);
DEFINE _prima_porc       DEC(16,2);
DEFINE v_saber 			 CHAR(3);
DEFINE v_codigo			 CHAR(5);

-- Descomponer los periodos en fechas
LET _ano1 = a_periodo1[1,4];
LET _mes1 = a_periodo1[6,7];
LET _ano2 = a_periodo2[1,4];
LET _mes2 = a_periodo2[6,7];
--LET _mes1 = _mes1;
LET _fecha1 = MDY(_mes1,1,_ano1);

IF _mes2 = 12 THEN
   LET _mes2 = 1;
   LET _ano2 = _ano2 + 1;
ELSE
   LET _mes2 = _mes2 + 1;
END IF
LET _fecha2 = MDY(_mes2,1,_ano2);
LET _fecha2 = _fecha2 - 1;

-- Tabla Temporal tmp_prod

CREATE TEMP TABLE tmp_prod(
		sucursal_origen CHAR(3)   NOT NULL,
		cod_grupo	   	CHAR(5)   NOT NULL,
		cod_agente     	CHAR(5)   NOT NULL,
		user_added     	CHAR(8)   NOT NULL,
		cod_ramo       	CHAR(3)   NOT NULL,
		cod_subramo    	CHAR(3)   NOT NULL,
		no_documento   	CHAR(20)  ,
		cod_contratante CHAR(10)  NOT NULL,
		vigencia_final 	DATE   	  NOT NULL,
		prima           DECIMAL(16,2),
		saldo	        DECIMAL(16,2),
		prima_sus		DECIMAL(16,2),
		incurrido_bruto	DECIMAL(16,2),
		tipo_produccion CHAR(1),
		estatus			CHAR(1),
		seleccionado   	SMALLINT DEFAULT 1 NOT NULL
		) WITH NO LOG;


CREATE INDEX iend1_tmp_prod ON tmp_prod(cod_ramo);
CREATE INDEX iend7_tmp_prod ON tmp_prod(cod_subramo);
CREATE INDEX iend2_tmp_prod ON tmp_prod(cod_grupo);
CREATE INDEX iend3_tmp_prod ON tmp_prod(sucursal_origen);
CREATE INDEX iend4_tmp_prod ON tmp_prod(tipo_produccion);
CREATE INDEX iend5_tmp_prod ON tmp_prod(cod_agente);
CREATE INDEX iend6_tmp_prod ON tmp_prod(user_added);

LET _cod_agente = "*";
SET ISOLATION TO DIRTY READ;

--Buscar el Incurrido Bruto
LET v_filtros = sp_rec59(
a_compania,
a_agencia,
a_periodo1
);

IF a_opcion_renovar	= 2 THEN --TODAS LAS POLIZAS *FILTRO TIPO*
	FOREACH WITH HOLD
	-- Informacion de Poliza

		SELECT no_poliza,
			   sucursal_origen,
			   cod_grupo,
			   cod_tipoprod,
			   cod_ramo,
			   user_added,
			   no_documento,
			   cod_contratante,
			   vigencia_final,
			   cod_subramo,
			   prima_neta
		  INTO _no_poliza,
		  	   _sucursal_origen,
		  	   _cod_grupo, 
		  	   _cod_tipoprod, 
		  	   _cod_ramo, 
		  	   _user_added,
			   _no_documento, 
			   _cod_contratante, 
			   _vigencia_final, 
			   _cod_subramo, 
			   _prima_neta
		  FROM emipomae
		 WHERE vigencia_final >= _fecha1 and vigencia_final <= _fecha2
		   AND actualizado = 1
		   AND no_renovar  = 0
	       AND incobrable  = 0
		   AND abierta     = 0
		   AND estatus_poliza IN (1,3)

	   FOREACH WITH HOLD
		    SELECT no_poliza,SUM(prima_suscrita)
			  INTO _no_p,_prima_sus
			  FROM endedmae
			 WHERE no_poliza = _no_poliza
			 GROUP BY no_poliza
			 ORDER BY no_poliza
			 EXIT FOREACH;
	   END FOREACH

	    SELECT tipo_produccion
		  INTO _tipo_produccion
		  FROM emitipro
		 WHERE cod_tipoprod = _cod_tipoprod;

	   FOREACH WITH HOLD
		    SELECT cod_agente
			  INTO _cod_agente
			  FROM emipoagt
			 WHERE no_poliza = _no_poliza
			 EXIT FOREACH;
	   END FOREACH

	   --Buscar el saldo neto
	   CALL sp_cob74b(
		 	a_compania,
		 	a_agencia,	
		 	_no_documento,
		 	a_periodo1,
		 	_fecha1
		    ) RETURNING _por_vencer_tot,
    				 	_exigible_tot,         
    				 	_corriente_tot,        
    				 	_monto_30_tot,         
    				 	_monto_60_tot,         
    				 	_monto_90_tot,
					 	_saldo_neto;


	   IF _saldo_neto > 0.00 THEN
	   	 IF _prima_neta <> 0 THEN
			   LET _prima_porc = (_saldo_neto * 100) / _prima_neta;

			   IF _prima_porc >= a_rango1 AND _prima_porc <= a_rango2 THEN
				 LET _estatus = "1";
			   END IF

			   IF _prima_porc >= a_rango3 AND _prima_porc <= a_rango4 THEN
				 LET _estatus = "2";
			   END IF

			   IF _prima_porc >= a_rango5 AND _prima_porc <= a_rango6 THEN
				 LET _estatus = "3";
			   END IF

			   IF _prima_porc > 60 THEN
				 LET _estatus = "4";
			   END IF
	     ELSE
		   		LET _estatus = "7";
	     END IF
	   END IF

	   IF _saldo_neto = 0.00 THEN
		 LET _estatus = "6";
	   END IF

	   IF _saldo_neto < 0 THEN
		 LET _estatus = "5";
	   END IF

	   LET _incurrido_bruto = 0.00;

	   FOREACH
		   SELECT no_poliza,sum(incurrido_bruto)
			 INTO _no_p,_incurrido_bruto
	 	     FROM tmp_sinis
	  	    WHERE no_poliza = _no_poliza
	  	    GROUP BY no_poliza
	  	    ORDER BY no_poliza
	   END FOREACH

	   IF _incurrido_bruto IS NULL THEN
		LET _incurrido_bruto = 0.00;
	   END IF

	-- Insercion / Actualizacion a la tabla temporal tmp_prod

		INSERT INTO tmp_prod(
		sucursal_origen,
		cod_grupo,
		cod_agente,
		user_added,
		cod_ramo,
		cod_subramo,
		no_documento,
	 	cod_contratante,
	 	vigencia_final,	 
		prima,
		saldo,
		prima_sus,
		incurrido_bruto,
		tipo_produccion,
		estatus,
		seleccionado	
		)
		VALUES(
		_sucursal_origen,
		_cod_grupo,
		_cod_agente,
		_user_added,
		_cod_ramo,
		_cod_subramo,
		_no_documento,
		_cod_contratante,
		_vigencia_final,
		_prima_neta,
		_saldo_neto,
		_prima_sus,
		_incurrido_bruto,
		_tipo_produccion,
		_estatus,
		1
		);
		
	END FOREACH;
ELSE
	FOREACH WITH HOLD
		-- Informacion de Poliza

		SELECT no_poliza, 
			   sucursal_origen, 
			   cod_grupo, 
			   cod_tipoprod, 
			   cod_ramo, 
			   user_added,
			   no_documento, 
			   cod_contratante, 
			   vigencia_final, 
			   prima_neta, 
			   cod_subramo
		  INTO _no_poliza, 
		  	   _sucursal_origen, 
		  	   _cod_grupo, 
		  	   _cod_tipoprod, 
		  	   _cod_ramo, 
		  	   _user_added,
			   _no_documento, 
			   _cod_contratante, 
			   _vigencia_final, 
			   _prima_neta, 
			   _cod_subramo 
		  FROM emipomae
		 WHERE vigencia_final >= _fecha1 and vigencia_final <= _fecha2
		   AND actualizado = 1
		   AND renovada    = a_opcion_renovar
		   AND no_renovar  = 0
	       AND incobrable  = 0
		   AND abierta     = 0
		   AND estatus_poliza IN (1,3)

	   FOREACH WITH HOLD
		    SELECT no_poliza,SUM(prima_suscrita)
			  INTO _no_p,_prima_sus
			  FROM endedmae
			 WHERE no_poliza = _no_poliza
			 GROUP BY no_poliza
			 ORDER BY no_poliza
			 EXIT FOREACH;
	   END FOREACH

	    SELECT tipo_produccion
		  INTO _tipo_produccion
		  FROM emitipro
		 WHERE cod_tipoprod = _cod_tipoprod;

	   FOREACH WITH HOLD
		    SELECT cod_agente
			  INTO _cod_agente
			  FROM emipoagt
			 WHERE no_poliza = _no_poliza
			 EXIT FOREACH;
	   END FOREACH

	   --Buscar el saldo neto
	   CALL sp_cob74b(
		 	a_compania,
		 	a_agencia,	
		 	_no_documento,
		 	a_periodo1,
		 	_fecha1
		    ) RETURNING _por_vencer_tot,       
    				 	_exigible_tot,         
    				 	_corriente_tot,        
    				 	_monto_30_tot,         
    				 	_monto_60_tot,         
    				 	_monto_90_tot,
					 	_saldo_neto;

	   IF _saldo_neto > 0.00 THEN
	   	 IF _prima_neta <> 0 THEN
			   LET _prima_porc = (_saldo_neto * 100) / _prima_neta;

			   IF _prima_porc >= a_rango1 AND _prima_porc <= a_rango2 THEN
				 LET _estatus = "1";
			   END IF

			   IF _prima_porc >= a_rango3 AND _prima_porc <= a_rango4 THEN
				 LET _estatus = "2";
			   END IF

			   IF _prima_porc >= a_rango5 AND _prima_porc <= a_rango6 THEN
				 LET _estatus = "3";
			   END IF

			   IF _prima_porc > 60 THEN
				 LET _estatus = "4";
			   END IF
	     ELSE
		   		LET _estatus = "7";
	     END IF
	   END IF

	   IF _saldo_neto = 0.00 THEN
		 LET _estatus = "6";
	   END IF

	   IF _saldo_neto < 0 THEN
		 LET _estatus = "5";
	   END IF

	   LET _incurrido_bruto = 0.00;

	   FOREACH
		   SELECT no_poliza,sum(incurrido_bruto)
			 INTO _no_p,_incurrido_bruto
	 	     FROM tmp_sinis
	  	    WHERE no_poliza = _no_poliza
	  	    GROUP BY no_poliza
	  	    ORDER BY no_poliza
	   END FOREACH

	   IF _incurrido_bruto IS NULL THEN
		LET _incurrido_bruto = 0.00;
	   END IF
	-- Insercion / Actualizacion a la tabla temporal tmp_prod

				INSERT INTO tmp_prod(
				sucursal_origen,
				cod_grupo,
				cod_agente,
				user_added,
				cod_ramo,
				cod_subramo,
				no_documento,
			 	cod_contratante,
			 	vigencia_final,	 
				prima,
				saldo,
				prima_sus,
				incurrido_bruto,
				tipo_produccion,
				estatus,
				seleccionado	
				)
				VALUES(
				_sucursal_origen,
				_cod_grupo,
				_cod_agente,
				_user_added,
				_cod_ramo,
				_cod_subramo,
				_no_documento,
				_cod_contratante,
				_vigencia_final,
				_prima_neta,
				_saldo_neto,
				_prima_sus,
				_incurrido_bruto,
				_tipo_produccion,
				_estatus,
				1
				);
		
	END FOREACH;
END IF
-- Procesos para Filtros

LET v_filtros = "";

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: ";-- ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

	   UPDATE tmp_prod
	   	  SET seleccionado = 0
		WHERE seleccionado = 1
		  AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);
       LET v_saber = "";
	ELSE		        -- (E) Excluir estos Registros

	   UPDATE tmp_prod
	   	  SET seleccionado = 0
		WHERE seleccionado = 1
		  AND cod_ramo IN (SELECT codigo FROM tmp_codigos);
       LET v_saber = " Ex";
	END IF
	SELECT prdramo.nombre,tmp_codigos.codigo
      INTO v_desc_ramo,v_codigo
      FROM prdramo,tmp_codigos
     WHERE prdramo.cod_ramo = codigo;
     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_ramo) || (v_saber);
	DROP TABLE tmp_codigos;

END IF

IF a_grupo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Grupo: "; --|| TRIM(a_grupo);

	LET _tipo = sp_sis04(a_grupo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
	END IF
    FOREACH
		SELECT cligrupo.nombre,tmp_codigos.codigo
	      INTO v_desc_grupo,v_codigo
	      FROM cligrupo,tmp_codigos
	     WHERE cligrupo.cod_grupo = codigo
	     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_grupo) || (v_saber);
    END FOREACH

	DROP TABLE tmp_codigos;

END IF

IF a_usuario <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Usuario: " ||  TRIM(a_usuario);

	LET _tipo = sp_sis04(a_usuario);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND user_added NOT IN (SELECT codigo FROM tmp_codigos);
	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND user_added IN (SELECT codigo FROM tmp_codigos);
	END IF

	DROP TABLE tmp_codigos;

END IF


IF a_sucursal <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: " ||  TRIM(a_sucursal);

	LET _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND sucursal_origen NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND sucursal_origen IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_reaseguro <> "*" THEN

	LET _tipo = sp_sis04(a_reaseguro);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

        LET v_filtros = TRIM(v_filtros) || " Reaseguro Asumido: Solamente ";

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND tipo_produccion NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excllir estos Registros

        LET v_filtros = TRIM(v_filtros) || " Reaseguro Asumido: Excluido ";

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND tipo_produccion IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_cod_cliente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Cliente: " ||  TRIM(a_cod_cliente);

	LET _tipo = sp_sis04(a_cod_cliente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contratante NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contratante IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

--Filtro de Poliza
	   IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||" Documento: "||TRIM(a_no_documento);
            UPDATE tmp_prod
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND no_documento <> a_no_documento;
      END IF
--

IF a_agente <> "*" THEN

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

   	LET v_filtros = TRIM(v_filtros) || " Corredor: "; -- ||  TRIM(a_agente);


	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
	ELSE		        -- Excluir estos Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
	END IF
	 FOREACH
		SELECT agtagent.nombre,tmp_codigos.codigo
          INTO v_desc_agente,v_codigo
          FROM agtagent,tmp_codigos
         WHERE agtagent.cod_agente = codigo
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_agente) || " " || TRIM(v_saber);
	 END FOREACH

	DROP TABLE tmp_codigos;

END IF
DROP TABLE tmp_sinis;
RETURN v_filtros;

END PROCEDURE;
