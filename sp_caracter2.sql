-- Procedimiento para corregir los caracteres especiales a motor, chasis y vin
-- 
-- Creado    : 09/05/2011 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_caracter2;

create procedure "informix".sp_caracter2()
returning integer, 
          char(100),
          char(30);
		  	
define _no_poliza    char(10); 
define _no_endoso	 char(5);
define _no_factura   char(30);
define _resultado    char(30);
define _no_documento char(20);
define _no_unidad    char(5);

define _error_cod	integer;
define _error_isam	integer;
define _error_desc	char(100);
define _no_motor    char(30);
define _cnt         integer;


set isolation to dirty read;

BEGIN WORK;

begin 
on exception set _error_cod, _error_isam, _error_desc
    rollback work;
	return _error_cod, _error_desc,_no_motor;
end exception

--SET DEBUG FILE TO "sp_caracter.trc"; 
--trace on;

let _resultado = "";

foreach

 select no_documento,
		no_unidad,
		no_motor,
		corregido
   into _no_documento,
	    _no_unidad,
		_no_motor,
		_resultado
   from attt

 let _resultado = trim(_resultado);
   	  	
 select count(*)
   into _cnt
   from emivehic
  where no_motor = _resultado;
 
 if _cnt > 0 then
	continue foreach;
 end if

 update emiauto
    set no_motor = "PRUEBA"
  where no_motor = _no_motor;
 
 update endmoaut
    set no_motor = "PRUEBA"
  where no_motor = _no_motor;

 update recrcmae
    set no_motor = "PRUEBA"
  where no_motor = _no_motor;

 update emivehic
    set no_motor = _resultado
  where no_motor = _no_motor;

 update emiauto
    set no_motor = _resultado
  where no_motor = "PRUEBA";
 
 update endmoaut
    set no_motor = _resultado
  where no_motor = "PRUEBA";

 update recrcmae
    set no_motor = _resultado
  where no_motor = "PRUEBA";

let _resultado = "";

end foreach;

end
COMMIT WORK;

let _error_cod  = 0;
let _error_desc = "Proceso Completado ...";

return _error_cod, _error_desc,"";

end procedure;
