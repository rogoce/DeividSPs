-- Procedimiento que Genera la Morosidad de Cartera
-- 
-- Creado    : 09/11/2001 - Autor: Amado Perez 
-- ***** Igual al sp_cob03 pero se utiliza la prima neta *****
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_comis2;		

CREATE PROCEDURE "informix".sp_comis2(
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
DEFINE _estatus           CHAR(1); 
DEFINE _forma_pago        CHAR(2);
DEFINE _vigencia_inic     DATE;     
DEFINE _vigencia_final    DATE; 
DEFINE _fecha_ult_pago    DATE;
DEFINE _monto_ult_pago    DEC(16,2);    
DEFINE _prima_orig        DEC(16,2);
DEFINE _prima_orig_tot    dec(16,2);
DEFINE _saldo             DEC(16,2);
DEFINE _saldo_im          DEC(16,2);
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

DEFINE _cod_tipoprod      CHAR(3);
DEFINE _cod_tipoprod1     CHAR(3);
DEFINE _mes_contable      CHAR(2);
DEFINE _ano_contable      CHAR(4);
DEFINE _periodo           CHAR(7);
DEFINE _porcentaje        DEC(16,2);
DEFINE _porc_comis_agt    DEC(5,2);
DEFINE _poliza_saldo      DEC(16,2);
DEFINE _poliza_ult_pago   DATE;
DEFINE _no_unidad         CHAR(5);

DEFINE _saldo_tot         DEC(16,2);
DEFINE _saldo_imp         DEC(16,2);
DEFINE _comis_agt         DEC(16,2);
DEFINE _dos_porciento     DEC(16,2);
DEFINE _incobrable		  INTEGER;
DEFINE _apartado          CHAR(20);
DEFINE _ramo_sis          SMALLINT;
	
DEFINE _count             INTEGER;

LET _count = 0;

SET ISOLATION TO DIRTY READ;

-- Tabla Temporal 

--DROP TABLE tmp_moros;

-- Se Determina el Codigo de Coaseguro Mayoritario o Sin Coaseguro
-- Se Evita Hacer 'JOINS' por Cuestion de 'PERFORMANCE' de la Base de Datos


SELECT cod_tipoprod
  INTO _cod_tipoprod1
  FROM emitipro
 WHERE tipo_produccion = 4;	-- Reaseguro Asumido

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
  WHERE cod_compania    = a_compania	   -- Seleccion por Compania
    AND actualizado     = 1			   	   -- Poliza este actualizada
	AND cod_tipoprod    <> _cod_tipoprod1  -- No toma en cuenta reaseguro asumido
  GROUP BY no_documento		

	CALL sp_cob74b(
		 a_compania,
		 a_agencia,	
		 _doc_poliza,
		 _periodo,
		 a_fecha
		 ) RETURNING _saldo_tot,
					 _saldo_imp;         
    				 
 	IF _saldo_tot = 0 THEN                   
		CONTINUE FOREACH;
 	END IF                                      

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
		   	vigencia_inic,
		    vigencia_final,
		    fecha_ult_pago,
		    sucursal_origen,
		    prima_neta,
		    cod_ramo,
		    incobrable	   
	   INTO	_no_poliza,
			_cod_cliente,   
		    _estatus,       
		    _cod_formapag,  
		    _vigencia_inic, 
		    _vigencia_final,
		    _poliza_ult_pago,
		    _cod_sucursal,
		    _prima_orig_tot,
		    _cod_ramo,
		    _incobrable
	   FROM	emipomae
	  WHERE no_documento       = _doc_poliza
		AND actualizado        = 1			   	   -- Poliza este actualizada
		AND cod_tipoprod       <> _cod_tipoprod1   -- No toma en cuenta Reaseguro Asumido
	  ORDER BY vigencia_final DESC
		EXIT FOREACH;
	END FOREACH


-- Lectura de Tablas Relacionadas
--Ramo
	SELECT ramo_sis
	  INTO _ramo_sis
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

--Compania Coaseguradora
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
	SELECT nombre
	  INTO _nombre_cliente
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;
	 
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
--	   AND fecha       <= a_fecha	    -- Hechas durante y antes de la fecha seleccionada
	 ORDER BY fecha DESC
		EXIT FOREACH;
	END FOREACH

	IF _fecha_ult_pago IS NULL THEN
		LET _monto_ult_pago = 0;
	END IF

	-- Determina todos los agentes de la poliza

	FOREACH 
	 SELECT	cod_agente,
			porc_partic_agt,
			porc_comis_agt
	   INTO	_cod_agente,
			_porcentaje,
			_porc_comis_agt
	   FROM emipoagt
	  WHERE	no_poliza = _no_poliza

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

		LET _prima_orig = _prima_orig_tot * (_porcentaje/ 100);
		LET _saldo      = _saldo_tot      * (_porcentaje/ 100);
		LET _saldo_im   = _saldo_imp      * (_porcentaje/ 100);
		LET _comis_agt  = _saldo_tot      * (_porcentaje / 100) * (_porc_comis_agt/100);

--		LET _comis_agt  = _saldo_imp       * (_porcentaje / 100) * (_porc_comis_agt/100);

		IF _ramo_sis <> 3 THEN	--distinto de Fianzas
		   LET _dos_porciento = _saldo_tot * (_porcentaje / 100) * (2 / 100);
		ELSE
		   LET _dos_porciento = 0;
		END IF

		-- Actualizacion de la Tabla Temporal

		INSERT INTO comisrep(
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
		saldo_imp,         
		comis_agt,
		dos_porciento,
		nombre_agente,
		telefono,
		cod_cobrador,
		cod_vendedor,
		nombre_acreedor,        
		cod_sucursal,
		cod_acreedor,
		cod_ramo,
		cod_formapago,
		cod_cliente,
		incobrable,
		cod_coasegur,
		apartado,
		cod_producto,
		porc_comis_agt
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
		_saldo_im,       
		_comis_agt,
		_dos_porciento,
		_nombre_agente,
		_telefono,
		_cod_cobrador,
		_cod_vendedor,
		_nombre_acreedor,       
		_cod_sucursal,
		_cod_acreedor,
		_cod_ramo,
		_cod_formapag,
		_cod_cliente,
		_incobrable,
		_cod_coasegur,
		_apartado,
		_cod_producto,
		_porc_comis_agt
		);

	END FOREACH

END FOREACH

END PROCEDURE;
