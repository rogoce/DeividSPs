-- Procedimiento para la Insercion Inicial de Polizas 
-- para el sistema de Cobros para Avisos de Cancelacion Automatico
-- Creado    : 23/12/2010  Por: Henry Giron
-- Modificado: 14/04/2012 - Autor: Henry Giron (excluir coaseguro minoritario)
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob757;
create procedure sp_cob757(a_cod_avican char (10))
returning integer, char(100);

define _vnom_agente			varchar(100);
define _error_desc			varchar(100);
define _vnom_supervisor		varchar(50);	
define _vnom_formapag		varchar(50);	
define _vnom_division		varchar(50);
define _vnom_gestor			varchar(50);	
define _vnom_zona			varchar(50);	
define _repetido			varchar(50);	
define v_no_documento		char(20);
define _cod_contratante		char(10);
define _filtro_esp			char(10);
define v_cod_pagador		char(10);
define v_no_poliza			char(10);
define _vusuario_supervisor	char(8);	
define _vusuario_gestor		char(8);	
define _usuario1			char(8);
define _cod_agente			char(5);
define _vcod_agente			char(5);  
define v_cod_agente			char(5);
define v_cod_grupo			char(5);
define v_cod_area			char(5);
define _agente				char(5);
define _grupo				char(5);
define _area				char(5);
define _vcod_supervisor		char(3);	
define v_cod_formapag		char(3);
define _vcod_formapag		char(3);	
define _vcod_division		char(3);	
define _cod_tipoprod		char(3);
define _vcod_gestor			char(3);	
define v_cod_pagos			char(3);
define v_cod_ramo			char(3);
define _vcod_zona			char(3);	
define v_cod_zona			char(3);
define _acreencia			char(3);
define v_cod_suc			char(3);
define _formapag			char(3);
define _pagos				char(3);
define _moros				char(3);
define _ramo				char(3);
define _zona				char(3);
define _suc					char(3);
define v_cod_status			char(1);
define _status				char(1);
define v_prima_bruta		dec(16,2);
define v_por_vencer			dec(16,2);
define v_corriente			dec(16,2);
define v_monto_180			dec(16,2);
define v_monto_150			dec(16,2);
define v_monto_120			dec(16,2);
define v_monto_90			dec(16,2);
define v_monto_60			dec(16,2);
define v_monto_30			dec(16,2);
define v_exigible			dec(16,2);
define v_saldo				dec(16,2);
define _filt_especiales		smallint;
define v_cod_acreencia		smallint;
define _cliente_vip			smallint;
define v_dia_cob1			smallint;
define v_dia_cob2			smallint;
define _dia_cob				smallint;
define _error				smallint;
define _veces				smallint;
define _r_ow,_cnt7				smallint;
define flag	,_valor			smallint;
define _contador2			integer; 
define v_vigencia_inic		date;
define v_vigencia_fin		date;
define _fecha_hoy			date;


on exception set _error
    return _error, 'Error al Ingresar los Registro';
end exception  

--set debug file to 'sp_cob757.trc';
--trace on;
--=================   
--Estatus_proceso
--=================
--clasificar    = R
--conservar     = E
--Marcar Aviso  = M
-------------------	  
--Data generada = G
--procesado     = I
--entregar      = M
--Pool cancelar = X
--desmarcar     = Y
--cancelar      = Z
--=================
--CLASE
--=================
--1 = Tiene Correo
--2 = Actualizar info

--1,2,3,4,5,8   '004','016','018','019',  '003','004','005','006','007','008','086','200','00141',1

set isolation to dirty read;

delete from avicanpoliza where cod_avican = a_cod_avican;
delete from avisocanc where no_aviso = a_cod_avican;

let _vusuario_supervisor = '' ;	
let _vnom_supervisor = '' ;
let _vcod_Supervisor = '' ;
let _vusuario_gestor = '' ;
let _vcod_formapag = '' ;
let _vnom_formapag = '' ;
let _vcod_division = '' ;
let _vnom_division = '' ;
let _vnom_agente = '' ;
let _vcod_agente = '' ;
let _vcod_Gestor = '' ;
let _vnom_gestor = '' ;
let _vcod_zona = '' ;
let _vnom_zona = '' ;
let _repetido = '';
let _usuario1 = '' ;
let _veces = 0;
let _r_ow = 0;
let flag = 0;
let _fecha_hoy = current;

