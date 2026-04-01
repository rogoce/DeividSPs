-- Procedimiento que Genera la Morosidad de Coaseguro
-- 
-- Creado    : 04/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 08/09/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 07/10/2002 - Autor: Armando Moreno M.(filtro de gestion de cobros)

-- Modificado: 18/02/2003 - Autor: Demetrio Hurtado Almanza 
		       -- Se modifico el procedure para que busque la ultima
			   -- vigencia de la poliza y luego evalue el tipo de 
			   -- produccion. Esto se hizo para evitar que una misma
			   -- poliza sea avaluada 2 veces, tanto por este procedure
			   -- como por el sp_cob03, los cuales entre ambos arman
			   -- la totalidad de la morosidad

DROP PROCEDURE sp_cob02;
CREATE PROCEDURE sp_cob02(
a_compania   CHAR(3),
a_agencia    CHAR(3),
a_fecha      DATE
)
DEFINE _no_poliza         CHAR(10); 
DEFINE _nombre_cliente    CHAR(100);
DEFINE _nombre_acreedor   CHAR(100);
DEFINE _nombre_agente     CHAR(100);
DEFINE _no_unidad         CHAR(5);
DEFINE _doc_poliza        CHAR(20); 
DEFINE _estatus,_gestion  CHAR(1); 
DEFINE _forma_pago        CHAR(4);
DEFINE _no_poliza_coas    CHAR(30); 
DEFINE _vigencia_inic     DATE;     
DEFINE _vigencia_final    DATE;     
DEFINE _porcentaje        DEC(16,2);
DEFINE _prima_orig        DEC(16,2);
DEFINE _saldo             DEC(16,2);
DEFINE _por_vencer        DEC(16,2);
DEFINE _exigible          DEC(16,2);
DEFINE _corriente         DEC(16,2);
DEFINE _monto_30          DEC(16,2);
DEFINE _monto_60          DEC(16,2);
DEFINE _monto_90          DEC(16,2);
DEFINE _nombre_coasegur	  CHAR(50);
DEFINE _incobrable        INTEGER;

DEFINE _cod_cliente       CHAR(10); 
DEFINE _cod_ramo          CHAR(3);
DEFINE _cod_formapag      CHAR(3);  
DEFINE _cod_coasegur      CHAR(3);
DEFINE _cod_sucursal      CHAR(3);
DEFINE _cod_acreedor      CHAR(5);
DEFINE _cod_agente        CHAR(5);
DEFINE _cod_cobrador      CHAR(3);

DEFINE _cod_tipoprod      CHAR(3);
DEFINE _cod_tipoprod4     CHAR(3);
DEFINE _cod_tipo_pol	  CHAR(3);	
DEFINE _mes_contable      CHAR(2);
DEFINE _ano_contable      CHAR(4);
DEFINE _periodo           CHAR(7);
DEFINE _poliza_saldo      DEC(16,2);
DEFINE _poliza_ult_pago   DATE;

DEFINE _prima_orig_tot    DEC(16,2);
DEFINE _saldo_tot         DEC(16,2);
DEFINE _por_vencer_tot    DEC(16,2);
DEFINE _exigible_tot      DEC(16,2);
DEFINE _corriente_tot     DEC(16,2);
DEFINE _monto_30_tot      DEC(16,2);
DEFINE _monto_60_tot      DEC(16,2);
DEFINE _monto_90_tot      DEC(16,2);
DEFINE  _cod_grupo        CHAR(5);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob02.trc";

-- Tabla Temporal 

DROP TABLE if exists tmp_moros;

