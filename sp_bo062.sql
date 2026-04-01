-- Procedimiento que crea los montos cobrados

-- Creado    : 04/09/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo062;

create procedure "informix".sp_bo062()
returning integer,
          char(50);

define _no_poliza		char(10);
define _no_documento	char(20);
define _centro_costo	char(3);
define _cuenta			char(25);
define _enlace			char(10);
define _periodo			char(7);
define _cod_tipoprod	char(3);

define _ano				char(4);
define _mes				smallint;
define _cia_comp		char(3);

define _monto			dec(16,2);
define _prima_cob_acu	dec(16,2);
define _cantidad		smallint;

define _error			integer;
define _error_desc		char(50);

delete from sac:cglsaldocob;

foreach
 select cuenta,
        periodo,
		centro_costo,
        sum(credito - debito)
   into _cuenta,
        _periodo,
		_centro_costo,
        _monto
   from cobasien
  where periodo[1,4] >= 2009
	and cuenta       like "131%"
  group by 1, 2, 3

	let _enlace = _cuenta[4,25];

	select count(*)
	  into _cantidad
	  from sac:cglsaldocob
	 where cia_comp = "001"
	   and ano      = _periodo[1,4]
	   and periodo  = _periodo[6,7]
	   and enlace   = _enlace
	   and ccosto	= _centro_costo;

	if _cantidad = 0 then

		insert into sac:cglsaldocob(cia_comp, ano, periodo, enlace, ccosto, prima_cobrada, prima_cobrada_acu)
		values ("001", _periodo[1,4], _periodo[6,7], _enlace, _centro_costo, _monto, 0.00);

	else

		update sac:cglsaldocob
		   set prima_cobrada = prima_cobrada + _monto
		 where cia_comp      = "001"
		   and ano           = _periodo[1,4]
		   and periodo       = _periodo[6,7]
		   and enlace        = _enlace
		   and ccosto	     = _centro_costo;

	end if

end foreach

foreach
 select cia_comp,
        ano,
		enlace,
		ccosto
   into _cia_comp,
        _ano,
		_enlace,
		_centro_costo
   from sac:cglsaldocob
  group by 1, 2, 3, 4
  order by 1, 2, 3, 4

	let _prima_cob_acu = 0.00;

	foreach
	 select periodo,
	        prima_cobrada
	   into _mes,
	        _monto
	   from sac:cglsaldocob
	  where cia_comp = _cia_comp
	    and ano      = _ano
		and enlace   = _enlace
		and ccosto   = _centro_costo
	  order by 1

		let _prima_cob_acu = _prima_cob_acu + _monto;

		update sac:cglsaldocob
		   set prima_cobrada_acu = _prima_cob_acu
		 where cia_comp          = _cia_comp
		   and ano               = _ano
		   and periodo           = _mes
		   and enlace            = _enlace
		   and ccosto            = _centro_costo;

	end foreach

end foreach

return 0, "Actualizacion Exitosa";

end procedure