-- Procedimiento que Carga las Primas de Produccion
-- en un Periodo Dado
--
-- Creado    : 08/08/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 08/08/2000 - Autor: Lic. Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro109;

CREATE PROCEDURE "informix".sp_pro109(
        a_compania     CHAR(3), 
        a_agencia      CHAR(3), 
        a_periodo1     CHAR(7),
        a_periodo2     CHAR(7),
		a_sucursal     CHAR(255)  DEFAULT "*",
		a_ramo         CHAR(255)  DEFAULT "*",
		a_grupo        CHAR(255)  DEFAULT "*",
		a_agente       CHAR(255)  DEFAULT "*"
        ) RETURNING CHAR(255);

DEFINE _no_poliza 		 CHAR(10);
DEFINE v_codigo 		 CHAR(10);
DEFINE v_desc_agen		 CHAR(50);
DEFINE _no_endoso 		 CHAR(5);
DEFINE v_saber	 		 CHAR(3);
DEFINE _periodo      	 CHAR(7);
DEFINE _cod_ramo    	 CHAR(3); 
DEFINE _cod_sucursal     CHAR(3);
DEFINE _cod_grupo  		 CHAR(5); 
DEFINE _cod_contrato	 CHAR(5); 
DEFINE _cod_subramo  	 CHAR(3);
DEFINE _cod_agente       CHAR(5);
DEFINE _no_unidad        CHAR(5);
DEFINE _cod_tipoprod     CHAR(3);
DEFINE _cod_cober_reas   CHAR(3);
DEFINE _cod_origen       CHAR(3);
DEFINE _tipo_produccion  CHAR(1);
DEFINE v_porc_comis,_porc_partic_agt		 DECIMAL(5,2);
DEFINE _porc_comis_rea	   DECIMAL(5,2);
DEFINE _porc_comis_fac_rea DECIMAL(5,2);
DEFINE _total_prima_sus    DECIMAL(16,2);
DEFINE v_comision		 DECIMAL(16,2);
DEFINE _total_prima_ret  DECIMAL(16,2);
DEFINE _total_prima_ced  DECIMAL(16,2);
DEFINE _impuesto		 DECIMAL(16,2);
DEFINE _prima_facultativo DECIMAL(16,2);
DEFINE _prima_otros      DECIMAL(16,2);
DEFINE _prima_contrato   DECIMAL(16,2);
DEFINE _monto,_monto2	 DECIMAL(16,2);
DEFINE t_total_prima_sus DECIMAL(16,2);
DEFINE t_total_prima_ret,t_total_prima_ced,_cont_fac,_cont_otros DECIMAL(16,2);
DEFINE _total_prima_neta_ret DECIMAL(16,2);
DEFINE v_filtros         CHAR(255);
DEFINE _tipo             CHAR(1);
DEFINE _tipo_contrato,_imp_gob,_orden,_aplica_impuesto  SMALLINT;
define _no_factura		char(10);
	
-- Tabla Temporal tmp_prod

CREATE TEMP TABLE tmp_prod(
		no_poliza      			CHAR(10)  NOT NULL,
		cod_sucursal   			CHAR(3)   NOT NULL,
		cod_subramo	   			CHAR(3)   NOT NULL,
		cod_ramo       			CHAR(3)   NOT NULL,
		cod_grupo	   			CHAR(5)   NOT NULL,
		cod_agente     			CHAR(5)   NOT NULL,
		tipo_produccion 		CHAR(1),
		total_pri_sus  			DEC(16,2) NOT NULL,
		total_pri_ret  			DEC(16,2) NOT NULL,
		total_pri_ced  			DEC(16,2) NOT NULL,
		total_prima_neta_ret 	DEC(16,2) NOT NULL,
		comision_corredor 		DEC(16,2) NOT NULL,
		impuesto		 		DEC(16,2) NOT NULL,
		comision_rea_ced 		DEC(16,2) NOT NULL,
		cont_facultativo		DEC(16,2) DEFAULT 0 NOT NULL,
		cont_otros				DEC(16,2) DEFAULT 0 NOT NULL,
		seleccionado   			SMALLINT  DEFAULT 1 NOT NULL,
		no_factura				char(10)
		) WITH NO LOG;

