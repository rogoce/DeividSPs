-- Impresion del Cheque
--
-- Creado    : 29/09/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 29/09/2000 - Autor: Lic. Armando Moreno
-- Modificado: 30/10/2000 - Autor: Demetrio Hurtado ALmanza
--
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_che01pru;

CREATE PROCEDURE "informix".sp_che01pru(
a_compania		CHAR(3), 
a_agencia 		CHAR(3), 
a_usuario 		CHAR(8), 
a_cod_banco 	CHAR(3), 
a_cod_chequera	CHAR(3), 
a_no_requis 	CHAR(10) DEFAULT '*'
) RETURNING DATE,
			CHAR(100),
		    DECIMAL(16,2), 
			CHAR(250),
		    DATE,
			INTEGER,
			CHAR(3),
			CHAR(3),
			CHAR(8),
			CHAR(3),
			CHAR(3),
			CHAR(10);

DEFINE v_a_nombre_de  CHAR(50);     
DEFINE v_monto        DECIMAL(16,2);
DEFINE v_monto_letras CHAR(250);    
DEFINE _no_requis     CHAR(10);
DEFINE _no_cheque,_no_cheque2     INTEGER;
DEFINE _origen_cheque CHAR(1);
DEFINE _transaccion	  CHAR(10);
DEFINE _cod_origen    CHAR(3);
DEFINE _enlace_cta    CHAR(20);
DEFINE _renglon		  SMALLINT;
DEFINE _cuenta		  CHAR(25);
define _periodo		  char(7);
define _mes_char      CHAR(2);
define _ano_char	  CHAR(4);


--SET DEBUG FILE TO "sp_che01.trc";
--TRACE ON;

-- Lectura del Numero de Cheque
set isolation to dirty read;

IF  MONTH(today) < 10 THEN
	LET _mes_char = '0'|| MONTH(today);
ELSE
	LET _mes_char = MONTH(today);
END IF

LET _ano_char = YEAR(today);
LET _periodo  = _ano_char || "-" || _mes_char;

let _no_cheque2 = null;

SELECT cont_no_cheque
  INTO _no_cheque
  FROM chqchequ
 WHERE cod_banco    = a_cod_banco
   AND cod_chequera = a_cod_chequera;

IF _no_cheque IS NULL THEN
	LET _no_cheque = 0;
END IF

-- Lectura del Origen del Banco para el Enlace de Cuentas
  	
SELECT cod_origen
  INTO _cod_origen
  FROM chqbanco
 WHERE cod_banco = a_cod_banco;

-- Inicio de la Impresion de Cheques

FOREACH 
 SELECT a_nombre_de,
		monto,
		no_requis,
		origen_cheque
   INTO v_a_nombre_de,
		v_monto,
		_no_requis,
		_origen_cheque
   FROM chqchmae
  WHERE cod_compania   = a_compania
	AND pagado         = 0
	AND fecha_captura  = today
	AND cod_banco      = a_cod_banco
	AND cod_chequera   = a_cod_chequera
  	AND tipo_requis    = "C"
	AND no_requis      MATCHES a_no_requis
  ORDER BY no_requis 
