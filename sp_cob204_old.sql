-- Generacion de los Lotes de las Tarjetas de Credito American

-- Creado    : 22/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 16/02/2007 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob204;

CREATE PROCEDURE "informix".sp_cob204(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_fecha			DATE,
a_periodo		CHAR(1),
a_user			CHAR(8)
) RETURNING SMALLINT,
            CHAR(100);

DEFINE _no_lote_char	CHAR(5);
define _error_desc		CHAR(100);
DEFINE _no_tarjeta		CHAR(19);
DEFINE _codigo          CHAR(2);
DEFINE _monto			DEC(16,2);
DEFINE _fecha_exp		CHAR(7);
DEFINE _no_documento	CHAR(20);
DEFINE _nombre			CHAR(100);
--DEFINE _cod_cliente		CHAR(10);

DEFINE _max_por_lote	INTEGER;
DEFINE _max_por_tran	INTEGER;
DEFINE _cant_tran		INTEGER;
DEFINE _cant_lote       INTEGER;

DEFINE _saldo           DEC(16,2);
DEFINE _cargo			DEC(16,2);
DEFINE _procesar        SMALLINT;
DEFINE _error_code      SMALLINT;
DEFINE _fecha_hoy		date;
define _fecha_hasta     date;
define _periodo         char(1);
define _periodo2        char(1);
DEFINE _ult_pago        DEC(16,2);
DEFINE _pronto_pago		SMALLINT;
define _valor			SMALLINT;
define _mensaje			char(50);
define v_fecha          date;
define v_periodo        char(7);
define _dif             decimal(16,2);
define v_por_vencer		decimal(16,2);
define v_exigible		decimal(16,2);
define v_corriente		decimal(16,2);
define v_monto_30		decimal(16,2);
define v_monto_60		decimal(16,2);
define v_monto_90		decimal(16,2);
define v_saldo			decimal(16,2);
define _dia_especial	smallint;
define _cnt_dia_esp		smallint;
define _dia				smallint;
define _fecha_inicio	date;


--set debug file to "sp_cob204.trc";
--trace on ;



LET _max_por_lote = 99;
--LET _max_por_tran = 998; --se cambio 14/06/2013 
LET _max_por_tran = 499; --se cambio 15/07/2014
LET _codigo       = '40';
let _mensaje      = "";
let _periodo2     = null;

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar los Lotes';
END EXCEPTION           

--let a_periodo = '1'

let v_fecha       = today;
if month(v_fecha) < 10 then
	let v_periodo = year(v_fecha) || '-0' || month(v_fecha);
else
	let v_periodo = year(v_fecha) || '-' || month(v_fecha);
end if 

call sp_cob338('AME',a_fecha) returning _error_code,_error_desc;


SELECT COUNT(*)
  INTO _cant_tran
  FROM cobtacre
 WHERE periodo = a_periodo;

IF _cant_tran IS NULL THEN
	LET _cant_tran = 0; 
END IF

IF _cant_tran = 0 THEN
	RETURN 1, 'No Existen Tarjetas para Procesar en esta Quincena ... '; 
END IF

IF _cant_tran > (_max_por_lote * _max_por_tran) THEN
	RETURN 1, 'Cantidad de Transacciones Excede el Maximo Permitido por el Banco ...'; 
END IF

DELETE FROM cobtatra;
DELETE FROM cobtalot;

let _fecha_hoy    = today;

LET _cant_lote = 0;
LET _cant_tran = 0;

LET _cant_lote    = _cant_lote + 1;
LET _no_lote_char = sp_set_codigo(5, _cant_lote);

-- Crea el Lote Inicial

INSERT INTO cobtalot
VALUES(
_no_lote_char,
a_fecha,
0,
0,
a_user,
'',
a_sucursal,
1,null,0      
);	

let _fecha_hasta = null;

