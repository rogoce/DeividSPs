-- Procedimiento que actualiza los número de pagos de endosos de pólizas que no han tenido plan pago.
-- Creado: 30/05/2017 - Autor: Román Gordón

drop procedure sp_dev06a_temis;
create procedure sp_dev06a_temis()
returning	smallint		as cod_error,
			varchar(100)	as error;

define _mensaje				varchar(100);
define _no_documento		char(20);
define _no_poliza			char(10);
define _cod_tipoprod		char(3);
define _excepcion			smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_suspension	date;
define _cubierto_hasta		date;
define _fecha_hoy			date;

set isolation to dirty read;

--set debug file to 'sp_dev06a.trc';
--trace on;

--Query para crear la temporal

begin

on exception set _error,_error_isam,_mensaje
	rollback work;
	return _error,_mensaje||_no_documento;
end exception

let _fecha_hoy = current;
let _no_documento = '';

foreach with hold
	select emi.no_documento
	  into _no_documento
	  from emipomae emi  
	 where emi.no_factura like '8%'
	   and emi.no_factura not like '%-%'
	   and emi.actualizado = 1

	begin
		on exception in(-535)

		end exception 	
		begin work;
	end

	{call sp_ley003(_no_documento,2) returning _excepcion,_mensaje;--Se pone en comentario, debido a que todas las polizas se les debe calcular la fecha de suspencion, 14/02/20

	if _excepcion <> 0 then
		commit work;
		continue foreach;
	end if}

	call sp_pro545(_no_documento) returning _error,_mensaje;

	if _error <> 0 then
		let _mensaje = _mensaje || ' ' || trim(_no_documento);
		return _error,_mensaje||_no_documento with resume;
		continue foreach;
	end if

	commit work;
end foreach

return 0,'Actualización Exitosa';
end
end procedure;