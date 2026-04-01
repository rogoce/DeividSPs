-- Procedimiento para la Insercion Inicial de Polizas para el sistema de Cobros por Campana
-- Creado    : 04/10/2010- Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cas107;

CREATE PROCEDURE sp_cas107(a_cod_campana char (10))
RETURNING INTEGER, CHAR(100);

Define v_motivo_rechazo		varchar(50);
Define _descripcion			varchar(50);
Define _sql_describe		char(500);
Define _sql_where			char(100);
Define _sql_and				char(100);
Define _error_desc			char(50);
Define v_no_documento 	 	char(20);
Define v_cod_pagador		char(10);
Define v_no_poliza			char(10);
Define v_fecha_exp			char(7);
Define _periodo				char(7);
Define v_cod_agente			char(5);
Define _cod_agente			char(5);
Define v_cod_grupo			char(5);
Define v_cod_area			char(5);
Define _agente				char(5);
Define _grupo				char(5);
Define _area				char(5);
Define _ano					char(4);
Define v_cod_ramo			char(3);
Define v_cod_formapag		char(3);
Define v_cod_suc			char(3);
Define v_cod_zona			char(3);
Define v_cod_subramo		char(3);
Define _cod_filtro			char(3);
Define v_cod_pagos			char(3);
Define _acreencia			char(3);
Define _formapag			char(3);
Define _ramo				char(3);
Define _suc					char(3);
Define _subramo				char(3);
Define _pagos				char(3);
Define _moros				char(3);
Define _zona				char(3);
Define _mes					char(2);
Define v_cod_status			char(1);
Define _especiales			char(1);
Define _gestion				char(1);
Define _status				char(1);
Define _char				char(1);
Define v_vigencia_inic		date;
Define v_vigencia_fin		date;
Define _fecha_hasta			date;
Define _fecha_desde			date;
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
Define v_dia_cob1			smallint;
Define v_dia_cob2			smallint;
Define _cnt_ramo			smallint;
Define _dia_cob				smallint;
Define _error				smallint;
Define flag					smallint;
define _tipo_campana        smallint;
Define _contador2			integer;

define v_xperiodo	           char(1);    
define v_xtipo		           char(1);  
define v_xmoro_cdc_porvencer   char(1);  
define v_xmoro_cdc_exigible    char(1);
define v_xanio  	           char(4);
define v_xmes                  char(2);
--define _cod_filtro             char(15);

on exception set _error
    --rollback work;
	return _error, "Error al Ingresar los Registro";
end exception  

--set debug file to "sp_cas107.trc";
--trace on;

set isolation to dirty read;
let flag = 0;
delete from campoliza where cod_campana = a_cod_campana;

Select filt_acre,
	   filt_agente,
	   filt_area,
	   filt_diacob,
	   filt_formapag,
	   filt_grupo,
	   filt_moros,
	   filt_pago,
	   filt_ramo,
	   filt_status,
	   filt_sucursal,
	   filt_zonacob,
	   filt_especiales,
	   filt_subramos,
	   filt_gestion,
	   tipo_campana,filt_nueva_renov_cdc,filt_periodo,filt_anio,filt_mes,filt_moro_cdc_exigible,filt_moro_cdc_porvencer
  into _acreencia,
	   _agente,
	   _area,
	   _dia_cob,
	   _formapag,
	   _grupo,
	   _moros,
	   _pagos,
	   _ramo,
	   _status,
	   _suc,
	   _zona,
	   _especiales,
	   _subramo,
	   _gestion,
	   _tipo_campana,v_xtipo,v_xperiodo,v_xanio,v_xmes,v_xmoro_cdc_exigible,v_xmoro_cdc_porvencer
  from cascampana
 where cod_campana = a_cod_campana;

