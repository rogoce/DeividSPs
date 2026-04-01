-- Procedimiento que Carga las Primas de Produccion
-- en un Periodo Dado
--
-- Creado    : 08/08/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 08/08/2000 - Autor: Lic. Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro27;

CREATE PROCEDURE "informix".sp_pro27(
        a_compania     CHAR(3), 
        a_agencia      CHAR(3), 
        a_periodo1     CHAR(7),
        a_periodo2     CHAR(7),
		a_sucursal     CHAR(255)  DEFAULT "*",
		a_ramo         CHAR(255)  DEFAULT "*",
		a_grupo        CHAR(255)  DEFAULT "*",
		a_usuario      CHAR(255)  DEFAULT "*",
		a_reaseguro    CHAR(255)  DEFAULT "*",
		a_agente       CHAR(255)  DEFAULT "*",
        a_origen       CHAR(3) DEFAULT "%") RETURNING CHAR(255);

DEFINE _no_poliza 		 CHAR(10); 
DEFINE _no_endoso 		 CHAR(5);
DEFINE _periodo      	 CHAR(7);
	
DEFINE _user_added       CHAR(8);
DEFINE _cod_ramo    	 CHAR(3); 
DEFINE _cod_sucursal     CHAR(3);
DEFINE _cod_grupo  		 CHAR(5); 
DEFINE _cod_contrato	 CHAR(5); 
DEFINE _cod_subramo  	 CHAR(3);
DEFINE _cod_agente       CHAR(5);
DEFINE _cod_tipoprod     CHAR(3);

DEFINE _tipo_produccion  CHAR(1);
DEFINE _porc_partic_agt  DECIMAL(5,2);
DEFINE _total_prima_sus	 DECIMAL(16,2);
DEFINE _total_prima_ret  DECIMAL(16,2);
DEFINE _total_prima_ced  DECIMAL(16,2);
DEFINE _prima_facultativo DECIMAL(16,2);
DEFINE _prima_otros      DECIMAL(16,2);
DEFINE _prima_contrato   DECIMAL(16,2);
DEFINE t_total_prima_sus DECIMAL(16,2);
DEFINE t_total_prima_ret DECIMAL(16,2);
DEFINE t_total_prima_ced DECIMAL(16,2);
DEFINE v_filtros         CHAR(255);
DEFINE _tipo             CHAR(1);
DEFINE _tipo_contrato    SMALLINT;
define _error			integer;
define _error_desc		char(255);
	
-- Tabla Temporal tmp_prod

CREATE TEMP TABLE tmp_prod(
		no_poliza      CHAR(10)  NOT NULL,
		cod_sucursal   CHAR(3)   NOT NULL,
		cod_subramo	   CHAR(3)   NOT NULL,
		cod_ramo       CHAR(3)   NOT NULL,
		cod_grupo	   CHAR(5)   NOT NULL,
		cod_agente     CHAR(5)   NOT NULL,
		user_added     CHAR(8)   NOT NULL,
		tipo_produccion CHAR(1),
		total_pri_sus  DEC(16,2) NOT NULL,
		total_pri_ret  DEC(16,2) NOT NULL,
		total_pri_ced  DEC(16,2) NOT NULL,
		total_pri_otro DEC(16,2) NOT NULL,
		total_pri_facu DEC(16,2) NOT NULL,
		seleccionado   SMALLINT  DEFAULT 1 NOT NULL,
		no_endoso      CHAR(5)
		) WITH NO LOG;

CREATE INDEX iend1_tmp_prod ON tmp_prod(cod_ramo);
CREATE INDEX iend2_tmp_prod ON tmp_prod(cod_grupo);
CREATE INDEX iend3_tmp_prod ON tmp_prod(cod_sucursal);
CREATE INDEX iend4_tmp_prod ON tmp_prod(tipo_produccion);
CREATE INDEX iend5_tmp_prod ON tmp_prod(cod_agente);
CREATE INDEX iend6_tmp_prod ON tmp_prod(user_added);

SET ISOLATION TO DIRTY READ;

