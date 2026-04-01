drop procedure sp_pro223;
create procedure 'informix'.sp_pro223(
a_no_poliza		char(10))
returning   integer,
			varchar(100)-- _error


define _mensaje				varchar(100);
define _cod_manzana			char(15);
define _no_unidad			char(5);
define _error_isam			integer;
define _error				integer;
define _cod_producto        char(5);
define _cod_ramo            char(3);

begin
on exception set _error,_error_isam,_mensaje 
 	return _error,_mensaje;         
end exception

set isolation to dirty read;

let _mensaje = '';


foreach
	select no_unidad,
		   cod_manzana,
		   cod_producto
	  into _no_unidad,
		   _cod_manzana,
		   _cod_producto
	  from emipouni
	 where no_poliza = a_no_poliza

	if _cod_manzana is null then
		let _cod_manzana = '';
	end if
	
	if _cod_manzana = '' then
	   foreach
		select cod_ramo
		  into _cod_ramo
		  from reacobre
		 where cod_cober_reas in(select c.cod_cober_reas from prdcobpd p, prdcober c, reacobre u
		 where p.cod_cobertura = c.cod_cobertura
		   and c.cod_cober_reas = u.cod_cober_reas
		   and p.cod_producto = _cod_producto)
		exit foreach;
       end foreach		
		if _cod_ramo not in('001','003') then
			continue foreach;
		end if	
		if _mensaje = '' then
			let _mensaje = trim(_no_unidad);
		else
			let _mensaje = _mensaje || ',' || trim(_no_unidad);
		end if
	end if
end foreach

if _mensaje <> '' then
	return 1,'Falta el código de manzana en la(s) unidad(es) : ' || trim(_mensaje) || '. Por Favor Verifique.';
end if

return 0,'Verificación Exitosa';

end
end procedure;