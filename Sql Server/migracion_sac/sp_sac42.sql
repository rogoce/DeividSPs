-- Reporte de Saldos para Mayor General

-- Creado    : 17/06/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_sac42;

create procedure "informix".sp_sac42(
a_ano 	char(4), 
a_mes 	smallint,
a_nivel	smallint,
a_db	char(18)
)

define _cuenta		char(12);
define _debito		dec(16,2);
define _credito		dec(16,2);
define _saldo		dec(16,2);
define _nombre		char(50);
define _referencia	char(20);

define _saldo_ant	dec(16,2);
define _saldo_act	dec(16,2);

define _mes_ant		smallint;
define _ano_ant		char(4);
define _ano_int		smallint;
define _recibe		char(1);
define _nivel		char(1);

define _det_tipo	char(2);
define _det_ccosto	char(3);

--set debug file to "sp_sac42.trc";

let _ano_int = a_ano;
let _mes_ant = a_mes;

if a_mes = 1 then
	let _ano_int = _ano_int - 1;
	let _mes_ant = 14;
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

let _det_tipo   = "*";
let _det_ccosto	= "*";

if a_db = "sac" then

	foreach
	 select	cta_cuenta,
	        referencia,
			cta_nombre
	   into	_cuenta,
			_referencia,
			_nombre
	   from sac:cglcuentas
	  where cta_nivel  matches _nivel
		and cta_recibe matches _recibe
	  order by 1

		select sum(sldet_debtop),
			   sum(sldet_cretop),
			   sum(sldet_saldop)
		  into _debito,
			   _credito,
			   _saldo_act
		  from sac:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = a_ano
		   and sldet_periodo = a_mes;

		select sum(sldet_saldop)
		  into _saldo_ant
		  from sac:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = _ano_ant
	       and sldet_periodo = _mes_ant;

		if _debito is null then
			let _debito = 0;
		end if

		if _credito is null then
			let _credito = 0;
		end if

		if _saldo_act is null then
			let _saldo_act = 0;
		end if

		if _saldo_ant is null then
			let _saldo_ant = 0;
		end if

		if _debito    = 0 and 
		   _credito   = 0 and
		   _saldo_act = 0 and 
		   _saldo_ant = 0 then
			continue foreach;
		end if

		let _saldo = _debito + _credito;

		insert into tmp_saldos(
		cuenta,
		nombre,
		debito,
		credito,
		saldo,
		saldo_ant,
		saldo_act,
		referencia
		)
		values(
		_cuenta,
		_nombre,
		_debito,
		_credito,
		_saldo,
		_saldo_ant,
		_saldo_act,
		_referencia
		);

	end foreach

elif a_db = "sac001" then

	foreach
	 select	cta_cuenta,
	        referencia,
			cta_nombre
	   into	_cuenta,
			_referencia,
			_nombre
	   from sac001:cglcuentas
	  where cta_nivel  matches _nivel
		and cta_recibe matches _recibe
	  order by 1

		select sum(sldet_debtop),
			   sum(sldet_cretop),
			   sum(sldet_saldop)
		  into _debito,
			   _credito,
			   _saldo_act
		  from sac001:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = a_ano
		   and sldet_periodo = a_mes;

		select sum(sldet_saldop)
		  into _saldo_ant
		  from sac001:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = _ano_ant
	       and sldet_periodo = _mes_ant;

		if _debito is null then
			let _debito = 0;
		end if

		if _credito is null then
			let _credito = 0;
		end if

		if _saldo_act is null then
			let _saldo_act = 0;
		end if

		if _saldo_ant is null then
			let _saldo_ant = 0;
		end if

		if _debito    = 0 and 
		   _credito   = 0 and
		   _saldo_act = 0 and 
		   _saldo_ant = 0 then
			continue foreach;
		end if

		let _saldo = _debito + _credito;

		insert into tmp_saldos(
		cuenta,
		nombre,
		debito,
		credito,
		saldo,
		saldo_ant,
		saldo_act,
		referencia
		)
		values(
		_cuenta,
		_nombre,
		_debito,
		_credito,
		_saldo,
		_saldo_ant,
		_saldo_act,
		_referencia
		);

	end foreach

