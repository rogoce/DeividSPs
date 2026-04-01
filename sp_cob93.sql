-- Procedimiento que Genera las Polizas para informe de metas de cobros
-- 
-- Modificado: 01/11/2002 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob93;

CREATE PROCEDURE "informix".sp_cob93(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_fecha    DATE
)

DEFINE _cod_agente        CHAR(5);
DEFINE _no_poliza         CHAR(10); 
DEFINE _nombre_cliente    CHAR(100);
DEFINE _doc_poliza        CHAR(20); 
DEFINE _estatus,_gestion  CHAR(1); 
DEFINE _forma_pago        CHAR(2);
DEFINE _vigencia_inic     DATE;     
DEFINE _vigencia_final    DATE; 
DEFINE _prima_orig        DEC(16,2);
DEFINE _cod_cobrador      CHAR(3);
DEFINE _cod_sucursal      CHAR(3);
DEFINE _cod_ramo          CHAR(3);
DEFINE _no_unidad         CHAR(5);
define _cobra_poliza	  char(1);
	
DEFINE _fecha_canc        DATE;
DEFINE _fecha_primer_pago DATE;
DEFINE _fecha_ult_pago    DATE;

DEFINE _cod_cliente       CHAR(10); 
DEFINE _cod_formapag      CHAR(3);  
DEFINE _cod_acreedor      CHAR(5);
DEFINE _cod_coasegur,_cod_perpago 	  CHAR(3);
DEFINE _nombre_coasegur   CHAR(50);

DEFINE _cod_tipoprod1     CHAR(3);
DEFINE _cod_tipoprod2     CHAR(3);
DEFINE _mes_contable      CHAR(2);
DEFINE _ano_contable      CHAR(4);
DEFINE _periodo           CHAR(7);

DEFINE _porcentaje        DEC(16,2);
DEFINE _poliza_saldo      DEC(16,2);
DEFINE _poliza_ult_pago   DATE;

DEFINE _prima_orig_tot    DEC(16,2);
DEFINE _monto_pagado      DEC(16,2);
DEFINE _prima_mensual     DEC(16,2);
DEFINE _no_pagos     	  SMALLINT;
DEFINE v_exigible,_por_vencer_tot     DEC(16,2);
DEFINE v_corriente,_saldo_tot         DEC(16,2);
DEFINE v_monto_30          DEC(16,2);
DEFINE v_monto_60          DEC(16,2);
DEFINE v_monto_90          DEC(16,2);

-- Filtros
DEFINE _nombre_acreedor   CHAR(50);
DEFINE _count,i,a,_meses,_mes_primer_pago,_mes_hasta,_ano_hasta,_ano INTEGER;

LET _count = 0;
let _cobra_poliza = "";

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03.trc";

-- Tabla Temporal 

--DROP TABLE tmp_moros;