if _moros = "1" then
	if flag = 0 then
	  	let flag = 1;
		let _sql_where = '';

		{let _char = sp_sis04('001,002,003,004,005,006,007;'); -- separa los valores del string

		delete from tmp_codigos
		 where codigo in (select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 2);

		foreach
			select cod_filtro
			  into _cod_filtro
			  from cascampanafil 
			 where cod_campana = a_cod_campana 
			   and tipo_filtro = 2

			if  _cod_filtro = '001' then
				let _sql_where = trim(_sql_where) || '+ corriente';
			elif _cod_filtro = '002' then
				let _sql_where = trim(_sql_where) || '+ monto_30';
			elif _cod_filtro = '003' then
				let _sql_where = trim(_sql_where) || '+ monto_60';
			elif _cod_filtro = '004' then
				let _sql_where = trim(_sql_where) || '+ monto_90';
			elif _cod_filtro = '005' then
				let _sql_where = trim(_sql_where) || '+ monto_120';
			elif _cod_filtro = '006' then
				let _sql_where = trim(_sql_where) || '+ monto_150';
			elif _cod_filtro = '007' then
				let _sql_where = trim(_sql_where) || '+ monto_180';
			end if		
		end foreach

		let _sql_where = _sql_where[2,100];
		let _sql_where = trim(_sql_where) || '> 0.00';
		let _sql_and = '';

		foreach
			select codigo
			  into _cod_filtro
			  from tmp_codigos 

			if  _cod_filtro = '001' then
				let _sql_and = trim(_sql_and) || '+ corriente';
			elif _cod_filtro = '002' then
				let _sql_and = trim(_sql_and) || '+ monto_30';
			elif _cod_filtro = '003' then
				let _sql_and = trim(_sql_and) || '+ monto_60';
			elif _cod_filtro = '004' then
				let _sql_and = trim(_sql_and) || '+ monto_90';
			elif _cod_filtro = '005' then
				let _sql_and = trim(_sql_and) || '+ monto_120';
			elif _cod_filtro = '006' then
				let _sql_and = trim(_sql_and) || '+ monto_150';
			elif _cod_filtro = '007' then
				let _sql_and = trim(_sql_and) || '+ monto_180';
			end if		
		end foreach

		let _sql_and = _sql_and[2,100];

		if _sql_and <> '' then
			let _sql_and = trim(_sql_and) || '= 0.00';
		end if

		drop table tmp_codigos;}

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
				   cod_subramo,
				   sin_gestion
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
			  from emipoliza
			 where cod_corriente  = (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 2 and cod_filtro = "001") 
			    or cod_monto_30   = (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 2 and cod_filtro = "002") 
			    or cod_monto_60   = (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 2 and cod_filtro = "003") 
			    or cod_monto_90   = (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 2 and cod_filtro = "004") 
			    or cod_monto_120  = (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 2 and cod_filtro = "005")
			    or cod_monto_150  = (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 2 and cod_filtro = "006")
			    or cod_monto_180  = (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 2 and cod_filtro = "007")

			{let _sql_describe = "select distinct no_documento,cod_ramo,cod_formapag,cod_area,cod_grupo,cod_pagos,cod_pagador,cod_sucursal,dia_cobros1,dia_cobros2,cod_status,vigencia_inic,vigencia_fin,exigible,por_vencer,corriente,monto_30,monto_60,monto_90,monto_120,monto_150,monto_180,saldo,cod_acreencia,cod_zona,cod_agente,prima_bruta,carta_aviso_canc,fecha_exp,motivo_rechazo,cod_subramo,sin_gestion";			
			
			if _sql_and <> '' then
				let _sql_where = trim(_sql_where) || 'and ' || trim(_sql_and);
			end if
			
			let _sql_describe = trim(_sql_describe) || " from emipoliza where " || trim(_sql_where);
			
			prepare equisql from _sql_describe;	
			declare equicur cursor for equisql;
			open equicur;
			while (1 = 1)			
				fetch equicur into	v_no_documento,
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
									v_cod_gestion;
				if (sqlcode = 100) then
					exit;
				end if

				if (sqlcode != 100) then}
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
					values(	v_no_documento,
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
				{else
					exit;
				end if
				
			end while
			close equicur;	
			free equicur;
			free equisql;}
		end foreach
	else
	end if 
end if

{if _poliza_sin_pago = '1' then
	if flag = 0 then
		let flag = 1;
		
		
	else
	end if
end if}

if _ramo = "1" then
	if flag = 0 then
		let flag = 1;
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
				   cod_subramo,
				   sin_gestion
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
			  from emipoliza
			 where cod_ramo in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 1)

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

				   	
		end foreach -- final de la secuencia de cada poliza
	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
		delete from campoliza where cod_ramo not in (Select cod_filtro from cascampanafil where tipo_filtro = 1 and cod_campana = a_cod_campana);
	end if -- end if del contador			
