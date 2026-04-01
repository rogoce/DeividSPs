-- Procedimiento que Carga las Primas de Produccion
-- en un Periodo Dado
--
-- Creado    : 08/08/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 08/08/2000 - Autor: Lic. Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro112;

CREATE PROCEDURE "informix".sp_pro112(
        a_compania     CHAR(3), 
        a_agencia      CHAR(3), 
        a_periodo1     CHAR(7),
        a_periodo2     CHAR(7),
		a_sucursal     CHAR(255)  DEFAULT "*",
		a_ramo         CHAR(255)  DEFAULT "*",
		a_grupo        CHAR(255)  DEFAULT "*",
		a_agente       CHAR(255)  DEFAULT "*"
        ) RETURNING CHAR(255);

DEFINE _no_poliza,_no_factura 		 CHAR(10);
DEFINE v_codigo 		 CHAR(10);
DEFINE v_desc_agen		 CHAR(50);
DEFINE _no_endoso 		 CHAR(5);
DEFINE v_saber	 		 CHAR(3);
DEFINE _periodo      	 CHAR(7);
DEFINE _cod_ramo,_cod_origen CHAR(3); 
DEFINE _cod_sucursal     CHAR(3);
DEFINE _cod_grupo  		 CHAR(5); 
DEFINE _cod_contrato	 CHAR(5); 
DEFINE _cod_subramo  	 CHAR(3);
DEFINE _cod_agente       CHAR(5);
DEFINE _no_unidad        CHAR(5);
DEFINE _cod_tipoprod     CHAR(3);
DEFINE _cod_cober_reas   CHAR(3);
DEFINE _tipo_produccion  CHAR(1);
DEFINE v_porc_comis,_porc_partic_agt		 DECIMAL(5,2);
DEFINE _porc_comis_rea	   DECIMAL(5,2);
DEFINE _porc_comis_fac_rea DECIMAL(5,2);
DEFINE _total_prima_sus,_comis_fac,_comis_otr DECIMAL(16,2);
DEFINE v_comision		 DECIMAL(16,2);
DEFINE _total_prima_ret  DECIMAL(16,2);
DEFINE _total_prima_ced  DECIMAL(16,2);
DEFINE _impuesto		 DECIMAL(16,2);
DEFINE _prima_facultativo DECIMAL(16,2);
DEFINE _prima_contrato   DECIMAL(16,2);
DEFINE _monto,_monto2,_monto3	 DECIMAL(16,2);
DEFINE t_total_prima_sus DECIMAL(16,2);
DEFINE t_total_prima_ret,t_total_prima_ced,_cont_fac,_cont_otros DECIMAL(16,2);
DEFINE _total_prima_neta_ret DECIMAL(16,2);
DEFINE v_filtros         CHAR(255);
DEFINE _tipo             CHAR(1);
DEFINE _tipo_contrato,_imp_gob,_orden,_aplica_impuesto    SMALLINT;
	
-- Tabla Temporal tmp_prod

CREATE TEMP TABLE tmp_prod3(
		no_poliza      			CHAR(10)  NOT NULL,
		cod_ramo       			CHAR(3)   NOT NULL,
		prima_otr				DEC(16,2) DEFAULT 0 NOT NULL,
		prima_fac				DEC(16,2) DEFAULT 0 NOT NULL,
		no_factura				CHAR(10)  NOT NULL,
		cod_contrato  			CHAR(5)   ,
		porc_fac				DEC(5,2)  DEFAULT 0 NOT NULL,
		porc_otr				DEC(5,2)  DEFAULT 0 NOT NULL,
		periodo  			    CHAR(7)   NOT NULL,
		cod_agente				CHAR(5)   ,
		comis_otr				DEC(16,2) DEFAULT 0 NOT NULL,
		comis_fac				DEC(16,2) DEFAULT 0 NOT NULL,
		seleccionado   			SMALLINT  DEFAULT 1 NOT NULL
		) WITH NO LOG;

CREATE INDEX iend1_tmp_prod3 ON tmp_prod3(cod_ramo);

SET ISOLATION TO DIRTY READ;

LET _cod_agente = "*";

let _porc_comis_fac_rea = 0;

FOREACH WITH HOLD
  SELECT no_poliza,	
         no_endoso, 	
         prima_suscrita,	 
         prima_retenida,
		 no_factura,
		 periodo
    INTO _no_poliza,		         
         _no_endoso, 	
         _total_prima_sus,	 
         _total_prima_ret,
		 _no_factura,
		 _periodo
    FROM endedmae
   WHERE periodo BETWEEN a_periodo1 AND a_periodo2
     AND actualizado = 1

	SELECT cod_ramo
	  INTO _cod_ramo
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

FOREACH
       SELECT cod_agente
         INTO _cod_agente
         FROM emipoagt
        WHERE no_poliza = _no_poliza

		EXIT FOREACH;
END FOREACH

	LET v_comision   = 0.00;
	LET _monto2      = 0.00;
	LET _monto3      = 0.00;
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

		let _comis_otr = 0;
		let _comis_fac = 0;

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

		    Let _comis_otr = _prima_contrato * _porc_comis_rea / 100;

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

                    if _porc_comis_fac_rea is null then
						let _porc_comis_fac_rea = 0;
					end if

				    Let _comis_fac = _monto * _porc_comis_fac_rea / 100;

						INSERT INTO tmp_prod3(
						no_poliza,
						no_factura,
						cod_contrato,
						porc_fac,
						porc_otr,
						prima_fac,
						prima_otr,
						cod_ramo,
						periodo,
						comis_fac,
						comis_otr,
						cod_agente
						)
						VALUES(
						_no_poliza,
						_no_factura,
						_cod_contrato,
						_porc_comis_fac_rea,
						0,
						_monto,
						0,
						_cod_ramo,
						_periodo,
						_comis_fac,
						0,
						_cod_agente
						);
				End Foreach
			ELSE
				INSERT INTO tmp_prod3(
				no_poliza,
				no_factura,
				cod_contrato,
				porc_fac,
				porc_otr,
				prima_fac,
				prima_otr,
				cod_ramo,
				periodo,
				comis_fac,
				comis_otr,
				cod_agente
				)
				VALUES(
				_no_poliza,
				_no_factura,
				_cod_contrato,
				0,
				_porc_comis_rea,
				0,
				_prima_contrato,
				_cod_ramo,
				_periodo,
				0,
				_comis_otr,
				_cod_agente
				);
			END IF
		END IF

	END FOREACH

END FOREACH;

-- Procesos para Filtros

LET v_filtros = "";

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

	   UPDATE tmp_prod3
	   	  SET seleccionado = 0
		WHERE seleccionado = 1
		  AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

	   UPDATE tmp_prod3
	   	  SET seleccionado = 0
		WHERE seleccionado = 1
		  AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_agente <> "*" THEN

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

   	LET v_filtros = TRIM(v_filtros) || " Corredor: "; --||  TRIM(a_agente);


	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_prod3
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = "";
	ELSE		        -- Excluir estos Registros

		UPDATE tmp_prod3
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