elif a_db = "sac002" then

	foreach
	 select	cta_cuenta,
	        referencia,
			cta_nombre
	   into	_cuenta,
			_referencia,
			_nombre
	   from sac002:cglcuentas
	  where cta_nivel  matches _nivel
		and cta_recibe matches _recibe
	  order by 1

		select sum(sldet_debtop),
			   sum(sldet_cretop),
			   sum(sldet_saldop)
		  into _debito,
			   _credito,
			   _saldo_act
		  from sac002:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = a_ano
		   and sldet_periodo = a_mes;

		select sum(sldet_saldop)
		  into _saldo_ant
		  from sac002:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = _ano_ant
	       and sldet_periodo = _mes_ant;

		if _debito is null then
			let _debito = 0;
		end if

		if _credito is null then
			let _credito = 0;
		end if

		if _saldo_act is null then
			let _saldo_act = 0;
		end if

		if _saldo_ant is null then
			let _saldo_ant = 0;
		end if

		if _debito    = 0 and 
		   _credito   = 0 and
		   _saldo_act = 0 and 
		   _saldo_ant = 0 then
			continue foreach;
		end if

		let _saldo = _debito + _credito;

		insert into tmp_saldos(
		cuenta,
		nombre,
		debito,
		credito,
		saldo,
		saldo_ant,
		saldo_act,
		referencia
		)
		values(
		_cuenta,
		_nombre,
		_debito,
		_credito,
		_saldo,
		_saldo_ant,
		_saldo_act,
		_referencia
		);

	end foreach

elif a_db = "sac003" then

	foreach
	 select	cta_cuenta,
	        referencia,
			cta_nombre
	   into	_cuenta,
			_referencia,
			_nombre
	   from sac003:cglcuentas
	  where cta_nivel  matches _nivel
		and cta_recibe matches _recibe
	  order by 1

		select sum(sldet_debtop),
			   sum(sldet_cretop),
			   sum(sldet_saldop)
		  into _debito,
			   _credito,
			   _saldo_act
		  from sac003:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = a_ano
		   and sldet_periodo = a_mes;

		select sum(sldet_saldop)
		  into _saldo_ant
		  from sac003:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = _ano_ant
	       and sldet_periodo = _mes_ant;

		if _debito is null then
			let _debito = 0;
		end if

		if _credito is null then
			let _credito = 0;
		end if

		if _saldo_act is null then
			let _saldo_act = 0;
		end if

		if _saldo_ant is null then
			let _saldo_ant = 0;
		end if

		if _debito    = 0 and 
		   _credito   = 0 and
		   _saldo_act = 0 and 
		   _saldo_ant = 0 then
			continue foreach;
		end if

		let _saldo = _debito + _credito;

		insert into tmp_saldos(
		cuenta,
		nombre,
		debito,
		credito,
		saldo,
		saldo_ant,
		saldo_act,
		referencia
		)
		values(
		_cuenta,
		_nombre,
		_debito,
		_credito,
		_saldo,
		_saldo_ant,
		_saldo_act,
		_referencia
		);

	end foreach

