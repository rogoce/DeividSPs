
drop procedure sp_rea011;

create procedure "informix".sp_rea011()
returning smallint,
          char(50);

define _cuenta	 	char(25);
define _cantidad	smallint;
define _no_registro	char(10);

define _cta_nivel	smallint;
define _indice		smallint;
define _posfinal	smallint;

foreach
 select a.cuenta,
        a.no_registro
   into _cuenta,
        _no_registro
   from sac999:reacompasie a, sac999:reacomp r
  where a.no_registro  = r.no_registro
    and r.sac_asientos = 1
--  group by cuenta
--  order by cuenta

	select count(*)
	  into _cantidad
	  from cglcuentas
	 where cta_cuenta = _cuenta;

	if _cantidad = 0 then

		return 1, _cuenta || " " || _no_registro with resume;

	else

		select cta_nivel
		  into _cta_nivel
		  from cglcuentas
	 	 where cta_cuenta = _cuenta;

		for _indice = _cta_nivel to 1 step -1 

			select est_posfinal 
			  into _posfinal
			  from cglestructura
			 where est_nivel = _indice;

			let _cuenta = substring(_cuenta from 1 for _posfinal);

			select count(*)
			  into _cantidad
			  from cglcuentas
			 where cta_cuenta = _cuenta;

			if _cantidad = 0 then

				return 1, _cuenta || " " || _no_registro with resume;

			end if

		end for

	end if

end foreach

return 0, "Verificacion Completa";

end procedure
