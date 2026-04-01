-- Procedimiento para la Insercion Inicial de Polizas para el sistema de Cobros por Campana
-- Creado    : 04/10/2010- Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cas107b;

CREATE PROCEDURE sp_cas107b(a_cod_campana char(10),a_flag	smallint)
RETURNING INTEGER, CHAR(100);

Define v_motivo_rechazo		varchar(50);
Define _descripcion			varchar(50);
Define _error_desc	 	 	char(100);
Define v_no_documento 	 	char(20);
Define v_cod_pagador		char(10);
Define v_no_poliza			char(10);
Define v_fecha_exp			char(7);
Define _periodo				char(7);
Define _cod_agente			char(5);
Define v_cod_agente			char(5);
Define v_cod_area			char(5);
Define v_cod_grupo			char(5);
Define v_cod_subramo		char(3);
Define v_cod_pagos			char(3);
Define v_cod_zona			char(3);
Define _ramo				char(3);
Define _formapag			char(3);
Define _suc					char(3);
Define _gestion				char(1);
Define _zona				char(3);
Define _agente				char(5);
Define _area				char(5);
Define _grupo				char(5);
Define _pagos				char(3);
Define _acreencia			char(3);
Define _moros				char(3);
Define _subramo				char(3);
Define _ano					char(4);
Define v_cod_ramo			char(3);
Define v_cod_formapag		char(3);
Define v_cod_suc			char(3);
Define _mes					char(2);
Define _especiales			char(1);
Define _char				char(1);
Define v_cod_status			char(1);
Define v_vigencia_inic		date;
Define v_vigencia_fin		date;
Define _fecha_hasta			date;
Define _fecha_desde			date;
Define v_por_vencer			dec(16,2);
Define v_exigible			dec(16,2);
Define v_corriente			dec(16,2);
Define v_monto_30			dec(16,2);
Define v_monto_60			dec(16,2);
Define v_monto_90			dec(16,2);
Define v_monto_120			dec(16,2);
Define v_monto_150			dec(16,2);			   
Define v_monto_180			dec(16,2);
Define v_saldo				dec(16,2);
Define v_prima_bruta		dec(16,2);
Define _dia_cob				smallint;
Define v_cod_acreencia		smallint;
Define v_dia_cob1			smallint;
Define v_dia_cob2			smallint;
Define _error				smallint;
Define _cnt_ramo			smallint;
Define flag					smallint;
Define v_carta_aviso_canc	smallint;
Define _contador2			integer;

on exception set _error
    --rollback work;						 
	return _error, "Error al Ingresar los Registro";
end exception  

--set debug file to "sp_cas107b.trc";
--trace on;


select filt_gestion
  into _gestion
  from cascampana
 where cod_campana = a_cod_campana;


set isolation to dirty read;

if _gestion = "1" then
	if a_flag = 0 then
		let a_flag = 1;
		foreach
			Select distinct no_documento,
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
				   cod_acreencia,
				   cod_zona,
				   cod_agente,
				   prima_bruta,
				   carta_aviso_canc,
				   fecha_exp,
				   motivo_rechazo,
				   cod_subramo
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
				   v_cod_subramo
			  from emipoliza
			 where sin_gestion in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 15)

			--let v_no_poliza = sp_sis21(v_no_documento);
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
						  cod_subramo)
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
						  v_cod_subramo);	   
				   
				   	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
		delete from campoliza
		where cod_gestion not in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 15);
	end if -- end if del contador			
end if-- end if del Filtro por Prima Original