end if-- end if del Filtro por Ramo

if _subramo = "1" then

	Select count(*)
	  into _cnt_ramo 
	  from cascampanafil 
	 where tipo_filtro = 1 
	   and cod_campana = a_cod_campana;

	if _cnt_ramo = 1 then
		if flag = 0 then
			let flag = 1;
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
				   cod_subramo,
				   sin_gestion
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
			  from emipoliza
			 where cod_ramo in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 1)
			   and cod_subramo in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 14)

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

					   	
			end foreach -- final de la secuencia de cada poliza

		else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
			delete from campoliza where cod_subramo not in (Select cod_filtro from cascampanafil where tipo_filtro = 14 and cod_campana = a_cod_campana);
		end if -- end if del contador
	end if			
end if-- end if del Filtro por Ramo


if _formapag = "1" then
	if flag = 0 then
		let flag = 1;
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
				   cod_subramo,
				   sin_gestion
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
			  from emipoliza
			 where cod_formapag in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 3)

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
				   	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
		delete from campoliza
		where cod_formapag not in (Select cod_filtro from cascampanafil where tipo_filtro = 3 and cod_campana = a_cod_campana);
	end if -- end if del contador			
end if-- end if del Filtro por Forma de Pago

if _zona = "1" then
	if flag = 0 then
		let flag = 1;
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
				   cod_subramo,
				   sin_gestion
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
			  from emipoliza
			 where cod_ramo in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 4)

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

				   	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
		delete from campoliza
		where cod_zona not in (Select cod_filtro from cascampanafil where tipo_filtro = 4 and cod_campana = a_cod_campana);
	end if -- end if del contador			
end if-- end if del Filtro por Zona de Cobros

--trace on;

if _agente = "1" then
	if flag = 0 then
		let flag = 1;
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
				   cod_subramo,
				   sin_gestion
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
			  from emipoliza
			 where cod_agente in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 5)
				or cod_agente = '00000'

			if v_cod_agente = '00000' then
				let v_no_documento = trim(v_no_documento);
				let v_no_poliza = sp_sis21(v_no_documento);

				select cod_agente
				  into _cod_agente
				  from emipoagt
				 where no_poliza = v_no_poliza
				   and cod_agente in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 5);
				
				if _cod_agente is not null then
					select cod_cobrador
					  into v_cod_zona
					  from agtagent
					 where cod_agente = _cod_agente;
				else
					continue foreach;
				end if 
			end if
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



		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
		delete from campoliza
		where cod_agente not in (Select cod_filtro from cascampanafil where tipo_filtro = 5 and cod_campana = a_cod_campana);
	end if -- end if del contador			
end if-- end if del Filtro por Agente
--trace off;

if _suc = "1" then
	if flag = 0 then
		let flag = 1;
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
				   cod_subramo,
				   sin_gestion
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
			  from emipoliza
			 where cod_sucursal in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 6)

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
				   	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
		delete from campoliza
		where cod_sucursal not in (Select cod_filtro from cascampanafil where tipo_filtro = 6 and cod_campana = a_cod_campana);
	end if -- end if del contador			
end if-- end if del Filtro por Sucursal


if _area = "1" then
	if flag = 0 then
		let flag = 1;
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
				   cod_subramo,
				   sin_gestion
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
			  from emipoliza
			 where cod_area in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 7)

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
				   	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
		delete from campoliza
		where cod_area not in (Select cod_filtro from cascampanafil where tipo_filtro = 7 and cod_campana = a_cod_campana);
	end if -- end if del contador			
end if-- end if del Filtro por Area

