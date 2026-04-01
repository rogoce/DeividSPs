
-- Procedimiento para insertar el endoso de descuento apoyo COVID-19
-- Amado Perez M - 29/04/2020
--execute procedure sp_pro418a('2020-04')

drop procedure sp_sis464;
create procedure sp_sis464() 
returning	smallint,
			char(20),
			char(100);

		   
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
define _no_cuenta			char(19);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define _no_endoso       	char(5);
define _cod_sucursal		char(3);
define _cod_formapag		char(3);
define _cod_perpago			char(3);
define _cod_ramo            char(3);
define _null            	char(1);
define _monto_act			dec(16,2);
define _monto_ant			dec(16,2);
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
	{select distinct ach.no_cuenta,
		   ach.no_documento,
		   ach.monto,
		   tmp.monto
	  into _no_cuenta,
		   _no_documento,
		   _monto_act,
		   _monto_ant
	  from polcovid cov
	 inner join cobcutas ach
		     on cov.no_documento = ach.no_documento
	  left join cobcutmpbk tmp
			 on tmp.no_cuenta = ach.no_cuenta
			and tmp.no_documento = ach.no_documento
			and date(tmp.date_added) = ach.fecha_ult_tran
	 where tmp.monto is not null}
	 
	select distinct tcr.no_tarjeta,
		   tcr.no_documento,
		   tcr.monto,
		   tmp.monto
	  into _no_cuenta,
		   _no_documento,
		   _monto_act,
		   _monto_ant
	  from polcovid cov
	 inner join cobtacre tcr
			 on cov.no_documento = tcr.no_documento
	  left join cobtatrabk tmp
			 on tmp.no_tarjeta = tcr.no_tarjeta
			and tmp.no_documento = tcr.no_documento
			and date(tmp.date_added) = tcr.fecha_ult_tran
	 where tmp.monto is not null

	begin
		on exception in(-535)

		end exception 	
		begin work;
	end

	{update cobcutas
	   set monto = _monto_ant
	 where no_cuenta = _no_cuenta
	   and no_documento = _no_documento;}
	
	update cobtacre
	   set monto = _monto_ant
	 where no_tarjeta = _no_cuenta
	   and no_documento = _no_documento;
	
	commit work;
	
	return 0,_no_documento,'' with resume;
END FOREACH			

return 0,'', "Actualizacion Exitosa...";
end
end procedure;