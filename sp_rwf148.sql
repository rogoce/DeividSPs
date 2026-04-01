-- Procedimiento que busca si hay registro en recrcmae antes de crear el reclamo

-- Creado    : 07/10/2011 - Autor: Amado Perez  

drop procedure sp_rwf148;

create procedure sp_rwf148(a_no_tranrec char(10)) 
returning smallint;

define _perdida_total	smallint;
define _perdida_rec	    smallint;
define _perdida_tr	    smallint;
define _no_reclamo      char(10);

--SET DEBUG FILE TO "sp_rwf148.trc"; 
--trace on;
set isolation to dirty read;

let _perdida_total = 0;
let _perdida_rec = 0;
let _perdida_tr = 0;

select no_reclamo,
       perd_total
  into _no_reclamo,
       _perdida_tr
  from rectrmae
 where no_tranrec = a_no_tranrec;

select perd_total
  into _perdida_rec
  from recrcmae
 where no_reclamo = _no_reclamo;
 
let _perdida_total = _perdida_tr + _perdida_rec;

return _perdida_total;

end procedure