--    AND cod_sucursal   = a_agencia

	select no_cheque
	  into _no_cheque2
	  from chqchmae
	 where no_requis = _no_requis;

	if _no_cheque2 IS NOT NULL and _no_cheque2 <> 0 then
		LET _no_cheque2 = _no_cheque2 - 1;
		LET _no_cheque  = _no_cheque2;
	end if

	LET _no_cheque = _no_cheque + 1;

	LET v_monto_letras = sp_sis11(v_monto);
	
	-- Actualizacion del Maestro de Cheques

	{UPDATE chqchmae
	   SET fecha_impresion = TODAY,
		   pagado          = 1,	
		   no_cheque       = _no_cheque,
		   periodo         = _periodo
	 WHERE no_requis       = _no_requis;
	 }
	-- Renglon de los Registros Contables
	
	SELECT MAX(renglon)
	  INTO _renglon	
	  FROM chqchcta
	 WHERE no_requis = _no_requis;

	IF _renglon IS NULL THEN
		LET _renglon = 0;
	END IF

	-- Actualizacion de los Cheques de Devolucion de Primas
	
	IF _origen_cheque = '6' THEN

		BEGIN

		DEFINE _no_poliza		CHAR(10);
		DEFINE _cod_tipoprod    CHAR(3);  
		DEFINE _tipo_produccion	SMALLINT; 
		DEFINE _prima_neta      DEC(16,2);
		DEFINE _porc_partic     DEC(5,2);
		DEFINE _porc_comis      DEC(5,2);
		DEFINE _doc_poliza		CHAR(20);
		DEFINE _comision        DEC(16,2);
		DEFINE _cod_agente      CHAR(5);
		DEFINE _tipo_agente     CHAR(1);

		FOREACH
		 SELECT	no_poliza,
				monto,
				no_documento
		   INTO	_no_poliza,
				_prima_neta,
				_doc_poliza
		   FROM	chqchpol
		  WHERE	no_requis = _no_requis

	  {		UPDATE emipomae
			   SET saldo     = saldo + _prima_neta
			 WHERE no_poliza = _no_poliza;
	   }
			SELECT cod_tipoprod
			  INTO _cod_tipoprod
			  FROM emipomae
			 WHERE no_poliza = _no_poliza;

			SELECT tipo_produccion
			  INTO _tipo_produccion
			  FROM emitipro
			 WHERE cod_tipoprod = _cod_tipoprod;

			-- Prima Neta

			IF _tipo_produccion = 3 THEN 
				LET _cuenta = sp_sis15('PACXCC',  '01', _no_poliza); -- Coaseguro Minoritario
			ELSE						 
				LET _cuenta = sp_sis15('PAPXCSD', '01', _no_poliza); -- Produccion Directa
			END IF

			LET _renglon = _renglon + 1;

			INSERT INTO chqchcta(
			no_requis,
			renglon,
			cuenta,
			debito,
			credito
			)
			VALUES(
			_no_requis,
			_renglon,
			_cuenta,
			_prima_neta,
			0
			);

