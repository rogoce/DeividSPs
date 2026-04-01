-- Procedure que verifica la Integridad del Catalogo

-- Creado    : 17/06/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_sac19;

create procedure "informix".sp_sac19(a_ano char(4), a_mes smallint)
returning char(12),
          dec(16,2),
		  dec(16,2);

define _cuenta	char(12);
define _cuenta2	char(12);
define _cuenta_	char(12);
define _saldo1	dec(16,2);
define _saldo2	dec(16,2);
define _saldo3	dec(16,2);
define _nivel1	smallint;
define _nivel2	smallint;
define _cant	smallint;

set isolation to dirty read;

foreach
 select sldet_cuenta,
        sldet_saldop
   into _cuenta,
		_saldo1
   from cglsaldodet
  where sldet_ano     = a_ano
    and sldet_periodo = a_mes
--	and sldet_cuenta  like "1%"
  order by sldet_cuenta

	select cta_nivel
	  into _nivel1
	  from cglcuentas
	 where cta_cuenta = _cuenta; 	

	let _nivel1  = _nivel1 + 1;
	let _cuenta_ = trim(_cuenta) || "%";
	let _saldo3  = 0.00;

	let _cant = 0;

	foreach
	 select sldet_cuenta,
        	sldet_saldop
	   into _cuenta2,
			_saldo2
	   from cglsaldodet
	  where sldet_ano     = a_ano
	    and sldet_periodo = a_mes
		and sldet_cuenta  like _cuenta_
		and sldet_cuenta  <> _cuenta

		let _cant = _cant + 1;

		select cta_nivel
		  into _nivel2
		  from cglcuentas
		 where cta_cuenta = _cuenta2; 	

		if _nivel1 = _nivel2 then
			let _saldo3 = _saldo3 + _saldo2;
		end if

	end foreach

	if _cant = 0 then
		continue foreach;
	end if

	if _saldo1 <> _saldo3 then

		return _cuenta,
		       _saldo1,
		       _saldo3
		       with resume; 
	end if
	
end foreach

end procedure 