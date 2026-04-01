
--execute procedure sp_sis212e('2018-07')
drop procedure sp_sis242;
create procedure "informix".sp_sis242()
returning	integer,
			varchar(250);

define _error_desc			varchar(250);
define _filtros				varchar(250);
define _no_documento		char(20);
define _no_remesa			char(10);
define _emi_periodo			char(7);
define _periodo				char(7);
define _cod_contrato_n		char(5);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_ruta			char(5);
define _no_endoso			char(5);
define _cod_cober_reas		char(3);
define _cod_cober_ter		char(3);
define _cod_endomov			char(3);
define _cod_ramo			char(3);
define _porc_partic_prima	dec(9,6);
define _porc_partic_suma	dec(9,6);
define _porc_proporcion		dec(9,6);
define _porc_sin_fac		dec(9,6);
define _suma_asegurada		dec(16,2);
define _prima_suscrita		dec(16,2);
define _suma_aseg_fac		dec(16,2);
define _suma_sin_fac		dec(16,2);
define _suma_aseg			dec(16,2);
define _prima_rea			dec(16,2);
define _tipo_contrato		smallint;
define _cnt_contrato		smallint;
define _cnt_existe			smallint;
define _no_cambio			smallint;
define _orden				smallint;
define _renglon				integer;
define _error_isam			integer;
define _error				integer;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_corte			date;

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc

 	return _error, _error_desc;         
end exception

foreach
	select no_remesa,
		   renglon
	  into _no_remesa,
		   _renglon
	  from cobredet
	 where no_poliza in (select distinct no_poliza from tmp_reas_inc) 
	   and periodo = '2018-07' 
	   and actualizado = 1

	call sp_sis171bk(_no_remesa,_renglon) returning _error,_error_desc;
	if _error <> 0 then
		return _error,_error_desc;
	end if		
end foreach

return 0,'Actualización Exitosa';
end
end procedure;