select filt_acre,
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
	   usuario1
  into _acreencia,
       _agente,_area,
       _dia_cob,
       _formapag,
       _grupo,
       _moros,
       _pagos,
       _ramo,
       _status,
       _suc,
       _zona,
	   _filt_especiales,
       _usuario1
  from avicanpar 
 where cod_avican = a_cod_avican;

foreach
	select trim(cod_filtro)||"-"||trim(descripcion), count(*)  ---SD#6804 HGIRON 12/06/2023 
	  into _repetido,_veces
	  from avicanfil
	 where cod_avican = a_cod_avican
     group by 1
    having 2 > 1
     order by 2 desc,1
      exit foreach;
end foreach

if _veces is null then
	let	_veces = 0;
end if
if _repetido is null then
	let	_repetido = '';
end if
if _veces > 1 then
   return -239,'Filtro '||Trim(_repetido)||' repetido '||_veces||' veces.';		   
end if

select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican 
   and tipo_filtro = 2;

if _moros = '1' and _contador2 = 0 then
	return 1,'Falta de Informacion de filtro - Morosidad .';
elif _moros = '0' and _contador2 > 0 then
	return 1,'No debe haber Informacion de filtro - Morosidad .';
end if

if _moros = '1' then
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
			 where fecha_suspension <= _fecha_hoy 
			   and exigible > 1 {cod_corriente  = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '001') 
			    or cod_monto_30   = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '002') 
			    or cod_monto_60   = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '003') 
			    or cod_monto_90   = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '004') 
			    or cod_monto_120  = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '005') 
			    or cod_monto_150  = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '006') 
			    or cod_monto_180  = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '007') }
	
				LET v_no_poliza    = sp_sis21(v_no_documento);

				SELECT cod_tipoprod,
					   cod_contratante
				  INTO _cod_tipoprod,
					   _cod_contratante
				  FROM emipomae
				 WHERE no_poliza = v_no_poliza;

				let _cliente_vip = 0;

				call sp_sis233(_cod_contratante) returning _cliente_vip, _error_desc;

				if _cliente_vip < 0 then
					return _cliente_vip,_error_desc;
				end if

				if _filt_especiales = 1 then

					select cod_filtro
					  into _filtro_esp
					  from avicanfil
					 where cod_avican = a_cod_avican
					   and tipo_filtro = 13;

					if _filtro_esp = '1' then
						if _cliente_vip = 0 then
							continue foreach;
						end if
					else
						if _cliente_vip = 1 then
							continue foreach;
						end if 
					end if
				else
					if _cliente_vip = 1 then
						continue foreach;
					end if 
				end if

				-- No Incluye Coaseguro Minoritario ni Reaseguro Asumido
				IF _cod_tipoprod = '002' THEN
				   CONTINUE FOREACH;
				END IF

			let _valor = sp_sis265(v_no_documento);	--*****Se marca la poliza por posible Nulidad con estatus "N"
			if _valor = 1 then
				let v_cod_status = 'N';
			end if
			
			
			Insert into avicanpoliza(
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
						  cod_avican,
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
						  a_cod_avican,
						  v_prima_bruta
						  );
		end foreach

	else
	   {	delete from avicanpoliza
	   	where cod_corriente  = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '001') 
		   or cod_monto_30   = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '002') 
		   or cod_monto_60   = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '003') 
		   or cod_monto_90   = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '004') 
		   or cod_monto_120  = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '005')
		   or cod_monto_150  = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '006')
		   or cod_monto_180  = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '007');				}
	end if 
end if

select count(*)
  into _r_ow
  from avicanpoliza
 where cod_avican = a_cod_avican;

select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 1;

 
 {delete from avicanpoliza
  where no_documento not in (select no_documento from emipoliza where (cod_ramo = '001' and cod_subramo ='006') or (cod_ramo = '003' and cod_subramo ='005'));}
 
if _ramo = '1' and _contador2 = 0 then
	return 1,'Falta de Informacion de filtro - Ramo.';
