-- Procedimiento para validar la forma, fecha expiración de la tarjeta y periodo de pago de las polizas del producto 10602
-- Creado     :	28/09/2024 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_emi03;		
create procedure sp_emi03(a_no_poliza char(10))
returning integer;
		  
define _cod_producto   char(5);
define _cod_formapag   char(3);
define _cod_perpago    char(3);
define _activo         integer;
define _fecha_exp 	   char(7);
define _error   	   smallint;
define _fecha_1_pago   date;
define _nueva_renov    char(1);
define _no_documento   char(20);
define _no_tarjeta	   char(19);
define _cod_sucursal    char(3);

set isolation to dirty read;

let _error = 0;
--SET DEBUG FILE TO "sp_emi03.trc";
--TRACE ON;
let _activo = 0;
select cod_formapag,
	   cod_perpago,
	   fecha_exp,
	   fecha_primer_pago,
	   nueva_renov,
	   no_documento,
	   no_tarjeta,
	   cod_sucursal
  into _cod_formapag,
       _cod_perpago,
	   _fecha_exp,
	   _fecha_1_pago,
	   _nueva_renov,
	   _no_documento,
	   _no_tarjeta,
	   _cod_sucursal
  from emipomae
 where no_poliza = a_no_poliza;
 
foreach
	select trim(cod_producto)
	  into _cod_producto
	  from emipouni
	 where no_poliza = a_no_poliza
	 
	if _cod_producto = '10602' then
		let _activo = 1;
		exit foreach;
	end if
end foreach
if _activo = 1 then
	if _cod_formapag = '003' and _nueva_renov = 'N' then
		update cobtacre
		   set excep_ini = _fecha_1_pago,
		       excep_fin = _fecha_1_pago + 5 UNITS DAY,
			   excepcion = 1
		where no_documento = _no_documento
		  and no_tarjeta   = _no_tarjeta;
	end if
{-- se quita por caso enviado #12635
	if _cod_formapag <> '003' then
		if _cod_formapag in ('006') then
			if _cod_perpago not in('006','008') then
				return 333;
			end if
		end if
	else
		CALL sp_cob9d(a_no_poliza,_fecha_exp) RETURNING _error;  --verificacion de la fecha de expiración 
		if _error <> 0 then
			return 335;
		end if
	end if}
end if

return 0;
end procedure 