CREATE INDEX iend1_tmp_prod ON tmp_prod(cod_ramo);
CREATE INDEX iend2_tmp_prod ON tmp_prod(cod_grupo);
CREATE INDEX iend3_tmp_prod ON tmp_prod(cod_sucursal);
CREATE INDEX iend4_tmp_prod ON tmp_prod(tipo_produccion);
CREATE INDEX iend5_tmp_prod ON tmp_prod(cod_agente);

--set debug file to "sp_pro109.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

LET _cod_agente = "*";

FOREACH WITH HOLD
  SELECT no_poliza,	
         no_endoso, 	
         prima_suscrita,	 
         prima_retenida,
		 no_factura
    INTO _no_poliza,		         
         _no_endoso, 	
         _total_prima_sus,	 
         _total_prima_ret,
		 _no_factura
    FROM endedmae
   WHERE periodo BETWEEN a_periodo1 AND a_periodo2
     AND actualizado = 1
--	 and no_factura = "01-203349"

	LET _prima_otros = 0.00;
	LET v_comision   = 0.00;
	LET _monto2      = 0.00;
	LET _cont_fac	 = 0.00;
	LET _cont_otros  = 0.00;
	
	LET _total_prima_ced = _total_prima_sus - _total_prima_ret;  

	--Lectura de la distribucion de reaseguro por contrato y factura
	FOREACH
	  SELECT cod_contrato,
	         prima,
			 cod_cober_reas,
			 no_unidad,
			 orden
	    INTO _cod_contrato,		         
	         _prima_contrato,
		     _cod_cober_reas,
			 _no_unidad,
			 _orden
	    FROM emifacon
	   WHERE no_poliza = _no_poliza
	     AND no_endoso = _no_endoso

	  SELECT tipo_contrato
	    INTO _tipo_contrato
	    FROM reacomae
	   WHERE cod_contrato = _cod_contrato;

		IF _tipo_contrato = 1 THEN 	-- Retencion
		  CONTINUE FOREACH;
		ELSE
			Select porc_comision	--%comision reaseg cedido
			  Into _porc_comis_rea
			  From reacocob
			 Where cod_contrato   = _cod_contrato
			   And cod_cober_reas = _cod_cober_reas;

			If _porc_comis_rea is null THEN
				LET _porc_comis_rea = 0;
			End If

			-- Para los Contratos Facultativos
			IF _tipo_contrato = 3 THEN
				Foreach
					Select prima,
						   porc_comis_fac
				      Into _monto,
					   	   _porc_comis_fac_rea
					  From emifafac
					 Where no_poliza      = _no_poliza
					   And no_endoso      = _no_endoso
					   And no_unidad      = _no_unidad
					   And cod_cober_reas = _cod_cober_reas
					   And orden		  = _orden

					   Let _cont_fac = _cont_fac + _monto;
					   Let _monto2 = _monto2 + (_monto * _porc_comis_fac_rea / 100);
				End Foreach
			ELSE
			   Let _monto2 = _monto2 + (_prima_contrato * _porc_comis_rea / 100);
			   Let _cont_otros = _cont_otros + _prima_contrato;
			END IF
		  LET _prima_otros = _prima_otros + _prima_contrato;
		END IF

	END FOREACH

	IF _total_prima_sus IS NULL THEN
		LET _total_prima_sus = 0;
	END IF

	-- Calculos para sacar la prima neta retenida