elif _ramo = '0' and _contador2 > 0 then
	return 1,'No debe haber Informacion de filtro - Ramo.';
end if
if _ramo = '1' then
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
			 where cod_ramo in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 1)

			LET v_no_poliza    = sp_sis21(v_no_documento);
			SELECT cod_tipoprod
			  INTO _cod_tipoprod
			  FROM emipomae
			 WHERE no_poliza = v_no_poliza;

			-- No Incluye Coaseguro Minoritario ni Reaseguro Asumido
			if _cod_tipoprod = '002' then
			   continue foreach;
			end if
			let _valor = sp_sis265(v_no_documento);	--*****Se marca la poliza por posible Nulidad con estatus "N"
			if _valor = 1 then
				let v_cod_status = 'N';
			end if

			insert into avicanpoliza(
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
				   cod_avican,
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
				   a_cod_avican,
				   v_prima_bruta);
				   	
		end foreach -- final de la secuencia de cada poliza
	else 			
		delete from avicanpoliza
		where cod_ramo not in (Select cod_filtro from avicanfil where tipo_filtro = 1 and cod_avican = a_cod_avican);
	end if -- end if del contador			
end if -- end if del Filtro por Ramo

select count(*)
  into _r_ow
  from avicanpoliza
 where cod_avican = a_cod_avican;

select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 3;

if _formapag = '1' and _contador2 = 0 then
	return 1,'Falta de Informacion de filtro - Forma de Pago .';
elif _formapag = '0' and _contador2 > 0 then
	return 1,'No debe haber Informacion de filtro - Forma de Pago .';
end if

if _formapag = '1' then
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
			 where cod_formapag in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 3)

				LET v_no_poliza    = sp_sis21(v_no_documento);
				SELECT cod_tipoprod
				  INTO _cod_tipoprod
				  FROM emipomae
				 WHERE no_poliza = v_no_poliza;

				-- No Incluye Coaseguro Minoritario ni Reaseguro Asumido
				IF _cod_tipoprod = '002' THEN
				   CONTINUE FOREACH;
				END IF

			let _valor = sp_sis265(v_no_documento);	--*****Se marca la poliza por posible Nulidad con estatus "N"
			if _valor = 1 then
				let v_cod_status = 'N';
			end if

			insert into avicanpoliza(
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
				   cod_avican,
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
				   a_cod_avican,
				   v_prima_bruta);	
		end foreach    -- Final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla avicanpoliza para esta campana 		
		delete from avicanpoliza
		where cod_formapag not in (Select cod_filtro from avicanfil where tipo_filtro = 3 and cod_avican = a_cod_avican);
	end if -- end if del contador			
end if-- end if del Filtro por Forma de Pago

select count(*)
  into _r_ow
  from avicanpoliza
 where cod_avican = a_cod_avican;

select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 4;

if _zona = '1' and _contador2 = 0 then
	return 1,'Falta de Informacion de filtro - Zona de Cobro .';
elif _zona = '0' and _contador2 > 0 then
	return 1,'No debe haber Informacion de filtro - Zona de Cobro .';
end if

if _zona = '1' then
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
			 where cod_zona in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 4)

				   LET v_no_poliza    = sp_sis21(v_no_documento);
				SELECT cod_tipoprod
				  INTO _cod_tipoprod
				  FROM emipomae
				 WHERE no_poliza = v_no_poliza;

				-- No Incluye Coaseguro Minoritario ni Reaseguro Asumido
				IF _cod_tipoprod = '002' THEN
				   CONTINUE FOREACH;
				END IF

			let _valor = sp_sis265(v_no_documento);	--*****Se marca la poliza por posible Nulidad con estatus "N"
			if _valor = 1 then
				let v_cod_status = 'N';
			end if

			insert into avicanpoliza(
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
				   cod_avican,
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
				   a_cod_avican,
				   v_prima_bruta);
				   	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla avicanpoliza para esta campana 		
		delete from avicanpoliza
		where cod_zona not in (Select cod_filtro from avicanfil where tipo_filtro = 4 and cod_avican = a_cod_avican);
	end if -- end if del contador			
end if-- end if del Filtro por Zona de Cobros

select count(*)
  into _r_ow
  from avicanpoliza
 where cod_avican = a_cod_avican;

