-- Encabezado de los Estados de Cuenta por Cliente y Morosidad (solo con saldos)
-- Creado por :     Marquelda Valdelamar 11/01/2001
-- Modificado por:	Marquelda Valdelamar 11/01/2001
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_co51_bk;

CREATE PROCEDURE "informix".sp_co51_bk(
a_compania     CHAR(3), 
a_sucursal     CHAR(3), 
a_cod_cliente  CHAR(10),
a_fecha        DATE,
a_periodo      CHAR(7)
) RETURNING	DATE,       -- vigencia_inic
			DATE,       -- vigencia_final
			CHAR(50),   -- nombre_ramo
			CHAR(50),   -- nombre_subramo
			CHAR(50),   -- nombre_agente
			CHAR(50),	-- nombre_cliente
			CHAR(100),	-- direccion1
			CHAR(100),  -- direccion2
			CHAR(20),   -- telefono1
			CHAR(20),	-- telefono2
			CHAR(10),   -- apartado
			CHAR(20),	-- no_documento
			CHAR(10),   -- no_poliza
			CHAR(30),   -- estatus de la poliza
			DATE,       -- fecha de cancelacion
			DEC(16,2),	-- por vencer
		  	DEC(16,2),	-- exigible
		  	DEC(16,2),	-- corriente
		  	DEC(16,2),	-- monto 30
		  	DEC(16,2),  -- monto 60
		  	DEC(16,2), 	-- monto 60
			DEC(16,2);	-- saldo

		  	
DEFINE _nombre_cliente   CHAR(50);
DEFINE _direccion1       CHAR(100);
DEFINE _direccion2       CHAR(100);
DEFINE _telefono1        CHAR(20);
DEFINE _telefono2        CHAR(20);
DEFINE _apartado         CHAR(10);
DEFINE _no_documento     CHAR(20);
DEFINE _vigencia_inic    DATE;
DEFINE _vigencia_final   DATE;
DEFINE _nombre_agente    CHAR(50);
DEFINE _nombre_ramo      CHAR(50);
DEFINE _nombre_subramo   CHAR(50);
DEFINE _cod_agente       CHAR(5);
DEFINE _cod_ramo         CHAR(3);
DEFINE _cod_subramo      CHAR(3);
DEFINE _no_poliza        CHAR(10);
DEFINE _estatus_poliza   INTEGER;
DEFINE _estatus          CHAR(30);
DEFINE _fecha_cancelacion DATE;

DEFINE _por_vencer	 	  DEC(16,2);
DEFINE _exigible	   	  DEC(16,2);
DEFINE _corriente		  DEC(16,2);
DEFINE _monto_30	      DEC(16,2);
DEFINE _monto_60	      DEC(16,2);
DEFINE _monto_90	      DEC(16,2);
DEFINE _saldo		      DEC(16,2);

DEFINE _por_vencer_tot 	  DEC(16,2);
DEFINE _exigible_tot   	  DEC(16,2);
DEFINE _corriente_tot     DEC(16,2);
DEFINE _monto_30_tot      DEC(16,2);
DEFINE _monto_60_tot      DEC(16,2);
DEFINE _monto_90_tot      DEC(16,2);
DEFINE _saldo_tot         DEC(16,2);
DEFINE _cod_tipoprod      CHAR(3);


SET ISOLATION TO DIRTY READ;

--ENCABEZADO DEL ESTADO DE CUENTA

LET _estatus = "";
LET _estatus_poliza = 0; 

LET _por_vencer_tot= 0.00;
LET _exigible_tot  = 0.00;
LET _corriente_tot = 0.00;
LET _monto_30_tot  = 0.00;
LET _monto_60_tot  = 0.00;
LET _monto_90_tot  = 0.00;
LET _saldo_tot     = 0.00;

-- Seleccion del tipo de produccion
	SELECT cod_tipoprod
	  INTO _cod_tipoprod
	  FROM emitipro
	 WHERE tipo_produccion = 4;	-- Reaseguro Asumido

