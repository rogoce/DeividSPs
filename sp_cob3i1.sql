-- Procedimiento que Genera la Morosidad de Cartera
-- 
-- Creado    : 08/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 23/07/2001 - Autor: Armando Moreno
-- Modificado: 21/05/2002 - Autor: Amado Perez -- se agrega campo no_pagos
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob3i1;		

CREATE PROCEDURE "informix".sp_cob3i1(
a_compania   CHAR(3),
a_agencia    CHAR(3),
a_fecha      DATE,   
a_tipo_moros CHAR(1) DEFAULT '1' 
) 
--RETURNING CHAR(20);

DEFINE _cod_agente,_cod_producto  CHAR(5); 
DEFINE _no_poliza         CHAR(10); 
DEFINE _nombre_cliente    CHAR(100);
DEFINE _doc_poliza        CHAR(20); 
DEFINE _estatus, _seleccionado    CHAR(1); 
DEFINE _forma_pago        CHAR(4);
DEFINE _vigencia_inic     DATE;     
DEFINE _vigencia_final    DATE; 
DEFINE _fecha_ult_pago    DATE;
DEFINE _monto_ult_pago    DEC(16,2);    
DEFINE _prima_orig        DEC(16,2);
DEFINE _saldo             DEC(16,2);
DEFINE _por_vencer        DEC(16,2);
DEFINE _exigible          DEC(16,2);
DEFINE _corriente         DEC(16,2);
DEFINE _monto_30          DEC(16,2);
DEFINE _monto_60          DEC(16,2);
DEFINE _monto_90          DEC(16,2);
DEFINE _nombre_agente	  CHAR(50);
DEFINE _telefono          CHAR(10);
DEFINE _cod_cobrador      CHAR(3);
DEFINE _cod_vendedor      CHAR(3);
DEFINE _nombre_acreedor	  CHAR(50);
DEFINE _nombre_coasegur	  CHAR(50);

DEFINE _cod_cliente       CHAR(10); 
DEFINE _cod_formapag      CHAR(3);  
DEFINE _cod_coasegur      CHAR(3);
DEFINE _cod_acreedor      CHAR(5);
DEFINE _cod_sucursal      CHAR(3);
DEFINE _cod_ramo          CHAR(3);

DEFINE _cod_tipoprod1     CHAR(3);
DEFINE _cod_tipoprod2     CHAR(3);
DEFINE _cod_tipoprod      CHAR(3);
DEFINE _mes_contable      CHAR(2);
DEFINE _ano_contable      CHAR(4);
DEFINE _periodo           CHAR(7);
DEFINE _porcentaje        DEC(16,2);
DEFINE _poliza_saldo      DEC(16,2);
DEFINE _poliza_ult_pago   DATE;
DEFINE _no_unidad         CHAR(5);
DEFINE _cod_tipo_pol	  CHAR(3);	
DEFINE _no_pagos          SMALLINT;


DEFINE _prima_orig_tot    DEC(16,2);
DEFINE _saldo_tot         DEC(16,2);
DEFINE _por_vencer_tot    DEC(16,2);
DEFINE _exigible_tot      DEC(16,2);
DEFINE _corriente_tot     DEC(16,2);
DEFINE _monto_30_tot      DEC(16,2);
DEFINE _monto_60_tot      DEC(16,2);
DEFINE _monto_90_tot      DEC(16,2);
DEFINE _incobrable		  INTEGER;
DEFINE _apartado2         CHAR(20);
DEFINE _count             INTEGER;
DEFINE _cnt_por_vencer   SMALLINT;
DEFINE _cnt_exigible	 SMALLINT;
DEFINE _cnt_corriente	 SMALLINT;
DEFINE _cnt_monto_30	 SMALLINT;
DEFINE _cnt_monto_60	 SMALLINT;
DEFINE _cnt_monto_90	 SMALLINT;

DEFINE _fax, _telefono1, _telefono2 CHAR(10);
DEFINE _apartado, _e_mail CHAR(20); 


LET _count = 0;

SET ISOLATION TO DIRTY READ;

-- Tabla Temporal 

--DROP TABLE tmp_moros;

