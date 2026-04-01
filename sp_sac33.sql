-- Estados Financieros en BO para los Fines de Año

-- Creado    : 15/03/2005 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_sac33;

create procedure "informix".sp_sac33()

define _tipo		char(2);
define _cuenta		char(12);
define _ccosto		char(3);
define _ano			char(4);
define _periodo		smallint;
define _debito		dec(16,2);
define _credito		dec(16,2);

define _saldo_ant	dec(16,2);
define _saldo_act	dec(16,2);

define _mes_ant		smallint;
define _ano_ant		char(4);
define _ano_int		smallint;
define _mes			smallint;

set isolation to dirty read;

let _ano    = "2005";
let _tipo   = "01";
let _ccosto = "001";

delete from cglsaldodet2;

foreach
 select	cta_cuenta
   into	_cuenta
   from cglcuentas
  where cta_recibe = "S"
  order by cta_cuenta

	for _periodo = 1 to 14 

		-- Movimiento del Mes

		select sldet_debtop,
			   sldet_cretop
		  into _debito,
			   _credito
		  from cglsaldodet
		 where sldet_tipo    = _tipo
		   and sldet_cuenta  = _cuenta
		   and sldet_ccosto  = _ccosto
		   and sldet_ano     = _ano
		   and sldet_periodo = _periodo;
 		
		-- Saldo del Periodo Anterior

		let _ano_int = _ano;
		let _mes_ant = _periodo;

		if _periodo = 1 then
			let _ano_int = _ano_int - 1;
			let _mes_ant = 12;
		else
			let _mes_ant = _mes_ant - 1;
		end if

		let _ano_ant = _ano_int;

		if _periodo = 1 then 
			
			if _cuenta[1,1] >= 4 then 

				let _saldo_ant = 0.00;

			else

				select sldet_saldop
				  into _saldo_ant
				  from cglsaldodet
			     where sldet_tipo    = _tipo
			       and sldet_cuenta  = _cuenta
				   and sldet_ccosto  = _ccosto
				   and sldet_ano     = _ano_ant
			       and sldet_periodo = _mes_ant;

			end if

		else 

			select sldet_debtop
			  into _saldo_ant
			  from cglsaldodet2
		     where sldet_tipo    = _tipo
		       and sldet_cuenta  = _cuenta
			   and sldet_ccosto  = _ccosto
			   and sldet_ano     = _ano_ant
		       and sldet_periodo = _mes_ant;

		end if
		
		-- Actualizacion de la Tabla

		if _saldo_ant is null then
			let _saldo_ant = 0.00;
		end if
		   
		if _debito is null then
			let _debito = 0.00;
		end if

		if _credito is null then
			let _credito = 0.00;
		end if

		let _saldo_act = _saldo_ant + _debito + _credito;

		insert into cglsaldodet2
		values (
		_tipo,
	    _cuenta,
		_ccosto,
		_ano,
		_periodo,
		_saldo_act,
		0.00,
		0.00,
		"",
		""
		);

	end for

end foreach

end procedure