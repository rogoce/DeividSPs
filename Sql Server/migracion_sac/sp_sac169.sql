-- Procedure que verifica que cuadre cglresumen vs cglsaldodet

-- Creado    : 13/09/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac169;

create procedure sp_sac169(a_cta_cuenta char(25))
returning char(1);

define _est_nivel		char(1);
define _est_posinicial	smallint;
define _est_posfinal	smallint;

define _cta_nivel		char(1);
define _largo			smallint;

let _largo = length(a_cta_cuenta);

let _cta_nivel = 0;

foreach
 select est_nivel,
 		est_posinicial,
 		est_posfinal
   into _est_nivel,
 		_est_posinicial,
 		_est_posfinal
   from cglestructura

	if _largo >= _est_posinicial and
	   _largo <= _est_posfinal   then

		let _cta_nivel = _est_nivel;
		exit foreach;
	end if

end foreach

return _cta_nivel;

end procedure 