-- Procedimiento que busca si hay registro en recrcmae antes de crear el reclamo

-- Creado    : 07/10/2011 - Autor: Amado Perez  

drop procedure sp_rwf96;

create procedure sp_rwf96(a_no_reclamo char(10)) 
returning Dec(16,2);

define _reserva_actual               Dec(16,2);

--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;
set isolation to dirty read;

let _reserva_actual = 0;

select sum(reserva_actual)
  into _reserva_actual
  from recrccob
 where no_reclamo = a_no_reclamo;

return _reserva_actual;

end procedure