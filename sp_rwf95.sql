-- Procedimiento que busca si hay registro en recrcmae antes de crear el reclamo

-- Creado    : 07/10/2011 - Autor: Amado Perez  

--drop procedure sp_rwf90;

create procedure sp_rwf95(a_no_reclamo char(10)) 
returning smallint;

define _cant               smallint;

--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;
set isolation to dirty read;

let _cant = 0;

select count(*)
  into _cant
  from recrccob
 where no_reclamo = a_no_reclamo;

return _cant;

end procedure