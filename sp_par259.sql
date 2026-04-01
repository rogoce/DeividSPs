-- Procedure que crea las cuentas de los cheques anulados

drop procedure sp_par259;

create procedure "informix".sp_par259(a_no_requis char(10))
returning smallint,
          char(50);

define _renglon_old		smallint;
define _renglon_new		smallint;
define _cantidad		smallint;

define _cuenta			char(50);
define _debito			dec(16,2);
define _credito			dec(16,2);
define _cod_auxiliar	char(5);
define _centro_costo	char(3);

select count(*)
  into _cantidad
  from chqchcta
 where no_requis = a_no_requis
   and tipo      = 2;

if _cantidad <> 0 then
	return 1, "Este Cheque ya tiene las cuentas anuladas";
end if

select max(renglon)
  into _renglon_new
  from chqchcta
  where no_requis = a_no_requis;

foreach
 select cuenta,
        debito,
		credito,
		cod_auxiliar,
		renglon,
		centro_costo
   into	_cuenta,
        _debito,
		_credito,
		_cod_auxiliar,
		_renglon_old,
		_centro_costo
   from chqchcta
  where no_requis = a_no_requis
    and tipo      = 1

	let _renglon_new = _renglon_new + 1;
	
	insert into chqchcta (no_requis, renglon, cuenta, debito, credito, cod_auxiliar, tipo, centro_costo)
	values (a_no_requis, _renglon_new, _cuenta, _credito, _debito, _cod_auxiliar, 2, _centro_costo);
	
	foreach 
	 select debito,
			credito,
			cod_auxiliar
	   into	_debito,
			_credito,
			_cod_auxiliar
	   from chqctaux
	  where no_requis = a_no_requis
	    and renglon   = _renglon_old

		insert into chqctaux (no_requis, renglon, cuenta, cod_auxiliar, debito, credito)
		values (a_no_requis, _renglon_new, _cuenta, _cod_auxiliar, _credito, _debito);

	end foreach

end foreach


update chqchmae
   set sac_anulados = 0
 where no_requis    = a_no_requis;


return 0, "Actualizacion Exitosa";

end procedure
