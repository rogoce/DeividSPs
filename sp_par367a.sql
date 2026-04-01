-- Procedimiento que genera las cancelaciones por Decisión de la Compañia (proceso de nueva ley de seguros parte II)
-- Creado     : 06/03/2014 - Autor: Román Gordón.
-- SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_par342('00000','DEIVID',0.00,'001','037',today)

drop procedure sp_par367a;
create procedure sp_par367a()
returning	integer,	--_error
            char(200),	--_error_desc
            char(5);	--_no_endoso

define _descripcion		char(200);
define _error_desc		char(50);
define _no_documento	char(20);
define _no_poliza		char(10);
define _no_endoso_ext	char(5);
define _no_endoso		char(5);
define _cod_impuesto	char(3);
define _cod_tipocalc	char(3);
define _cod_endomov		char(3);
define _cod_tipocan		char(3);
define _null			char(1);
define _factor_impuesto	dec(16,2);
define _suma_asegurada	dec(16,2);
define _prima_suscrita	dec(16,2);
define _prima_retenida 	dec(16,2);
define _suma_impuesto	dec(16,2);
define _prima_bruta		dec(16,2);
define _prima_neta		dec(16,2);
define _descuento		dec(16,2);
define _impuesto		dec(16,2);
define _recargo			dec(16,2);
define _prima 			dec(16,2);
define _tiene_impuesto	smallint;
define _no_endoso_int	smallint;
define _cantidad		smallint;
define _error_isam		integer;
define _error			integer;
define _facultativo     smallint;

--set debug file to 'sp_par342.trc';
--trace on;

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc, '';
end exception

set isolation to dirty read;

foreach
	select no_documento,
		   no_poliza
	  into _no_documento,
		   _no_poliza
	  from emipoliza
	 where cod_status = '1'
	   and cod_ramo = '016'
	   and cod_grupo = '01016'
	   and vigencia_fin >= '01/06/2018'
	   and vigencia_inic < '01/06/2018'

	call sp_par367(_no_poliza,'DEIVID',0.00,'001',null,today) returning _error,_error_desc,_no_endoso;

	if _error <> 0 then
		return _error,_error_desc,_no_endoso;
	end if
end foreach

return 0, 'Actualizacion Exitosa',null;
end
end procedure;