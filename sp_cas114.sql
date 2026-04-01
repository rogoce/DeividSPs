-- Procedimiento para la Insercion Inicial de Polizas para el sistema de Cobros por Campana
-- Creado    : 04/10/2010- Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas114;

create procedure sp_cas114(a_cod_campana char (10))
returning	integer,
			char(100);

Define v_motivo_rechazo		varchar(50);
Define _error_desc			char(50);
Define v_no_documento 	 	char(20);
define _no_documento		char(20);
Define v_cod_pagador		char(10);
Define v_no_poliza			char(10);
Define v_fecha_exp			char(7);
Define v_cod_agente			char(5);
Define v_cod_grupo			char(5);
Define v_cod_area			char(5);
Define v_cod_ramo			char(3);
Define v_cod_formapag		char(3);
Define v_cod_suc			char(3);
Define v_cod_zona			char(3);
Define v_cod_subramo		char(3);
Define v_cod_pagos			char(3);
Define v_cod_status			char(1);
Define v_prima_bruta		dec(16,2);
Define v_por_vencer			dec(16,2);
Define v_corriente			dec(16,2);
Define v_monto_180			dec(16,2);
Define v_monto_150			dec(16,2);
Define v_monto_120			dec(16,2);
Define v_monto_30			dec(16,2);
Define v_monto_60			dec(16,2);
Define v_monto_90			dec(16,2);
Define v_exigible			dec(16,2);
Define v_saldo				dec(16,2);
Define v_carta_aviso_canc	smallint;
Define v_cod_acreencia		smallint;
Define v_cod_gestion		smallint;
define _error_isam			smallint;
Define v_dia_cob1			smallint;
Define v_dia_cob2			smallint;
Define _dia_cob				smallint;
Define _error				smallint;
define _cnt					integer;
define _cnt_cas				integer;
Define v_vigencia_inic		date;
Define v_vigencia_fin		date;

on exception set _error,_error_isam,_error_desc
	return _error, "Error al Ingresar los Registro. " || trim(_error_desc);
end exception  

--set debug file to "sp_cas114.trc";
--trace on;

set isolation to dirty read;

select count(*)
  into _cnt
  from campoliza
 where cod_campana = a_cod_campana;

if _cnt is null then
	let _cnt = 0;
end if

select count(*)
  into _cnt_cas
  from campoliza
 where cod_campana = a_cod_campana;
 
if _cnt_cas is null then
	let _cnt_cas = 0;
end if

if _cnt_cas > 0 then
	foreach
		select no_documento
		  into _no_documento
		  from campoliza
		 where cod_campana = a_cod_campana

		select count(*)
		  into _cnt
		  from recrecup r, recrcmae m
		 where r.no_reclamo = m.no_reclamo
		   and m.no_documento = _no_documento
		   and r.cod_abogado = '049'
		   and r.estatus_recobro = 5;

		if _cnt is null then
			let _cnt = 0;
		end if

		if _cnt = 0 then
			delete from campoliza
			 where no_documento = _no_documento;
		end if
	end foreach
else
	foreach
		Select distinct e.no_documento,
				   e.cod_ramo,
				   e.cod_formapag,
				   e.cod_area,   
				   e.cod_grupo,
				   e.cod_pagos,
				   e.cod_pagador,
				   e.cod_sucursal,
				   e.dia_cobros1,
				   e.dia_cobros2,
				   e.cod_status,
				   e.vigencia_inic,
				   e.vigencia_fin,
				   e.exigible,
				   e.por_vencer,
				   e.corriente,
				   e.monto_30,
				   e.monto_60,
				   e.monto_90,
				   e.monto_120,
				   e.monto_150,
				   e.monto_180,
				   e.saldo,
				   e.cod_acreencia,
				   e.cod_zona,
				   e.cod_agente,
				   e.prima_bruta,
				   e.carta_aviso_canc,
				   e.fecha_exp,
				   e.motivo_rechazo,
				   e.cod_subramo,
				   e.sin_gestion
			  into v_no_documento,
				   v_cod_ramo,
				   v_cod_formapag,
				   v_cod_area,
				   v_cod_grupo,
				   v_cod_pagos,
				   v_cod_pagador,
				   v_cod_suc,
				   v_dia_cob1,
				   v_dia_cob2,
				   v_cod_status,
				   v_vigencia_inic,
				   v_vigencia_fin,
				   v_exigible,
				   v_por_vencer,
				   v_corriente,
				   v_monto_30,
				   v_monto_60,
				   v_monto_90,
				   v_monto_120,
				   v_monto_150,
				   v_monto_180,
				   v_saldo,
				   v_cod_acreencia,
				   v_cod_zona,
				   v_cod_agente,
				   v_prima_bruta,
				   v_carta_aviso_canc,
				   v_fecha_exp,
				   v_motivo_rechazo,
				   v_cod_subramo,
				   v_cod_gestion				    				  
			  from emipoliza e, recrecup r, recrcmae m
			 where r.no_reclamo = m.no_reclamo
			   and e.no_documento = m.no_documento
			   and r.cod_abogado = '049'
			   and r.estatus_recobro = 5

			Insert into campoliza(
						  no_documento,
						  cod_ramo,
						  cod_formapag,
						  cod_area,   
						  cod_grupo,
						  cod_pagos,
						  cod_pagador,
						  cod_sucursal,
						  dia_cobros1,
						  dia_cobros2,
						  cod_status,
						  vigencia_inic,
						  vigencia_fin,
						  exigible,
						  por_vencer,
						  corriente,
						  monto_30,
						  monto_60,
						  monto_90,
						  monto_120,
						  monto_150,
						  monto_180,
						  saldo,
						  cod_agente,
						  cod_zona,
						  cod_acreencia,
						  cod_campana,
						  prima_bruta,
						  carta_aviso_canc,
						  fecha_exp,
						  motivo_rechazo,
						  cod_subramo,
						  cod_gestion)
				 values(
						  v_no_documento,
						  v_cod_ramo,
						  v_cod_formapag,
						  v_cod_area,
						  v_cod_grupo,
						  v_cod_pagos,
						  v_cod_pagador,
						  v_cod_suc,
						  v_dia_cob1,
						  v_dia_cob2,
						  v_cod_status,
						  v_vigencia_inic,
						  v_vigencia_fin,
						  v_exigible,
						  v_por_vencer,
						  v_corriente,
						  v_monto_30,
						  v_monto_60,
						  v_monto_90,
						  v_monto_120,
						  v_monto_150,
						  v_monto_180,
						  v_saldo,
						  v_cod_agente,
						  v_cod_zona,
						  v_cod_acreencia,
						  a_cod_campana,
						  v_prima_bruta,
						  v_carta_aviso_canc,
						  v_fecha_exp,
						  v_motivo_rechazo,
						  v_cod_subramo,
						  v_cod_gestion);
	end foreach
end if
end procedure;