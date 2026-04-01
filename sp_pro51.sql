-- Listado de Vencimientos
--
-- Creado    : 01/12/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 01/12/2000 - Autor: Lic. Armando Moreno
-- Modificado: 28/08/2001 - Autor: Lic. Marquelda Valdelamar (para incluir filtro de cliente)
--			   06/09/2001                                     filtro de poliza
-- Modificado: 17 de Mayo de 2007- Rub‚n Dar¡o Arn ez Se adiciono El filtro para el tipo de Producto
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro51;

CREATE PROCEDURE "informix".sp_pro51(
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
		a_saldo_cero    SMALLINT,
		a_cod_cliente   CHAR(255) DEFAULT "*",
		a_no_documento  CHAR(255) DEFAULT "*",
		a_opcion_renovar SMALLINT DEFAULT 0,
		a_codtipoprod   CHAR(255) DEFAULT "*",
		a_zona          CHAR(255) DEFAULT "*"
        ) RETURNING CHAR(255);

DEFINE _sucursal_origen  CHAR(3);
DEFINE _cod_grupo  		 CHAR(5);
DEFINE _cod_agente       CHAR(5);
DEFINE _user_added       CHAR(8);
DEFINE _cod_ramo    	 CHAR(3);
DEFINE _no_documento     CHAR(20);
--DEFINE _ref     		 CHAR(20);
--DEFINE _no_doc     	 CHAR(20);
DEFINE _cod_contratante  CHAR(10);
--DEFINE _n_p  			 CHAR(10);
DEFINE _no_poliza		 CHAR(10);
DEFINE _vigencia_final   DATE;
DEFINE _prima			 DECIMAL(16,2);
--DEFINE _exigible_tot	 DECIMAL(16,2);
--DEFINE _corriente_tot	 DECIMAL(16,2);
--DEFINE _monto_30_tot	 DECIMAL(16,2);
DEFINE _saldo		   	 DECIMAL(16,2);
--DEFINE _monto_60_tot	 DECIMAL(16,2);
--DEFINE _monto_90_tot	 DECIMAL(16,2);
DEFINE _periodo		     CHAR(7);
--DEFINE _per			 CHAR(7);
DEFINE v_desc_agente     CHAR(50);
DEFINE _cod_tipoprod     CHAR(3);
DEFINE _tipo_produccion  CHAR(1);
DEFINE _fecha1  		 DATE;
DEFINE _fecha2	 		 DATE;
--DEFINE _fec 		 	 DATE;
DEFINE _mes1     		 SMALLINT;
DEFINE _mes2     	     SMALLINT;
DEFINE _ano1     	     SMALLINT;
DEFINE _ano2     		 SMALLINT;
DEFINE v_filtros         CHAR(255);
DEFINE _tipo,_estatus    CHAR(1);
DEFINE _porc_saldos      DEC(16,2);
DEFINE _prima_porc       DEC(16,2);
DEFINE _por_vencer_tot   DEC(16,2);
DEFINE v_saber 			 CHAR(3);
DEFINE v_codigo			 CHAR(5);

LET _porc_saldos = 10;

-- Descomponer los periodos en fechas
LET _ano1 = a_periodo1[1,4];
LET _mes1 = a_periodo1[6,7];

LET _ano2 = a_periodo2[1,4];
LET _mes2 = a_periodo2[6,7];

LET _mes1 = _mes1;
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
		no_documento   	CHAR(20)  ,
		cod_contratante CHAR(10)  NOT NULL,
		vigencia_final 	DATE   	  NOT NULL,
		prima           DECIMAL(16,2),
		saldo	        DECIMAL(16,2),
		tipo_produccion CHAR(1),
		estatus			CHAR(1),
		seleccionado   	SMALLINT  DEFAULT 1 NOT NULL
		--no_poliza       CHAR(10)  NOT NULL
		) WITH NO LOG;


CREATE INDEX iend1_tmp_prod ON tmp_prod(cod_ramo);
CREATE INDEX iend2_tmp_prod ON tmp_prod(cod_grupo);
CREATE INDEX iend3_tmp_prod ON tmp_prod(sucursal_origen);
CREATE INDEX iend4_tmp_prod ON tmp_prod(tipo_produccion);
CREATE INDEX iend5_tmp_prod ON tmp_prod(cod_agente);
CREATE INDEX iend6_tmp_prod ON tmp_prod(user_added);

LET _cod_agente = "*";
SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro51.trc";
--trace on;

