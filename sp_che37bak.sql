-- Procedimiento que Genera Remesa para el descuento 
-- de comision de los corredores, pago de primas y afectacion de catalogo
-- antes del proceso de ACH

-- Creado    : 07/12/2005 - Autor: Amado Perez Mendoza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che37;

CREATE PROCEDURE sp_che37(
a_compania 		 CHAR(3), 
a_sucursal 		 CHAR(3),
a_fecha_desde    DATE,
a_fecha_hasta    DATE,
a_user           CHAR(8)
) RETURNING SMALLINT,	
            CHAR(100);   
			
define _renglon			SMALLINT;
DEFINE v_comision       DEC(16,2);
DEFINE v_deuda			DEC(16,2);

DEFINE _cod_agente      CHAR(5);  
define _tipo			smallint;
define _monto			dec(16,2);
define _no_documento	char(30);
define _saldo			dec(16,2);
define _saldo_pol		dec(16,2);
define _cod_auxiliar	char(5);
DEFINE _quincena     	SMALLINT;
DEFINE _registros       INTEGER;

DEFINE _error 			SMALLINT;
DEFINE _descripcion		CHAR(100);
DEFINE _no_remesa       CHAR(10);


CREATE TEMP TABLE tmp_comis(
	cod_agente		CHAR(5),
	comision		DEC(16,2),
	primary key (cod_agente)
	) WITH NO LOG;

CREATE TEMP TABLE tmp_comis2(
	cod_agente		CHAR(5),
	tipo			smallint,
	no_documento	char(30),
	monto			DEC(16,2),
	cod_auxiliar	char(5),
	saldo_pol       DEC(16,2),
	renglon         smallint
	) WITH NO LOG;


-- Genera los registros de las comisiones

CALL sp_che02(
a_compania, 
a_sucursal,
a_fecha_desde,
a_fecha_hasta,
1
);

--SET DEBUG FILE TO "sp_che37.trc";
--TRACE ON;

-- Determinar quien tiene deudas
SET ISOLATION TO DIRTY READ;

IF DAY(a_fecha_desde) < 15 THEN
   LET _quincena = 1;
ELSE	
   LET _quincena = 2;
END IF

FOREACH
 SELECT cod_agente
   INTO _cod_agente
   FROM agtdeuda
  GROUP BY cod_agente
--  where cod_agente = "00124"

--	LET _cod_agente = "00124";

	SELECT sum(comision)
	  INTO v_comision
	  FROM tmp_agente
	 WHERE cod_agente = _cod_agente;

	if v_comision is null then
		let v_comision = 0;
	end if

	if v_comision <> 0.00 then

		INSERT INTO tmp_comis(
		cod_agente,
		comision
		)
		VALUES(
		_cod_agente,
		v_comision
		);

	end if

END FOREACH

SELECT COUNT(*)
  INTO _registros
  FROM tmp_comis;

-- Proceso para Deudas
IF _registros >	0 THEN

	FOREACH
	 SELECT cod_agente,
	     	comision
	   INTO	_cod_agente,
	  		v_comision
	   FROM tmp_comis

	   FOREACH
	    SELECT renglon,
	           monto,
			   no_documento,
			   saldo,
			   cod_auxiliar
	      INTO _renglon,
	           v_deuda,
			   _no_documento,
			   _saldo,
			   _cod_auxiliar
	      FROM agtdeuda
	     WHERE cod_agente = _cod_agente
		   AND tipo       = 1
		   AND quincena   in (0, _quincena)

			Let _saldo_pol = _saldo; 

			If _saldo < v_deuda then
				let v_deuda = _saldo;
			end if

			If v_comision < v_deuda Then
				let v_comision = v_deuda;
	        End If

			Let v_comision = v_comision - v_deuda;
			Let _saldo = _saldo - v_deuda;

			insert into tmp_comis2
			values(
			_cod_agente,
			1,
			_no_documento,
			v_deuda,
			_cod_auxiliar,
			_saldo_pol,
			_renglon
			);

			If v_comision <=  0.00 Then
				EXIT FOREACH;
			End If

		END FOREACH

	END FOREACH


	-- Porceso para Pago a Polizas

	FOREACH
	 SELECT cod_agente,
	     	comision
	   INTO	_cod_agente,
	  		v_comision
	   FROM tmp_comis

	   FOREACH
	    SELECT renglon,
	           monto,
			   no_documento,
			   saldo,
			   cod_auxiliar
	      INTO _renglon,
	           v_deuda,
			   _no_documento,
			   _saldo,
			   _cod_auxiliar
	      FROM agtdeuda
	     WHERE cod_agente = _cod_agente
		   AND tipo       = 2
		   AND quincena   in (0, _quincena)

			let _saldo = sp_cob115b('001','001',_no_documento,'');

			Let _saldo_pol = _saldo; 

			If _saldo < v_deuda then
				let v_deuda = _saldo;
			end if

			If v_comision < v_deuda Then
				let v_comision = v_deuda;
	        End If

			Let v_comision = v_comision - v_deuda;
			Let _saldo = _saldo - v_deuda;

			insert into tmp_comis2
			values(
			_cod_agente,
			2,
			_no_documento,
			v_deuda,
			_cod_auxiliar,
			_saldo_pol,
			_renglon
			);

			If v_comision <=  0.00 Then
				EXIT FOREACH;
			End If

		END FOREACH

	END FOREACH

	-- Generar la Remesa


	CALL sp_che38(a_compania,a_sucursal,a_user,a_fecha_hasta) returning _error, _descripcion, _no_remesa;

ELSE
  LET _error = 1;
  LET _descripcion = "No hay registros para procesar";
END IF

DROP TABLE tmp_agente;
DROP TABLE tmp_comis;
DROP TABLE tmp_comis2;

RETURN _error,
       _descripcion;

END PROCEDURE;