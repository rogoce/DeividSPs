drop procedure sp_actuario_cobbk;
create procedure "informix".sp_actuario_cobbk(a_periodo_desde char(7), a_periodo_hasta char(7), _dup_reg smallint, _reg1 integer, _reg2 integer, _reg3 integer )
	returning integer,varchar(250);

BEGIN
define v_filtros            varchar(255);
define _error_desc			varchar(250);
define _cod_usuario			varchar(30);
define _id_certificado		varchar(25);
define _id_recibo			varchar(25);
define _id_poliza			varchar(25);
define _cod_moneda			varchar(3);
define _tipo_poliza			varchar(3);
define _cod_contratante		char(10);
define _no_poliza			char(10);
define _no_remesa			char(10);
define _periodo				char(7);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define _no_endoso			char(5);
define _cod_cober_reas		char(3);
define _cod_tipoprod		char(3);
define _cod_sucursal        char(3);
define _cod_subramo			char(3);
define _cod_origen          char(3);
define _cod_ramo			char(3);
define _nueva_renov			char(1);
define _indcol              char(1);
define _mto_comision		dec(18,2);
define _mto_prima_ok      	dec(18,2);
define _mto_prima_ac		dec(18,2);
define _mto_reserva			dec(18,2);
define _mto_prima			dec(18,2);
define _mto_suma			dec(18,2);
define _comision_descontada dec(16,2);        
define _monto_descontado    dec(16,2);
define _impuesto     		dec(16,2);
define _porc_partic_prima   dec(9,6);
define _porc_proporcion		dec(9,6);
define _porc_p				dec(9,6);
define _por_tasa			dec(7,3);
define _porc_partic_agt		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _cod_producto_ttcorp	smallint;
define _cod_area_seguro		smallint;
define _cod_ramo_ttcorp		smallint;
define _id_mov_tecnico		integer;
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
define _id_reas_caract		integer;
define _id_mov_reas			integer;
define _error_isam			integer;
define _cantidad            integer;
define _renglon				integer;
define _error				integer;
define _cnt					integer;
define _fec_situacion		date;
define _fec_operacion		date;
define _fec_registro		date;
define _fec_emision			date;
define _fec_inivig			date;
define _fec_finvig			date;
define _fecha_recibo        date;
define _cnt_existe          integer;
define _mensaje				char(50);
define _dup_reg				smallint;
define _reg1				integer;
define _reg2				integer;
define _reg3				integer;

on exception set _error,_error_isam,_error_desc
	drop table temp_det;
	drop table tmp_movim_tec_pri_tt;
	drop table tmp_movim_reaseguro_tt;
	drop table tmp_reas_caract_pri_tt;
	rollback work;
	let _error_desc = trim(_error_desc) || '3no_poliza: ' || _no_poliza || 'no_endoso: ' ||  _no_endoso;
	return _error,_error_desc;
end exception

{set debug file to "sp_actuario_cobbk.trc";
trace on;}

set isolation to dirty read;

let _fec_operacion	= today;
let _fec_registro	= today;
let _mto_reserva	= 0.00;
let _cod_situacion	= 13;	--13 para prima cobrada
let _cod_empresa	= 11;
let _por_tasa		= 1;
let _cod_moneda		= 'USD';
let _mensaje		= 'Inserción Exitosa';

--Verificacion de periodo existente
--call sp_ttc08(a_periodo_hasta,2) returning _dup_reg, _reg1,_reg2,_reg3 ;


--delete from reas_caract_pri_tt;
--delete from movim_reaseguro_tt;
--delete from movim_tec_pri_tt;

select valor_parametro
  into _id_mov_tecnico
  from parcont
 where cod_parametro = 'ttcorp_id1_pri';

select valor_parametro
  into _id_mov_reas
  from parcont
 where cod_parametro = 'ttcorp_id2_pri';

 select valor_parametro
  into _id_reas_caract
  from parcont
 where cod_parametro = 'ttcorp_id3_pri';

if _id_mov_tecnico is null then
	let _id_mov_tecnico = 0;
end if

select *
  from movim_tec_pri_tt
 where 1=2
  into temp tmp_movim_tec_pri_tt;
create index idx_tmp_movim_tec_pri_tt_1 on tmp_movim_tec_pri_tt(id_mov_tecnico_anc);
 