elif a_db = "sac004" then

	foreach
	 select	cta_cuenta,
	        referencia,
			cta_nombre
	   into	_cuenta,
			_referencia,
			_nombre
	   from sac004:cglcuentas
	  where cta_nivel  matches _nivel
		and cta_recibe matches _recibe
	  order by 1

		select sum(sldet_debtop),
			   sum(sldet_cretop),
			   sum(sldet_saldop)
		  into _debito,
			   _credito,
			   _saldo_act
		  from sac004:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = a_ano
		   and sldet_periodo = a_mes;

		select sum(sldet_saldop)
		  into _saldo_ant
		  from sac004:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = _ano_ant
	       and sldet_periodo = _mes_ant;

		if _debito is null then
			let _debito = 0;
		end if

		if _credito is null then
			let _credito = 0;
		end if

		if _saldo_act is null then
			let _saldo_act = 0;
		end if

		if _saldo_ant is null then
			let _saldo_ant = 0;
		end if

		if _debito    = 0 and 
		   _credito   = 0 and
		   _saldo_act = 0 and 
		   _saldo_ant = 0 then
			continue foreach;
		end if

		let _saldo = _debito + _credito;

		insert into tmp_saldos(
		cuenta,
		nombre,
		debito,
		credito,
		saldo,
		saldo_ant,
		saldo_act,
		referencia
		)
		values(
		_cuenta,
		_nombre,
		_debito,
		_credito,
		_saldo,
		_saldo_ant,
		_saldo_act,
		_referencia
		);

	end foreach

elif a_db = "sac005" then

	foreach
	 select	cta_cuenta,
	        referencia,
			cta_nombre
	   into	_cuenta,
			_referencia,
			_nombre
	   from sac005:cglcuentas
	  where cta_nivel  matches _nivel
		and cta_recibe matches _recibe
	  order by 1

		select sum(sldet_debtop),
			   sum(sldet_cretop),
			   sum(sldet_saldop)
		  into _debito,
			   _credito,
			   _saldo_act
		  from sac005:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = a_ano
		   and sldet_periodo = a_mes;

		select sum(sldet_saldop)
		  into _saldo_ant
		  from sac005:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = _ano_ant
	       and sldet_periodo = _mes_ant;

		if _debito is null then
			let _debito = 0;
		end if

		if _credito is null then
			let _credito = 0;
		end if

		if _saldo_act is null then
			let _saldo_act = 0;
		end if

		if _saldo_ant is null then
			let _saldo_ant = 0;
		end if

		if _debito    = 0 and 
		   _credito   = 0 and
		   _saldo_act = 0 and 
		   _saldo_ant = 0 then
			continue foreach;
		end if

		let _saldo = _debito + _credito;

		insert into tmp_saldos(
		cuenta,
		nombre,
		debito,
		credito,
		saldo,
		saldo_ant,
		saldo_act,
		referencia
		)
		values(
		_cuenta,
		_nombre,
		_debito,
		_credito,
		_saldo,
		_saldo_ant,
		_saldo_act,
		_referencia
		);

	end foreach

elif a_db = "sac006" then

	foreach
	 select	cta_cuenta,
	        referencia,
			cta_nombre
	   into	_cuenta,
			_referencia,
			_nombre
	   from sac006:cglcuentas
	  where cta_nivel  matches _nivel
		and cta_recibe matches _recibe
	  order by 1

		select sum(sldet_debtop),
			   sum(sldet_cretop),
			   sum(sldet_saldop)
		  into _debito,
			   _credito,
			   _saldo_act
		  from sac006:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = a_ano
		   and sldet_periodo = a_mes;

		select sum(sldet_saldop)
		  into _saldo_ant
		  from sac006:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = _ano_ant
	       and sldet_periodo = _mes_ant;

		if _debito is null then
			let _debito = 0;
		end if

		if _credito is null then
			let _credito = 0;
		end if

		if _saldo_act is null then
			let _saldo_act = 0;
		end if

		if _saldo_ant is null then
			let _saldo_ant = 0;
		end if

		if _debito    = 0 and 
		   _credito   = 0 and
		   _saldo_act = 0 and 
		   _saldo_ant = 0 then
			continue foreach;
		end if

		let _saldo = _debito + _credito;

		insert into tmp_saldos(
		cuenta,
		nombre,
		debito,
		credito,
		saldo,
		saldo_ant,
		saldo_act,
		referencia
		)
		values(
		_cuenta,
		_nombre,
		_debito,
		_credito,
		_saldo,
		_saldo_ant,
		_saldo_act,
		_referencia
		);

	end foreach

