-- Recibos en coaseguro mayoritario
-- Creado    : 30/10/2003 - Autor: Lic. Armando Moreno 
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_cob128;

CREATE PROCEDURE "informix".sp_cob128(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_periodo1 CHAR(7),
a_periodo2 CHAR(7),
a_ramo 	   CHAR(255) DEFAULT "*",
a_coasegur CHAR(255) DEFAULT "*"
)
RETURNING CHAR(10),
		  CHAR(30),
          CHAR(100), 
		  DATE,
          DECIMAL(16,2),
          DECIMAL(16,2),
          DECIMAL(16,2),
          DECIMAL(16,2),
          CHAR(50),
          CHAR(50),
          CHAR(255),
		  DATE,
		  DATE,
		  CHAR(3),
          DECIMAL(16,2),
		  DECIMAL(7,4),
		  DECIMAL(16,2),
		  DECIMAL(16,2),
		  DECIMAL(16,2),
		  CHAR(50),
		  DECIMAL(5,2),
		  DECIMAL(16,2),
		  DECIMAL(16,2);

DEFINE _prima_coas  	  DECIMAL(16,2);
DEFINE _porc_partic_coas  DECIMAL(7,4);
DEFINE _imp_1_coas  	  DECIMAL(16,2);
DEFINE _imp_5_coas  	  DECIMAL(16,2);
DEFINE _tot_pri_imp		  DECIMAL(16,2);
DEFINE v_nombre_ramo   	  CHAR(50);
DEFINE _no_remesa   	  CHAR(10);
DEFINE v_cod_tipoprod 	  CHAR(3);
DEFINE v_nombre_cliente   CHAR(100);
DEFINE v_imp_1			  DECIMAL(16,2);
DEFINE _factor_imp		  DECIMAL(16,2);
DEFINE v_imp_5			  DECIMAL(16,2);
DEFINE v_impuesto		  DECIMAL(16,2);
DEFINE v_prima_neta 	  DECIMAL(16,2);
DEFINE v_monto	 		  DECIMAL(16,2);
DEFINE v_compania_nombre  CHAR(50);
DEFINE v_nombre_cia_coas  CHAR(50);
DEFINE v_filtros          CHAR(255);
DEFINE v_cod_contratante  CHAR(10);
DEFINE v_no_documento     CHAR(30);
DEFINE v_no_recibo        CHAR(10);
DEFINE v_fecha		      DATE;
DEFINE _vigencia_inic     DATE;
DEFINE _vigencia_final    DATE;
DEFINE v_no_poliza		  CHAR(10);
DEFINE v_codramo		  CHAR(3);
DEFINE v_cod_impuesto	  CHAR(3);
DEFINE _cod_coasegur	  CHAR(3);
DEFINE _tipo              CHAR(1);
DEFINE _porc_comis_agt    DECIMAL(5,2);
DEFINE _porc_partic_agt   DECIMAL(5,2);
DEFINE _prima_agt		  DECIMAL(16,2);
define _prima_agt_f		  DECIMAL(16,2);
DEFINE _coas_neto_pagar	  DECIMAL(16,2);
DEFINE _ramo_sis		  SMALLINT;
DEFINE v_tipo_produccion  SMALLINT;
DEFINE _renglon			  SMALLINT;


SET ISOLATION TO DIRTY READ;

LET v_compania_nombre = sp_sis01(a_compania); -- Nombre de la Compania

--DROP TABLE tmp_prod;

CREATE TEMP TABLE tmp_prod(
		no_recibo   	CHAR(10)  NOT NULL,
		cod_ramo       	CHAR(3)   ,
		no_documento   	CHAR(20)  NOT NULL,
		cod_contratante CHAR(10)  ,
		fecha		 	DATE   	  NOT NULL,
		prima_neta      DECIMAL(16,2),
		imp1		    DECIMAL(16,2),
		imp5		    DECIMAL(16,2),
		monto	        DECIMAL(16,2),
		vigencia_inic	DATE,
		vigencia_final	DATE,
		porc_partic_coas decimal(7,4),
		cod_coasegur    CHAR(3),
		prima_coas		DECIMAL(16,2),
		imp_1_coas		DECIMAL(16,2),
		imp_5_coas		DECIMAL(16,2),
		tot_pri_imp		DECIMAL(16,2),
		porc_comis_agt  DECIMAL(5,2),
		prima_agt		DECIMAL(16,2),
		coas_neto_pagar DECIMAL(16,2),
		seleccionado   	SMALLINT  DEFAULT 1 NOT NULL
		) WITH NO LOG;

