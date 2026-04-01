 													   
drop procedure sp_rec231a;

create procedure sp_rec231a(a_orden char(10), a_cod_proveedor char(10), a_tipo CHAR(1))
returning integer,
          decimal(16,2),
		  char(10),
		  char(18),
		  char(10);

define _mto_orden       decimal(16,2);
define _tramite         char(10);
define _numrecla		char(18);
define _no_orden        char(10);
define _error           integer;
define _cod_proveedor   char(10);
define _cnt             smallint;

--SET DEBUG FILE TO "sp_rec231a.trc"; 
--TRACE ON;                                                                
set isolation to dirty read;

begin


let _mto_orden = 0.00;
let _error     = 0;
let _cnt       = 0;

select count(*)
  into _cnt
  from recordma
 where no_orden = a_orden
   and pagado   = 1;

if _cnt > 0 then
	return -1,0,'','','';
end if

select count(*)
  into _cnt
  from recordma
 where no_orden = a_orden
   and tipo_ord_comp = a_tipo;

if _cnt = 0 then
	return -2,0,'','','';
end if

select monto - monto_pagado,
       no_tramite,
	   numrecla,
	   no_orden,
	   cod_proveedor
  into _mto_orden,
       _tramite,
	   _numrecla,
	   _no_orden,
	   _cod_proveedor
  from recordma
 where no_orden = a_orden
   and pagado   = 0;


if trim(_cod_proveedor) <> trim(a_cod_proveedor) then
	let _error = 1;
end if

return _error,_mto_orden,_tramite,_numrecla,_no_orden;

end

end procedure