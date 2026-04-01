

CREATE PROCEDURE sp_cas107(a_cod_campana char (10))
RETURNING INTEGER, CHAR(100);

Define v_no_documento	char(20);
Define v_no_poliza		char(10);
Define v_cod_ramo		char(3);
Define v_cod_formapag	char(3);
Define v_cod_suc		char(3);
Define v_cod_status		char(1);
Define v_cod_zona		char(3);
Define v_cod_agente		char(5);
Define v_cod_area		char(5);
Define v_cod_grupo		char(5);
Define v_cod_pagos		char(3);
Define _ramo			char(3);
Define _formapag		char(3);
Define _suc				char(3);
Define _status			char(1);
Define _zona			char(3);
Define _agente			char(5);
Define _area			char(5);
Define _grupo			char(5);
Define _pagos			char(3);
Define _acreencia		char(3);
Define _moros			char(3);
Define v_cod_pagador	char(10);
Define v_vigencia_inic	date;
Define v_vigencia_fin	date;
Define v_por_vencer		dec(16,2);
Define v_exigible		dec(16,2);
Define v_corriente		dec(16,2);
Define v_monto_30		dec(16,2);
Define v_monto_60		dec(16,2);
Define v_monto_90		dec(16,2);
Define v_monto_120		dec(16,2);
Define v_monto_150		dec(16,2);
Define v_monto_180		dec(16,2);
Define v_saldo			dec(16,2);
Define v_prima_bruta	dec(16,2);
Define _cod_agente		char(5);
Define _dia_cob			smallint;
Define v_cod_acreencia	smallint;
Define v_dia_cob1		smallint;
Define v_dia_cob2		smallint;
Define _error			smallint;
Define _contador2		integer; 
Define flag				smallint;

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
	   filt_zonacob
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
	   _zona
  from cascampana
 where cod_campana = a_cod_campana;

if _moros = "1" then
	if flag = 0 then
	  	let flag = 1;
		foreach
			Select no_documento,
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
				   prima_bruta
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
				   v_prima_bruta 				  
			  from emipoliza
			 where cod_corriente  = (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 2 and cod_filtro = "001") 
			    or cod_monto_30   = (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 2 and cod_filtro = "002") 
			    or cod_monto_60   = (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 2 and cod_filtro = "003") 
			    or cod_monto_90   = (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 2 and cod_filtro = "004") 
			    or cod_monto_120  = (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 2 and cod_filtro = "005")
			    or cod_monto_150  = (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 2 and cod_filtro = "006")
			    or cod_monto_180  = (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 2 and cod_filtro = "007")

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
						  prima_bruta)
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
						  v_prima_bruta);
		end foreach

	else
	   {	delete from campoliza
	   	where cod_corriente  = (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 2 and cod_filtro = "001") 
		   or cod_monto_30   = (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 2 and cod_filtro = "002") 
		   or cod_monto_60   = (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 2 and cod_filtro = "003") 
		   or cod_monto_90   = (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 2 and cod_filtro = "004") 
		   or cod_monto_120  = (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 2 and cod_filtro = "005")
		   or cod_monto_150  = (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 2 and cod_filtro = "006")
		   or cod_monto_180  = (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 2 and cod_filtro = "007")}				
	end if 
end if

if _ramo = "1" then
	if flag = 0 then
		let flag = 1;
		foreach
			Select no_documento,
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
				   prima_bruta
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
				   v_prima_bruta
			  from emipoliza
			 where cod_ramo in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 1)

			--let v_no_poliza = sp_sis21(v_no_documento);
			insert into campoliza(
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
				   prima_bruta)
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
				   v_prima_bruta);
				   	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
		delete from campoliza
		where cod_ramo not in (Select cod_filtro from cascampanafil where tipo_filtro = 1 and cod_campana = a_cod_campana);
	end if -- end if del contador			
end if-- end if del Filtro por Ramo


if _formapag = "1" then
	if flag = 0 then
		let flag = 1;
		foreach
			Select no_documento,
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
				   prima_bruta
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
				   v_prima_bruta
			  from emipoliza
			 where cod_formapag in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 3)

			--let v_no_poliza = sp_sis21(v_no_documento);
			insert into campoliza(
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
				   prima_bruta)
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
				   v_prima_bruta);	
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
			Select no_documento,
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
				   prima_bruta
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
				   v_prima_bruta
			  from emipoliza
			 where cod_ramo in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 4)

			--let v_no_poliza = sp_sis21(v_no_documento);
			insert into campoliza(
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
				   prima_bruta)
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
				   v_prima_bruta);
				   	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
		delete from campoliza
		where cod_zona not in (Select cod_filtro from cascampanafil where tipo_filtro = 4 and cod_campana = a_cod_campana);
	end if -- end if del contador			
