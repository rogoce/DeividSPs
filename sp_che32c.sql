-- Procedimiento que Genera el Cheque para Un Corredor

-- Creado    : 24/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/10/2000 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_che32;

CREATE PROCEDURE sp_che32c(a_no_requis char(10), a_fecha DATE) RETURNING INTEGER; 

DEFINE _no_requis	CHAR(10);
DEFINE _monto_banco	DEC(16,2);
DEFINE _banco_ach   CHAR(3);
DEFINE _comision	DEC(16,2);

define _renglon		smallint;
DEFINE _cuenta      CHAR(25);
define _origen_banc	char(3);
define _tipo_agente char(1);
define _cod_agente	char(5);
define _cod_subramo	char(3);
define _cod_ramo	char(3);
define _cod_origen	char(3);
define _origen_cheq	char(1);
define _error       integer;
define _error_desc  char(50);


--SET DEBUG FILE TO "sp_che32.trc"; 
--TRACE ON;                                                                

--BEGIN WORK;

let _cod_origen = "001";

foreach
 select	no_requis,
        cod_banco,
		monto,
		cod_agente,
		origen_cheque
   into _no_requis,
		_banco_ach,
		_monto_banco,
		_cod_agente,
		_origen_cheq
   From chqchmae
  where no_requis = a_no_requis

	if _origen_cheq = "2" or
	   _origen_cheq = "7" then
	else
		return 0;
	end if
	
	-- Registros Contables de Cheques de Comisiones

	call sp_par205c(_no_requis, a_fecha) returning _error, _error_desc;

	if _error <> 0 then
		return _error;
	end if
	
	{select tipo_agente
	  into _tipo_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	select cod_origen
	  into _origen_banc
	  from chqbanco
	 where cod_banco = _banco_ach;

    DELETE FROM chqctaux WHERE no_requis = _no_requis;

	delete from chqchcta
	 WHERE no_requis = _no_requis;
	 
	LET _renglon = 0;

	IF _tipo_agente = "A" THEN

		-- Registros Contables de Comisiones por Pagar

		let _renglon = _renglon + 1 ;
		LET _cuenta  = sp_sis15('PPCOMXPCO', '03', _cod_agente);

		INSERT INTO chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito
		)
		VALUES(
		_no_requis,
		1,
		_cuenta,
		_monto_banco,
		0
		);

	elif _tipo_agente = "E" THEN

		FOREACH
		 SELECT monto,
				cod_ramo
		   INTO _comision,
				_cod_ramo
		   FROM chqchagt
		  WHERE no_requis = _no_requis

			foreach
			 select cod_subramo
			   into _cod_subramo
			   from prdsubra
			  where cod_ramo = _cod_ramo
				exit foreach;
			end foreach

			-- Registros Contables de Honorarios por Pagar

			let _renglon = _renglon + 1 ;
			LET _cuenta  = sp_sis15('PPGHONXPCO', '04', _cod_origen, _cod_ramo, _cod_subramo);

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
			_comision,
			0
			);

		END FOREACH

	end if

	-- Registros Contables del Banco

	LET _renglon = _renglon + 1;

	IF _origen_banc = '001' THEN
		LET _cuenta = sp_sis15('BACHEBL', '02', _banco_ach); -- Chequera Bancos Locales
	ELSE
		LET _cuenta = sp_sis15('BACHEBE', '02', _banco_ach); -- Chequera Bancos Extranjeros
	END IF

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
	_monto_banco
	);
}
END FOREACH

RETURN 0;

END PROCEDURE;