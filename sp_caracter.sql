-- Procedimiento para corregir los caracteres especiales a motor, chasis y vin
-- 
-- Creado    : 09/05/2011 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_caracter;

create procedure "informix".sp_caracter()
returning integer, 
          char(100);
		  	
define _no_poliza    char(10); 
define _no_endoso	 char(5);
define _no_factura   char(30);
define _resultado    char(30);
define _no_documento char(20);
define _no_unidad    char(5);
define i,_valor      integer; 
DEFINE _char_1       CHAR(1);

define _error_cod	integer;
define _error_isam	integer;
define _error_desc	char(100);


set isolation to dirty read;

begin 
on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, _error_desc;
end exception

--SET DEBUG FILE TO "sp_caracter.trc"; 
--trace on;

let _resultado = "";
let _char_1    = "";

foreach
 select no_documento,
		no_unidad,
		no_chasis
   into _no_documento,
	    _no_unidad,
		_no_factura
   from attt
--  where no_documento = '0209-00421-03'
--    and no_unidad    = '00001'
  	  	
 let _no_factura = trim(_no_factura);
 let _valor = length(_no_factura);

 for i = 1 to _valor

	LET _char_1     = _no_factura[1, 1];
	LET _no_factura = _no_factura[2, 30];

	if _char_1 = "-" or _char_1 = "." or _char_1 = " " or _char_1 = "/" or _char_1 = "*" or _char_1 = "+" or _char_1 = "!" or _char_1 = "#" or _char_1 = "$" or _char_1 = '?' or
	   _char_1 = ":" or _char_1 = "," or _char_1 = ";" then
	else	
		let _resultado = trim(_resultado) || trim(_char_1);
	end if

    if i = _valor then
		EXIT FOR;
	end if

 end for

 let _resultado = trim(_resultado);

 update attt
    set corregido    = _resultado
  where no_documento = _no_documento
    and no_unidad    = _no_unidad;

 let _resultado = "";
 let _char_1    = "";

end foreach;

end

let _error_cod  = 0;
let _error_desc = "Proceso Completado ...";

return _error_cod, _error_desc;

end procedure;
