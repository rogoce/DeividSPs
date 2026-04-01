-- Procedure que crea el registro de la cuenta auxiliar para los cheques
-- 
-- Creado    : 07/11/2007 - Autor: Demetrio Hurtado Almanza

DROP PROCEDURE sp_sac74;

create procedure "informix".sp_sac74() 
returning smallint,
          char(50);

define _cod_auxiliar	char(5);
define _cantidad		smallint;
define _no_requis		char(10);
define _cuenta			char(25);
define _debito			dec(16,2);
define _credito			dec(16,2);
define _renglon			smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

foreach
 select c.cod_auxiliar,
        c.no_requis,
		c.renglon,
		c.cuenta,
		c.debito,
		c.credito
   into _cod_auxiliar,
        _no_requis,
		_renglon,
		_cuenta,
		_debito,
		_credito
   from chqchmae m, chqchcta c
  where m.no_requis    = c.no_requis
    and m.pagado       = 1
	and m.sac_asientos = 0
	and c.tipo         = 1
	and c.cod_auxiliar is not null

	select count(*)
	  into _cantidad
	  from chqctaux
	 where no_requis = _no_requis
	   and renglon   = _renglon;

	if _cantidad = 0 then

		insert into chqctaux (no_requis, renglon, cuenta, cod_auxiliar, debito, credito)
		values (_no_requis, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);
	
	end if

end foreach

foreach
 select c.cod_auxiliar,
        c.no_requis,
		c.renglon,
		c.cuenta,
		c.debito,
		c.credito
   into _cod_auxiliar,
        _no_requis,
		_renglon,
		_cuenta,
		_debito,
		_credito
   from chqchmae m, chqchcta c
  where m.no_requis    = c.no_requis
    and m.anulado      = 1
	and m.sac_anulados = 0
	and c.tipo         = 2
	and c.cod_auxiliar is not null

	select count(*)
	  into _cantidad
	  from chqctaux
	 where no_requis = _no_requis
	   and renglon   = _renglon;

	if _cantidad = 0 then

		insert into chqctaux (no_requis, renglon, cuenta, cod_auxiliar, debito, credito)
		values (_no_requis, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);
	
	end if

end foreach

end

return 0, "Actualizacion Exitosa";

end procedure