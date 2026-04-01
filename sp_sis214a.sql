-- 
drop procedure sp_sis214a;
create procedure "informix".sp_sis214a()
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
	  from cobreaco r, cobredet t, reacomae m
	 where r.no_remesa = t.no_remesa
	   and r.renglon = t.renglon
	   and m.cod_contrato = r.cod_contrato
	   and t.actualizado = 1
	   and t.doc_remesa[1,2] in('02','23','20')
	   and r.cod_contrato not in('00647','00648','00649')
	   and t.periodo >= '2015-09'

	begin work;
	
	call sp_sis171bk(_no_remesa,_renglon) returning _error,_error_desc;
	
	if _error <> 0 then
		rollback work;
		return _error, _error_desc;   
	end if

	commit work;
end foreach
end
end procedure;