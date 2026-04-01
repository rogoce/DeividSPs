-- 
-- Creado    : 23/01/2004 - Autor: Armando Moreno M.

-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

drop procedure sp_averiguar2;

create procedure sp_averiguar2(a_cobrador char(3))
returning integer,
		  integer,
		  integer;

define _cod_cliente		char(10);
define _cnt_rutero,_cnt_cobcapen      integer;
define _cnt_saldo_cero  integer;
define _cantidad  smallint;
define _existe    smallint;
define _tiene_una smallint;
define v_documento char(20);
DEFINE v_por_vencer     DEC(16,2);
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente		DEC(16,2);
DEFINE v_monto_30		DEC(16,2);
DEFINE v_monto_60		DEC(16,2);
DEFINE v_monto_90		DEC(16,2);
DEFINE v_apagar			DEC(16,2);
DEFINE v_saldo			DEC(16,2);
define _fecha_hoy       date;
define _mes_char      char(2);
define _ano_char      char(4);
define _periodo       char(7);
define _fecha_ult_dia  date;


--set debug file to "sp_cob101.trc";

set isolation to dirty read;

let _cnt_rutero   = 0;
let _cnt_cobcapen = 0;
let _cnt_saldo_cero = 0;
LET _cod_cliente  = null;
let _fecha_hoy    = current;

-- Armar varibale que contiene el periodo(aaaa-mm)

IF  MONTH(_fecha_hoy) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_hoy);
ELSE
	LET _mes_char = MONTH(_fecha_hoy);
END IF

LET _ano_char = YEAR(_fecha_hoy);
LET _periodo  = _ano_char || "-" || _mes_char;

CALL sp_sis36(_periodo) RETURNING _fecha_ult_dia;

begin

foreach
	select cod_cliente
	  into _cod_cliente
 	  from cascliente
	 where cod_cobrador = a_cobrador

	select count(*)
      into _cantidad
      from cobcapen
     where cod_cliente = _cod_cliente;

	select count(*)
	  into _existe
	  from cobruter1
	 where cod_pagador = _cod_cliente;

	if _existe = 1 then
		let _cnt_rutero = _cnt_rutero + 1;
	end if

	if _cantidad = 0 then
		let _cnt_cobcapen = _cnt_cobcapen + 1;

		 select	count(*)
		   into	_tiene_una
		   from	caspoliza
		  where	cod_cliente = _cod_cliente;

		 if _tiene_una = 1 then

			 select no_documento
			   into v_documento
			   from caspoliza
			  where cod_cliente = _cod_cliente;

			 CALL sp_cob33(
				'001',
				'001',
				v_documento,
				_periodo,
				_fecha_ult_dia
				) RETURNING v_por_vencer,
						    v_exigible,  
						    v_corriente,
						    v_monto_30,  
						    v_monto_60,  
						    v_monto_90,
						    v_saldo
						    ;

			 if v_saldo <= 0 then
				let _cnt_saldo_cero = _cnt_saldo_cero + 1;
			 end if

		 end if
	end if


end foreach

    return _cnt_cobcapen,
		   _cnt_rutero,
		   _cnt_saldo_cero;

end

end procedure