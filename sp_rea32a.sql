--------------------------------------------
--Proceso de Reversión masiva de notrx
--execute procedure sp_rea32()
--22/07/2016 - Autor: Román Gordón.
--------------------------------------------
drop procedure sp_rea32a;
create procedure sp_rea32a()
returning	smallint	as error,
			varchar(50)	as desc_error;

define _error_desc			varchar(100);
define _nom_contrato		varchar(50);
define _no_documento		char(20);
define _no_registro			char(10);
define _no_factura			char(10);
define _no_remesa			char(10);
define _no_poliza			char(10);
define _periodo_inicio		char(8);
define _periodo				char(8);
define _cod_contrato		char(5);
define _no_endoso			char(5);
define _no_unidad			char(5);
define _cod_ruta			char(5);
define _cod_cober_reas		char(3);
define _cod_ramo			char(3);
define _prima_retenida		dec(16,2);
define _prima_suscrita		dec(16,2);
define _serie_contrato		smallint;
define _cnt_notrx			smallint;
define _serie				smallint;
define _error_isam			integer;
define _notrx				integer;
define _error				integer;
define _vigencia_inic		date;
define _vigencia_final		date;

--set debug file to 'sp_rea27.trc';
--trace on;

begin
on exception set _error,_error_isam,_error_desc
    --rollback work;
	return _error,_error_desc;
end exception  

set isolation to dirty read;

--let _periodo_inicio = '2016-01';

foreach
	select e.no_poliza,e.no_endoso,e.prima_suscrita,sum(r.prima)
	  into _no_poliza,_no_endoso,_prima_suscrita,_prima_retenida
	  from deivid_tmp:facturas t, endedmae e,emifacon r, reacomae c
	 where t.no_poliza = e.no_poliza 
	   and t.no_endoso = e.no_endoso
	   and t.no_poliza = r.no_poliza
	   and t.no_endoso = r.no_endoso
	   and c.cod_contrato = r.cod_contrato
	   and c.tipo_contrato = 1
	 group by 1,2,3
	 order by 1,2

	update sac999:reacomp
	   set sac_asientos = 0
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;
end foreach

return 0,'Actualización Exitosa';
end
end procedure;