select *
  from movim_reaseguro_tt
 where 1=2
  into temp tmp_movim_reaseguro_tt;
create index idx_tmp_movim_reaseguro_tt_1 on tmp_movim_reaseguro_tt(id_mov_reas_ancon);
create index idx_tmp_movim_reaseguro_tt_2 on tmp_movim_reaseguro_tt(id_mov_tecnico_ancon);

select *
  from reas_caract_pri_tt
 where 1=2
  into temp tmp_reas_caract_pri_tt;
create index idx_tmp_reas_caract_pri_tt_1 on tmp_reas_caract_pri_tt(id_reas_caract_ancon);
create index idx_tmp_reas_caract_pri_tt_2 on tmp_reas_caract_pri_tt(id_mov_reas_ancon);

if _id_mov_tecnico is null then
	let _id_mov_tecnico = 0;
end if

let _id_certificado = '00001';
let a_periodo_desde = trim(a_periodo_desde);
let a_periodo_hasta = trim(a_periodo_hasta);

--Sacar la prima cobrada

--call sp_pro307_dist('001','001',a_periodo_desde,a_periodo_hasta,'*','*','*','*','*','*') returning v_filtros;   --crea temp_det

call sp_pro307('001','001',a_periodo_desde,a_periodo_hasta,'*','*','*','*','*','*') returning v_filtros; --crea temp_det

--SET DEBUG FILE TO "sp_a.trc";
--trace on;

foreach with hold
	select no_poliza,
		   no_endoso,
		   no_documento,
		   prima_neta,
		   vigencia_inic,
		   no_factura,
		   no_remesa,
		   renglon
	  into _no_poliza,
		   _no_endoso,
		   _id_poliza,
		   _mto_prima,
		   _fec_emision,
		   _id_recibo,
		   _no_remesa,
		   _renglon
	  from temp_det
	 where seleccionado = 1