CREATE TEMP TABLE tmp_moros(
		no_poliza       CHAR(10)	NOT NULL,
        cod_ramo        CHAR(3),
		nombre_cliente  CHAR(100)	NOT NULL,
		doc_poliza      CHAR(20),
		estatus         CHAR(1)     NOT NULL,
		forma_pago      CHAR(4)		NOT NULL,
		no_poliza_coas  CHAR(30),
		vigencia_inic   DATE,
		vigencia_final  DATE,
		prima_orig      DEC(16,2)	DEFAULT 0 NOT NULL,
		saldo           DEC(16,2)	DEFAULT 0 NOT NULL,
		por_vencer      DEC(16,2)	DEFAULT 0 NOT NULL,
		exigible        DEC(16,2)	DEFAULT 0 NOT NULL,
		corriente       DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_30        DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_60        DEC(16,2)	DEFAULT 0 NOT NULL,
		monto_90        DEC(16,2)	DEFAULT 0 NOT NULL, 
		nombre_coasegur CHAR(50)	NOT NULL,
		seleccionado    SMALLINT    DEFAULT 1 NOT NULL,
		cod_sucursal    CHAR(3)     NOT NULL,
		cod_coasegur	CHAR(3),
		incobrable      INTEGER,
		cod_acreedor    CHAR(5)     NOT NULL,
  		cod_agente		CHAR(5)		NOT NULL,
   		cod_cobrador    CHAR(3)     NOT NULL,
		gestion		    CHAR(1)		NOT NULL,
		cod_grupo       CHAR(5),
		PRIMARY KEY (no_poliza)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_moros ON tmp_moros(cod_sucursal);
CREATE INDEX xie02_tmp_moros ON tmp_moros(cod_coasegur);
CREATE INDEX xie04_tmp_moros ON tmp_moros(cod_acreedor);

-- Se Determina el Codigo del Coaseguro Minoritario
-- Se Evita Hacer 'JOINS' por Cuestion de 'PERFORMANCE' de la Base de Datos

SELECT cod_tipoprod
  INTO _cod_tipoprod
  FROM emitipro
 WHERE tipo_produccion = 3;	--coas minoritario

SELECT cod_tipoprod
  INTO _cod_tipoprod4
  FROM emitipro
 WHERE tipo_produccion = 4; --reas asumido

-- Periodo de Seleccion
-- Se Filtran los Registros por Fecha y Periodo Contable

LET _ano_contable = YEAR(a_fecha);

IF MONTH(a_fecha) < 10 THEN
	LET _mes_contable = '0' || MONTH(a_fecha);
ELSE
	LET _mes_contable = MONTH(a_fecha);
END IF

LET _periodo = _ano_contable || '-' || _mes_contable;

--	IF _cod_tipo_pol is null THEN
let _cod_tipo_pol = "0";
-- 	END IF
-- Seleccion de la Polizas

FOREACH 
 SELECT no_documento
   INTO	_doc_poliza
   FROM emipomae 
  WHERE cod_compania       = a_compania		-- Seleccion por Compania
    AND actualizado        = 1			   	-- Poliza este actualizada
  GROUP BY no_documento		

	-- Determina la Ultima Vigencia del Documento

	FOREACH 
	 SELECT no_poliza,
			cod_contratante,
			estatus_poliza,
			cod_formapag,
			no_poliza_coaseg,
			vigencia_inic,
			vigencia_final,
			saldo,
			fecha_ult_pago,
			cod_sucursal,
			prima_bruta,
			incobrable,
			cod_ramo,
		    cod_tipoprod,
			gestion,
		    cod_grupo
	   INTO	_no_poliza,     
			_cod_cliente,   
			_estatus,       
			_cod_formapag,  
			_no_poliza_coas,
			_vigencia_inic, 
			_vigencia_final,
			_poliza_saldo,
			_poliza_ult_pago,
			_cod_sucursal,
			_prima_orig,
			_incobrable,
			_cod_ramo,
			_cod_tipo_pol,
			_gestion,
		    _cod_grupo
	   FROM emipomae 
	  WHERE cod_compania       = a_compania		-- Seleccion por Compania
		AND no_documento       = _doc_poliza	-- Numero de Poliza
	    AND actualizado        = 1			   	-- Poliza este actualizada
	  ORDER BY vigencia_final DESC, no_poliza DESC
		EXIT FOREACH;
	END FOREACH

	-- Si la Ultima Vigencia es Reaseguro Asumido no Evalua el Registro
	IF _cod_tipo_pol = _cod_tipoprod4 THEN
    	CONTINUE FOREACH;
  	END IF

	-- Si la Ultima Vigencia No es Coas. Minoritario no Evalua el Registro
	IF _cod_tipo_pol <> _cod_tipoprod THEN
    	CONTINUE FOREACH;
  	END IF

	CALL sp_cob33(
		 a_compania,
		 a_agencia,	
		 _doc_poliza,
		 _periodo,
		 a_fecha
		 ) RETURNING _por_vencer,       
    				 _exigible,         
    				 _corriente,        
    				 _monto_30,         
    				 _monto_60,         
    				 _monto_90,
    				 _saldo;    
   				 
	IF _saldo = 0 THEN
		CONTINUE FOREACH;
	END IF

	-- Lectura de Tablas Relacionadas

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

-- Cliente de la Poliza
	SELECT nombre
	  INTO _nombre_cliente
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

-- Forma de Pago de la Poliza	 
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

-- Determina todos los agentes de la poliza

	FOREACH 
	 SELECT	cod_agente,
			porc_partic_agt
	   INTO	_cod_agente,
			_porcentaje
	   FROM emipoagt
	  WHERE	no_poliza = _no_poliza

		SELECT nombre,
			   cod_cobrador
		 INTO  _nombre_agente,
			   _cod_cobrador
		 FROM  agtagent
		WHERE  cod_agente = _cod_agente; 
    EXIT FOREACH;
 END FOREACH
		
-- Actualizacion de la Tabla Temporal

	INSERT INTO tmp_moros(
	no_poliza,      
	nombre_cliente, 
	doc_poliza,     
	estatus,        
	forma_pago,     
	no_poliza_coas, 
	vigencia_inic,  
	vigencia_final, 
	prima_orig,    
	saldo,          
	por_vencer,     
	exigible,       
	corriente,     
	monto_30,       
	monto_60,       
	monto_90,
	nombre_coasegur,
	cod_sucursal,
	cod_coasegur,
	incobrable,
	cod_acreedor,
	cod_agente,
	cod_cobrador,
	gestion,
	cod_grupo
	)
	VALUES(
	_no_poliza,      
	_nombre_cliente, 
	_doc_poliza,     
	_estatus,        
	_forma_pago,     
	_no_poliza_coas, 
	_vigencia_inic,  
	_vigencia_final, 
	_prima_orig,    
	_saldo,          
	_por_vencer,     
	_exigible,       
	_corriente,     
	_monto_30,       
	_monto_60,       
	_monto_90,
	_nombre_coasegur,        
	_cod_sucursal,
	_cod_coasegur,
	_incobrable,
	_cod_acreedor,
  	_cod_agente,
  	_cod_cobrador,
	_gestion,
	_cod_grupo
	);

	END FOREACH
END PROCEDURE;

