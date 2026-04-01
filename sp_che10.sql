-- Procedimiento que Carga las Comisiones Descontadas por Corredor

-- Creado    : 02/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 02/02/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che10;

CREATE PROCEDURE sp_che10(
a_compania 		 CHAR(3), 
a_sucursal 		 CHAR(3),
a_fecha_desde    DATE,
a_fecha_hasta    DATE
)

DEFINE _cod_agente   CHAR(5);  
DEFINE _no_poliza    CHAR(10); 
DEFINE _no_remesa    CHAR(10); 
DEFINE _renglon      CHAR(5);  
DEFINE _monto        DEC(16,2);
DEFINE _no_recibo    CHAR(10); 
DEFINE _fecha        DATE;     
DEFINE _prima        DEC(16,2);
DEFINE _porc_partic  DEC(5,2); 
DEFINE _porc_comis   DEC(5,2); 
DEFINE _comision     DEC(16,2);
DEFINE _nombre       CHAR(50); 
DEFINE _no_documento CHAR(20); 
DEFINE _no_requis    CHAR(10); 
DEFINE _cod_tipoprod CHAR(3);
DEFINE _tipo_prod    SMALLINT;
DEFINE _monto_vida   DEC(16,2);
DEFINE _monto_danos  DEC(16,2);
DEFINE _monto_fianza DEC(16,2);
DEFINE _cod_tiporamo CHAR(3);
DEFINE _tipo_ramo    SMALLINT;
DEFINE _cod_ramo     CHAR(3);
DEFINE _no_licencia  CHAR(10);

--set debug file to "sp_che10.trc";
--trace on;

--DROP TABLE tmp_agente;

CREATE TEMP TABLE tmp_agente(
	cod_agente		CHAR(15),
	no_poliza		CHAR(10),
	no_recibo		CHAR(10),
	fecha			DATE,
	monto           DEC(16,2),
	prima           DEC(16,2),
	porc_partic		DEC(5,2),
	porc_comis		DEC(5,2),
	comision		DEC(16,2),
	nombre			CHAR(50),
	no_documento    CHAR(20),
	monto_vida      DEC(16,2),
	monto_danos     DEC(16,2),
	monto_fianza    DEC(16,2),
	no_licencia     CHAR(10)
--	PRIMARY KEY		(cod_agente, no_poliza, no_recibo, fecha)
	) WITH NO LOG;

CREATE INDEX idx_tmp_agente ON tmp_agente(cod_agente, no_poliza, no_recibo, fecha);

SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT	no_poliza,
		no_remesa,
		renglon,
		no_recibo,
		fecha,
		monto,
		prima_neta
   INTO	_no_poliza,
		_no_remesa,
		_renglon,
		_no_recibo,
		_fecha,
		_monto,
		_prima
   FROM	cobredet
  WHERE	cod_compania     = a_compania
    AND actualizado      = 1
	AND tipo_mov         IN ('P','N')
	AND fecha            >= a_fecha_desde
	AND fecha            <= a_fecha_hasta
	AND monto_descontado <> 0

	SELECT no_documento,
		   cod_tipoprod,
		   cod_ramo	
	  INTO _no_documento,
		   _cod_tipoprod,
		   _cod_ramo	
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_prod
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	-- No Incluye Coaseguro Minoritario ni Reaseguro Asumido

	IF _tipo_prod = 3 OR
	   _tipo_prod = 4 THEN
	   CONTINUE FOREACH;
	END IF
	
	SELECT cod_tiporamo
	  INTO _cod_tiporamo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo; 	

	SELECT tipo_ramo
	  INTO _tipo_ramo
	  FROM prdtiram
	 WHERE cod_tiporamo = _cod_tiporamo;

	FOREACH
	 SELECT	cod_agente,
			monto_man,
			porc_partic_agt,
			porc_comis_agt
	   INTO	_cod_agente,
			_comision,
			_porc_partic,
			_porc_comis
	   FROM	cobreagt
	  WHERE	no_remesa = _no_remesa
	    AND renglon   = _renglon

		LET _monto_vida   = 0;
		LET _monto_danos  = 0;
		LET _monto_fianza = 0;

		IF   _tipo_ramo = 1 THEN
			LET _monto_vida   = _comision;
		ELIF _tipo_ramo = 2 THEN	
			LET _monto_danos  = _comision;
		ELSE
			LET _monto_fianza = _comision;
		END IF

		SELECT nombre,
			   no_licencia	
		  INTO _nombre,
			   _no_licencia
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

-- 		BEGIN                                                      
--                                                                 
-- 			ON EXCEPTION IN(-239)                                  
--                                                                 
-- 				UPDATE tmp_agente                                  
-- 				   SET monto        = monto        + _monto,       
-- 				       prima        = prima        + _prima,       
-- 					   comision     = comision     + _comision,    
-- 					   monto_vida   = monto_vida   + _monto_vida,  
-- 					   monto_danos  = monto_danos  + _monto_danos, 
-- 					   monto_fianza = monto_fianza + _monto_fianza 
-- 				 WHERE cod_agente   = _cod_agente                  
-- 				   AND no_poliza    = _no_poliza                   
-- 				   AND no_recibo    = _no_recibo                   
-- 				   AND fecha        = _fecha;                      
--                                                                 
-- 			END EXCEPTION                                          

			INSERT INTO tmp_agente(
			cod_agente,
			no_poliza,
			no_recibo,
			fecha,
			monto,
			prima,
			porc_partic,
			porc_comis,
			comision,
			nombre,
			no_documento,
			monto_vida,
			monto_danos,
			monto_fianza,
			no_licencia
			)
			VALUES(
			_cod_agente,
			_no_poliza,
			_no_recibo,
			_fecha,
			_monto,
			_prima,
			_porc_partic,
			_porc_comis,
			_comision,
			_nombre,
			_no_documento,
			_monto_vida,
			_monto_danos,
			_monto_fianza,
			_no_licencia
			);

--		END

	END FOREACH

END FOREACH

END PROCEDURE;