{
			FOREACH
			 SELECT	porc_partic_agt,
			        porc_comis_agt,
					cod_agente
			   INTO	_porc_partic,
					_porc_comis,
					_cod_agente
			   FROM	chqchpoa
			  WHERE	no_requis    = _no_requis
			    AND no_documento = _doc_poliza

				SELECT tipo_agente
				  INTO _tipo_agente
				  FROM agtagent
				 WHERE cod_agente = _cod_agente;

				IF _tipo_agente <> 'O' THEN

					LET _cuenta   = sp_sis15('PPCOMXPCO',  '01', _no_poliza); -- Comision por Pagar
					LET _comision = _prima_neta * (_porc_comis / 100) * (_porc_partic / 100);
					LET _renglon  = _renglon + 1;

					INSERT INTO chqchcta(
					no_requis,
					renglon,
					cuenta,
					debito,
					credito
					)
					VALUES(
					_no_requis,
					_renglon,
					_cuenta,
					0,
					_comision
					);

				END IF

			END FOREACH
}	
		END FOREACH

		END

		END IF

	-- Actualizacion para los Cheques de Reclamos

	IF _origen_cheque = '3' THEN

		BEGIN

		DEFINE _fecha_transac DATE;
		DEFINE _fecha_param   DATE;
		DEFINE _monto_transac DEC(16,2);
		DEFINE _debito        DEC(16,2);
		DEFINE _credito       DEC(16,2);

		DELETE FROM chqchcta
		 WHERE no_requis = _no_requis;

		SELECT rec_fecha_prov
		  INTO _fecha_param
		  FROM parparam
		 WHERE cod_compania = a_compania;

		FOREACH
		 SELECT transaccion,
				monto
		   INTO _transaccion,
				_monto_transac
		   FROM chqchrec
		  WHERE no_requis = _no_requis

		{	UPDATE rectrmae
			   SET pagado       = 1,
				   no_requis    = _no_requis,
				   fecha_pagado = TODAY
		 	 WHERE transaccion  = _transaccion;
		 }
			SELECT fecha
			  INTO _fecha_transac
			  FROM rectrmae
			 WHERE transaccion = _transaccion;

			IF _fecha_transac > _fecha_param THEN
				LET  _cuenta  = sp_sis15('BCXPP'); 
			ELSE
				LET  _cuenta  = sp_sis15('BCXPPV'); 
			END IF

			IF _monto_transac > 0 THEN
				LET  _debito  = _monto_transac;
				LET  _credito = 0;
			ELSE
				LET  _debito  = 0;
				LET  _credito = _monto_transac * -1;
			END IF

			SELECT renglon
			  INTO _renglon
			  FROM chqchcta
			 WHERE no_requis = _no_requis
			   AND cuenta    = _cuenta;

			IF _renglon IS NULL THEN
				LET _renglon = 0;
			END IF

			IF _renglon = 0 THEN
				
				SELECT MAX(renglon)
				  INTO _renglon	
				  FROM chqchcta
				 WHERE no_requis = _no_requis;

				IF _renglon IS NULL THEN
					LET _renglon = 0;
				END IF

				LET _renglon = _renglon + 1;

				INSERT INTO chqchcta(
				no_requis,
				renglon,
				cuenta,
				debito,
				credito
				)
				VALUES(
				_no_requis,
				_renglon,
				_cuenta,
				_debito,
				_credito
				);
			
			ELSE

		  {		UPDATE chqchcta
				   SET debito    = debito  + _debito,
				       credito   = credito + _credito
				 WHERE no_requis = _no_requis
				   AND renglon   = _renglon;
		   }
			END IF

		END FOREACH

		let _monto_transac = 0.00;

		SELECT sum(monto)
		  INTO _monto_transac
		  FROM chqchrec
		 WHERE no_requis = _no_requis;

		if _monto_transac <> v_monto then
			let v_monto = _monto_transac;

		  {	update chqchmae
			   set monto     = v_monto
			 where no_requis = _no_requis;
		   }
			LET v_monto_letras = sp_sis11(v_monto);
		end if

		END 

	END IF

	-- Registros Contables del Banco
	
	SELECT MAX(renglon)
	  INTO _renglon	
	  FROM chqchcta
	 WHERE no_requis = _no_requis;

	IF _renglon IS NULL THEN
		LET _renglon = 0;
	END IF

	LET _renglon = _renglon + 1;

	IF _cod_origen = '001' THEN
		LET _enlace_cta = 'BACHEBL'; -- Chequera Bancos Locales                           
	ELSE
		LET _enlace_cta = 'BACHEBE'; -- Chequera Bancos Extranjeros
	END IF

	LET _cuenta = sp_sis15(_enlace_cta, '02', a_cod_banco);

	INSERT INTO chqchcta(
	no_requis,
	renglon,
	cuenta,
	debito,
	credito
	)
	VALUES(
	_no_requis,
	_renglon,
	_cuenta,
	0,
	v_monto
	);

	-- Datos del Cheque

	RETURN  TODAY, 
			v_a_nombre_de,
			v_monto, 
			v_monto_letras,      
			TODAY,
			_no_cheque,
			a_compania, 
			a_agencia, 
			a_usuario, 
			a_cod_banco, 
			a_cod_chequera, 
			_no_requis
			WITH RESUME;

END FOREACH

-- Actualizacion del Ultimo Numero de Cheque
if _no_cheque2 IS NULL or _no_cheque2 = 0 then
   {	UPDATE chqchequ
	   SET cont_no_cheque = _no_cheque
	 WHERE cod_banco      = a_cod_banco
	   AND cod_chequera   = a_cod_chequera;}
end if

END PROCEDURE;
