-- Verificacion de reacomp vs produccion
--
-- Creado    : 06/08/2010 - Autor: Demetrio Hurtado Almanza
--
--drop procedure sp_rea020;

create procedure "informix".sp_rea020() 
returning char(10);

define _no_registro	char(10);

foreach
 select r.no_registro
   into _no_registro
   from sac999:reacomp r, endedmae e
  where r.no_poliza = e.no_poliza
    and r.no_endoso = e.no_endoso
    and r.periodo   <> e.periodo
    and e.periodo   >= "2010-07"

	delete from sac999:reacompasiau where no_registro = _no_registro;
	delete from sac999:reacompasie  where no_registro = _no_registro;
	delete from sac999:reacomp      where no_registro = _no_registro;

	return _no_registro with resume;

end foreach

end procedure