CREATE INDEX iend1_tmp_prod ON tmp_prod(cod_ramo);

--set debug file to "sp_cob128.trc";

FOREACH WITH HOLD
	-- Informacion de Poliza
	SELECT no_poliza,
		   no_recibo,
		   doc_remesa,
		   fecha,
		   prima_neta,
		   impuesto,
		   monto,
		   no_remesa,
		   renglon
	  INTO v_no_poliza,
	  	   v_no_recibo,
	  	   v_no_documento,
	  	   v_fecha,
	  	   v_prima_neta,
	  	   v_impuesto,
	  	   v_monto,
		   _no_remesa,
		   _renglon
	  FROM cobredet
	 WHERE periodo >= a_periodo1 and periodo <= a_periodo2
	   AND tipo_mov IN ("P","N")
	   AND renglon <> 0
	   AND actualizado = 1

    SELECT cod_contratante,
    	   cod_ramo,
    	   cod_tipoprod,
		   vigencia_inic,
		   vigencia_final
	  INTO v_cod_contratante,
	  	   v_codramo,
	  	   v_cod_tipoprod,
		   _vigencia_inic,
		   _vigencia_final
	  FROM emipomae
	 WHERE no_poliza = v_no_poliza;

    SELECT tipo_produccion
	  INTO v_tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = v_cod_tipoprod;

	 IF v_tipo_produccion <> 2 THEN
		 CONTINUE FOREACH;
	 END IF

	LET v_imp_1 = 0;
	LET v_imp_5 = 0;

	--BUSCAR LOS IMPUESTOS Y EFECTUAR OPERACION
    FOREACH
	    SELECT cod_impuesto
		  INTO v_cod_impuesto
		  FROM emipolim
		 WHERE no_poliza = v_no_poliza

	    SELECT factor_impuesto
		  INTO _factor_imp
		  FROM prdimpue
		 WHERE cod_impuesto = v_cod_impuesto;

		 IF _factor_imp = 1.00 THEN
		 	LET v_imp_1 = v_prima_neta * _factor_imp / 100;
		 ELIF _factor_imp = 5.00 THEN
		 	LET v_imp_5 = v_prima_neta * _factor_imp / 100;
		 END IF
	END FOREACH

 	LET _prima_coas  	 = 0;
 	LET _imp_1_coas  	 = 0;
 	LET _imp_5_coas  	 = 0;
	LET _tot_pri_imp 	 = 0;

    FOREACH
	    SELECT cod_coasegur,
			   porc_partic_coas
		  INTO _cod_coasegur,
			   _porc_partic_coas
		  FROM emicoama
		 WHERE no_poliza = v_no_poliza
		   AND cod_coasegur <> "036"

	 	LET _prima_coas  = v_prima_neta * _porc_partic_coas / 100;
	 	LET _imp_1_coas  = v_imp_1 * _porc_partic_coas / 100;
	 	LET _imp_5_coas  = v_imp_5 * _porc_partic_coas / 100;
		LET _tot_pri_imp = _prima_coas + _imp_1_coas + _imp_5_coas;
		LET _prima_agt   	 = 0;
		LET _coas_neto_pagar = 0;
		let _prima_agt_f     = 0;

	   foreach
			SELECT porc_comis_agt,
				   porc_partic_agt
			  INTO _porc_comis_agt,
				   _porc_partic_agt
			  FROM cobreagt
			 WHERE no_remesa = _no_remesa
			   AND renglon   = _renglon

			LET _prima_agt   = (_prima_coas * _porc_comis_agt / 100) * (_porc_partic_agt / 100);
			let _prima_agt_f = _prima_agt_f + _prima_agt;
	   end foreach

	  --LET _coas_neto_pagar = _coas_neto_pagar + _tot_pri_imp - _prima_agt;
		LET _coas_neto_pagar = _tot_pri_imp - _prima_agt_f;

		-- Insercion / Actualizacion a la tabla temporal tmp_prod
		INSERT INTO tmp_prod(
		no_recibo,
		cod_ramo,
		no_documento,
	 	cod_contratante,
	 	fecha,
	 	prima_neta,
	 	imp1,
	 	imp5,
	 	monto,
	 	seleccionado,
		vigencia_inic,
		vigencia_final,
		cod_coasegur,
		prima_coas,
		porc_partic_coas,
		imp_1_coas,
		imp_5_coas,
		tot_pri_imp,
		porc_comis_agt, 
		prima_agt,		
		coas_neto_pagar
		)
		VALUES(
		v_no_recibo,
		v_codramo,
		v_no_documento,
		v_cod_contratante,
		v_fecha,
		v_prima_neta,
		v_imp_1,
		v_imp_5,
		v_monto,
		1,
		_vigencia_inic,
		_vigencia_final,
		_cod_coasegur,
		_prima_coas,
		_porc_partic_coas,
		_imp_1_coas,
		_imp_5_coas,
		_tot_pri_imp,
		_porc_comis_agt, 
		_prima_agt_f,		
		_coas_neto_pagar
		);
	END FOREACH

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

