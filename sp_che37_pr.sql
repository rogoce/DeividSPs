-- Procedimiento que Genera Remesa para el descuento 
-- de comision de los corredores, pago de primas y afectacion de catalogo
-- antes del proceso de ACH

-- Creado    : 07/12/2005 - Autor: Amado Perez Mendoza
-- Modificado: 25/02/2008 - Autor: Amado Perez Mendoza
--             Se modifica para que funcione para pagos Semanales  

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che37_pr;

CREATE PROCEDURE sp_che37_pr(
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
define _arrastre        dec(16,2);
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

BEGIN
ON EXCEPTION SET _error 
	DROP TABLE tmp_agente;
	DROP TABLE tmp_comis;
	DROP TABLE tmp_comis2;

	RETURN _error, "Error con el agente " || _cod_agente;
END EXCEPTION           


IF DAY(a_fecha_hasta) < 16 THEN	  --Se tomara la fecha_hasta para determinar de que quincena y no la fecha_desde
   LET _quincena = 1;
ELSE	
   LET _quincena = 2;
END IF

FOREACH
 SELECT cod_agente
   INTO _cod_agente
   FROM agtdeuda
  WHERE quincena   in (0, _quincena)
  GROUP BY cod_agente
--  where cod_agente = "00124"

--	LET _cod_agente = "00124";

	SELECT sum(comision)
	  INTO v_comision
	  FROM tmp_agente
	 WHERE cod_agente = _cod_agente;

	if v_comision is null then
		continue foreach;
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

           let _cod_agente = _cod_agente;
           let v_comision = v_comision;

     SELECT saldo	  --> Se agrega el arrastre porque se debe sumar a la comision del periodo actual para hacer los descuentos de forma correcta 
       INTO _arrastre
	   FROM agtagent 
	  WHERE cod_agente = _cod_agente;

	   IF _arrastre IS NULL THEN
	   	LET _arrastre = 0;
	   END IF

       LET v_comision = v_comision + _arrastre;

	   FOREACH
	    SELECT renglon,
	           monto,
			   no_documento,
			   saldo,
			   cod_auxiliar,
			   tipo
	      INTO _renglon,
	           v_deuda,
			   _no_documento,
			   _saldo,
			   _cod_auxiliar,
			   _tipo
	      FROM agtdeuda
	     WHERE cod_agente = _cod_agente
		   AND quincena   in (0, _quincena)

           let _renglon = _renglon;
           let v_deuda = v_deuda;
           let _no_documento = _no_documento;
           let _saldo = _saldo;
           let _cod_auxiliar = _cod_auxiliar;
           let _tipo = _tipo;

            If _tipo = 2 Then
				let _saldo = sp_cob115b('001','001',_no_documento,'');
			End If

			Let _saldo_pol = _saldo; 

			If _saldo < v_deuda then
				let v_deuda = _saldo;
			end if
										 --> Luis Enrique Moya 30/08/2008 al 03/09/2008
			If v_comision < v_deuda Then --> esta es la condicion que da problemas v_comision = -119.50 y v_deuda = 34.65 no se le sumo el arrastre 125.94 y por eso dio error
				If v_comision <= 0 Then
					let v_deuda = 0;
			    Else	
					let v_deuda = v_comision;
				End If
	        End If

			Let v_comision = v_comision - v_deuda;
			Let _saldo = _saldo - v_deuda;

			insert into tmp_comis2
			values(
			_cod_agente,
			_tipo,
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
 --trace off;
	-- Generar la Remesa

--	CALL sp_che38(a_compania,a_sucursal,a_user,a_fecha_hasta) returning _error, _descripcion, _no_remesa;

 --trace on;
--let  _error = _error;
--let  _descripcion = _descripcion;

    -- Actualiza Remesa	para que sea automatico, comision semanal 25/02/2008
--	IF _error = 0 THEN
 --		CALL sp_cob29(_no_remesa, a_user) returning _error, _descripcion;
 --	END IF
--trace on;

--let  _error = _error;
--let  _descripcion = _descripcion;
-- trace off;
ELSE
  LET _error = 1;
  LET _descripcion = "No hay registros para procesar";
END IF

END
--trace on;
DROP TABLE tmp_agente;
DROP TABLE tmp_comis;
DROP TABLE tmp_comis2;
RETURN 0,
       "Actualizacion Exitosa";
-- trace off;
END PROCEDURE;