CREATE TEMP TABLE tmp_moros(
		cod_agente		CHAR(5)		NOT NULL,
		no_poliza       CHAR(10)	NOT NULL,
		nombre_cliente  CHAR(100)	NOT NULL,
		doc_poliza      CHAR(20),
		forma_pago      CHAR(2)		NOT NULL,
		vigencia_inic   DATE,
		vigencia_final  DATE,
		prima_orig      DEC(16,2)	DEFAULT 0 NOT NULL,
		prima_mensual   DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_pagado    DEC(16,2)	DEFAULT 0 NOT NULL, 
		cod_cobrador    CHAR(3)     NOT NULL,
		cod_sucursal    CHAR(3)     NOT NULL,
		cod_acreedor    CHAR(5)     NOT NULL,
		cod_formapag    CHAR(3),
		cod_cliente     CHAR(5)	    NOT NULL,
		cod_coasegur    CHAR(3),
		cod_ramo        CHAR(3),
		no_pagos	    SMALLINT    DEFAULT 0 NOT NULL,
		seleccionado    SMALLINT    DEFAULT 1 NOT NULL,
		exigible      	DEC(16,2),
		corriente     	DEC(16,2),
		monto_30      	DEC(16,2),
		monto_60      	DEC(16,2),
		monto_90      	DEC(16,2),
		gestion		  	CHAR(1)		NOT NULL,
		PRIMARY KEY (no_poliza)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_moros ON tmp_moros(cod_sucursal);
CREATE INDEX xie02_tmp_moros ON tmp_moros(cod_cobrador);

-- Se Determina el Codigo de Coaseguro Mayoritario o Sin Coaseguro
-- Se Evita Hacer 'JOINS' por Cuestion de 'PERFORMANCE' de la Base de Datos

SET ISOLATION TO DIRTY READ;

SELECT cod_tipoprod
  INTO _cod_tipoprod1
  FROM emitipro
 WHERE tipo_produccion = 1;	-- Coaseguro Mayoritario

SELECT cod_tipoprod
  INTO _cod_tipoprod2
  FROM emitipro
 WHERE tipo_produccion = 2;	-- Sin Coaseguro

-- Periodo de Seleccion
-- Se Filtran los Registros por Fecha y Periodo Contable

LET _ano_contable = YEAR(a_fecha);

IF MONTH(a_fecha) < 10 THEN
	LET _mes_contable = '0' || MONTH(a_fecha);
ELSE
	LET _mes_contable = MONTH(a_fecha);
END IF

LET _periodo = _ano_contable || '-' || _mes_contable;
											 
-- Seleccion de la Polizas
FOREACH 
 SELECT no_documento
   INTO	_doc_poliza
   FROM emipomae 
  WHERE cod_compania       = a_compania		   -- Seleccion por Compania
    AND actualizado        = 1			   	   -- Poliza este actualizada
	AND incobrable         <> 1			   	   -- excluye incobrables
	AND (cod_tipoprod      = _cod_tipoprod1 OR -- Coaseguro Mayoritario
	     cod_tipoprod      = _cod_tipoprod2)   -- Sin Coaseguro
  GROUP BY no_documento

  FOREACH 
	 SELECT no_poliza,
			cod_contratante,
			no_documento,
			estatus_poliza,
			cod_formapag,
			vigencia_inic,
			vigencia_final,
			saldo,
			fecha_ult_pago,
			fecha_cancelacion,
			cod_sucursal,
			prima_bruta,
			cod_ramo,
			no_pagos,
			fecha_primer_pago,
			cod_perpago,
			gestion,
			cobra_poliza
	   INTO	_no_poliza,     
			_cod_cliente,   
			_doc_poliza,    
			_estatus,       
			_cod_formapag,  
			_vigencia_inic, 
			_vigencia_final,
			_poliza_saldo,
			_poliza_ult_pago,
			_fecha_canc,
			_cod_sucursal,
			_prima_orig_tot,
			_cod_ramo,
			_no_pagos,
			_fecha_primer_pago,
			_cod_perpago,
			_gestion,
			_cobra_poliza
	   FROM emipomae 
	  WHERE no_documento       = _doc_poliza
		AND actualizado        = 1			   	   -- Poliza este actualizada
		AND (cod_tipoprod      = _cod_tipoprod1 OR -- Coaseguro Mayoritario
		     cod_tipoprod      = _cod_tipoprod2)   -- Sin Coaseguro
	  ORDER BY vigencia_final DESC
		EXIT FOREACH;
  END FOREACH

  if _cobra_poliza <> "C" then
  	continue foreach;
  end if

-- Selecciona el Primer Acreedor de la Poliza

	LET _nombre_acreedor = '... SIN ACREEDOR ...';
	LET _cod_acreedor    = '';

	FOREACH
	 SELECT	cod_acreedor,	no_unidad
	   INTO	_cod_acreedor,	_no_unidad
	   FROM emipoacr
	  WHERE	no_poliza = _no_poliza
	  ORDER BY no_unidad

		IF _cod_acreedor IS NOT NULL THEN

			SELECT nombre
			  INTO _nombre_acreedor
			  FROM emiacre
			 WHERE cod_acreedor = _cod_acreedor;

			EXIT FOREACH;
		END IF
	END FOREACH

	IF _cod_acreedor IS NULL THEN
		LET _cod_acreedor = '';
	END	IF

	IF _gestion IS NULL THEN
		LET _gestion = 'P';
	END IF

-- Compania Coaseguradora
	SELECT cod_coasegur
	  INTO _cod_coasegur
	  FROM emicoami
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO _nombre_coasegur
	  FROM emicoase
	 WHERE cod_coasegur = _cod_coasegur;

	IF _nombre_coasegur IS NULL THEN
		LET _nombre_coasegur = '... Aseguradora Incorrecta ...';
	END IF		

	-- Si la poliza se cancelo en la fecha pedida
	-- no se debe tomar en cuenta
	{IF _fecha_canc IS NOT NULL THEN
  		IF _fecha_canc <= a_fecha THEN
			CONTINUE FOREACH;
	  	END IF
	END IF}

	-- Se determina la fecha del ultimo pago

	LET _fecha_ult_pago = NULL;

	-- Se determina la morosidad para la poliza
   CALL sp_cob33(
        a_compania, 
        a_agencia, 
        _doc_poliza,
		_periodo,
        a_fecha 
        ) RETURNING _por_vencer_tot,    
					v_exigible,
					v_corriente,    
					v_monto_30,      
					v_monto_60,      
					v_monto_90,
					_saldo_tot;
	-- Se excluyen polizas con saldo cero
	IF _saldo_tot = 0 THEN
  		CONTINUE FOREACH;
	END IF

	SELECT SUM(b.monto)
	  INTO _monto_pagado
	  FROM cobredet b
	 WHERE b.no_poliza = _no_poliza
	   AND b.actualizado = 1
	   AND b.tipo_mov = 'P'
	   AND b.periodo = _periodo;

	 IF _monto_pagado IS NULL THEN
		LET _monto_pagado = 0;
	 END IF

	-- Lectura de Tablas Relacionadas

	SELECT nombre
	  INTO _nombre_cliente
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;
	 
	SELECT nombre
	  INTO _forma_pago
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

	IF _forma_pago IS NULL THEN
		LET _forma_pago = '';
	END IF

	-- Determina todos los agentes de la poliza

	FOREACH 
	 SELECT	cod_agente
	   INTO	_cod_agente
	   FROM emipoagt
	  WHERE	no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH

		SELECT cod_cobrador
		  INTO _cod_cobrador
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

		-- periodo de pago
		SELECT meses
		  INTO _meses
		  FROM cobperpa
		 WHERE cod_perpago = _cod_perpago;

		-- sacar la prima mensual
		 IF _prima_orig_tot IS NULL THEN
			LET _prima_orig_tot = 0;
		 END IF
		 --prima bruta / no. de pagos
		 LET _prima_mensual = _prima_orig_tot / _no_pagos;

		 LET _mes_primer_pago =	MONTH(_fecha_primer_pago);
		 LET _ano			  =	YEAR(_fecha_primer_pago);
		 LET _mes_hasta       =	MONTH(a_fecha);
		 LET _ano_hasta       =	YEAR(a_fecha);

		 LET a = _mes_primer_pago;

		 IF _no_pagos IS NULL THEN
			LET _no_pagos = 0;
		 END IF

	 FOR i = 1 TO _no_pagos
	 	IF (a = _mes_hasta) AND (_ano = _ano_hasta) THEN
			INSERT INTO tmp_moros(
			cod_agente,
			no_poliza,      
			nombre_cliente, 
			doc_poliza,     
			forma_pago,     
			vigencia_inic,  
			vigencia_final, 
			prima_orig,
			prima_mensual,
			monto_pagado,
			cod_cobrador,
			cod_sucursal,
			cod_acreedor,
			cod_formapag,
			cod_cliente,
			cod_coasegur,
			cod_ramo,
			no_pagos,
			exigible,       
			corriente,     
			monto_30,       
			monto_60,       
			monto_90,
			gestion
			)
			VALUES(
			_cod_agente,
			_no_poliza,      
			_nombre_cliente, 
			_doc_poliza,     
			_forma_pago,     
			_vigencia_inic,  
			_vigencia_final, 
			_prima_orig_tot,    
			_prima_mensual,
			_monto_pagado,
			_cod_cobrador,
			_cod_sucursal,
			_cod_acreedor,
			_cod_formapag,
			_cod_cliente,
			_cod_coasegur,
			_cod_ramo,
			_no_pagos,
			v_exigible,       
			v_corriente,     
			v_monto_30,       
			v_monto_60,       
			v_monto_90,
			_gestion
			);
			EXIT FOR;
		END IF
		LET a = a + _meses;
		IF a > 12 THEN
			IF a = 13 THEN
			   LET a = 1;
			ELIF a = 14 THEN
			   LET a = 2;
			ELIF a = 15 THEN
			   LET a = 3;
			ELIF a = 16 THEN
			   LET a = 4;
			ELIF a = 17 THEN
			   LET a = 5;
			ELIF a = 18 THEN
			   LET a = 6;
			ELIF a = 19 THEN
			   LET a = 7;
			ELIF a = 20 THEN
			   LET a = 8;
			ELIF a = 21 THEN
			   LET a = 9;
			ELIF a = 22 THEN
			   LET a = 10;
			ELIF a = 23 THEN
			   LET a = 11;
			ELIF a = 24 THEN
			   LET a = 12;
			END IF
			LET _ano = _ano + 1;
		END IF
	 END FOR
END FOREACH
END PROCEDURE;

