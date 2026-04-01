-- Procedimiento que busca si hay registro en recrcmae antes de crear el reclamo

-- Creado    : 07/10/2011 - Autor: Amado Perez  

drop procedure sp_rwf178;

create procedure sp_rwf178(a_numrecla varchar(20)) 
returning varchar(10);

define _no_reclamo	varchar(10);

--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;
set isolation to dirty read;

let _no_reclamo = null;

select no_reclamo
  into _no_reclamo
  from recrcmae
 where numrecla = trim(a_numrecla);

return _no_reclamo;

end procedure