-- Procedimiento busca quien aprueba las transacciones

-- Creado    : 07/12/2018 - Autor: Amado Perez  

drop procedure sp_rwf162;

create procedure sp_rwf162(a_no_tranrec char(10)) 
returning char(10);

--define _suma_asegurada 	dec(16,2);
define _no_requis       char(10);

--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;

set isolation to dirty read;

let _no_requis = null;

 select no_requis
   into _no_requis
   from rectrmae
  where no_tranrec = a_no_tranrec;
  
  return _no_requis;

end procedure