select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 5;

if _agente = '1' and _contador2 = 0 then
	return 1,'Falta de Informacion de filtro - Corredor .';
elif _agente = '0' and _contador2 > 0 then
	return 1,'No debe haber Informacion de filtro - Corredor .';
end if

if _agente = '1' then
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
			 where cod_agente in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 5)
				or cod_agente = '00000'

				   LET v_no_poliza    = sp_sis21(v_no_documento);
				SELECT cod_tipoprod
				  INTO _cod_tipoprod
				  FROM emipomae
				 WHERE no_poliza = v_no_poliza;

				-- No Incluye Coaseguro Minoritario ni Reaseguro Asumido
				IF _cod_tipoprod = '002' THEN
				   CONTINUE FOREACH;
				END IF


			if v_cod_agente = '00000' then
				let v_no_documento = trim(v_no_documento);
				let v_no_poliza = sp_sis21(v_no_documento);

				select cod_agente
				  into _cod_agente
				  from emipoagt
				 where no_poliza = v_no_poliza
				   and cod_agente in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 5);
				
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
			let _valor = sp_sis265(v_no_documento);	--*****Se marca la poliza por posible Nulidad con estatus "N"
			if _valor = 1 then
				let v_cod_status = 'N';
			end if

			insert into avicanpoliza(
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
				   cod_avican,
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
				   a_cod_avican,
				   v_prima_bruta);	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla avicanpoliza para esta campana 		
		delete from avicanpoliza
		where cod_agente not in (Select cod_filtro from avicanfil where tipo_filtro = 5 and cod_avican = a_cod_avican);
	end if -- end if del contador			
end if-- end if del Filtro por Agente

select count(*)
into _r_ow
from avicanpoliza
where cod_avican = a_cod_avican;

select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 6;

if _suc = '1' and _contador2 = 0 then
	return 1,'Falta de Informacion de filtro - Sucursal .';
elif _suc = '0' and _contador2 > 0 then
	return 1,'No debe haber Informacion de filtro - Sucursal .';
end if

if _suc = '1' then
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
			 where cod_sucursal in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 6)

				   LET v_no_poliza    = sp_sis21(v_no_documento);
				SELECT cod_tipoprod
				  INTO _cod_tipoprod
				  FROM emipomae
				 WHERE no_poliza = v_no_poliza;

				-- No Incluye Coaseguro Minoritario ni Reaseguro Asumido
				IF _cod_tipoprod = '002' THEN
				   CONTINUE FOREACH;
				END IF

			let _valor = sp_sis265(v_no_documento);	--*****Se marca la poliza por posible Nulidad con estatus "N"
			if _valor = 1 then
				let v_cod_status = 'N';
			end if

			insert into avicanpoliza(
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
				   cod_avican,
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
				   a_cod_avican,
				   v_prima_bruta);	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla avicanpoliza para esta campana 		
		delete from avicanpoliza
		where cod_sucursal not in (Select cod_filtro from avicanfil where tipo_filtro = 6 and cod_avican = a_cod_avican);
	end if -- end if del contador			
end if-- end if del Filtro por Sucursal

select count(*)
into _r_ow
from avicanpoliza
where cod_avican = a_cod_avican;

select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 7;

if _area = '1' and _contador2 = 0 then
	return 1,'Falta de Informacion de filtro - Area .';
elif _area = '0' and _contador2 > 0 then
	return 1,'No debe haber Informacion de filtro - Area .';
end if

if _area = '1' then
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
			 where cod_area in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 7)

				   LET v_no_poliza    = sp_sis21(v_no_documento);
				SELECT cod_tipoprod
				  INTO _cod_tipoprod
				  FROM emipomae
				 WHERE no_poliza = v_no_poliza;

				-- No Incluye Coaseguro Minoritario ni Reaseguro Asumido
				IF _cod_tipoprod = '002' THEN
				   CONTINUE FOREACH;
				END IF
				let _valor = sp_sis265(v_no_documento);	--*****Se marca la poliza por posible Nulidad con estatus "N"
				if _valor = 1 then
					let v_cod_status = 'N';
				end if

			insert into avicanpoliza(
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
				   cod_avican,
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
				   a_cod_avican,
				   v_prima_bruta);	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla avicanpoliza para esta campana 		
		delete from avicanpoliza
		where cod_area not in (Select cod_filtro from avicanfil where tipo_filtro = 7 and cod_avican = a_cod_avican);
	end if -- end if del contador			