CREATE TEMP TABLE tmp_moros(
		cod_agente		CHAR(5)		NOT NULL,
		no_poliza       CHAR(10)	NOT NULL,
		nombre_cliente  CHAR(100)	NOT NULL,
		doc_poliza      CHAR(20),
		estatus         CHAR(1)     NOT NULL,
		forma_pago      CHAR(4)		NOT NULL,
		vigencia_inic   DATE,
		vigencia_final  DATE,
		fecha_ult_pago  DATE,
		monto_ult_pago  DEC(16,2),
		prima_orig      DEC(16,2)	DEFAULT 0 NOT NULL,
		saldo           DEC(16,2)	DEFAULT 0 NOT NULL,
		por_vencer      DEC(16,2)	DEFAULT 0 NOT NULL,
		exigible        DEC(16,2)	DEFAULT 0 NOT NULL,
		corriente       DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_30        DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_60        DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_90        DEC(16,2)	DEFAULT 0 NOT NULL, 
		nombre_agente   CHAR(50)	NOT NULL,
		telefono		CHAR(10),
		cod_cobrador    CHAR(3)     NOT NULL,
		cod_vendedor    CHAR(3)     NOT NULL,
		nombre_acreedor CHAR(50),
		seleccionado    SMALLINT    DEFAULT 1 NOT NULL,
		cod_sucursal    CHAR(3)     NOT NULL,
		cod_acreedor    CHAR(5),
		cod_ramo        CHAR(3),
		cod_formapago   CHAR(3),
		no_pagos        SMALLINT,
		cod_cliente     CHAR(10),
		incobrable		INTEGER,
		cod_coasegur	CHAR(3),
		apartado        CHAR(20),
		cod_producto	CHAR(5),
		cnt_por_vencer  SMALLINT    DEFAULT 0 NOT NULL,
		cnt_exigible    SMALLINT    DEFAULT 0 NOT NULL,
		cnt_corriente   SMALLINT    DEFAULT 0 NOT NULL,
		cnt_monto_30    SMALLINT    DEFAULT 0 NOT NULL,
		cnt_monto_60    SMALLINT    DEFAULT 0 NOT NULL,
		cnt_monto_90    SMALLINT    DEFAULT 0 NOT NULL,
		fax             CHAR(10),
		telefono1		CHAR(10),
		telefono2		CHAR(10),
		apartado2		CHAR(20),
		e_mail  		CHAR(20),
		PRIMARY KEY (cod_agente, no_poliza)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_moros ON tmp_moros(cod_sucursal);
CREATE INDEX xie02_tmp_moros ON tmp_moros(cod_cobrador);
CREATE INDEX xie03_tmp_moros ON tmp_moros(cod_acreedor);

-- Se Determina el Codigo de Coaseguro Mayoritario o Sin Coaseguro
-- Se Evita Hacer 'JOINS' por Cuestion de 'PERFORMANCE' de la Base de Datos

SELECT cod_tipoprod
  INTO _cod_tipoprod
  FROM emitipro
 WHERE tipo_produccion = 3;	-- Coaseguro Mayoritario

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

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03.trc";   
--TRACE ON;                                                                  

FOREACH 
 SELECT no_documento
   INTO	_doc_poliza
   FROM emipomae 
  WHERE cod_compania       = a_compania		   -- Seleccion por Compania
    AND actualizado        = 1			   	   -- Poliza este actualizada
	AND cod_ramo  NOT IN ('018','019')		   -- Exclu. Salud y Vida Individual
	AND cod_grupo    <> '00000'				   -- Exclu. Estado
	AND cod_formapag <> '046'				   -- Exclu. Forma de Pago Abogado
	AND (cod_tipoprod      = _cod_tipoprod1 OR -- Coaseguro Mayoritario
	     cod_tipoprod      = _cod_tipoprod2 OR   -- Sin Coaseguro
		 cod_tipoprod      = _cod_tipoprod)
GROUP BY no_documento		

-- Procedimiento que genera la morosidad para una poliza
	CALL sp_cob33(
		 a_compania,
		 a_agencia,	
		 _doc_poliza,
		 _periodo,
		 a_fecha
		 ) RETURNING _por_vencer_tot,       
    				 _exigible_tot,         
    				 _corriente_tot,        
    				 _monto_30_tot,         
    				 _monto_60_tot,         
    				 _monto_90_tot,
					 _saldo_tot;         
    				 

 	IF _saldo_tot = 0 THEN                   
		CONTINUE FOREACH;
 	END IF                                      

		--Tipo de Morosidad
		IF a_tipo_moros = '1' THEN -- Diferente de Cero
			IF _saldo_tot = 0 THEN
				CONTINUE FOREACH;
			END IF
		ELIF a_tipo_moros = '2' THEN -- Mayores de Cero
		 	IF _saldo_tot <= 0 THEN                   
				CONTINUE FOREACH;
			END IF
		ELIF a_tipo_moros = '3' THEN -- Menores de Cero
		 	IF _saldo_tot >= 0 THEN                   
				CONTINUE FOREACH;
			END IF
		ELSE
	 	END IF                                      

	FOREACH
	 SELECT	no_poliza,
			cod_contratante,
		    estatus_poliza,
		   	cod_formapag,
			no_pagos,
		   	vigencia_inic,
		    vigencia_final,
		    fecha_ult_pago,
		    sucursal_origen,
		    prima_bruta,
		    cod_ramo,
		    incobrable,
		    cod_tipoprod	   
	   INTO	_no_poliza,
			_cod_cliente,   
		   _estatus,       
		   _cod_formapag,  
		   _no_pagos,
		   _vigencia_inic, 
		   _vigencia_final,
		   _poliza_ult_pago,
		   _cod_sucursal,
		   _prima_orig_tot,
		   _cod_ramo,
		   _incobrable,
		   _cod_tipo_pol
	   FROM	emipomae
	  WHERE no_documento       = _doc_poliza
		AND actualizado        = 1			   	   -- Poliza este actualizada
		AND cod_ramo  NOT IN ('018','019')		   -- Exclu. Salud y Vida Individual
		AND cod_grupo    <> '00000'				   -- Exclu. Estado
		AND cod_formapag <> '046'				   -- Exclu. Forma de Pago Abogado
		AND (cod_tipoprod      = _cod_tipoprod1 OR -- Coaseguro Mayoritario
		     cod_tipoprod      = _cod_tipoprod2 OR -- Sin Coaseguro
			 cod_tipoprod      = _cod_tipoprod)
	  ORDER BY vigencia_final DESC
		EXIT FOREACH;
	END FOREACH

  LET _seleccionado = 1;

  IF  _cod_tipo_pol = _cod_tipoprod THEN
       CONTINUE FOREACH;
  END IF

-- Lectura de Tablas Relacionadas
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

--Cliente de la poliza
	SELECT nombre,
	       trim(fax),
		   telefono1,
		   telefono2,
		   apartado,
		   e_mail
	  INTO _nombre_cliente,
	       _fax,
		   _telefono1,
		   _telefono2,
		   _apartado2,
	       _e_mail
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;


    IF TRIM(_fax) = '507' THEN
	   LET _fax = '';
	   LET _seleccionado = 0;
	END IF

	IF _fax[1,3] = '507' THEN
	   LET _fax = _fax[4,10];
	END IF

	IF _fax[1,1] = '6' THEN
	   LET _seleccionado = 0;
	END IF
	 
--	IF LEN(_fax) 

--Forma de Pago
	SELECT nombre
	  INTO _forma_pago
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

	IF _forma_pago IS NULL THEN
		LET _forma_pago = '';
	END IF

--Estatus de la Poliza
	IF _estatus = '2' THEN -- Poliza Cancelada
		LET _estatus = 'C';
	ELSE
		LET _estatus = '';
	END IF

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

	-- Se determina el producto
	FOREACH 
	 SELECT	cod_producto
	   INTO	_cod_producto
	   FROM	emipouni
	  WHERE	no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH

	-- Se determina la fecha y el monto
	-- del ultimo pago

	LET _fecha_ult_pago = NULL;

   FOREACH
	SELECT fecha, 
	       monto
	  INTO _fecha_ult_pago,
	  	   _monto_ult_pago
	  FROM cobredet
	 WHERE doc_remesa   = _doc_poliza	-- Recibos de la Poliza
	   AND actualizado  = 1			    -- Recibo este actualizado
	   AND tipo_mov     = 'P'       	-- Pago de Prima(P)
       AND periodo     <= _periodo	    -- No Incluye Periodos Futuros
	 ORDER BY fecha DESC
		EXIT FOREACH;
	END FOREACH

	IF _fecha_ult_pago IS NULL THEN
		LET _monto_ult_pago = 0;
	END IF

	-- Determina todos los agentes de la poliza

	FOREACH 
	 SELECT	cod_agente,
			porc_partic_agt
	   INTO	_cod_agente,
			_porcentaje
	   FROM emipoagt
	  WHERE	no_poliza = _no_poliza

	   IF _cod_agente = '00521' THEN
	      CONTINUE FOREACH;
	   END IF

		SELECT nombre,
			   telefono1,
			   cod_cobrador,
			   cod_vendedor,
			   apartado
		 INTO  _nombre_agente,
			   _telefono,
			   _cod_cobrador,
			   _cod_vendedor,
			   _apartado
		 FROM  agtagent
		WHERE  cod_agente = _cod_agente;     

		LET _prima_orig = _prima_orig_tot / 100 * _porcentaje;
		LET _saldo      = _saldo_tot      / 100 * _porcentaje;
		LET _por_vencer = _por_vencer_tot / 100 * _porcentaje;
		LET _exigible   = _exigible_tot   / 100 * _porcentaje;
		LET _corriente  = _corriente_tot  / 100 * _porcentaje;
		LET _monto_30   = _monto_30_tot   / 100 * _porcentaje;
		LET _monto_60   = _monto_60_tot   / 100 * _porcentaje;
		LET _monto_90   = _monto_90_tot   / 100 * _porcentaje;
		 	   	
			IF _por_vencer <> 0 THEN
				LET _cnt_por_vencer = 1;
			ELSE
				LET _cnt_por_vencer = 0;
			END IF
			IF _exigible <> 0 THEN
				LET _cnt_exigible = 1;
			ELSE
				LET _cnt_exigible = 0;
			END IF
			IF _corriente <> 0 THEN
				LET _cnt_corriente = 1;
			ELSE
				LET _cnt_corriente = 0;
			END IF
			IF _monto_30 <> 0 THEN
				LET _cnt_monto_30 = 1;
			ELSE
				LET _cnt_monto_30 = 0;
			END IF
			IF _monto_60 <> 0 THEN
				LET _cnt_monto_60 = 1;
			ELSE
				LET _cnt_monto_60 = 0;
			END IF
			IF _monto_90 <> 0 THEN
				LET _cnt_monto_90 = 1;
			ELSE
				LET _cnt_monto_90 = 0;
			END IF

		-- Actualizacion de la Tabla Temporal

		INSERT INTO tmp_moros(
		cod_agente,
		no_poliza,      
		nombre_cliente, 
		doc_poliza,     
		estatus,        
		forma_pago,     
		vigencia_inic,  
		vigencia_final, 
		fecha_ult_pago,
		monto_ult_pago,
		prima_orig,    
		saldo,          
		por_vencer,     
		exigible,       
		corriente,     
		monto_30,       
		monto_60,       
		monto_90,
		nombre_agente,
		telefono,
		cod_cobrador,
		cod_vendedor,
		nombre_acreedor,        
		cod_sucursal,
		cod_acreedor,
		cod_ramo,
		cod_formapago,
		no_pagos,
		cod_cliente,
		incobrable,
		cod_coasegur,
		apartado,
		cod_producto,
		cnt_por_vencer,
		cnt_exigible,
		cnt_corriente,
		cnt_monto_30,
		cnt_monto_60,
		cnt_monto_90,
		fax,
		telefono1,
		telefono2,
		apartado2,
		e_mail,
		seleccionado
		)
		VALUES(
		_cod_agente,
		_no_poliza,      
		_nombre_cliente, 
		_doc_poliza,     
		_estatus,        
		_forma_pago,     
		_vigencia_inic,  
		_vigencia_final, 
		_fecha_ult_pago,
		_monto_ult_pago,
		_prima_orig,    
		_saldo,          
		_por_vencer,     
		_exigible,       
		_corriente,     
		_monto_30,       
		_monto_60,       
		_monto_90,
		_nombre_agente,
		_telefono,
		_cod_cobrador,
		_cod_vendedor,
		_nombre_acreedor,       
		_cod_sucursal,
		_cod_acreedor,
		_cod_ramo,
		_cod_formapag,
		_no_pagos,
		_cod_cliente,
		_incobrable,
		_cod_coasegur,
		_apartado,
		_cod_producto,
		_cnt_por_vencer,
		_cnt_exigible,
		_cnt_corriente,
		_cnt_monto_30,
		_cnt_monto_60,
		_cnt_monto_90,
		_fax,
		_telefono1,
		_telefono2,
		_apartado2,
		_e_mail,
		_seleccionado
		);

	END FOREACH

END FOREACH

END PROCEDURE;
