-- Reporte de Pólizas cuya fecha de primer pago sea diferente a la vigencia inicial
-- Creado    : 08/04/2015 - Autor: Román Gordón
-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

drop procedure sp_cob369;
create procedure sp_cob369(a_fecha_desde date)
returning	char(19)	as Polizas,				--_no_documento,
			date		as Vigencia_Inicial,	--_vigencia_inic,
			date		as Vigencia_Final,		--_vigencia_final,
			date		as Fecha_Primer_Pago,	--_fecha_primer_pago,
			varchar(50)	as Ramo,				--_nom_ramo,
			varchar(50)	as Forma_Pago,			--_nom_formapag,
			varchar(50)	as Zona_Cobros,			--_nom_zonacob,
			varchar(50)	as Corredor,			--_nom_agente,
			varchar(50)	as Zona_Ventas,			--_nom_zonavende,
			dec(16,2)	as Prima_Bruta,			--_prima_bruta,
			dec(16,2)	as Saldo,				--_saldo,
			dec(16,2)	as Por_Vencer,			--_por_vencer,
			dec(16,2)	as Exigible,			--_exigible,
			dec(16,2)	as Corriente,			--_corriente,
			dec(16,2)	as Monto30,				--_monto_30,
			dec(16,2)	as Monto60,				--_monto_60,
			dec(16,2)	as Monto90,				--_monto_90,
			integer		as Dif_Primer_Pago;		--_diferencia_pago;

define _error_desc			varchar(100);
define _nom_zonavende		varchar(50);
define _nom_formapag		varchar(50);
define _nom_zonacob			varchar(50);
define _nom_agente			varchar(50);
define _nom_ramo			varchar(50);
define _no_documento		char(19);
define _cod_campana			char(10);
define _cod_cliente			char(10);
define _periodo				char(8);
define _cod_formapag		char(3);
define _cod_vendedor		char(3);
define _cod_cobrador		char(3);
define _cod_ramo			char(3);
define _prima_bruta			dec(16,2);
define _por_vencer			dec(16,2);
define _corriente			dec(16,2);
define _exigible			dec(16,2);
define _monto_30			dec(16,2);
define _monto_60			dec(16,2);
define _monto_90			dec(16,2);
define _saldo				dec(16,2);
define _cnt_cascliente		smallint;
define _cnt_caspoliza		smallint;
define _diferencia_pago		integer;
define _error_isam			integer;
define _error				integer;
define _fecha_primer_pago	date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_hoy			date;

--set debug file to "sp_cob356.trc";
--trace on;

set isolation to dirty read;
begin

on exception set _error,_error_isam,_error_desc
	return '',null,null,null,_error_desc,'','','','',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,_error;
end exception  

let _fecha_hoy = current;
let _periodo = sp_sis39(_fecha_hoy);

foreach
	select e.no_documento,
		   e.cod_ramo,
		   e.cod_formapag,
		   e.vigencia_inic,
		   e.vigencia_final,
		   c.nombre,
		   c.cod_vendedor,
		   c.cod_cobrador,
		   e.fecha_primer_pago,
		   e.fecha_primer_pago - e.vigencia_inic,
		   e.prima_bruta
	  into _no_documento,
		   _cod_ramo,
		   _cod_formapag,
		   _vigencia_inic,
		   _vigencia_final,
		   _nom_agente,
		   _cod_vendedor,
		   _cod_cobrador,
		   _fecha_primer_pago,
		   _diferencia_pago,
		   _prima_bruta
	  from emipomae e, emipoagt a, agtagent c
	 where e.no_poliza = a.no_poliza
	   and a.cod_agente = c.cod_agente
	   and e.vigencia_inic >= a_fecha_desde
	   and e.vigencia_inic <> e.fecha_primer_pago
	   and e.actualizado = 1
	 order by 10

	select nombre
	  into _nom_formapag
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre
	  into _nom_zonavende
	  from agtvende
	 where cod_vendedor = _cod_vendedor;

	select nombre
	  into _nom_zonacob
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;

	call sp_cob33('001','001',_no_documento,_periodo, _fecha_hoy)
	returning   _por_vencer,
				_exigible,
				_corriente,
				_monto_30,
				_monto_60,
				_monto_90,
				_saldo;

	return	_no_documento,
			_vigencia_inic,
			_vigencia_final,
			_fecha_primer_pago,
			_nom_ramo,
			_nom_formapag,
			_nom_zonacob,
			_nom_agente,
			_nom_zonavende,
			_prima_bruta,
			_saldo,
			_por_vencer,
			_exigible,
			_corriente,
			_monto_30,
			_monto_60,
			_monto_90,
			_diferencia_pago with resume;	
end foreach
end
end procedure;