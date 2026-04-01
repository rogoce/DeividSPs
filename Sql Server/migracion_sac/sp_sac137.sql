-- Comparacion del catalogo de cuenta entre Ancon y Promotora

drop procedure sp_sac137;

create procedure sp_sac137()
returning char(25),
          char(100);

define _cta_cuenta_1	char(25);
define _cta_cuenta_2	char(25);
define _nombre			char(100);

define _cantidad		smallint;

foreach
 select	cta_cuenta,
        cta_nombre
   into _cta_cuenta_1,
        _nombre
   from sac:cglcuentas
  order by 1
  
	select count(*)
	  into _cantidad
	  from sac006:cglcuentas
	 where cta_cuenta = _cta_cuenta_1;
	 
	 if _cantidad = 0 then
	 
		insert into sac006:cglcuentas
		select *
		  from sac:cglcuentas
		 where cta_cuenta = _cta_cuenta_1;

	 	return _cta_cuenta_1,
		       _nombre
			   with resume;

	end if

end foreach    

return "0", "Proceso Completado";

end procedure