--	   and no_documento = '0113-00393-01'
--and renglon in (1,2,3)

	begin work;

	select count(*)
	  into _cnt
	  from tmp_movim_tec_pri_tt
	 where no_remesa = _no_remesa
	   and renglon   = _renglon;

	if _cnt > 0 then
	    commit work;
		continue foreach;
	end if

	let _porc_p = 0;

	select sum(porc_proporcion)
	  into _porc_p
	  from cobreaco
	 where no_remesa = _no_remesa
	   and renglon   = _renglon;
	
	select count(*)
	  into _cnt
	  from cobreaco
	 where no_remesa = _no_remesa
	   and renglon   = _renglon;
	
    if _porc_p is null then
		let _porc_p = 0;
	end if

	select impuesto,
		   monto_descontado
	  into _impuesto,
	       _monto_descontado
	  from cobredet
	 where no_remesa = _no_remesa
	   and renglon   = _renglon;
  
	if _monto_descontado <> 0 then 
		let _comision_descontada = 1;
	else 	 
		let _comision_descontada = 0;
	end if 
	   
	   
	select user_added,
		   periodo,
		   date_added
	  into _cod_usuario,
		   _periodo,
		   _fec_situacion
	  from cobremae
	 where no_remesa = _no_remesa;

	select vigencia_inic,
		   vigencia_final,
		   cod_ramo,
		   cod_subramo,
		   serie,
		   cod_contratante,
		   cod_tipoprod,
		   cod_grupo,
		   cod_sucursal,
		   cod_origen,
		   nueva_renov
	  into _fec_inivig,
		   _fec_finvig,
		   _cod_ramo,
		   _cod_subramo,
		   _num_serie,
		   _cod_contratante,
		   _cod_tipoprod,
		   _cod_grupo,
		   _cod_sucursal,
		   _cod_origen,
		   _nueva_renov
	  from emipomae
	 where no_poliza   = _no_poliza
	   and actualizado = 1;
	
	--if _cod_ramo = '002' then
	--else
	if _porc_p = 0 then
		call sp_sis171bk(_no_remesa,_renglon) returning _error, _error_desc;
	end if
	--end if

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
	
	if _cod_tipoprod = '002' and _cod_grupo not in ('00000','1000') then
		let _tipo_poliza = 2;
	elif _cod_tipoprod = '004' then 
		let _tipo_poliza = 3;
	elif _cod_tipoprod = '005' and _cod_grupo in ('00000','1000') then
		let _tipo_poliza = 4;
	elif _cod_tipoprod = '002' and _cod_grupo in ('00000','1000') then
		let _tipo_poliza = 5;
	end if

	--Individual/Colectivo
	select count(*)
	  into _cantidad
	  from emipouni
	 where no_poliza = _no_poliza;

	let _indcol = 'I';

	if _cod_ramo IN('002','020') and _cantidad > 5 then --Es colectivo
	   let _indcol = 'C';
	elif (_cod_ramo = '004' and _cantidad > 10) or (_cod_ramo = '004' and _cod_grupo = '01016') then
	   let _indcol = 'C';
	elif _cod_ramo = '018' and _cod_subramo in('010','012') then
	   let _indcol = 'C';
	end if

	if _cod_grupo in('991','990','00000','1000') then
	   let _indcol = 'C';
	end if

	if abs(_mto_prima) < 0.04 then
	    commit work;
		continue foreach;
	end if

	let _mto_prima = _mto_prima;
	
	call sp_sis122a(_no_remesa,_renglon) returning _error,_error_desc;
		
	if _error <> 0 then
	   {drop table tmp_movim_tec_pri_tt;
		drop table tmp_movim_reaseguro_tt;
		drop table tmp_reas_caract_pri_tt;}
		rollback work;
		
		let _error_desc = trim(_error_desc) || '1no_poliza: ' ||_no_poliza || 'no_endoso: ' || _no_endoso;
		return _error,_error_desc;
	end if

	let _mto_prima_ac = 0.00;
	foreach
		select cod_agente,
			   porc_partic_agt,
			   porc_comis_agt
		  into _cod_agente,
			   _porc_partic_agt,
			   _porc_comis_agt
		  from cobreagt
		 where no_remesa = _no_remesa
		   and renglon	 = _renglon
		
		let _id_relac_productor = _cod_agente;
			
		foreach
			select distinct cod_cober_reas
			  into _cod_cober_reas
			  from tmp_reas

			 --where no_remesa = _no_remesa
			 --  and renglon   = _renglon
			
			let _id_mov_tecnico = _id_mov_tecnico + 1;
			let _cod_ramorea	= _cod_cober_reas;

			select sum(porc_partic_prima),porc_proporcion
			  into _porc_partic_prima,_porc_proporcion
			  from tmp_reas
			 where cod_cober_reas = _cod_cober_reas
			  --and no_remesa      = _no_remesa
			   --and renglon        = _renglon
			 group by porc_proporcion;

			let _mto_prima_ok = 0;

			let _mto_prima_ok = _mto_prima * (_porc_partic_prima / 100) * (_porc_proporcion / 100) * (_porc_partic_agt / 100) ;
			let _mto_comision = _mto_prima_ok * (_porc_comis_agt / 100);
			
			let _mto_prima_ac = _mto_prima_ac + _mto_prima_ok;
			
			insert into tmp_movim_tec_pri_tt(
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
					no_remesa,
					renglon,
					cod_sucursal,
					comision_descontada,
					nueva_renov,
					cod_origen,
					cod_subramo,
					indcol,
					id_mov_tecnico_anc,
					cod_ramo_ancon,
					cod_ramorea_ancon,
					id_relac_cliente_ancon,
					id_relac_productor_ancon,
					ind_actualizado
					)
			values	(0,                        
					_cod_empresa,
					_num_ano,
					_num_mes,
					_num_serie,
					_cod_area_seguro,
					_cod_producto,
					0,
					0,
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
					0,
					_mto_reserva,
					_mto_prima_ok,
					_mto_comision,
					0,
					0,
					_fec_operacion,
					_fec_registro,
					_cod_usuario,
					_no_remesa,
					_renglon,
					_cod_sucursal,
					_comision_descontada,
					_nueva_renov,
					_cod_origen,
					_cod_subramo,
					_indcol,
					_id_mov_tecnico,
					_cod_producto,
					_cod_ramorea,
					_id_relac_cliente,
					_id_relac_productor,
					0
					);

			call sp_actuario_cob1(_id_mov_tecnico,_id_mov_tecnico,_id_mov_reas,_id_reas_caract) returning _error,_error_desc;

			if _error <> 0 then
				{drop table tmp_reas;
				drop table tmp_movim_tec_pri_tt;
				drop table tmp_movim_reaseguro_tt;
				drop table tmp_reas_caract_pri_tt;}
				rollback work;
				
				let _error_desc = trim(_error_desc) || '2no_poliza: ' || _no_poliza || 'no_endoso: ' ||  _no_endoso;
				return _error,_error_desc;
			end if

			select count(*)
			  into _cnt_existe
			  from tmp_movim_reaseguro_tt
			 where id_mov_tecnico_ancon = _id_mov_tecnico;
			
			if _cnt_existe is null then
				let _cnt_existe = 0;
			end if
			
			if _cnt_existe = 0 then
				update tmp_movim_tec_pri_tt
				   set flag = 4
				 where id_mov_tecnico_anc = _id_mov_tecnico
				   and flag = 0;
			end if

			select max(id_mov_reas_ancon)
			  into _id_mov_reas
			  from tmp_movim_reaseguro_tt;

		end foreach
	end foreach
	
	if abs(_mto_prima_ac - _mto_prima) > 0.55 then
		
		update tmp_movim_tec_pri_tt
		   set flag = 1
		 where no_remesa = _no_remesa
		   and renglon	 = _renglon
		   and flag		 = 0;
	end if

	if _impuesto is null then
		let _impuesto = 0.00;
	end if
	
	if _impuesto <> 0.00 then
		let _cod_ramorea = 100;
		let _id_mov_tecnico = _id_mov_tecnico + 1;
		insert into tmp_movim_tec_pri_tt(
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
				no_remesa,
				renglon,
				cod_sucursal,
				comision_descontada,
				nueva_renov,
				cod_origen,
				cod_subramo,
				indcol,
				id_mov_tecnico_anc,
				cod_ramo_ancon,
				cod_ramorea_ancon,
				id_relac_cliente_ancon,
				id_relac_productor_ancon,
				ind_actualizado
				)
		values	(0,                        
				_cod_empresa,
				_num_ano,
				_num_mes,
				_num_serie,
				_cod_area_seguro,
				_cod_producto,
				0,
				0,
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
				0,
				_mto_reserva,
				_impuesto,
				_mto_comision,
				0,
				0,
				_fec_operacion,
				_fec_registro,
				_cod_usuario,
				_no_remesa,
				_renglon,
				_cod_sucursal,
				_comision_descontada,
				_nueva_renov,
				_cod_origen,
				_cod_subramo,
				_indcol,
				_id_mov_tecnico,
				_cod_producto,
				_cod_ramorea,
				_id_relac_cliente,
				_id_relac_productor,
				0
				);
	end if
	
	let _mto_comision	= 0.00;
	let _mto_reserva	= 0.00;
	let _impuesto		= 0.00;
	let _mto_suma		= 0.00;
	
	drop table tmp_reas;
	commit work;

