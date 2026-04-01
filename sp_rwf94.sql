-- Procedimiento que busca si hay registro en recrcmae antes de crear el reclamo

-- Creado    : 07/10/2011 - Autor: Amado Perez  

drop procedure sp_rwf94;

create procedure sp_rwf94(a_no_reclamo char(10), a_cod_tercero char(10)) 
returning smallint;

define _cant               smallint;

--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;
set isolation to dirty read;

let _cant = 0;

select count(*)
  into _cant
  from recterce
 where no_reclamo = a_no_reclamo
   and cod_tercero = a_cod_tercero;
   
if _cant is null then
	let _cant = 0;
end if

return _cant;

end procedure