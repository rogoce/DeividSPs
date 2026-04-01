-- Procedimiento que busca si hay registro en recrcmae antes de crear el reclamo

-- Creado    : 07/10/2011 - Autor: Amado Perez  

--drop procedure sp_tem04;

create procedure sp_tem04(a_no_tranrec char(10), a_cod_cobertura char(5)) 
returning smallint;

define _cant               smallint;

--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;
set isolation to dirty read;

let _cant = 0;

select count(*)
  into _cant
  from rectrcob
 where no_tranrec = a_no_tranrec
   and cod_cobertura = a_cod_cobertura;

return _cant;

end procedure