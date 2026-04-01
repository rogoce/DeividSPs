-- Proceso diario
-- Creado    : 06/04/2005 - Autor: Demetrio Hurtado Almanza 
-- Modificado: Henry utilizado para duplicidad de clientes

--drop procedure sp_sis73d;

create procedure "informix".sp_sis73d()
returning integer,char(100);

define _tiempo		    date;
define _error		    integer;
define _error_isam	    integer;
define _error_desc	    char(100);
define a_cod_errado	    char(10);
define a_cod_correcto 	char(10);

define _por_vencer		dec(16,2);
define _exigible 		dec(16,2);
define _corriente 		dec(16,2);
define _monto_30 		dec(16,2);
define _monto_60 		dec(16,2);
define _monto_80 		dec(16,2);
define _saldo 			dec(16,2);

let _tiempo = current;
let _tiempo = _tiempo - 1;

SET LOCK MODE TO WAIT 5;

--set debug file to "sp_sis73d.trc";
--trace on;

begin
	on exception set _error, _error_isam, _error_desc
		return _error, _error_desc;
	end exception


foreach

	select cod_errado,
	       cod_correcto
	  into a_cod_errado,
	       a_cod_correcto
	  from clidepur
	 where date(date_changed) = _tiempo


	BEGIN
	ON EXCEPTION IN(-244,-243)  
	END EXCEPTION
		update emiporen
		   set cod_contratante = a_cod_correcto
		 where cod_contratante = a_cod_errado;
	END 

	BEGIN
	ON EXCEPTION IN(-244,-243)  
	END EXCEPTION
		update emiporen
	   	   set cod_pagador = a_cod_correcto
	 	 where cod_pagador = a_cod_errado;
	END


	BEGIN
	ON EXCEPTION IN(-244,-243)  
	END EXCEPTION
	update rectrmae
	   set cod_cliente = a_cod_correcto
	 where cod_cliente = a_cod_errado;
	END 

	BEGIN
	ON EXCEPTION IN(-244,-243)  
	END EXCEPTION
	update rectrmae
	   set cod_proveedor = a_cod_correcto
	 where cod_proveedor = a_cod_errado;
	END 

end foreach

return 0, "Actualizacion Exitosa";
end
end procedure;

   