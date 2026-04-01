-- Encabezado de los Estados de Cuenta por Poliza y Morosidad Total por poliza (solo con saldo)
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_co50;

CREATE PROCEDURE "informix".sp_co50(a_compania  CHAR(3),a_sucursal CHAR(3), a_no_documento CHAR(20), a_fecha DATE, a_periodo CHAR(7), a_reaseg_asumido INT DEFAULT 2)
RETURNING	CHAR(50),	-- nombre_cliente
			CHAR(100),	-- direccion1
			CHAR(100),  -- direccion2
			CHAR(20),   -- telefono1
			CHAR(20),	-- telefono2
			CHAR(10),   -- apartado
			CHAR(20),	-- no_documento
			DATE,       -- vigencia_inic
			DATE,       -- vigencia_final
			CHAR(50),   -- nombre_agente
			CHAR(50),   -- nombre_ramo
			CHAR(50),   -- nombre_subramo
			DATE,       -- fecha_aviso,
			DATE,       -- fecha_efectiva
			CHAR(30),   -- estatus_poliza
			DATE;       -- fecha de cancelacion
					  	
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
DEFINE _cod_cliente      CHAR(10);						
DEFINE _cod_subramo      CHAR(3);
DEFINE _no_poliza        CHAR(10);
DEFINE _fecha_aviso_canc DATE;
DEFINE _fecha_efectiva   DATE;
DEFINE _estatus_poliza   INTEGER;
DEFINE _estatus          CHAR(30);
DEFINE _fecha_cancelacion DATE;
DEFINE _cod_tipoprod	 CHAR(3);

LET _no_poliza = null;
LET _estatus_poliza = 0;
LET _estatus= "";
LET _fecha_aviso_canc = null;

SET ISOLATION TO DIRTY READ;

-- Seleccion del tipo de produccion
	SELECT cod_tipoprod
	  INTO _cod_tipoprod
	  FROM emitipro
	 WHERE tipo_produccion = 4;	-- Reaseguro Asumido

-- Datos de la Poliza
IF a_reaseg_asumido = 2 THEN
	FOREACH
		 SELECT vigencia_inic,
		        vigencia_final,
				cod_ramo,
				cod_subramo,
				cod_contratante,
				no_poliza,
				fecha_aviso_canc,
				estatus_poliza,
				fecha_cancelacion
		   INTO _vigencia_inic,
				_vigencia_final,
				_cod_ramo,
				_cod_subramo,
				_cod_cliente,
				_no_poliza,
				_fecha_aviso_canc,
				_estatus_poliza,
				_fecha_cancelacion
		   FROM emipomae
		  WHERE no_documento = a_no_documento
		    AND saldo        > 0.00
		    AND actualizado  = 1
		  	AND periodo      <= a_periodo
		   	AND cod_tipoprod <> _cod_tipoprod -- no incl. Reaseguro Asumido
	   ORDER BY vigencia_inic DESC

	   EXIT FOREACH;
	END FOREACH
ELIF a_reaseg_asumido = 1 THEN  --incluye reaseg. asumido
	FOREACH
	 SELECT vigencia_inic,
	        vigencia_final,
			cod_ramo,
			cod_subramo,
			cod_contratante,
			no_poliza,
			fecha_aviso_canc,
			estatus_poliza,
			fecha_cancelacion
	   INTO _vigencia_inic,
			_vigencia_final,
			_cod_ramo,
			_cod_subramo,
			_cod_cliente,
			_no_poliza,
			_fecha_aviso_canc,
			_estatus_poliza,
			_fecha_cancelacion
	   FROM emipomae
	  WHERE no_documento = a_no_documento
	    AND saldo        > 0.00
	    AND actualizado  = 1
	  	AND periodo      <= a_periodo
  	ORDER BY vigencia_inic DESC
		EXIT FOREACH;
	END FOREACH
ELSE
	FOREACH
	 SELECT vigencia_inic,
	        vigencia_final,
			cod_ramo,
			cod_subramo,
			cod_contratante,
			no_poliza,
			fecha_aviso_canc,
			estatus_poliza,
			fecha_cancelacion
	   INTO _vigencia_inic,
			_vigencia_final,
			_cod_ramo,
			_cod_subramo,
			_cod_cliente,
			_no_poliza,
			_fecha_aviso_canc,
			_estatus_poliza,
			_fecha_cancelacion
	   FROM emipomae
	  WHERE no_documento = a_no_documento
	    AND saldo        > 0.00
	    AND actualizado  = 1
	  	AND periodo      <= a_periodo
	   	AND cod_tipoprod = _cod_tipoprod --solo Reaseguro Asumido
  		ORDER BY vigencia_inic DESC
	EXIT FOREACH;
	END FOREACH
END IF

IF _no_poliza IS NOT NULL THEN     
	--Estatus de la poliza
		IF _estatus_poliza = 1 then
			LET _estatus = 'Vigente';
		ELIF _estatus_poliza = 2 then
		    LET _estatus = 'Cancelada';
		ELIF _estatus_poliza = 3 then
		    LET _estatus = 'Vencida';
		ELSE
		    LET _estatus = 'Anulada';
		END IF

		LET _fecha_efectiva = (_fecha_aviso_canc + 10);

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
	WHERE cod_cliente = _cod_cliente;

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
		 INTO   _cod_agente
		 FROM   emipoagt
		 WHERE  no_poliza = _no_poliza
		 
		 SELECT nombre
		   INTO _nombre_agente
		   FROM agtagent
		  WHERE cod_agente = _cod_agente;
		EXIT FOREACH;
		END FOREACH
	

	RETURN
	_nombre_cliente,
	_direccion1,
	_direccion2,
	_telefono1,
	_telefono2,
	_apartado,
	a_no_documento,
	_vigencia_inic,
	_vigencia_final,
	_nombre_agente,
	_nombre_ramo,
	_nombre_subramo,
	_fecha_aviso_canc,
	_fecha_efectiva,
	_estatus,
	_fecha_cancelacion
	WITH RESUME;
END IF
END PROCEDURE;
