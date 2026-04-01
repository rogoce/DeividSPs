-- Numero Interno de Reclamo para Workflow

-- Creado    : 10/03/2004 - Autor: Demetrio Hurtado Almanza 

--drop procedure sp_sis111;

create procedure "informix".sp_sis111()
returning char(10),
          dec(16,4);

define _no_poliza		char(10);

define _porc_partic_agt	dec(16,4);

define _cantidad		integer;
define _error			integer;

set isolation to dirty read;

let _error = 0;

foreach 
 select p.no_poliza, 
        sum(porc_partic_agt)
   into _no_poliza,
        _porc_partic_agt
   from emipomae p, emipoagt a
  where p.no_poliza = a.no_poliza
    and p.actualizado = 1
  group by 1
 having sum(porc_partic_agt) <> 100

	return _no_poliza,
		   _porc_partic_agt
		   with resume;

end foreach

return "", 0.00;

end procedure