-- Datos del Cliente
SELECT nombre,
       direccion_1,
	   direccion_2,
	   telefono1,
	   telefono2,
	   apartado
 INTO  _nombre_cliente,
       _direccion1,
	   _direccion2,
	   _telefono1,
	   _telefono2,
	   _apartado
FROM  cliclien					 
WHERE cod_cliente = a_cod_cliente;

-- Polizas del Ciente
	FOREACH
		SELECT no_documento
		 INTO  _no_documento
		  FROM emipomae
	     WHERE cod_contratante = a_cod_cliente
		   AND actualizado  = 1
		   AND saldo        > 0.00
		   AND periodo      <= a_periodo
		   AND cod_tipoprod <> _cod_tipoprod -- Reaseguro Asumido
	   GROUP BY no_documento

		LET	 _no_poliza = sp_sis21(_no_documento);

-- Datos de la Poliza del Ciente
   FOREACH	
	SELECT vigencia_inic,
	 	   vigencia_final,
		   cod_ramo,
		   cod_subramo,
		   estatus_poliza,
		   fecha_cancelacion
	 INTO  _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo,
		   _cod_subramo,
		   _estatus_poliza,
		   _fecha_cancelacion
	  FROM emipomae
	 WHERE no_documento = _no_documento
     ORDER BY vigencia_inic DESC
	EXIT FOREACH;
   END FOREACH

	IF _estatus_poliza = 1 then
		LET _estatus = 'Vigente';
	ELIF _estatus_poliza = 2 then
	    LET _estatus = 'Cancelada';
	ELIF _estatus_poliza = 3 then
	    LET _estatus = 'Vencida';
	ELSE
	    LET _estatus = 'Anulada';
	END IF

-- Ramo y Subramo
	SELECT nombre
	INTO   _nombre_ramo
	FROM  prdramo
	WHERE cod_ramo = _cod_ramo;	

	SELECT nombre
	INTO   _nombre_subramo
	FROM  prdsubra
	WHERE cod_ramo = _cod_ramo
	AND   cod_subramo = _cod_subramo;
    
-- Agente de la Poliza
	FOREACH
		SELECT cod_agente
		  INTO _cod_agente
		  FROM emipoagt
		 WHERE no_poliza = _no_poliza

		SELECT nombre
		  INTO _nombre_agente
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;
	EXIT FOREACH;
   END FOREACH

--Sumatoria de la Morosidad Total
	CALL sp_cob33(
	a_compania, 
	a_sucursal, 
	_no_documento,
	a_periodo,
	a_fecha   
	) RETURNING _por_vencer,       
	    		_exigible,         
	    		_corriente,        
	    		_monto_30,         
	    		_monto_60,         
	    		_monto_90,
				_saldo;

	LET _por_vencer_tot= _por_vencer_tot + _por_vencer;
	LET _exigible_tot  = _exigible_tot   + _exigible;
	LET _corriente_tot = _corriente_tot  + _corriente;
	LET _monto_30_tot  = _monto_30_tot   + _monto_30;
	LET _monto_60_tot  = _monto_60_tot   + _monto_60;
	LET _monto_90_tot  = _monto_90_tot   + _monto_90;
	LET _saldo_tot     = _saldo_tot      + _saldo;


RETURN
   	_vigencia_inic,
	_vigencia_final,
	_nombre_ramo,
	_nombre_subramo,
	_nombre_agente,
	_nombre_cliente,
	_direccion1,
	_direccion2,
	_telefono1,
	_telefono2,
	_apartado,
	_no_documento,
	_no_poliza,
	_estatus,
	_fecha_cancelacion,
	_por_vencer_tot,
	_exigible_tot,
	_corriente_tot,
	_monto_30_tot,
	_monto_60_tot,
	_monto_90_tot,
	_saldo_tot
   	WITH RESUME;

END FOREACH
END PROCEDURE;

