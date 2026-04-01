-- Reporte de Saldos para Mayor General

-- Creado    : 17/06/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_sac01;

create procedure "informix".sp_sac01(
a_ano 	char(4), 
a_mes 	smallint,
a_nivel	smallint
) returning char(2),
            char(12),
		    char(50),
		    dec(16,2),
		    dec(16,2),
		    dec(16,2),
		    dec(16,2),
		    dec(16,2),
            char(3);

define _tipo		char(2);
define _cuenta		char(12);
define _debito		dec(16,2);
define _credito		dec(16,2);
define _saldo		dec(16,2);
define _nombre		char(50);

define _saldo_ant	dec(16,2);
define _saldo_act	dec(16,2);

define _mes_ant		smallint;
define _ano_ant		char(4);
define _ano_int		smallint;
define _recibe		char(1);
define _nivel		char(1);
define _cuenta_may	char(3);

define _det_tipo	char(2);
define _det_ccosto	char(3);

let _det_tipo   = "01";
let _det_ccosto = "001";

let _ano_int = a_ano;
let _mes_ant = a_mes;

if a_mes = 1 then
	let _ano_int = _ano_int - 1;
	let _mes_ant = 12;
else
	let _mes_ant = _mes_ant - 1;
end if

let _ano_ant = _ano_int;

if a_nivel = 1 then
	let _recibe = "*";
	let _nivel  = "1";
else
	let _recibe = "S";
	let _nivel  = "*";
end if
	
foreach
 select	cta_cuenta
   into	_cuenta
   from cglcuentas
  where cta_nivel  matches _nivel
	and cta_recibe matches _recibe
  order by 1

	select sldet_debtop,
		   sldet_cretop,
		   sldet_saldop
	  into _debito,
		   _credito,
		   _saldo_act
	  from cglsaldodet
	 where sldet_tipo    = _det_tipo
	   and sldet_cuenta  = _cuenta
	   and sldet_ccosto  = _det_ccosto
	   and sldet_ano     = a_ano
	   and sldet_periodo = a_mes;

	if _debito is null then
		let _debito = 0.00;
	end if

	if _credito is null then
		let _credito = 0.00;
	end if

	if _saldo_act is null then
		let _saldo_act = 0.00;
	end if

	select sldet_saldop
	  into _saldo_ant
	  from cglsaldodet
	 where sldet_tipo    = _det_tipo
	   and sldet_cuenta  = _cuenta
	   and sldet_ccosto  = _det_ccosto
       and sldet_ano     = _ano_ant
       and sldet_periodo = _mes_ant;
	
	if _saldo_ant is null then
		let _saldo_ant = 0.00;
	end if
	   
	let _saldo      = _debito + _credito;
	let _tipo       = _cuenta[1,1];
	let _cuenta_may = _cuenta[1,3];

	if 	_debito    = 0.00 and
		_credito   = 0.00 and
		_saldo	   = 0.00 and
		_saldo_ant = 0.00 and
		_saldo_act = 0.00 then
		continue foreach;
	end if

	select cta_nombre
	  into _nombre
	  from cglcuentas
	 where cta_cuenta = _cuenta;

	return _tipo,
	       _cuenta,
		   _nombre,
		   _debito,
		   _credito,
		   _saldo,
		   _saldo_ant,
		   _saldo_act,
		   _cuenta_may
		   with resume;

end foreach

end procedure