IF a_opcion_renovar	= 2 THEN --TODAS LAS POLIZAS
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
			   prima_bruta
		  INTO _no_poliza, 
		  	   _sucursal_origen, 
		  	   _cod_grupo, 
		  	   _cod_tipoprod, 
		  	   _cod_ramo, 
		  	   _user_added,
			   _no_documento, 
			   _cod_contratante, 
			   _vigencia_final, 
			   _prima
		  FROM emipomae
		 WHERE vigencia_final >= _fecha1 
		   AND vigencia_final <= _fecha2
		   AND actualizado = 1
		   AND no_renovar  = 0
	       AND incobrable  = 0
		   AND abierta     = 0
		   AND estatus_poliza IN (1,3)

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

	   --Buscar el saldo de la poliza
	   CALL sp_cob85(
		 	a_compania,
		 	a_agencia,	
		 	_no_documento
		    ) RETURNING _saldo;

	   LET _prima_porc = _prima * _porc_saldos / 100;
	   	
	   IF _saldo > 0 THEN
		 IF _saldo > _prima_porc THEN
			 LET _estatus = "0";		
		 ELSE
			 LET _estatus = "1";
		 END IF
	   ELSE
		 LET _estatus = "1";
	   END IF

		-- Insercion / Actualizacion a la tabla temporal tmp_prod

		INSERT INTO tmp_prod(
		sucursal_origen,
		cod_grupo,
		cod_agente,
		user_added,
		cod_ramo,
		no_documento,
	 	cod_contratante,
	 	vigencia_final,	 
		prima,
		saldo,
		tipo_produccion,
		estatus,
		seleccionado
		--no_poliza	
		)
		VALUES(
		_sucursal_origen,
		_cod_grupo,
		_cod_agente,
		_user_added,
		_cod_ramo,
		_no_documento,
		_cod_contratante,
		_vigencia_final,
		_prima,
		_saldo,
		_tipo_produccion,
		_estatus,
		--_no_poliza,
		1
		);
		
	END FOREACH;
ELSE	   --0 = EXCL REN.         1 = SOLO REN.

	FOREACH WITH HOLD			-- Informacion de Poliza
		SELECT no_poliza, 
			   sucursal_origen, 
			   cod_grupo, 
			   cod_tipoprod, 
			   cod_ramo, 
			   user_added,
			   no_documento, 
			   cod_contratante, 
			   vigencia_final, 
			   prima_bruta
		  INTO _no_poliza, 
		  	   _sucursal_origen, 
		  	   _cod_grupo, 
		  	   _cod_tipoprod, 
		  	   _cod_ramo, 
		  	   _user_added,
			   _no_documento, 
			   _cod_contratante, 
			   _vigencia_final, 
			   _prima
		  FROM emipomae
		 WHERE vigencia_final >= _fecha1 
		   AND vigencia_final <= _fecha2
		   AND actualizado = 1
		   AND renovada    = a_opcion_renovar
		   AND no_renovar  = 0
	       AND incobrable  = 0
		   AND abierta     = 0
		   AND estatus_poliza IN (1,3)

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

 	   --Buscar el saldo de la poliza

	   CALL sp_cob85(a_compania,a_agencia,_no_documento) RETURNING _saldo;

	   --si el saldo es 10% mayor que la prima bruta entonces se excluye del inf.	
	   LET _prima_porc = _prima * _porc_saldos / 100;
	   	
	   IF _saldo > 0 THEN
		 IF _saldo > _prima_porc THEN
			 LET _estatus = "0";		
		 ELSE
			 LET _estatus = "1";
		 END IF
	   ELSE
		 LET _estatus = "1";
	   END IF

		-- Insercion / Actualizacion a la tabla temporal tmp_prod

		INSERT INTO tmp_prod(
		sucursal_origen,
		cod_grupo,
		cod_agente,
		user_added,
		cod_ramo,
		no_documento,
	 	cod_contratante,
	 	vigencia_final,	 
		prima,
		saldo,
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
		_no_documento,
		_cod_contratante,
		_vigencia_final,
		_prima,
		_saldo,
		_tipo_produccion,
		_estatus,
		1
		);
		
	END FOREACH;
END IF
-- Procesos para Filtros

LET v_filtros = "";

IF a_saldo_cero = 1 THEN --SOLO SALDO = 0

   	LET v_filtros = " Saldo Cero y Cred.;";

   UPDATE tmp_prod
   	  SET seleccionado = 0
	WHERE seleccionado = 1
	  AND estatus <> "1";

ELIF a_saldo_cero = 0 THEN --CON SALDO

   	LET v_filtros = " Con Saldo;";

   UPDATE tmp_prod
   	  SET seleccionado = 0
	WHERE seleccionado = 1
	  AND estatus <> "0";

ELSE --TODO

   	LET v_filtros = " Todas las polizas;";

END IF

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

	   UPDATE tmp_prod
	   	  SET seleccionado = 0
		WHERE seleccionado = 1
		  AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

	   UPDATE tmp_prod
	   	  SET seleccionado = 0
		WHERE seleccionado = 1
		  AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_grupo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Grupo: " ||  TRIM(a_grupo);

	LET _tipo = sp_sis04(a_grupo);  -- Separa lls Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo IN (SELECT codigo FROM tmp_codigos);

	END IF

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

-- FILTRO DE TIPO DE PRODUCTO
IF a_codtipoprod <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Tipo Produccion "||TRIM(a_codtipoprod);
         LET _tipo = sp_sis04(a_codtipoprod); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_detalle
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_tipoprod NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_detalle
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_tipoprod IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

--Filtro de Poliza
	   IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);
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




RETURN v_filtros;

END PROCEDURE;