end if-- end if del Filtro por Area

select count(*)
into _r_ow
from avicanpoliza
where cod_avican = a_cod_avican;

select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 8;

if _status = '1' and _contador2 = 0 then
	return 1,'Falta de Informacion de filtro - Estatus .';
elif _status = '0' and _contador2 > 0 then
	return 1,'No debe haber Informacion de filtro - Estatus .';
end if

if _status = '1' then
	select count(*)
	  into _cnt7
	  from avicanfil
     where cod_avican = a_cod_avican
       and cod_filtro = 'N';
	if _cnt7 is null then 
		let _cnt7 = 0;
	end if
	if _cnt7 = 0 then
		insert into avicanfil(cod_avican,tipo_filtro,cod_filtro,descripcion)
		values(a_cod_avican,8,'N','Nulidad');
	end if	
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
			 where cod_status in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 8)

				   LET v_no_poliza    = sp_sis21(v_no_documento);
				SELECT cod_tipoprod
				  INTO _cod_tipoprod
				  FROM emipomae
				 WHERE no_poliza = v_no_poliza;

				-- No Incluye Coaseguro Minoritario ni Reaseguro Asumido
				IF _cod_tipoprod = '002' THEN
				   CONTINUE FOREACH;
				END IF
			let _valor = sp_sis265(v_no_documento);	--*****Se marca la poliza por posible Nulidad con estatus "N"
			if _valor = 1 then
				let v_cod_status = 'N';
			end if

			insert into avicanpoliza(
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
				   cod_avican,
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
				   a_cod_avican,
				   v_prima_bruta);	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla avicanpoliza para esta campana 		
		delete from avicanpoliza
		where cod_status not in (Select cod_filtro from avicanfil where tipo_filtro = 8 and cod_avican = a_cod_avican);
	end if -- end if del contador			
end if -- end if del Filtro por Estatus de Poliza

select count(*)
into _r_ow
from avicanpoliza
where cod_avican = a_cod_avican;

select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 9;

if _grupo = '1' and _contador2 = 0 then
	return 1,'Falta de Informacion de filtro - Grupo .';
elif _grupo = '0' and _contador2 > 0 then
	return 1,'No debe haber Informacion de filtro - Grupo .';
end if

if _grupo = '1' then
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
			 where cod_grupo in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 9)

				   LET v_no_poliza    = sp_sis21(v_no_documento);
				SELECT cod_tipoprod
				  INTO _cod_tipoprod
				  FROM emipomae
				 WHERE no_poliza = v_no_poliza;

				-- No Incluye Coaseguro Minoritario ni Reaseguro Asumido
				IF _cod_tipoprod = '002' THEN
				   CONTINUE FOREACH;
				END IF

			let _valor = sp_sis265(v_no_documento);	--*****Se marca la poliza por posible Nulidad con estatus "N"
			if _valor = 1 then
				let v_cod_status = 'N';
			end if

			insert into avicanpoliza(
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
				   cod_avican,
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
				   a_cod_avican,
				   v_prima_bruta);	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla avicanpoliza para esta campana 		
		delete from avicanpoliza
		where cod_grupo not in (Select cod_filtro from avicanfil where tipo_filtro = 9 and cod_avican = a_cod_avican);
	end if -- end if del contador			
end if-- end if del Filtro por Grupo


select count(*)
into _r_ow
from avicanpoliza
where cod_avican = a_cod_avican;

select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 10;

if _dia_cob = '1' and _contador2 = 0 then
	return 1,'Falta de Informacion de filtro - Dias Cobros .';
elif _dia_cob = '0' and _contador2 > 0 then
	return 1,'No debe haber Informacion de filtro - Dias Cobros .';
end if

