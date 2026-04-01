-- Procedimiento para la Insercion Inicial de Polizas para el sistema de Cobros por Campana
-- Creado    : 04/10/2010- Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cas107b_2;

CREATE PROCEDURE sp_cas107b_2(a_cod_campana char(10),a_flag	smallint)
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

define v_xperiodo	           char(1);    
define v_xtipo		           char(1);  
define v_xmoro_cdc_porvencer   char(1);  
define v_xmoro_cdc_exigible    char(1);
define v_xanio  	           char(4);
define v_xmes                  char(2);
define _cod_filtro             char(12);
define v_nueva_renov           char(1);
Define _flag1				   smallint;
Define _flag2				   smallint;
Define _flag3				   smallint;
Define _flag4				   smallint;
define _tipo_campana           smallint;
Define _status				char(1);


on exception set _error
    --rollback work;						 
	return _error, "Error al Ingresar los Registro";
end exception  

--set debug file to "sp_cas107b.trc";
--trace on;


select filt_gestion, filt_nueva_renov_cdc,filt_periodo,filt_anio,filt_mes,filt_moro_cdc_exigible,filt_moro_cdc_porvencer
  into _gestion,v_xtipo,v_xperiodo,v_xanio,v_xmes,v_xmoro_cdc_exigible,v_xmoro_cdc_porvencer
  from cascampana
 where cod_campana = a_cod_campana;


set isolation to dirty read;
let _cod_filtro = '0';
let _flag1 = 0;
let _flag2 = 0;
let _flag3 = 0;
let _flag4 = 0;
-------------------------------------------
let a_flag = 0;
if v_xtipo <> "0" then	
		Select cod_filtro
		  into _cod_filtro
		  from cascampanafil
		 where cod_campana = a_cod_campana
		   and tipo_filtro = '19';
		   
		  	let _char = _cod_filtro[1,1];
			
			delete from campoliza where no_documento in (
			 select a.no_documento from emipoliza a, emipomae b 
			  where a.no_poliza = b.no_poliza  and b.actualizado = 1  
				and b.estatus_poliza in (1,3)   -- (3,2,4)
                and b.nueva_renov not in ( _char)
				and a.saldo > 0	); 
		   
		let _flag1 = 1;
		foreach
			Select first 1000 distinct a.no_documento,
				   a.cod_ramo,
				   a.cod_formapag,
				   a.cod_area,   
				   a.cod_grupo,
				   a.cod_pagos,
				   a.cod_pagador,
				   a.cod_sucursal,
				   a.dia_cobros1,
				   a.dia_cobros2,
				   a.cod_status,
				   a.vigencia_inic,
				   a.vigencia_fin,
				   a.exigible,
				   a.por_vencer,
				   a.corriente,
				   a.monto_30,
				   a.monto_60,
				   a.monto_90,
				   a.monto_120,
				   a.monto_150,
				   a.monto_180,
				   a.saldo,
				   a.cod_acreencia,
				   a.cod_zona,
				   a.cod_agente,
				   a.prima_bruta,
				   a.carta_aviso_canc,
				   a.fecha_exp,
				   a.motivo_rechazo,
				   a.cod_subramo,
				   b.nueva_renov
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
				   v_nueva_renov
			  from emipoliza a, emipomae b
			 where a.no_poliza = b.no_poliza
			    and b.actualizado = 1  
				and b.estatus_poliza in (1,3)   -- (3,2,4)
                and upper(trim(b.nueva_renov)) = upper(trim(_char))
				and a.saldo > 0				
				
				
			 if v_nueva_renov <> upper(trim(_char)) then 
				continue foreach;
			 end if	
			 

			--let v_no_poliza = sp_sis21(v_no_documento);
			begin
				on exception in(-239,-217,-268)				   
				end exception					
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
				end				   	
		end foreach -- final de la secuencia de cada poliza	
		let _char = _char;
			delete from campoliza where no_documento in (
			 select a.no_documento from emipoliza a, emipomae b 
			  where a.no_poliza = b.no_poliza  and b.actualizado = 1  
				and b.estatus_poliza in (1,3)   -- (3,2,4)
                and upper(trim(b.nueva_renov)) not in (upper(trim(_char)))
				and a.saldo > 0	); 	

end if-- end if del Filtro por Prima Original

if v_xmoro_cdc_porvencer = "1" then	
		Select cod_filtro
		  into _cod_filtro
		  from cascampanafil
		 where cod_campana = a_cod_campana
		   and tipo_filtro = '20';	
		let _flag2 = 1;
		--delete from campoliza where por_vencer = 0 ; 
		
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
			 where cast(por_vencer*1 as money) > 0
			 
			 if v_por_vencer <= 0 then 
				continue foreach;
			 end if			 

			--let v_no_poliza = sp_sis21(v_no_documento);
			begin
				on exception in(-239,-217,-268)					   
				end exception					
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
				end				   
				   	
		end foreach -- final de la secuencia de cada poliza		

		delete from campoliza where cast(por_vencer*1 as money) <= 0 ;  --por_vencer = 0 ; 
end if-- end if del Filtro por Prima Original

