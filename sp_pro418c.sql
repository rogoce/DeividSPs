
-- Procedimiento para insertar el endoso de descuento apoyo COVID-19
-- Amado Perez M - 29/04/2020
--execute procedure sp_pro418a()

drop procedure sp_pro418c;
create procedure sp_pro418c() 
returning	smallint as Error_No,
			char(20) as Poliza,
			char(100) as Descripcion;

		   
define _nom_contratante		varchar(50);
define _nom_formapag		varchar(50);
define _nom_sucursal		varchar(50);
define _desc_aplica			varchar(100);
define _nom_perpago			varchar(50);
define _nom_agente			varchar(50);
define _nom_grupo			varchar(50);
define _nom_ramo			varchar(50);
define _error_desc			char(30);
define _no_documento		char(20);
define _no_poliza			char(10);
define _periodo				char(7);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define _no_endoso       	char(5);
define _cod_sucursal		char(3);
define _cod_formapag		char(3);
define _cod_perpago			char(3);
define _cod_ramo            char(3);
define _null            	char(1);
define _suma_asegurada		dec(16,2);
define _letra_sin_imp		dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_neta			dec(16,2);
define _por_vencer			dec(16,2);
define _corriente			dec(16,2);
define _descuento			dec(16,2);
define _exigible			dec(16,2);
define _monto_30			dec(16,2);
define _monto_60			dec(16,2);
define _monto_90			dec(16,2);
define _impuesto			dec(16,2);
define _saldo				dec(16,2);
define _letra				dec(16,2);
define _no_pagos			smallint;
define _aplica				smallint;
define _rango				smallint;
define _error_isam			integer;
define _error				integer;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_hoy			date;
define _fecha_sus           date;
define _fecha_gestion   	datetime year to second;

--set debug file to "sp_sis418.trc";
--trace on;

set isolation to dirty read;

begin

on exception set _error,_error_isam,_error_desc
	if _no_documento is null then
		let _no_documento = '';
	end if

	begin
		on exception in(-535)

		end exception 	
		begin work;
	end

 	return	_error,
			_no_documento,
			_error_desc;
end exception

FOREACH with hold
	select no_poliza,
		   no_endoso,
		   no_documento
	  into _no_poliza,
		   _no_endoso,
		   _no_documento
	  from endedmae 
	 where cod_endomov in ('033')
	   and actualizado = 0
	   and user_added = 'DEIVID'

	begin
		on exception in(-535)

		end exception 	
		begin work;
	end

	call sp_pro43(_no_poliza,_no_endoso) returning _error,_error_desc;
	
	if _error <> 0 then
		rollback work;
		return	_error,
				_no_documento,
				_error_desc with resume;
		continue foreach;
	end if
	
	{update polcovid
	   set procesado = 1,
		   fecha_procesado = today,
		   no_endoso = _no_endoso
	 where no_poliza = _no_poliza
	   and periodo = a_periodo;}
	
	commit work;
	
	return 0,_no_documento,'Endoso: ' || _no_endoso || '. Actualizacion Exitosa' with resume;
END FOREACH			

return 0,'', "Actualizacion Exitosa...";
end
end procedure 