elif a_db = "sac007" then

	foreach
	 select	cta_cuenta,
	        referencia,
			cta_nombre
	   into	_cuenta,
			_referencia,
			_nombre
	   from sac007:cglcuentas
	  where cta_nivel  matches _nivel
		and cta_recibe matches _recibe
	  order by 1

		select sum(sldet_debtop),
			   sum(sldet_cretop),
			   sum(sldet_saldop)
		  into _debito,
			   _credito,
			   _saldo_act
		  from sac007:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = a_ano
		   and sldet_periodo = a_mes;

		select sum(sldet_saldop)
		  into _saldo_ant
		  from sac007:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = _ano_ant
	       and sldet_periodo = _mes_ant;

		if _debito is null then
			let _debito = 0;
		end if

		if _credito is null then
			let _credito = 0;
		end if

		if _saldo_act is null then
			let _saldo_act = 0;
		end if

		if _saldo_ant is null then
			let _saldo_ant = 0;
		end if

		if _debito    = 0 and 
		   _credito   = 0 and
		   _saldo_act = 0 and 
		   _saldo_ant = 0 then
			continue foreach;
		end if

		let _saldo = _debito + _credito;

		insert into tmp_saldos(
		cuenta,
		nombre,
		debito,
		credito,
		saldo,
		saldo_ant,
		saldo_act,
		referencia
		)
		values(
		_cuenta,
		_nombre,
		_debito,
		_credito,
		_saldo,
		_saldo_ant,
		_saldo_act,
		_referencia
		);

	end foreach

elif a_db = "sac008" then

	foreach
	 select	cta_cuenta,
	        referencia,
			cta_nombre
	   into	_cuenta,
			_referencia,
			_nombre
	   from sac008:cglcuentas
	  where cta_nivel  matches _nivel
		and cta_recibe matches _recibe
	  order by 1

		select sum(sldet_debtop),
			   sum(sldet_cretop),
			   sum(sldet_saldop)
		  into _debito,
			   _credito,
			   _saldo_act
		  from sac008:cglsaldodet
		 where sldet_tipo    matches _det_tipo
		   and sldet_cuenta  = _cuenta
		   and sldet_ccosto  matches _det_ccosto
		   and sldet_ano     = a_ano
		   and sldet_periodo = a_mes;

		select sum(sldet_saldop)
		  into _saldo_ant
		  from sac008:cglsaldodet
		 where sldet_tipo    matches _det_tipo
		   and sldet_cuenta  = _cuenta
		   and sldet_ccosto  matches _det_ccosto
	       and sldet_ano     = _ano_ant
	       and sldet_periodo = _mes_ant;

		if _debito is null then
			let _debito = 0;
		end if

		if _credito is null then
			let _credito = 0;
		end if

		if _saldo_act is null then
			let _saldo_act = 0;
		end if

		if _saldo_ant is null then
			let _saldo_ant = 0;
		end if

		if _debito    = 0 and 
		   _credito   = 0 and
		   _saldo_act = 0 and 
		   _saldo_ant = 0 then
			continue foreach;
		end if

		let _saldo = _debito + _credito;

		insert into tmp_saldos(
		cuenta,
		nombre,
		debito,
		credito,
		saldo,
		saldo_ant,
		saldo_act,
		referencia
		)
		values(
		_cuenta,
		_nombre,
		_debito,
		_credito,
		_saldo,
		_saldo_ant,
		_saldo_act,
		_referencia
		);

	end foreach

end if

{
update tmp_saldos
   set debito = 0
 where debito is null;

update tmp_saldos
   set credito = 0
 where credito is null;

update tmp_saldos
   set saldo_ant = 0
 where saldo_ant is null;

update tmp_saldos
   set saldo_act = 0
 where saldo_act is null;


update tmp_saldos
   set saldo = debito + credito;

delete from tmp_saldos
 where debito    = 0 
   and credito   = 0 
   and saldo     = 0 
   and saldo_ant = 0 
   and saldo_act = 0; 
}
    
end procedure