END FOREACH

begin work;
insert into movim_tec_pri_tt
select * 
  from tmp_movim_tec_pri_tt;

insert into movim_reaseguro_tt
select * 
  from tmp_movim_reaseguro_tt;

insert into reas_caract_pri_tt
select * 
  from tmp_reas_caract_pri_tt;

drop table temp_det;
drop table tmp_movim_tec_pri_tt;
drop table tmp_movim_reaseguro_tt;
drop table tmp_reas_caract_pri_tt;

commit work;

--actualiza el contador en caso tal de que sea requerido
begin work;
IF _dup_reg = 1 THEN 
	UPDATE parcont 
				   SET valor_parametro = _reg1
				 WHERE cod_parametro = 'ttcorp_id1_pri';
				
				UPDATE parcont 
				   SET valor_parametro = _reg2
				 WHERE cod_parametro = 'ttcorp_id2_pri';
				 
				 UPDATE parcont 
				   SET valor_parametro = _reg3
				 WHERE cod_parametro = 'ttcorp_id3_pri';
END IF
commit work;

let _cnt = 0;

select count(*)
  into _cnt
  from movim_tec_pri_tt
 where flag in(1,2,4);

IF  _cnt = 0 THEN 
	select count(*)
	  into _cnt
	  from movim_reaseguro_tt
	 where flag in(3);
END IF

IF _cnt <> 0 THEN
	LET _mensaje = 'Se encontraron: '|| _cnt ||' registros con problemas.';
END IF

return _cnt,_mensaje;	

end			
end procedure;