-- Procedimiento que Genera la Morosidad para un Documento
-- 
-- Creado    : 28/11/2000 - Autor: Demetrio Hurtado Almanza
-- modificado: 28/11/2000 - Autor: Demetrio Hurtado Almanza
-- 
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob430;
create procedure sp_cob430()
returning	char(5)			as cod_corredor,
			varchar(100)	as corredor,
			char(20)		as poliza,
			char(3)			as cod_ramo,
			varchar(50)		as ramo,
			date			as vigencia_inic,
			date			as vigencia_final,
			char(3)			as cod_perpago,
			varchar(20)		as periodo_pago,
			date			as fecha_primer_pago,
			char(10)		as remesa,
			integer			as renglon,
			date			as fecha_cobro,
			char(7)			as periodo_cobro,
			dec(16,2)		as monto_cobrado,
			dec(16,2)		as impuesto,
			dec(16,2)		as saldo_cob,
			dec(16,2)		as prima_neta,
			dec(16,2)		as por_vencer,	-- por vencer
			dec(16,2)		as exigible,	-- exigible
			dec(16,2)		as corriente,	-- corriente
			dec(16,2)		as monto_30,	-- 30 dias
			dec(16,2)		as monto_60,	-- 60 dias
			dec(16,2)		as monto_90,	-- 90 dias
			dec(16,2)		as saldo;		-- saldo
			

define _error_desc				varchar(100);
define _nom_agente				varchar(100);
define _nom_ramo				varchar(50);
define _nom_perpago				varchar(20);
define _no_documento			char(20);
define _no_remesa				char(10);
define _no_poliza				char(10);
define _no_requis				char(10);
define _periodo_cobro			char(7);
define _cod_agente				char(5);
define _cod_perpago				char(3);
define _cod_ramo				char(3);
define _null					char(1);
define _monto_cobrado			dec(16,2);
define _prima_neta				dec(16,2);
define _impuesto				dec(16,2);
define _saldo_cob				dec(16,2);
define _por_vencer				dec(16,2);
define _prima_bruta				dec(16,2);
define _corriente				dec(16,2);
define _monto_30				dec(16,2);
define _monto_60				dec(16,2);
define _monto_90				dec(16,2);
define _exigible				dec(16,2);
define _cnt_dias				dec(16,2);
define _saldo					dec(16,2);
define _monto					dec(16,2);
define _error_isam				integer;
define _error					integer;
define _renglon					integer;
define _fecha_primer_pago		date;
define _vigencia_final			date;
define _vigencia_inic			date;
define _fecha_cobro				date;
define _fecha_moros				date;

--set debug file to 'sp_cob430.trc';
--trace on;

set isolation to dirty read;
let _null = null;

begin
on exception set _error, _error_isam, _error_desc
	begin
		on exception in(-255)
		end exception
		rollback work;
	end 
	return	_null,
			_error_desc,
			_no_documento,
			_null,
			_null,
			_null,
			_null,
			_null,
			_null,
			_null,
			_null,
			_error,
			_null,
			_null,
			_error_isam,
			0.00,
			0.00,
			_saldo_cob,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00;
end exception

foreach with hold
	select agt.cod_agente,
		   agt.nombre,
		   mae.no_documento,
		   ram.cod_ramo,
		   ram.nombre,
		   mae.vigencia_inic,
		   mae.vigencia_final,
		   mae.cod_perpago,
		   per.nombre,
		   mae.fecha_primer_pago,
		   cob.no_remesa,
		   cob.renglon,
		   cob.fecha,
		   cob.periodo,
		   cob.monto,
		   cob.impuesto,
		   cob.prima_neta,
		   cob.saldo
	  into _cod_agente,
		   _nom_agente,
		   _no_documento,
		   _cod_ramo,
		   _nom_ramo,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_perpago,
		   _nom_perpago,
		   _fecha_primer_pago,
		   _no_remesa,
		   _renglon,
		   _fecha_cobro,
		   _periodo_cobro,
		   _monto_cobrado,
		   _impuesto,
		   _prima_neta,
		   _saldo_cob
	  from emipoliza emi
	 inner join cobredet cob on cob.doc_remesa = emi.no_documento
	 inner join emipomae mae on mae.no_poliza = cob.no_poliza
	 inner join agtagent agt on agt.cod_agente = emi.cod_agente
	 inner join cobperpa per on per.cod_perpago = mae.cod_perpago
	 inner join prdramo ram on ram.cod_ramo = mae.cod_ramo
	 where emi.cod_agente in ('02311','01589','02901')
	   and cob.tipo_mov in ('P','N')
	   and cob.fecha >= '01/01/2022'
	 order by mae.no_documento,cob.fecha
	
	let _fecha_moros = _fecha_cobro - 1 units day;
	call sp_cob33d('001','001',_no_documento,_periodo_cobro,_fecha_moros)
	returning	_por_vencer,
				_exigible,
				_corriente,
				_monto_30,
				_monto_60,
				_monto_90,
				_saldo;
	
	return	_cod_agente,
			_nom_agente,
			_no_documento,
			_cod_ramo,
			_nom_ramo,
			_vigencia_inic,
			_vigencia_final,
			_cod_perpago,
			_nom_perpago,
			_fecha_primer_pago,
			_no_remesa,
			_renglon,
			_fecha_cobro,
			_periodo_cobro,
			_monto_cobrado,
			_impuesto,
			_prima_neta,
			_saldo_cob,
			_por_vencer,
			_exigible,
			_corriente,
			_monto_30,
			_monto_60,
			_monto_90,
			_saldo
		   with resume;
end foreach
end 
end procedure
