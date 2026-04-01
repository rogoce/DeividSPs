--Verificación de series contrato vs series ruta con respecto a la vigencia de la póliza
--22/07/2016 - Autor: Román Gordón.
--execute procedure sp_sac249('2016-01')
--------------------------------------------
drop procedure sp_sac249;
create procedure sp_sac249(a_periodo_desde char(7))
returning	char(10)	as no_registro,
			integer		as no_trx,
			char(7)		as periodo;

define _error_desc			varchar(100);
define _no_documento		char(20);
define _no_registro			char(10);
define _no_factura			char(10);
define _no_poliza			char(10);
define _no_remesa			char(10);
define _periodo				char(7);
define _no_endoso			char(5);
define _cod_ramo			char(3);
define _cnt_cgl				smallint;
define _error_isam			integer;
define _sac_notrx			integer;
define _error				integer;
define _vigencia_inic		date;
define _vigencia_final		date;

--set debug file to 'sp_sac249.trc';
--trace on;

begin
on exception set _error,_error_isam,_error_desc
    --rollback work;
	return _error_desc,_error,'';
end exception  

set isolation to dirty read;

--Producción
foreach
	select no_poliza,
		   no_endoso,
		   periodo,
		   sac_notrx
	  into _no_poliza,
		   _no_endoso,
		   _periodo,
		   _sac_notrx
	  from endasien
	 where periodo >= a_periodo_desde

	select count(*)
	  into _cnt_cgl
	  from cglresumen
	 where res_notrx = _sac_notrx;

	if _cnt_cgl is null then
		let _cnt_cgl = 0;
	end if

	if _cnt_cgl = 0 then
		select no_factura
		  into _no_factura
		  from endedmae
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;

		return _no_factura, _sac_notrx, _periodo with resume;
	end if
end foreach

--Cobros
foreach
	select no_remesa,
		   periodo,
		   sac_notrx
	  into _no_remesa,
		   _periodo,
		   _sac_notrx
	  from cobasien
	 where periodo >= a_periodo_desde

	select count(*)
	  into _cnt_cgl
	  from cglresumen
	 where res_notrx = _sac_notrx;

	if _cnt_cgl is null then
		let _cnt_cgl = 0;
	end if

	if _cnt_cgl = 0 then
		return _no_remesa, _sac_notrx, _periodo with resume;
	end if
end foreach

--Reaseguro
foreach
	select no_registro,
		   periodo
	  into _no_registro,
		   _periodo
	  from sac999:reacomp
	 where periodo >= a_periodo_desde

	foreach
		select distinct sac_notrx
		  into _sac_notrx
		  from sac999:reacompasie
		 where no_registro = _no_registro

		select count(*)
		  into _cnt_cgl
		  from cglresumen
		 where res_notrx = _sac_notrx;

		if _cnt_cgl is null then
			let _cnt_cgl = 0;
		end if

		if _cnt_cgl = 0 then
			return _no_registro, _sac_notrx,_periodo with resume;
		end if
	end foreach
end foreach

return '',0,'1900-01';

end
end procedure;