foreach
	Select descripcion
	  into _descripcion
	  from cascampanafil
	 where cod_campana	= a_cod_campana
	   and tipo_filtro	= 13

	let _char = _descripcion[1,1];

	if _char = '1' then
		Select cod_filtro
		  into _periodo
		  from cascampanafil
		 where cod_campana = a_cod_campana
		   and tipo_filtro = '13';

		Call sp_sis36(_periodo) Returning _fecha_hasta;
		let _ano = _periodo[1,4];
		let _mes = _periodo[6,7];

		let _fecha_desde = MDY(_mes, 1, _ano);
			 
		if a_flag = 0 then
			let a_flag = 1;
			foreach
				Select distinct no_documento,
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
					   cod_acreencia,
					   cod_zona,
					   cod_agente,
					   prima_bruta,
					   carta_aviso_canc,
					   fecha_exp,
					   motivo_rechazo,
					   cod_subramo
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
					   v_cod_subramo
				  from emipoliza
				 where vigencia_fin between _fecha_desde and _fecha_hasta and vigencia_fin is not null  

				--let v_no_poliza = sp_sis21(v_no_documento);
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
							  cod_subramo)
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
							  v_cod_subramo);					   
						
			end foreach -- final de la secuencia de cada poliza

		else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
			delete from campoliza
			where vigencia_fin not between _fecha_desde and _fecha_hasta or vigencia_fin is null;
		end if -- end if del contador
	elif _char = '2' then

		Select cod_filtro
		  into _periodo
		  from cascampanafil
		 where cod_campana = a_cod_campana
		   and tipo_filtro = '13';

		let _ano 	 = _periodo[1,4];
		let _mes 	 = _periodo[6,7];
		let _periodo = _mes || '-' || _ano; 
		if a_flag = 0 then
			let a_flag = 1;
			foreach
				Select distinct no_documento,
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
					   cod_acreencia,
					   cod_zona,
					   cod_agente,
					   prima_bruta,
					   carta_aviso_canc,
					   fecha_exp,
					   motivo_rechazo,
					   cod_subramo
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
					   v_cod_subramo
				  from emipoliza
				 where fecha_exp = _periodo

				--let v_no_poliza = sp_sis21(v_no_documento);
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
							  cod_subramo)
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
							  v_cod_subramo);				   
						
			end foreach -- final de la secuencia de cada poliza

		else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
			delete from campoliza
			where fecha_exp <> _periodo;
		end if -- end if del contador
	elif _char = '3' then
		if a_flag = 0 then
			let a_flag = 1;
			foreach
				Select distinct no_documento,
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
					   cod_acreencia,
					   cod_zona,
					   cod_agente,
					   prima_bruta,
					   carta_aviso_canc,
					   fecha_exp,
					   motivo_rechazo,
					   cod_subramo
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
					   v_cod_subramo
					  from emipoliza
					 where carta_aviso_canc = 1

				--let v_no_poliza = sp_sis21(v_no_documento);
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
							  cod_subramo)
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
							  v_cod_subramo);	   
					   
						
			end foreach -- final de la secuencia de cada poliza
		else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
			delete from campoliza
			where carta_aviso_canc <> 1;
		end if -- end if del contador	
	elif _char = '4' then
		if a_flag = 0 then
			let a_flag = 1;
			foreach
				Select distinct no_documento,
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
					   cod_acreencia,
					   cod_zona,
					   cod_agente,
					   prima_bruta,
					   carta_aviso_canc,
					   fecha_exp,
					   motivo_rechazo,
					   cod_subramo
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
					   v_cod_subramo
					  from emipoliza
					 where motivo_rechazo in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 13)

				--let v_no_poliza = sp_sis21(v_no_documento);
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
							  cod_subramo)
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
							  v_cod_subramo);	   
					   
						
			end foreach -- final de la secuencia de cada poliza
		else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
			delete from campoliza
			where motivo_rechazo not in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 13) or motivo_rechazo is null;
		end if -- end if del contador	 
	--end if			
	--end if-- end if del Filtro por Prima Original

	elif _char = '5' then
		if a_flag = 0 then
			let a_flag = 1;
			foreach
				Select distinct no_documento,
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
					   cod_acreencia,
					   cod_zona,
					   cod_agente,
					   prima_bruta,
					   carta_aviso_canc,
					   fecha_exp,
					   motivo_rechazo,
					   cod_subramo
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
					   v_cod_subramo
					  from emipoliza
					 where motivo_rechazo in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 13)

				--let v_no_poliza = sp_sis21(v_no_documento);
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
							  cod_subramo)
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
							  v_cod_subramo);	   
					   
						
			end foreach -- final de la secuencia de cada poliza
		else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
			delete from campoliza
			where motivo_rechazo not in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 13) or motivo_rechazo is null;
		end if -- end if del contador
	elif _char = '6' then	--Filtro para póliza sin Pago
		call sp_cas113(a_cod_campana) returning _error,_error_desc;

		if _error <> 0 then
			return _error,_error_desc;
		end if
	elif _char = '7' then	--Filtro de Recobros
		call sp_cas114(a_cod_campana) returning _error,_error_desc;

		if _error <> 0 then
			return _error,_error_desc;
		end if
----
	elif _char = '8' then
			if a_flag = 0 then
				let a_flag = 1;
				foreach
					Select distinct no_documento,
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
						   cod_acreencia,
						   cod_zona,
						   cod_agente,
						   prima_bruta,
						   carta_aviso_canc,
						   fecha_exp,
						   motivo_rechazo,
						   cod_subramo
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
						   v_cod_subramo
						  from emipoliza
						 where cod_pagador in (select cod_cliente from clivip)

					--let v_no_poliza = sp_sis21(v_no_documento);
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
								  cod_subramo)
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
								  v_cod_subramo);	   
						   
							
				end foreach -- final de la secuencia de cada poliza 
			else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 
				delete from campoliza
				where cod_pagador not in (select cod_cliente from clivip);
			end if -- end if del contador
----		

	end if			
	--end if-- end if del Filtro por Prima Original
end foreach		


--trace on;	   
select count(*) 
  into _contador2	
  from campoliza
 where cod_campana = a_cod_campana;

if _contador2 = 0 then
	return 1,"No hay Registro para los Filtros Aplicados a esta Campaña";
else
	return 0,"Exito";
end if

end procedure