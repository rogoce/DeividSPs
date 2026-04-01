  
--drop procedure sp_sis410a;
create procedure "informix".sp_sis410a(a_anno integer)
returning char(10);

define i,_cant_reg,_reg	integer;
define _no_rec_fin      integer;
define _cuantos,_cuantos1 integer;
define _fecha           datetime year to fraction(5);
define _completado smallint;
define _cod_entrada_min   char(10);

set isolation to dirty read;

foreach
 select cod_entrada,cant_registros
   into _cod_entrada_min,_cant_reg
   from atcdocma
  where year(fecha) = a_anno
    and completado = 0
  order by cod_entrada

 select count(*)
   into _reg
   from atcdocde
  where cod_entrada = _cod_entrada_min
    and completado = 1;
	
  if _cant_reg = _reg then	
	return _cod_entrada_min with resume;
  end if
	
end foreach
end procedure