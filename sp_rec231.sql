 													   
drop procedure sp_rec231a;

create procedure sp_rec231a(a_orden char(10), a_cod_proveedor char(10))
returning integer,
          decimal(16,2),
		  char(10),
		  char(18),
		  char(10);

define _mto_orden       decimal(16,2);
define _tramite         char(10);
define _numrecla		char(18);
define _no_orden        char(5);
define _error           integer;
define _cod_proveedor   char(10);


begin

let _mto_orden = 0.00;
let _error     = 0;

select monto,
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