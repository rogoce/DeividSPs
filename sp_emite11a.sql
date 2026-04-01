-- Procedimiento para procesar los valores en las tablas de DEIVID y emitir las polizas de ducruet
-- Creado    : 28/07/2022 - Autor: Román  Gordón

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_emite11a;

create procedure "informix".sp_emite11a(a_usuario char(8)) 
returning	smallint,varchar(200);


define _error_title			varchar(200);
define _error_desc			varchar(200);
define _deducible_colision	varchar(50);
define _deducible_incendio	varchar(50);
define _deducible_robo		varchar(50);
define _asegurado			varchar(50);
define _email				varchar(50);
define _poliza_ant			varchar(30);
define _cedula				varchar(30);
define _no_documento		varchar(20);
define _no_chasis			varchar(30);
define _no_motor			varchar(30);
define _uso_auto			char(30);
define _ruc					char(30);
define _poliza_maestra_auto	char(20);
define _poliza_maestra_tran	char(20);
define _cod_producto		char(10);
define _cod_cliente			char(10);
define _no_poliza_mae		char(10);
define _no_poliza			char(10);
define _estatus				char(10);
define _tipo				char(10);
define _periodo				char(7);
define _asiento				char(7);
define _tomo				char(7);
define _placa				char(6);
define _cod_agente			char(5);
define _cod_modelo			char(5);
define _cod_marca			char(5);
define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _cod_impuesto		char(3);
define _cod_subramo			char(3);
define _cod_tipoveh			char(3);
define _cod_ramo			char(3);
define _provincia			char(2);
define _inicial				char(2);
define _tipo_persona		char(1);
define _null				char(1);
define _limite_lesiones1	dec(16,2);
define _limite_lesiones2	dec(16,2);
define _tarifa_colision		dec(16,2);
define _suma_asegurada		dec(16,2);
define _limite_dpa1			dec(16,2);
define _limite_dpa2			dec(16,2);
define _prima_asistencia	dec(16,2);
define _prima_extraterr		dec(16,2);
define _prima_lesiones		dec(16,2);
define _prima_colision		dec(16,2);
define _prima_incendio		dec(16,2);
define _prima_naviera		dec(16,2);
define _prima_muerte		dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_robo			dec(16,2);
define _prima_dpa			dec(16,2);
define _impuesto			dec(16,2);
define _subtotal			dec(16,2);
define _prima				dec(16,2);
define _factor_impuesto		dec(5,2);
define _porc_comision		dec(5,2);
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_hoy			date;
define _error_isam			smallint;
define _capacidad			smallint;
define _ano_actual			smallint;
define _ano_tarifa			smallint;
define _auto_nuevo			smallint;
define _serie				smallint;
define li_return			smallint;
define _ramo_sis			smallint;
define _ano_auto			smallint;
define _tipo_doc			smallint;
define _cnt_auto			smallint;
define _existe				smallint;
define _error				smallint;

	begin
	on exception set _error,_error_isam,_error_desc
		return _error,_error_desc;         
	end exception

	set isolation to dirty read;
	--set debug file to "sp_emite01.trc"; 
	--trace on;

 -- Actualización del Endoso
	--call sp_pro43(a_poliza, a_endoso) returning _error,_error_desc;

--	if _error <> 0 then
--		return _error,_error_desc;
--	end if

	let _fecha_hoy = today;
	let _cod_agente = '02311';
	--let _serie = year(_vigencia_inic);
	let _cod_ramo = '002';
	let _cod_subramo = '016';
	let _cod_compania = '001';
	let _cod_sucursal = '001';
	let _null = null;
	
	select ramo_sis
	  into _ramo_sis
	  from prdramo
	 where cod_ramo = _cod_ramo;
	
	select emi_periodo 														   
	  into _periodo
	  from parparam;
	  
	drop table if exists tmp_poliza_mae;
	drop table if exists tmp_unidad_mae;

	foreach
		select tmp.no_documento,mae.no_poliza
		  into _no_documento,_no_poliza
		   from deivid_tmp:carga_serafin tmp
		 inner join emipomae mae on mae.no_documento =  tmp.no_documento_tr
		  left join emirepo rep on rep.no_poliza = mae.no_poliza and rep.estatus in (5,9)
		 where procesado = 1
		   and rep.estatus is null
		   --and tmp.no_documento >= '0222-02369-01'
		 order by no_documento
		 
		select count(*)
		  into _serie
		  from emirepo
		 where no_poliza = _no_poliza
		   and estatus in (5,9);
		 
		if _serie is null then
			let _serie = 0;
		end if
		
		if _serie = 0 then
			let _error = sp_pro326(_no_poliza,a_usuario);
		end if
	end foreach
	return 0,"Actualización Exitosa";
	end
end procedure
