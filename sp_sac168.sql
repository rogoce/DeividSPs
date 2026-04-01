-- Procedure que verifica que cuadre cglresumen vs cglsaldodet

-- Creado    : 13/09/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac168;

create procedure sp_sac168()
returning char(25),
          char(1),
          smallint,
          char(1);

define _cta_cuenta	char(25);
define _cta_nivel	char(1);
define _cta_nivel2	char(1);

define _largo		smallint;

foreach
 select cta_cuenta,
        cta_nivel
   into _cta_cuenta,
        _cta_nivel
   from cglcuentas

	let _largo      = length(_cta_cuenta);
	let _cta_nivel2 = sp_sac169(_cta_cuenta);

	if _cta_nivel <> _cta_nivel2 then
		
		return _cta_cuenta,
		       _cta_nivel,
			   _largo,
			   _cta_nivel2
			   with resume;

	end if

end foreach

return "",
       "0",
	   0,
	   "0"
	   with resume;

end procedure 