-- Procesa Todas las Tarjetas de Credito
FOREACH
 SELECT h.no_tarjeta,
		c.monto,
		c.cargo_especial,
		h.fecha_exp,
		c.no_documento,
		h.nombre,
		c.fecha_inicio,
		c.fecha_hasta,
		c.dia,
		c.dia_especial
   INTO _no_tarjeta,
		_monto,
		_cargo,
		_fecha_exp,
		_no_documento,
		_nombre,
		_fecha_inicio,
		_fecha_hasta,
		_dia,
		_dia_especial
   FROM cobtacre c, cobtahab h
  WHERE c.no_tarjeta = h.no_tarjeta
    --AND c.periodo    = a_periodo
	AND c.procesar   = 1
	AND h.tipo_tarjeta = "4"
  ORDER BY h.nombre


	call sp_cob33('001', '001', _no_documento, v_periodo, v_fecha)
	returning   v_por_vencer,
				v_exigible,
				v_corriente,
				v_monto_30,
				v_monto_60,
				v_monto_90,
				v_saldo;

	if _monto < v_exigible then
		let _dif = 0;
		let _dif = v_exigible - _monto;
		if _dif <= 1.00 then
			let _monto = v_exigible;
		end if

	end if

	--Esto es para el cargo adicional.

	if _periodo2 is null then
		let _periodo2 = "0";
	end if

	{if _fecha_hasta is not null then

		if _fecha_hasta > _fecha_hoy then  -- tiene cargo adicional
			if _periodo = _periodo2 then   -- se debe sumar el cargo al monto
				let _monto = _monto + _cargo;
			else
				if a_periodo = _periodo2 then
					if _cargo > 0 then
						let _monto = _cargo;
					end if
				end if
			end if
		end if
	end if}
	
	if _fecha_hasta is not null then
		if _fecha_hasta >= _fecha_hoy then  -- tiene cargo adicional
			if _fecha_inicio <= _fecha_hoy then --ok
				
				select count(*)
				  into _cnt_dia_esp
				  from tmp_dias_proceso
				  where dia = _dia;
				
				if _cnt_dia_esp is null then
					let _cnt_dia_esp = 0;
				end if
				
				if _cnt_dia_esp <> 0 then    -- se debe sumar el cargo al monto
					let _monto = _monto + _cargo;
				else
					let _monto = _cargo;
				end if
			end if
		end if
	end if

 	SELECT SUM(saldo)                   
 	  INTO _saldo                       
 	  FROM emipomae                     
 	 WHERE no_documento = _no_documento 
 	   AND actualizado  = 1;            

	IF _saldo IS NULL THEN
		LET _saldo = 0;
	END IF

	LET _procesar = 1;              
	LET _cant_tran = _cant_tran + 1;

	IF _cant_tran > _max_por_tran THEN

		LET _cant_tran    = 1;
		LET _cant_lote    = _cant_lote + 1;
		LET _no_lote_char = sp_set_codigo(5, _cant_lote);

		INSERT INTO cobtalot
		VALUES(
		_no_lote_char,
		a_fecha,
		0,
		0,
		a_user,
		'               ',
		a_sucursal,
		1,null,0      
		);	

	END IF

    let _ult_pago    = 0;
    let _pronto_pago = 0;
    call sp_sis395(_no_documento) returning _valor, _mensaje,_ult_pago;

    if _valor = 0 then
		let _pronto_pago = 1;
		let _monto       = _ult_pago;
    else
		let _pronto_pago = 0;		
    end if

	INSERT INTO cobtatra
	VALUES(
	_no_lote_char,
	_cant_tran,
	_no_tarjeta,
	_codigo,
	_monto,
	_fecha_exp,
	_no_documento,
	_nombre,
	_saldo,
	_procesar,
	'',
	_pronto_pago
	);
END FOREACH

FOREACH
 SELECT COUNT(*),
  	    SUM(monto),
	    no_lote
   INTO _cant_tran,
        _monto,
        _no_lote_char
   FROM cobtatra
  GROUP BY no_lote      

	UPDATE cobtalot
	   SET total_transac = _cant_tran,
	       total_monto   = _monto
     WHERE no_lote       = _no_lote_char;
     
END FOREACH
       	   	
RETURN 0, 'Actualizacion Exitosa ...'; 

END 

END PROCEDURE;
