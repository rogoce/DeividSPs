-- Procedimiento que Arregla los valores de Colectivo-Individual en polizas

-- Creado    : 20/10/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 03/07/2001 - Autor: Demetrio Hurtado Almanza

drop procedure sp_sis92;

create procedure "informix".sp_sis92()
returning char(10),
          integer;

define _no_poliza	char(10);
define _cantidad	integer;

foreach
 select p.no_poliza, 
        count(*)
   into _no_poliza,
        _cantidad
   from emipomae p, emipouni u
  where p.no_poliza = u.no_poliza
    and p.colectiva = "I"
    and p.actualizado = 1
--    and p.cod_ramo = "002"
 --and p.no_documento = "1604-00024-01"
  group by p.no_poliza
 having count(*) > 1

{
	update emipomae
	   set colectiva = "C"
	 where no_poliza = _no_poliza;
}
	return _no_poliza,
	       _cantidad
		   with resume;

end foreach

return "",
       0;

end procedure