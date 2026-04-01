-- Procedimiento que actualiza los número de pagos de endosos de pólizas que no han tenido plan pago.
-- Creado: 30/05/2017 - Autor: Román Gordón
-- execute procedure sp_dev06b(today);

drop procedure sp_dev06b;
create procedure sp_dev06b(a_fecha_calculo date)
returning	smallint		as cod_error,
			varchar(100)	as mensaje;

define _mensaje				varchar(100);
define _no_documento		char(20);
define _no_poliza			char(10);
define _cod_endomov			char(3);
define _prima_diaria_acum	dec(16,2);
define _monto_devolucion	dec(16,2);
define _monto_cobrado		dec(16,2);
define _prima_diaria		dec(16,2);
define _prima_bruta			dec(16,2);
define _dif_prima			dec(16,2);
define _dias_vigencia		integer;
define _error_isam			integer;
define _contador			integer;
define _error				integer;
define _fecha_cancelacion	date;
define _fecha_suspension	date;
define _vigencia_final		date;
define _cubierto_hasta		date;
define _fecha_hasta			date;
define _fecha_hoy			datetime year to second;

set isolation to dirty read;

--set debug file to "sp_sis236.trc";
--trace on;

--Query para crear la temporal

begin
on exception set _error,_error_isam,_mensaje
return _error,_mensaje;
end exception

let _fecha_hoy = current;

foreach
	select no_documento,
		   fecha_suspension
	  into _no_documento,
		   _fecha_suspension
	  from emipoliza
	 where flag_cubierto = 1
	   and fecha_suspension <= a_fecha_calculo

	let _fecha_cancelacion = _fecha_suspension + 60 units day;

	begin
		on exception in(-268)
			let _no_poliza = sp_sis21(_no_documento);

			select vigencia_final
			  into _vigencia_final
			  from emipomae
			 where no_poliza = _no_poliza;

			if a_fecha_calculo <= _vigencia_final then
				let _fecha_hasta = a_fecha_calculo;
			else
				let _fecha_hasta = _vigencia_final;
			end if
			
			update leysuscob
			   set fecha_hasta = _fecha_hasta,
				   last_update = _fecha_hoy
			  where no_documento = _no_documento
				and activo = 1;
		end exception

		insert into leysuscob(
				no_documento,
				fecha_desde,
				fecha_hasta,
				fecha_cancelacion,
				date_added,
				last_update)
		values(	_no_documento,
				_fecha_suspension,
				a_fecha_calculo,
				_fecha_cancelacion,
				_fecha_hoy,
				_fecha_hoy);
	end
end foreach

return 0,'Actualización Exitosa';
end
end procedure;