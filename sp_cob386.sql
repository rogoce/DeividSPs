--------------------------------------------
--Verificación de series contrato vs series ruta con respecto a la vigencia de la póliza
--22/07/2016 - Autor: Román Gordón.
--execute procedure sp_rea30()
--------------------------------------------
drop procedure sp_cob386;
create procedure sp_cob386()
returning	char(7)		as periodo,
			char(10)	as no_poliza,
			char(5)		as no_endoso,
			char(20)	as poliza,
			char(10)	as no_factura,
			date		as vigencia_inic,
			date		as _vigencia_final,
			char(5)		as no_unidad,
			smallint	as serie,
			char(5)		as cod_contrato,
			varchar(50)	as nom_contrato,
			smallint	as serie_contrato;

define _error_desc			varchar(100);
define _nom_ramo			varchar(50);
define _no_tarjeta			char(30);
define _no_documento		char(20);
define _no_factura			char(10);
define _no_poliza			char(10);
define _periodo_inicio		char(8);
define _periodo				char(8);
define _cod_contrato		char(5);
define _no_endoso			char(5);
define _no_unidad			char(5);
define _cod_ruta			char(5);
define _cod_cober_reas		char(3);
define _cod_ramo			char(3);
define _monto_electronico	dec(16,2);
define _por_vencer			dec(16,2);
define _corriente			dec(16,2);
define _exigible			dec(16,2);
define _monto_30			dec(16,2);
define _monto_60			dec(16,2);
define _monto_90			dec(16,2);
define _saldo				dec(16,2);
define _dia_cargo			smallint;
define _error				integer;
define _vigencia_inic		date;
define _vigencia_final		date;
define _fecha_hoy			date;

--set debug file to 'sp_rea27.trc';
--trace on;

begin
on exception set _error,_error_isam,_error_desc
    --rollback work;
	return '','','','','',null,null,'',_error,'',_error_desc,_error_isam;
end exception  

set isolation to dirty read;

call sp_sis39(_fecha_hoy) returning _periodo;

foreach
	select no_documento,
		   no_tarjeta,
		   dia,
		   excepcion,
		   excep_ini,
		   excep_fin,
		   monto
	  into _no_documento,
		   _no_tarjeta,
		   _dia_cargo,
		   _excep_ini,
		   _excep_fin,
		   _monto_electronico
	  from cobtacre
	 order by dia

	call sp_sis21(_no_documento) returning _no_poliza;

	select cod_ramo,
		   vigencia_inic,
		   vigencia_final
	  into _cod_ramo,
		   _vigencia_inic,
		   _vigencia_final
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	call sp_cob33('001', '001', _no_documento, _periodo, _fecha_hoy)
	returning   _por_vencer,
				_exigible,
				_corriente,
				_monto_30,
				_monto_60,
				_monto_90,
				_saldo;
end foreach

return '','','','','',null,null,'',0,'','Verificación Exitosa',0;

end
end procedure;