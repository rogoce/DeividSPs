-- Procedimiento que Genera la Prima cobrada devengada neta para Bono de Rentabilidad
-- Creado: 03/01/2018 - Autor: Román Gordón
--execute procedure sp_dev06c('001','2017-01','2017-12')


drop procedure sp_dev06f_rentasim;
create procedure sp_dev06f_rentasim(a_no_documento char(20),a_fecha_corte date, a_fecha_desde date, a_fecha_hasta date)
returning	smallint		as cod_error,
			varchar(100)	as poliza,
			char(10)        as remesa,
			smallint        as renglon,
			char(1)         as tipo_mov;

define _mensaje				varchar(100);
define _no_poliza,_no_remesa			char(10);
define _cod_agente			char(5);
define _anio				char(4);
define _porc_partic_agt		dec(5,2);
define _prima_cob_dev_neta	dec(16,2);
define _prim_cobrada_bruta	dec(16,2);
define _prima_cob_dev_agt	dec(16,2);
define _porc_coas_ancon		dec(5,2);
define _cod_tipoprod        char(3);
define _factor_impuesto,_renglon		smallint;
define _tiene_impuesto,_tipo_prod		smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_suspension	date;
define _cubierto_hasta		date;
define _tipo_mov char(1);

set isolation to dirty read;

--set debug file to 'sp_dev06e.trc';
--trace on;

begin
	on exception set _error,_error_isam,_mensaje
		let _mensaje = _mensaje || trim(a_no_documento);
		return _error,_mensaje,'','','';
	end exception

	call sp_dev06_sin_facsim(a_no_documento,a_fecha_corte) returning _error,_mensaje,_no_remesa,_renglon,_tipo_mov;

return 0,a_no_documento,_no_remesa,_renglon,_tipo_mov;
end
end procedure;