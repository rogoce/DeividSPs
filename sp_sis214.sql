-- 
drop procedure sp_sis214;
create procedure "informix".sp_sis214()
returning	integer,
			varchar(250);

define _error_desc			varchar(250);
define _filtros				varchar(250);
define _no_documento		char(20);
define _no_poliza			char(10);
define _no_remesa			char(10);
define _periodo_corte		char(7);
define _periodo				char(7);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_ruta			char(5);
define _no_endoso			char(5);
define _cod_cober_reas		char(3);
define _cod_ramo			char(3);
define _porc_partic_prima	dec(9,6);
define _porc_partic_suma	dec(9,6);
define _porc_proporcion		dec(9,6);
define _porc_sin_fac		dec(9,6);
define _porcentaje			dec(9,6);
define _suma_asegurada		dec(16,2);
define _prima_suscrita		dec(16,2);
define _suma_aseg_fac		dec(16,2);
define _suma_sin_fac		dec(16,2);
define _suma_aseg			dec(16,2);
define _prima_rea			dec(16,2);
define _cnt_facultativo		smallint;
define _ult_no_cambio		smallint;
define _contador_ret		smallint;
define _cnt_existe			smallint;
define _no_cambio			smallint;
define _renglon				smallint;
define _orden				smallint;
define _error_isam			integer;
define _error				integer;
define _vigencia_inic		date;
define _fecha_corte			date;

set isolation to dirty read;


--set debug file to "sp_sis212a.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc
	--let _error_desc = 'no_poliza: '  || _no_poliza || trim(_error_desc);
	
	rollback work;
 	return _error, _error_desc;         
end exception

foreach with hold
	select distinct t.no_remesa,
		   t.renglon
	  into _no_remesa,
		   _renglon
  from tmp_cobreaco t, cobreaco r
 where r.no_remesa = t.no_remesa
   and r.renglon = t.renglon
   and t.no_remesa not in ('966367','968858')

	begin work;
	
	update sac999:reacomp
	   set sac_asientos = 0
	 where no_remesa = _no_remesa
	   and renglon = _renglon
	   and tipo_registro = 2;
	commit work;
end foreach
end
end procedure;