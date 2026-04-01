drop procedure sp_actuario19;
-- copia de sp_actuario
create procedure "informix".sp_actuario19(a_periodo_desde char(7), a_periodo_hasta char(7))
	returning integer,varchar(250);

BEGIN
define _error_desc			varchar(250);
define _cod_usuario			varchar(30);
define _id_certificado		varchar(25);
define _id_recibo			varchar(25);
define _id_poliza			varchar(25);
define _cod_moneda			varchar(3);
define _tipo_poliza			varchar(3);
define _cod_contratante		char(10);
define _no_poliza			char(10);
define _periodo				char(7);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define _no_endoso			char(5);
define _cod_cober_reas		char(3);
define _cod_tipoprod		char(3);
define _cod_sucursal        char(3);
define _cod_ramo			char(3);
define _nueva_renov			char(1);
define _tipo_produccion     smallint;
define _tiene_impuesto      smallint;
define _prima_neta_end		dec(16,2);
define _impuesto			dec(16,2);
define _mto_comision		dec(18,2);
define _mto_prima_ac		dec(18,2);
define _mto_reserva			dec(18,2);
define _mto_prima			dec(18,2);
define _mto_suma			dec(18,2);
define _por_tasa			dec(7,3);
define _porc_partic_agt		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _cod_producto_ttcorp	smallint;
define _cod_area_seguro		smallint;
define _cod_ramo_ttcorp		smallint;
define _cod_situacion		smallint;
define _cod_producto		smallint;
define _cod_ramorea			smallint;
define _cod_empresa			smallint;
define _num_serie			smallint;
define _ramo_sis			smallint;
define _num_ano				smallint;
define _num_mes				smallint;
define _id_relac_productor	integer;
define _id_relac_cliente	integer;
define _id_mov_tecnico		integer;
define _error_isam			integer;
define _error				integer;
define _fec_situacion		date;
define _fec_operacion		date;
define _fec_registro		date;
define _fec_emision			date;
define _fec_inivig			date;
define _fec_finvig			date;

on exception set _error,_error_isam,_error_desc
	let _error_desc = trim(_error_desc) || 'no_poliza: ' || _no_poliza || 'no_endoso: ' ||  _no_endoso;
	return _error,_error_desc;
end exception

--set debug file to "sp_actuario19.trc";
--trace on;

set isolation to dirty read;

let _fec_operacion	= today;
let _fec_registro	= today;
let _mto_reserva	= 0.00;
let _id_mov_tecnico = 0;
let _cod_situacion	= 5;	--13 para prima cobrada
let _cod_empresa	= 11;
let _por_tasa		= 1;
let _cod_moneda		= 'USD';

select max(id_mov_tecnico)
  into _id_mov_tecnico
  from movim_tec_pri_copy;

if _id_mov_tecnico is null then
	let _id_mov_tecnico = 0;
end if

let a_periodo_desde = trim(a_periodo_desde);
let a_periodo_hasta = trim(a_periodo_hasta);