if _dia_cob = '1' then
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
			 where dia_cobros1 in (Select cod_filtro from avicanfil where tipo_filtro = 10 and cod_avican = a_cod_avican)
		   		or dia_cobros2 in (Select cod_filtro from avicanfil where tipo_filtro = 10 and cod_avican = a_cod_avican)

				   LET v_no_poliza    = sp_sis21(v_no_documento);
				SELECT cod_tipoprod
				  INTO _cod_tipoprod
				  FROM emipomae
				 WHERE no_poliza = v_no_poliza;

				-- No Incluye Coaseguro Minoritario ni Reaseguro Asumido
				IF _cod_tipoprod = '002' THEN
				   CONTINUE FOREACH;
				END IF
			let _valor = sp_sis265(v_no_documento);	--*****Se marca la poliza por posible Nulidad con estatus "N"
			if _valor = 1 then
				let v_cod_status = 'N';
			end if

			insert into avicanpoliza(
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
				   cod_avican,
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
				   a_cod_avican,
				   v_prima_bruta);	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla avicanpoliza para esta campana 		
		delete from avicanpoliza
		where dia_cobros1 not in (Select cod_filtro from avicanfil where tipo_filtro = 10 and cod_avican = a_cod_avican)
		   or dia_cobros2 not in (Select cod_filtro from avicanfil where tipo_filtro = 10 and cod_avican = a_cod_avican);
	end if -- end if del contador			
end if-- end if del Filtro por Dias de Cobros

select count(*)
into _r_ow
from avicanpoliza
where cod_avican = a_cod_avican;

select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 11;

if _acreencia = '1' and _contador2 = 0 then
	return 1,'Falta de Informacion de filtro - Acreencia .';
elif _acreencia = '0' and _contador2 > 0 then
	return 1,'No debe haber Informacion de filtro - Acreencia .';
end if

if _acreencia = '1' then

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
			 where cod_acreencia in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 11)

				   LET v_no_poliza    = sp_sis21(v_no_documento);
				SELECT cod_tipoprod
				  INTO _cod_tipoprod
				  FROM emipomae
				 WHERE no_poliza = v_no_poliza;

				-- No Incluye Coaseguro Minoritario ni Reaseguro Asumido
				IF _cod_tipoprod = '002' THEN
				   CONTINUE FOREACH;
				END IF
				let _valor = sp_sis265(v_no_documento);	--*****Se marca la poliza por posible Nulidad con estatus "N"
				if _valor = 1 then
					let v_cod_status = 'N';
				end if

			insert into avicanpoliza(
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
				   cod_avican,
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
				   a_cod_avican,
				   v_prima_bruta);	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla avicanpoliza para esta campana 		
		delete from avicanpoliza
		where cod_acreencia not in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 11);
	end if -- end if del contador			
end if-- end if del Filtro por Acreencia

select count(*)
into _r_ow
from avicanpoliza
where cod_avican = a_cod_avican;

select count(*)
  into _contador2
  from avicanfil
 where cod_avican = a_cod_avican and tipo_filtro = 12;

if _pagos = '1' and _contador2 = 0 then
	return 1,'Falta de Informacion de filtro - Pagos .';
elif _pagos = '0' and _contador2 > 0 then
	return 1,'No debe haber Informacion de filtro - Pagos .';
end if

if _pagos = '1' then
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
			 where cod_pagos in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 12)

				   LET v_no_poliza    = sp_sis21(v_no_documento);
				SELECT cod_tipoprod
				  INTO _cod_tipoprod
				  FROM emipomae
				 WHERE no_poliza = v_no_poliza;

				-- No Incluye Coaseguro Minoritario ni Reaseguro Asumido
				IF _cod_tipoprod = '002' THEN
				   CONTINUE FOREACH;
				END IF
				
				let _valor = sp_sis265(v_no_documento);	--*****Se marca la poliza por posible Nulidad con estatus "N"
				if _valor = 1 then
					let v_cod_status = 'N';
				end if

			insert into avicanpoliza(
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
				   cod_avican,
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
				   a_cod_avican,
				   v_prima_bruta);	
		end foreach -- final de la secuencia de cada poliza

	else 			-- Borrara los registros que no cumplan con el filtro especificado en caso de que haya regristros en la tabla avicanpoliza para esta campana 		
		delete from avicanpoliza
		where cod_pagos not in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 12);
	end if -- end if del contador			
end if -- end if del Filtro por Prima Original