--trace on;
if _status = "1" then
	if flag = 0 then
		let flag = 1;
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
				   cod_subramo,
				   sin_gestion
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
			  from emipoliza
			 where cod_status in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 8)

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
				   
				   	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
		delete from campoliza
		where cod_status not in (Select cod_filtro from cascampanafil where tipo_filtro = 8 and cod_campana = a_cod_campana);
	end if -- end if del contador			
end if-- end if del Filtro por Estatus de Poliza

-- off;


if _grupo = "1" then
	if flag = 0 then
		let flag = 1;
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
				   cod_subramo,
				   sin_gestion
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
			  from emipoliza
			 where cod_grupo in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 9)

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
				   
				   	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
		delete from campoliza
		where cod_grupo not in (Select cod_filtro from cascampanafil where tipo_filtro = 9 and cod_campana = a_cod_campana);
	end if -- end if del contador			
end if-- end if del Filtro por Grupo


if _dia_cob = "1" then
	if flag = 0 then
		let flag = 1;
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
				   cod_subramo,
				   sin_gestion
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
			  from emipoliza
			 where dia_cobros1 in (Select cod_filtro from cascampanafil where tipo_filtro = 10 and cod_campana = a_cod_campana)
		   		or dia_cobros2 in (Select cod_filtro from cascampanafil where tipo_filtro = 10 and cod_campana = a_cod_campana)

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
				   
				   	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
		delete from campoliza
		where dia_cobros1 not in (Select cod_filtro from cascampanafil where tipo_filtro = 10 and cod_campana = a_cod_campana)
		   or dia_cobros2 not in (Select cod_filtro from cascampanafil where tipo_filtro = 10 and cod_campana = a_cod_campana);
	end if -- end if del contador			
end if-- end if del Filtro por Dias de Cobros


if _acreencia = "1" then
	if flag = 0 then
		let flag = 1;
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
				   cod_subramo,
				   sin_gestion
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
			  from emipoliza
			 where cod_acreencia in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 11)

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
				   
				   	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
		delete from campoliza
		where cod_acreencia not in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 11);
	end if -- end if del contador			
end if-- end if del Filtro por Acreencia



if _pagos = "1" then
	if flag = 0 then
		let flag = 1;
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
				   cod_subramo,
				   sin_gestion
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
			  from emipoliza
			 where cod_pagos in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 12)

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
		end foreach -- final de la secuencia de cada poliza
	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
		delete from campoliza
		where cod_pagos not in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 12);
	end if -- end if del contador			
end if-- end if del Filtro por Prima Original

--trace on;
-- 1:Se excluye polizas gestada en VOCEM, RGORDON 26/7/18
{delete from campoliza
	where no_documento in (	
	select distinct no_documento   
	  from caspoliza 
     where cod_campana = '01656') ;}

if _especiales <> '0' or _gestion <> '0' then
   	call sp_cas107b(a_cod_campana,flag) returning _error,_error_desc;
   	if _error <> 0 then
   		return _error,_error_desc;
   	end if  
end if-- end if del Filtros Especiales 

if v_xtipo <> '0' or v_xperiodo <> '0' or v_xmoro_cdc_exigible <> '0' or v_xmoro_cdc_porvencer <> '0'  then
SET DEBUG FILE TO "sp_cas107_2.trc";
TRACE ON ;
   	call sp_cas107b_2(a_cod_campana,flag) returning _error,_error_desc;
   	if _error <> 0 then
   		return _error,_error_desc;
   	end if  
end if-- end if del Filtros Especiales 

delete from campoliza
 where cod_campana = a_cod_campana
   and cod_grupo in ('1090', '124', '125', '148','1122','77960','77982');   --CASO: 30140 USER: ASTANZIO grupo: 148 desde: 18/12/2018 5pm -- F9:30295 1122 ASTANZIO  15/01/2019    -- SD#3010 07/04/2022 4:00pm -- SD#5708 23/02/2023 HG
   
   if _tipo_campana = 3 then
		delete from campoliza
		 where cod_campana = a_cod_campana
		   and cod_grupo in ('00087');   --CASO: 31333 USER: ASTANZIO 5/5/2019 00087 Excluir   si es Anulacion
   end if

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