--	LET _total_prima_neta_ret = _total_prima_sus - _prima_otros;

	-- Informacion de Poliza
	SELECT sucursal_origen, 
	       cod_tipoprod, 
	       cod_ramo,	
	       cod_grupo,    
	       cod_subramo,
		   cod_origen
	  INTO _cod_sucursal, 
	       _cod_tipoprod, 
	       _cod_ramo,	
	       _cod_grupo,   
	       _cod_subramo,
		   _cod_origen
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	IF _cod_origen IS NULL THEN
		LET _cod_origen = "001"; --LOCAL
	END IF

    SELECT aplica_impuesto
	  INTO _aplica_impuesto
	  FROM parorig
	 WHERE cod_origen = _cod_origen;

    SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	--saber si ramo paga 2% de imp al gobierno
    SELECT imp_gob
	  INTO _imp_gob
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	LET _impuesto = 0;

	IF _imp_gob = 1 THEN
		IF _aplica_impuesto = 1 THEN
		   LET _impuesto = _total_prima_sus * 0.02;
		END IF
	END IF

	--buscar comision de corredores y calculo de dicha comision
	LET t_total_prima_sus = 0;
    FOREACH
       SELECT cod_agente,
       		  porc_comis_agt,
			  porc_partic_agt
         INTO _cod_agente,
         	  v_porc_comis,
			  _porc_partic_agt
         FROM emipoagt
        WHERE no_poliza = _no_poliza

       IF _cod_agente IS NULL THEN
          CONTINUE FOREACH;
       END IF

	   LET t_total_prima_sus  = _porc_partic_agt * _total_prima_sus / 100;
	   LET t_total_prima_ret  = _porc_partic_agt * _total_prima_ret / 100;
	   LET t_total_prima_ced  = _porc_partic_agt * _total_prima_ced / 100;

       LET v_comision            = t_total_prima_sus * v_porc_comis / 100;
       LET _total_prima_neta_ret = t_total_prima_sus - t_total_prima_ced;

		-- Insercion / Actualizacion a la tabla temporal tmp_prod
		INSERT INTO tmp_prod(
		no_poliza,
		cod_subramo,
		cod_ramo,
		cod_grupo,
		cod_agente,
		total_pri_sus,
		total_pri_ret,
		total_pri_ced,
		tipo_produccion,
		cod_sucursal,
		total_prima_neta_ret,
		comision_corredor,
		impuesto,
		comision_rea_ced,
		no_factura
		)
		VALUES(
		_no_poliza,
		_cod_subramo,
		_cod_ramo,
		_cod_grupo,
		_cod_agente,
		t_total_prima_sus,
		0,
		t_total_prima_ced,
		_tipo_produccion,
		_cod_sucursal,
		_total_prima_neta_ret,
		v_comision,
		0,
		0,
		_no_factura
		);
    END FOREACH;
		-- Insercion / Actualizacion a la tabla temporal tmp_prod
		if _monto2 is null then
			let _monto2 = 0;
		end if

		INSERT INTO tmp_prod(
		no_poliza,
		cod_subramo,
		cod_ramo,
		cod_grupo,
		cod_agente,
		total_pri_sus,
		total_pri_ret,
		total_pri_ced,
		tipo_produccion,
		cod_sucursal,
		total_prima_neta_ret,
		comision_corredor,
		impuesto,
		comision_rea_ced,
		cont_facultativo,
		cont_otros,
		no_factura
		)
		VALUES(
		_no_poliza,
		_cod_subramo,
		_cod_ramo,
		_cod_grupo,
		_cod_agente,
		0,
		0,
		0,
		_tipo_produccion,
		_cod_sucursal,
		0,
		0,
		_impuesto,
		_monto2,
		_cont_fac,
		_cont_otros,
		_no_factura
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

IF a_agente <> "*" THEN

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

   	LET v_filtros = TRIM(v_filtros) || " Corredor: "; --||  TRIM(a_agente);


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
	      INTO v_desc_agen,v_codigo
	      FROM agtagent,tmp_codigos
	     WHERE agtagent.cod_agente = codigo
	     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_agen) || (v_saber);
    END FOREACH

	DROP TABLE tmp_codigos;

END IF

RETURN v_filtros;

END PROCEDURE;