if v_xmoro_cdc_exigible = "1" then	
		Select cod_filtro
		  into _cod_filtro
		  from cascampanafil
		 where cod_campana = a_cod_campana
		   and tipo_filtro = '21';	
		let _flag3 = 1;
		--delete from campoliza where exigible = 0 ; 
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
			 where cast(exigible*1 as money) > 0
			 
			 if v_exigible <= 0 then 
				continue foreach;
			 end if

			--let v_no_poliza = sp_sis21(v_no_documento);
			begin
				on exception in(-239,-217,-268)					   
				end exception			
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
					end						  
				   
				   	
		end foreach -- final de la secuencia de cada poliza	
		
	
end if-- end if del Filtro por Prima Original

if v_xperiodo = "1" then  --18		
		Select cod_filtro
		  into _periodo
		  from cascampanafil
		 where cod_campana = a_cod_campana
		   and tipo_filtro = '18';

		Call sp_sis36(_periodo) Returning _fecha_hasta;
		let _ano = _periodo[1,4];
		let _mes = _periodo[6,7];
        let _flag4 = 1;
		let _fecha_desde = MDY(_mes, 1, _ano);
		--delete from campoliza where vigencia_fin not between _fecha_desde and _fecha_hasta ; 
		
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
			 where vigencia_inic between _fecha_desde and _fecha_hasta --and vigencia_fin is not null  		  
--			  where vigencia_fin between _fecha_desde and _fecha_hasta --and vigencia_fin is not null  

			--let v_no_poliza = sp_sis21(v_no_documento);
			begin
				on exception in(-239,-217,-268)				   
				end exception					
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
				end				   
				   	
		end foreach -- final de la secuencia de cada poliza	
		delete from campoliza where vigencia_inic not between _fecha_desde and _fecha_hasta ; 		
--		delete from campoliza where vigencia_fin not between _fecha_desde and _fecha_hasta ; 
end if-- end if del Filtro por Prima Original
-------------------------------------------
if _flag1 = 1 then
			delete from campoliza where no_documento in (
			 select a.no_documento from emipoliza a, emipomae b 
			  where a.no_poliza = b.no_poliza  and b.actualizado = 1  
				and b.estatus_poliza in (1,3)   -- (3,2,4)
                and b.nueva_renov not in ( _char)
				and a.saldo > 0	); 
end if

 if v_xmoro_cdc_exigible = "1"  and  v_xmoro_cdc_porvencer = "1" then	
		delete from campoliza where cast(por_vencer*1 as money) + cast(exigible*1 as money) <= 0; 
        let _flag2 = 0;
		let _flag3 = 0;
 end if

if _flag2 = 1 then
	delete from campoliza where cast(por_vencer*1 as money) <= 0 ;  --por_vencer = 0 ; 
end if

if _flag3 = 1 then
	delete from campoliza where cast(exigible*1 as money) <= 0;   --exigible = 0 ; 	
end if

if _flag4 = 1 then
	delete from campoliza where vigencia_inic not between _fecha_desde and _fecha_hasta ;
--	delete from campoliza where vigencia_fin not between _fecha_desde and _fecha_hasta ;
end if

delete from campoliza where cod_campana = a_cod_campana and cod_formapag = '084';  -- JEPEREZ sin COA MIN


---******
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
	   tipo_campana
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
	   _tipo_campana
  from cascampana
 where cod_campana = a_cod_campana;
 
 if _ramo = "1" then
	delete from campoliza where cod_ramo not in (Select cod_filtro from cascampanafil where tipo_filtro = 1 and cod_campana = a_cod_campana);
 end if
 if _subramo = "1" then
	delete from campoliza where cod_subramo not in (Select cod_filtro from cascampanafil where tipo_filtro = 14 and cod_campana = a_cod_campana);
 end if
 if _formapag = "1" then
	delete from campoliza	where cod_formapag not in (Select cod_filtro from cascampanafil where tipo_filtro = 3 and cod_campana = a_cod_campana);
 end if
 if _zona = "1" then
	delete from campoliza where cod_zona not in (Select cod_filtro from cascampanafil where tipo_filtro = 4 and cod_campana = a_cod_campana);
 end if
 if _agente = "1" then
	delete from campoliza	where cod_agente not in (Select cod_filtro from cascampanafil where tipo_filtro = 5 and cod_campana = a_cod_campana);
 end if
 if _suc = "1" then
	delete from campoliza where cod_sucursal not in (Select cod_filtro from cascampanafil where tipo_filtro = 6 and cod_campana = a_cod_campana);
 end if
 if _area = "1" then
	delete from campoliza	where cod_area not in (Select cod_filtro from cascampanafil where tipo_filtro = 7 and cod_campana = a_cod_campana);
 end if
 if _status = "1" then
	delete from campoliza	where cod_status not in (Select cod_filtro from cascampanafil where tipo_filtro = 8 and cod_campana = a_cod_campana);
 end if
 if _grupo = "1" then
	delete from campoliza	where cod_grupo not in (Select cod_filtro from cascampanafil where tipo_filtro = 9 and cod_campana = a_cod_campana);
 end if
 if _dia_cob = "1" then
	delete from campoliza
		where dia_cobros1 not in (Select cod_filtro from cascampanafil where tipo_filtro = 10 and cod_campana = a_cod_campana)
		   or dia_cobros2 not in (Select cod_filtro from cascampanafil where tipo_filtro = 10 and cod_campana = a_cod_campana);
 end if
 if _acreencia = "1" then
	delete from campoliza	where cod_acreencia not in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 11);
 end if
 if _pagos = "1" then
	delete from campoliza	where cod_pagos not in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 12);
 end if
 

---******


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