foreach with hold
	select a.no_poliza,
		   a.no_endoso,
		   a.no_documento,
		   a.vigencia_inic,
		   a.vigencia_final,
		   a.fecha_emision,
		   b.cod_ramo,
		   b.serie,
		   a.no_factura,
		   a.periodo,
		   b.cod_contratante,
		   b.cod_tipoprod,
		   b.cod_grupo,
		   a.user_added,
		   a.date_added,
		   a.impuesto,
		   a.cod_sucursal,
		   b.tiene_impuesto,
		   a.prima_neta,
		   b.nueva_renov
	  into _no_poliza,
		   _no_endoso,
		   _id_poliza,
		   _fec_inivig,
		   _fec_finvig,
		   _fec_emision,
		   _cod_ramo,
		   _num_serie,
		   _id_recibo,
		   _periodo,
		   _cod_contratante,
		   _cod_tipoprod,
		   _cod_grupo,
		   _cod_usuario,
		   _fec_situacion,
		   _impuesto,
		   _cod_sucursal,
		   _tiene_impuesto,
		   _prima_neta_end,
		   _nueva_renov
	  from endedmae a, emipomae b
	 where a.no_poliza = b.no_poliza
	   and a.periodo >= a_periodo_desde
	   and a.periodo <= a_periodo_hasta
	   --and a.no_poliza = '582755'
	   and a.prima <> 0
	   and a.actualizado = 1
	
	let _num_ano = _periodo[1,4];
	let _num_mes = _periodo[6,7];
	let _id_relac_cliente = _cod_contratante;
	
	select ramo_sis
	  into _ramo_sis
	  from prdramo
	 where cod_ramo = _cod_ramo;

	if _ramo_sis = 1 then
		let _cod_area_seguro = 2; --Automovil
	elif _ramo_sis = 3 then
		let _cod_area_seguro = 7; --Fianza
	elif _ramo_sis = 5 then
		let _cod_area_seguro = 1; --Salud
	elif _ramo_sis in (6,7) then
		let _cod_area_seguro = 4; --Personas
	else
		let _cod_area_seguro = 9; --Patrimoniales
	end if
	
	let _cod_producto = _cod_ramo;
	
	let _tipo_poliza = 1;
	
	select tipo_produccion
	  into _tipo_produccion
	  from emitipro
	 where cod_tipoprod = _cod_tipoprod;
	
	if _cod_tipoprod = '002' and _cod_grupo not in ('00000','1000') then
		let _tipo_poliza = 2;
	elif _cod_tipoprod = '004' then 
		let _tipo_poliza = 3;
	elif _cod_tipoprod = '005' and _cod_grupo in ('00000','1000') then
		let _tipo_poliza = 4;
	elif _cod_tipoprod = '002' and _cod_grupo in ('00000','1000') then
		let _tipo_poliza = 5;
	end if
	
	let _mto_prima_ac = 0.00;
	foreach
		select cod_agente,
			   porc_partic_agt,
			   porc_comis_agt
		  into _cod_agente,
			   _porc_partic_agt,
			   _porc_comis_agt
		  from emipoagt
		 where no_poliza = _no_poliza
		
		let _id_relac_productor = _cod_agente;
		
		foreach
			select no_unidad,
				   suma_asegurada
			  into _id_certificado,
				   _mto_suma
			  from endeduni
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso
						
			{select sum(e.prima_neta)
			  into _mto_prima
			  from endedcob e
			 where e.no_poliza = _no_poliza
			   and no_endoso = _no_endoso
			   and e.no_unidad = _id_certificado;}
			
			let _mto_prima = 0.00;
			
			foreach
				select c.cod_cober_reas,
					   sum(e.prima_neta)
				  into _cod_cober_reas,
					   _mto_prima
				  from endedcob e, prdcober c
				 where e.cod_cobertura = c.cod_cobertura
				   and e.no_poliza = _no_poliza
				   and e.no_endoso = _no_endoso
				   and no_unidad = _id_certificado
				 group by 1
				
				if _mto_prima is null then
					let _mto_prima = 0.00;
				end if
				
				if _mto_prima = 0.00 then
					continue foreach;
				end if
				
				let _mto_comision = 0.00;
				let _mto_prima = _mto_prima * (_porc_partic_agt / 100);
				let _mto_comision = _mto_prima  * (_porc_comis_agt / 100);
				
				let _mto_prima_ac = _mto_prima_ac + _mto_prima;
				{select distinct cod_cober_reas
				  into _cod_cober_reas
				  from emifacon
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso
				   and no_unidad = _id_certificado}
				
				let _id_mov_tecnico = _id_mov_tecnico + 1;
				let _cod_ramorea	= _cod_cober_reas;
				
				insert into movim_tec_pri_copy(
						id_mov_tecnico,                        
						cod_empresa,
						num_ano,
						num_mes,
						num_serie,
						cod_area_seguro,
						cod_producto,
						cod_ramo,
						cod_ramorea,
						cod_moneda,
						por_tasa,
						tip_poliza,
						id_poliza,
						id_recibo,
						id_certificado,
						fec_inivig,
						fec_finvig,
						fec_emision,
						cod_situacion,
						fec_situacion,
						mto_suma,
						mto_reserva,
						mto_prima,
						mto_comision,
						id_relac_cliente,
						id_relac_productor,
						fec_operacion,
						fec_registro,
						cod_usuario,
						cod_sucursal,
						tipo_produccion,
						tipo_impuesto,
						nueva_renov)
				values	(_id_mov_tecnico,                        
						_cod_empresa,
						_num_ano,
						_num_mes,
						_num_serie,
						_cod_area_seguro,
						_cod_producto,
						_cod_producto,
						_cod_ramorea,
						_cod_moneda,
						_por_tasa,
						_tipo_poliza,
						_id_poliza,
						_id_recibo,
						_id_certificado,
						_fec_inivig,
						_fec_finvig,
						_fec_emision,
						_cod_situacion,
						_fec_situacion,
						_mto_suma,
						_mto_reserva,
						_mto_prima,
						_mto_comision,
						_id_relac_cliente,
						_id_relac_productor,
						_fec_operacion,
						_fec_registro,
						_cod_usuario,
						_cod_sucursal,
						_tipo_produccion,
						_tiene_impuesto,
						_nueva_renov);
			end foreach
		end foreach
	end foreach
	
	if abs(abs(_mto_prima_ac) - abs(_prima_neta_end)) > 0.01  then
		update movim_tec_pri_copy
		   set flag = 1
		 where id_recibo = _id_recibo;
	end if
	
	if _impuesto is null then
		let _impuesto = 0.00;
	end if
	
	if _impuesto <> 0.00 then
		let _cod_ramorea = 100;
		let _id_mov_tecnico = _id_mov_tecnico + 1;
		insert into movim_tec_pri_copy(
				id_mov_tecnico,                        
				cod_empresa,
				num_ano,
				num_mes,
				num_serie,
				cod_area_seguro,
				cod_producto,
				cod_ramo,
				cod_ramorea,
				cod_moneda,
				por_tasa,
				tip_poliza,
				id_poliza,
				id_recibo,
				id_certificado,
				fec_inivig,
				fec_finvig,
				fec_emision,
				cod_situacion,
				fec_situacion,
				mto_suma,
				mto_reserva,
				mto_prima,
				mto_comision,
				id_relac_cliente,
				id_relac_productor,
				fec_operacion,
				fec_registro,
				cod_usuario,
				cod_sucursal,
				tipo_produccion,
				tipo_impuesto,
				nueva_renov)
		values	(_id_mov_tecnico,                        
				_cod_empresa,
				_num_ano,
				_num_mes,
				_num_serie,
				_cod_area_seguro,
				_cod_producto,
				_cod_producto,
				_cod_ramorea,
				_cod_moneda,
				_por_tasa,
				_tipo_poliza,
				_id_poliza,
				_id_recibo,
				_id_certificado,
				_fec_inivig,
				_fec_finvig,
				_fec_emision,
				_cod_situacion,
				_fec_situacion,
				_mto_suma,
				_mto_reserva,
				_impuesto,
				_mto_comision,
				_id_relac_cliente,
				_id_relac_productor,
				_fec_operacion,
				_fec_registro,
				_cod_usuario,
				_cod_sucursal,
				_tipo_produccion,
				_tiene_impuesto,
				_nueva_renov);
	end if
	
	let _mto_comision	= 0.00;
	let _mto_reserva	= 0.00;
	let _impuesto		= 0.00;
	let _mto_suma		= 0.00;	
end foreach

return 0,'Inserción Exitosa';	
end			
end procedure;