--drop procedure sp_rec118;

create procedure "informix".sp_rec118(a_usuer char(8))

define _no_reclamo	char(10);

foreach
 select no_reclamo
   into _no_reclamo
   from recrcmae
  where cod_compania = "001"
    and cod_sucursal = "001"
    and user_added   = a_usuer
    and actualizado  = 0

	execute procedure sp_rec117(_no_reclamo);

end foreach


end procedure