end if-- end if del Filtro por Zona de Cobros


if _agente = "1" then
	if flag = 0 then
		let flag = 1;
		foreach
			Select no_documento,
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
				   prima_bruta
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
				   v_prima_bruta
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
			insert into campoliza(
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
				   prima_bruta)
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
				   v_prima_bruta);	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
		delete from campoliza
		where cod_agente not in (Select cod_filtro from cascampanafil where tipo_filtro = 5 and cod_campana = a_cod_campana);
	end if -- end if del contador			
end if-- end if del Filtro por Agente


if _suc = "1" then
	if flag = 0 then
		let flag = 1;
		foreach
			Select no_documento,
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
				   prima_bruta
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
				   v_prima_bruta
			  from emipoliza
			 where cod_sucursal in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 6)

			--let v_no_poliza = sp_sis21(v_no_documento);
			insert into campoliza(
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
				   prima_bruta)
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
				   v_prima_bruta);	
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
			Select no_documento,
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
				   prima_bruta
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
				   v_prima_bruta
			  from emipoliza
			 where cod_area in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 7)

			--let v_no_poliza = sp_sis21(v_no_documento);
			insert into campoliza(
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
				   prima_bruta)
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
				   v_prima_bruta);	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
		delete from campoliza
		where cod_area not in (Select cod_filtro from cascampanafil where tipo_filtro = 7 and cod_campana = a_cod_campana);
	end if -- end if del contador			
end if-- end if del Filtro por Area

if _status = "1" then
	if flag = 0 then
		let flag = 1;
		foreach
			Select no_documento,
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
				   prima_bruta
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
				   v_prima_bruta
			  from emipoliza
			 where cod_status in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 8)

			--let v_no_poliza = sp_sis21(v_no_documento);
			insert into campoliza(
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
				   prima_bruta)
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
				   v_prima_bruta);	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
		delete from campoliza
		where cod_status not in (Select cod_filtro from cascampanafil where tipo_filtro = 8 and cod_campana = a_cod_campana);
	end if -- end if del contador			
end if-- end if del Filtro por Estatus de Poliza


if _grupo = "1" then
	if flag = 0 then
		let flag = 1;
		foreach
			Select no_documento,
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
				   prima_bruta
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
				   v_prima_bruta
			  from emipoliza
			 where cod_grupo in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 9)

			--let v_no_poliza = sp_sis21(v_no_documento);
			insert into campoliza(
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
				   prima_bruta)
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
				   v_prima_bruta);	
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
			Select no_documento,
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
				   prima_bruta
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
				   v_prima_bruta
			  from emipoliza
			 where dia_cobros1 in (Select cod_filtro from cascampanafil where tipo_filtro = 10 and cod_campana = a_cod_campana)
		   		or dia_cobros2 in (Select cod_filtro from cascampanafil where tipo_filtro = 10 and cod_campana = a_cod_campana)

			--let v_no_poliza = sp_sis21(v_no_documento);
			insert into campoliza(
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
				   prima_bruta)
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
				   v_prima_bruta);	
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
			Select no_documento,
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
				   prima_bruta
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
				   v_prima_bruta
			  from emipoliza
			 where cod_acreencia in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 11)

			--let v_no_poliza = sp_sis21(v_no_documento);
			insert into campoliza(
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
				   prima_bruta)
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
				   v_prima_bruta);	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
		delete from campoliza
		where cod_acreencia in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 11);
	end if -- end if del contador			
end if-- end if del Filtro por Acreencia



if _pagos = "1" then
	if flag = 0 then
		let flag = 1;
		foreach
			Select no_documento,
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
				   prima_bruta
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
				   v_prima_bruta
			  from emipoliza
			 where cod_pagos in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 12)

			--let v_no_poliza = sp_sis21(v_no_documento);
			insert into campoliza(
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
				   prima_bruta)
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
				   v_prima_bruta);	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla campoliza para esta campana 		
		delete from campoliza
		where cod_pagos in (Select cod_filtro from cascampanafil where cod_campana = a_cod_campana and tipo_filtro = 12);
	end if -- end if del contador			
end if-- end if del Filtro por Prima Original


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