IF a_coasegur <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Aseguradora: " ||  TRIM(a_coasegur);

	LET _tipo = sp_sis04(a_coasegur);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_coasegur NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_prod
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_coasegur IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF
--------------------------------------------------------------------------

--Recorre la tabla temporal y asigna valores a variables de salida

FOREACH WITH HOLD
	SELECT no_recibo,
			no_documento,
			cod_contratante,
			fecha,
			prima_neta,
			imp1,
			imp5,
			cod_ramo,
			monto,
			vigencia_inic,
			vigencia_final,
			cod_coasegur,
			prima_coas,
			porc_partic_coas,
			imp_1_coas,
			imp_5_coas,
			tot_pri_imp,
			porc_comis_agt, 
			prima_agt,		
			coas_neto_pagar
	  INTO v_no_recibo,
			v_no_documento,
			v_cod_contratante,
			v_fecha,
			v_prima_neta,
			v_imp_1,
			v_imp_5,
			v_codramo,
			v_monto,
			_vigencia_inic,
			_vigencia_final,
			_cod_coasegur,
			_prima_coas,
			_porc_partic_coas,
			_imp_1_coas,
			_imp_5_coas,
			_tot_pri_imp,
			_porc_comis_agt, 
			_prima_agt,		
			_coas_neto_pagar
	  FROM tmp_prod
	 WHERE seleccionado = 1

--Selecciona los nombres de Ramos
         SELECT	nombre
  	       INTO v_nombre_ramo
           FROM prdramo
          WHERE cod_ramo = v_codramo;

--Selecciona los nombres de Clientes
         SELECT	nombre
  	       INTO v_nombre_cliente
           FROM	cliclien
          WHERE cod_cliente = v_cod_contratante;

         SELECT	nombre
  	       INTO v_nombre_cia_coas
           FROM	emicoase
          WHERE cod_coasegur = _cod_coasegur;

RETURN    v_no_recibo,
   		  v_no_documento,
		  v_nombre_cliente,
		  v_fecha,
		  v_prima_neta,
		  v_imp_1,
		  v_imp_5,
		  v_monto,
		  v_nombre_ramo,
		  v_compania_nombre,
		  v_filtros,
		  _vigencia_inic,
		  _vigencia_final,
		  _cod_coasegur,
		  _prima_coas,
		  _porc_partic_coas,
		  _imp_1_coas,
		  _imp_5_coas,
		  _tot_pri_imp,
		  v_nombre_cia_coas,
		  _porc_comis_agt, 
		  _prima_agt,		
		  _coas_neto_pagar
		  WITH RESUME;
END FOREACH;
DROP TABLE tmp_prod;
END PROCEDURE;