LET _cod_agente = "*";

FOREACH WITH HOLD
  SELECT e.no_poliza,	
         e.no_endoso, 	
         e.prima_suscrita,	 
         e.prima_retenida
    INTO _no_poliza,		         
         _no_endoso, 	
         _total_prima_sus,	 
         _total_prima_ret
    FROM endedmae e, emipomae f
   WHERE e.no_poliza = f.no_poliza
     AND f.cod_origen like a_origen
     AND (e.periodo    >= a_periodo1
     AND e.periodo     <= a_periodo2)
	 AND e.actualizado  = 1
	 AND e.cod_compania = a_compania

	LET _prima_facultativo = 0.00;
	LET _prima_otros       = 0.00;
	let _total_prima_ret   = 0.00;
	
	drop table if exists tmp_reas;
	call sp_sis122(_no_poliza, _no_endoso) returning _error,_error_desc;

   	FOREACH
		SELECT cod_contrato,
			   prima_rea
		  INTO _cod_contrato,		         
			   _prima_contrato
		  FROM tmp_reas
		 where prima_rea <> 0

		{SELECT e.cod_contrato,
		   	   e.prima
	      INTO _cod_contrato,		         
	           _prima_contrato
		  FROM emifacon	e, endeduni r
		 where e.no_poliza = r.no_poliza
		   and e.no_endoso = r.no_endoso
		   and e.no_unidad = r.no_unidad
		   and r.no_poliza = _no_poliza
		   and r.no_endoso = _no_endoso}

--		AND e.prima <> 0


	  SELECT tipo_contrato
	    INTO _tipo_contrato
	    FROM reacomae
	   WHERE cod_contrato = _cod_contrato;

		IF _tipo_contrato = 1 THEN 	-- Retencion

			let _total_prima_ret = _total_prima_ret + _prima_contrato;

			--CONTINUE FOREACH;
		END IF

		IF _tipo_contrato = 3 THEN 	-- Facultativo
		  LET _prima_facultativo = _prima_facultativo + _prima_contrato;
		ELSE						-- Otros Contratos
		  LET _prima_otros       = _prima_otros + _prima_contrato;
		END IF

	END FOREACH

	IF _total_prima_sus IS NULL THEN
		LET _total_prima_sus = 0;
	END IF

	-- Calculos para sacar la prima cedida
   --	LET _total_prima_ced = _total_prima_sus - _total_prima_ret;

		LET _total_prima_ced = _prima_facultativo + _prima_otros - _total_prima_ret;

	-- Informacion de Poliza
	SELECT sucursal_origen, 
	       cod_tipoprod, 
	       cod_ramo,	
	       cod_grupo,    
	       cod_subramo,
	       user_added
	  INTO _cod_sucursal, 
	       _cod_tipoprod, 
	       _cod_ramo,	
	       _cod_grupo,   
	       _cod_subramo,
	       _user_added
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

    SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	-- Insercion / Actualizacion a la tabla temporal tmp_prod

	INSERT INTO tmp_prod(
	no_poliza,
	cod_subramo,
	cod_ramo,
	cod_grupo,
	cod_agente,
	user_added,
	total_pri_sus,
	total_pri_ret,
	total_pri_ced,
	tipo_produccion,
	cod_sucursal,
	total_pri_otro,
	total_pri_facu,
	no_endoso
	)
	VALUES(
	_no_poliza,
	_cod_subramo,
	_cod_ramo,
	_cod_grupo,
	_cod_agente,
	_user_added,
	_total_prima_sus,
	_total_prima_ret,
	_total_prima_ced,
	_tipo_produccion,
	_cod_sucursal,
	_prima_otros,
	_prima_facultativo,
	_no_endoso
	);

END FOREACH;

-- Procesos para Filtros

LET v_filtros = "";

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
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal IN (SELECT codigo FROM tmp_codigos);

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

IF a_agente <> "*" THEN

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

   	LET v_filtros = TRIM(v_filtros) || " Corredor: " ||  TRIM(a_agente);


	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

RETURN v_filtros;

END PROCEDURE;
