-- Procedimiento que saca de excepcion las polizas del producto 10602 cuya fecha final de excepcion sea hoy
-- Creado     :	13/03/2025 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_web78;		
create procedure sp_web78(a_no_poliza char(10))
returning integer;
		  
define _cod_producto   char(5);
define _cod_formapag   char(3);
define _activo         integer;
define _error   	   smallint;
define _excep_fin      date;
define _monto_visa     dec(16,2)
define _no_documento   char(20);
define _no_tarjeta	   char(19);
define _no_poliza	   char(10);

set isolation to dirty read;

let _error = 0;
--SET DEBUG FILE TO "sp_web78.trc";
--TRACE ON;
let _activo = 0;

select no_tarjeta, 
	   no_documento, 
       excep_fin
  into _no_tarjeta,
       _no_documento,
	   _excep_fin
 from cobtacre 
where excep_fin = today

let _no_poliza = sp_sis21(_no_documento);

select monto_visa,
       trim(cod_formapag)
  into _monto_visa,
       _cod_formapag
  from emipomae
 where no_poliza = _no_poliza;

foreach
	select trim(cod_producto)
	  into _cod_producto
	  from emipouni
	 where no_poliza = _no_poliza
	 
	if _cod_producto = '10602' and _cod_formapag = '003' then
		let _activo = 1;
		exit foreach;
	end if
end foreach
if _activo = 1 then

		update cobtacre
		   set excep_ini 		= '',
		       excep_fin 		= '',
			   excepcion 		= 0,
			   cargo_especial 	= _monto_visa, 
			   fecha_inicio   	= _excep_fin + 1 UNITS DAY,
			   fecha_hasta 		= _excep_fin + 1 UNITS DAY, 
			   dia_especial 	= day(_excep_fin + 1 UNITS DAY)
		where no_documento = _no_documento
		  and no_tarjeta   = _no_tarjeta;

end if

return 0;
end procedure 