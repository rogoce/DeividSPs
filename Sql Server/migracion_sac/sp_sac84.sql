-- Procedure que arregla los saldos de los auxiliares

drop procedure sp_sac84;

create procedure sp_sac84(
a_cuenta	char(25),
a_ano		smallint,
a_periodo	smallint,
a_tercero	char(5),
a_debito	dec(16,2),
a_credito	dec(16,2)
) returning char(25),
            char(5),
            smallint,
            smallint,
            dec(16,2),
            dec(16,2),
            dec(16,2);

define _saldo_ant	dec(16,2);
define _mes_ant		smallint;

define _ano_for		smallint;
define _mes_for		smallint;
define _mes_ini		smallint;

define _monto_neto	dec(16,2);

let _mes_ant = a_periodo - 1;

select sld1_saldo
  into _saldo_ant
  from sac:cglsaldoaux1
 where sld1_tipo    = "01"
   and sld1_cuenta  = a_cuenta
   and sld1_tercero = a_tercero
   and sld1_ano     = a_ano
   and sld1_periodo = _mes_ant;

if _saldo_ant is null then

	let _saldo_ant = 0.00;

	insert into sac:cglsaldoaux
	values("01", a_cuenta, a_tercero, a_ano, 0.00);

	insert into sac:cglsaldoaux1
	values("01", a_cuenta, a_tercero, a_ano, a_periodo, 0.00, 0.00, 0.00);

end if

update sac:cglsaldoaux1
   set sld1_debitos  = a_debito,
       sld1_creditos = a_credito
 where sld1_tipo     = "01"
   and sld1_cuenta   = a_cuenta
   and sld1_tercero  = a_tercero
   and sld1_ano      = a_ano
   and sld1_periodo  = a_periodo;

for _ano_for = a_ano to 2007

	if _ano_for = a_ano then
		let _mes_ini = a_periodo;
	else
		let _mes_ini = 1;
	end if

	for _mes_for = _mes_ini to 14

		select (sld1_debitos + sld1_creditos)
		  into _monto_neto
		  from sac:cglsaldoaux1
		 where sld1_tipo    = "01"
		   and sld1_cuenta  = a_cuenta
		   and sld1_tercero = a_tercero
		   and sld1_ano     = _ano_for
		   and sld1_periodo = _mes_for;

		if _monto_neto is null then

			let _monto_neto = 0.00;

			insert into sac:cglsaldoaux1
			values("01", a_cuenta, a_tercero, _ano_for, _mes_for, 0.00, 0.00, 0.00);

		end if

		update sac:cglsaldoaux1
		   set sld1_saldo	 = _saldo_ant + _monto_neto
		 where sld1_tipo     = "01"
		   and sld1_cuenta   = a_cuenta
		   and sld1_tercero  = a_tercero
		   and sld1_ano      = _ano_for
		   and sld1_periodo  = _mes_for;

		return a_cuenta,
		       a_tercero,
			   _ano_for,
			   _mes_for,
			   _saldo_ant,
			   _monto_neto,
			   (_saldo_ant + _monto_neto)
			   with resume;

		let _saldo_ant = _saldo_ant + _monto_neto;
		
	end for

end for

end procedure