select count(*)
  into _r_ow
  from avicanpoliza
 where cod_avican = a_cod_avican;

if _r_ow > 0 then
   -- Elimina los existente para evitar duplicidad entre gestores
   delete from avicanpoliza 
    where cod_avican = a_cod_avican and  no_documento in ( select distinct no_documento from avisocanc Where estatus  in ('G','I','M','X') and desmarca = 1 );
end if

delete from avicanpoliza
 where no_documento = '0115-00800-01';

select count(*)
  into _r_ow
  from avicanpoliza
 where cod_avican = a_cod_avican;

if _r_ow > 0 then
   -- Elimina los saldos <=  B/.5.00 . Sr. Carlos Berrocal 18/10/2011
   delete from avicanpoliza
   where cod_avican = a_cod_avican and cod_ramo not in ('004','016','018','019') and (monto_30 + monto_60 + monto_90+monto_120+monto_150+monto_180) <= 5.00;

   delete from avicanpoliza
   where cod_avican = a_cod_avican and cod_ramo in ('004','016','018','019') and (monto_30 + monto_60+monto_90+monto_120+monto_150+monto_180) <= 5.00;
end if

select count(*)
  into _r_ow
  from avicanpoliza
 where cod_avican = a_cod_avican;

if _r_ow > 0 then
   -- Elimina los existente para evitar duplicidad entre gestores
   delete from avicanpoliza
    where cod_avican = a_cod_avican and no_documento in ( select distinct no_documento from avisocanc Where estatus  in ('G','I') and desmarca = 0 and abs(today - fecha_desmarca) <= 15 );
end if

select count(*)
  into _r_ow
  from avicanpoliza
 where cod_avican = a_cod_avican;

if _r_ow > 0 then
--Pólizas del Grupo Colectivo Scotiabank 25/10/2016.
--CASO: 29066 USER: ASTANZIO Execpcion pólizas del GRUPOS 125 23/08/2018. ASTANZIO  ,'148'
--30/01/2020;CASO: 33717 USER: RGORDON AGREGAR EL GRUPO 77850 - TRASPASO ASSA GENERALI BANISI A LA EXCEPCIÓN DE LA GENERACIÓN DE AVISOS DE CANCELACIÓN    -- SD#3010 07/04/2022 4:00pm
delete from avicanpoliza
  where cod_avican = a_cod_avican and cod_grupo in ('1090', '124', '125','1122','77850','77960','77982','78020');   --CASO: 30140 USER: ASTANZIO grupo: 148 desde: 18/12/2018 5pm -- F9:30295 1122 ASTANZIO  15/01/2019  -- SD#5708 23/02/2023 HG
end if

select count(*)
  into _r_ow
  from avicanpoliza
 where cod_avican = a_cod_avican;
 

if _r_ow > 0 then
   -- Elimina los existente con carta de cancelacion en emipomae - vigentes 
   delete from avicanpoliza
    where cod_avican = a_cod_avican and cod_status = 1 and no_documento in ( select distinct no_documento from emipomae where carta_aviso_canc = 1 and estatus_poliza = 1 ) ;
   -- Elimina los existente con carta de cancelacion en emipomae - vencidas
   delete from avicanpoliza
    where cod_avican = a_cod_avican and cod_status = 3 and no_documento in ( select distinct no_documento from emipomae where carta_vencida_sal = 1  and estatus_poliza = 3 ) ;
   -- Elimina los existente con carta de cancelacion en emipomae - vigentes
   delete from avicanpoliza
    where cod_avican = a_cod_avican and cod_status = 1 and no_documento in ( select distinct no_documento from emipomae where carta_aviso_canc = 1 and vigencia_final = current ) ;
end if

select count(*) 
  into _contador2	
  from avicanpoliza
 where cod_avican = a_cod_avican;

if _contador2 = 0 then
	return 1,'No hay Registro para los Filtros Aplicados a este Aviso Cancelacion Automatico ';
else
--	call sp_sis154(_usuario1) returning _vcod_Supervisor,_vnom_supervisor,_vusuario_supervisor,_vcod_Gestor,_vnom_gestor,_vusuario_gestor; 
	return 0,'Exito';
end if

end procedure;