-- Procedimiento que Genera la Prima cobrada devengada neta para Bono de Rentabilidad
-- Creado: 03/01/2018 - Autor: Román Gordón
--execute procedure sp_dev06c('001','2017-01','2017-12')


drop procedure sp_dev06f_renta;
create procedure sp_dev06f_renta(a_no_documento char(20),a_fecha_corte date, a_fecha_desde date, a_fecha_hasta date)
returning	smallint		as cod_error,
			varchar(100)	as error,
			decimal(16,2)   as prima_neta_cob_dev;

define _mensaje				varchar(100);
define _prima_cob_dev_neta	dec(16,2);
define _error_isam			integer;
define _error				integer;
define _fecha_suspension	date;
define _cubierto_hasta		date;

set isolation to dirty read;

--set debug file to 'sp_dev06e.trc';
--trace on;

begin
	on exception set _error,_error_isam,_mensaje
		let _mensaje = _mensaje || trim(a_no_documento);
		return _error,_mensaje,0;
	end exception

	call sp_dev06_sin_fac(a_no_documento,a_fecha_corte) returning _error,_mensaje,_cubierto_hasta,_fecha_suspension;
	
	if _error <> 0 then
		let _mensaje = _mensaje || ' ' || trim(a_no_documento);
		return _error,_mensaje,0;
	end if

	select sum(prima_cobrada)
	  into _prima_cob_dev_neta
	  from consumo_prima
	 where no_documento = a_no_documento
	   and fecha >= a_fecha_desde
	   and fecha <= a_fecha_hasta;

	if _prima_cob_dev_neta is null then
		let _prima_cob_dev_neta = 0.00;
	end if

	truncate table consumo_prima;

return 0,'Actualización Exitosa',_prima_cob_dev_neta;
end
end procedure;