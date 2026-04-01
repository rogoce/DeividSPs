-- Procedimiento que actualiza los número de pagos de endosos de pólizas que no han tenido plan pago.
-- Creado: 30/05/2017 - Autor: Román Gordón

drop procedure sp_dev06a;
create procedure sp_dev06a()
returning	smallint		as cod_error,
			varchar(100)	as error;

define _mensaje				varchar(100);
define _no_documento		char(20);
define _no_poliza			char(10);
define _cod_tipoprod		char(3);
define _error_isam			integer;
define _error				integer;
define _cubierto_hasta		date;
define _fecha_hoy			date;

set isolation to dirty read;

--set debug file to 'sp_dev06a.trc';
--trace on;

--Query para crear la temporal

begin
on exception set _error,_error_isam,_mensaje
	rollback work;
	return _error,_mensaje;
end exception

let _fecha_hoy = current;

foreach with hold
	select no_documento
	  into _no_documento
	  from emipoliza
	 where abs((monto_30 + monto_60 + monto_90 + monto_120 + monto_150 + monto_180)) > 1.00
	   and flag_cubierto = 0
	   and (cod_ramo is not null and cod_ramo not in ('008','014'))-- and (cod_ramo not in ('016') and cod_subramo not in ('007')))
	   and cod_formapag not in ('084','085')
	   and cod_grupo  not in ('00000','1000','1090','1009','01016')

	begin
		on exception in(-535)

		end exception 	
		begin work;
	end

	let _no_poliza = sp_sis21(_no_documento);

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod in ('004','002') then
		commit work;
		continue foreach;
	end if

	call sp_dev06(_no_documento,_fecha_hoy) returning _error,_mensaje,_cubierto_hasta;

	if _error <> 0 then
		let _mensaje = _mensaje || ' ' || trim(_no_documento);
		return _error,_mensaje with resume;
		continue foreach;
	end if

	if _cubierto_hasta is not null then
		update emipoliza
		   set fecha_cubierto = _cubierto_hasta,
			   flag_cubierto = 1
		 where no_documento = _no_documento;
	end if

	commit work;
end foreach

return 0,'Actualización Exitosa';
end
end procedure;