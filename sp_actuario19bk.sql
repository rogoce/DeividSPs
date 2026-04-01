drop procedure sp_actuario19bk;
-- copia de sp_actuario
create procedure "informix".sp_actuario19bk(a_periodo_desde char(7), a_periodo_hasta char(7), _dup_reg smallint, _reg1 integer, _reg2 integer, _reg3 integer )
	returning integer,varchar(250);

BEGIN

define _error_desc					varchar(250);
define _cod_usuario					varchar(30);
define _id_certificado				varchar(25);
define _id_recibo					varchar(25);
define _id_poliza					varchar(25);
define _cod_moneda					varchar(3);
define _tipo_poliza					varchar(3);
define _cod_contratante				char(10);
define _no_poliza					char(10);
define _periodo						char(7);
define _cod_agente					char(5);
define _cod_grupo					char(5);
define _no_endoso					char(5);
define _cod_cober_reas				char(3);
define _cod_tipoprod				char(3);
define _cod_sucursal        		char(3);
define _cod_subramo         		char(3);
define _cod_ramo					char(3);
define _nueva_renov					char(1);
define _tipo_agente            		char(1);
define _indcol              		char(1);
define _mto_comision				dec(18,2);
define _mto_prima_ac				dec(18,2);
define _mto_reserva					dec(18,2);
define _mto_prima					dec(18,2);
define _mto_suma					dec(18,2);
define _prima_neta_calc				dec(16,2);
define _prima_neta_end				dec(16,2);
define _prima_suscrita				dec(16,2);
define _impuesto					dec(16,2);
define _porc_partic_ancon			dec(7,4);
define _por_tasa					dec(7,3);
define _porc_partic_agt				dec(5,2);
define _porc_comis_agt				dec(5,2);
define _cod_producto_ttcorp			smallint;
define _cod_ramorea_ancon			smallint;
define _tipo_produccion     		smallint;
define _ind_actualizado				smallint;
define _cod_area_seguro				smallint;
define _cod_ramo_ttcorp				smallint;
define _tiene_impuesto      		smallint;
define _cod_ramo_ancon				smallint;
define _cod_situacion				smallint;
define _cod_producto				smallint;
define _cod_ramorea					smallint;
define _cod_empresa					smallint;
define _num_serie					smallint;
define _ramo_sis					smallint;
define _num_ano						smallint;
define _num_mes						smallint;
define _flag						smallint;
define _id_relac_productor			integer;
define _id_mov_tecnico_anc			integer;
define _id_relac_cliente			integer;
define _id_mov_tecnico				integer;
define _id_reas_caract				integer;
define _cnt_endedcob				integer;
define _id_mov_reas					integer;
define _error_isam					integer;
define _cantidad            		integer;
define _error						integer;
define _fec_situacion				date;
define _fec_operacion				date;
define _fec_registro				date;
define _fec_emision					date;
define _fec_inivig					date;
define _fec_finvig					date;
define _cnt                         integer;
define _cnt_existe                  integer;
define _mensaje						char(50);
-- define _dup_reg						smallint;
-- define _reg1						integer;
-- define _reg2						integer;
-- define _reg3						integer;


on exception set _error,_error_isam,_error_desc
	drop table tmp_movim_tec_pri_ttco;
	drop table tmp_movim_reaseguro_pr;
	drop table tmp_reas_caract_pri;
	rollback work;
	let _error_desc = trim(_error_desc) || 'no_poliza: ' || _no_poliza || 'no_endoso: ' ||  _no_endoso;
	return _error,_error_desc;
end exception

{set debug file to "sp_actuario19bk.trc";
trace on;}

set isolation to dirty read;

let _fec_operacion	= today;
let _fec_registro	= today;
let _mto_reserva	= 0.00;
let _id_mov_tecnico = 0;
let _cod_situacion	= 5;	--5 para prima produccion
let _cod_empresa	= 11;
let _por_tasa		= 1;
let _cod_moneda		= 'USD';
let _mensaje        = 'Insercion Exitosa';

--call sp_ttc08(a_periodo_hasta,1) returning _dup_reg, _reg1,_reg2,_reg3 ;

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



--delete from deivid_ttcorp:reas_caract_pri;
--delete from deivid_ttcorp:movim_reaseguro_pr;
--delete from deivid_ttcorp:movim_tec_pri_ttco;

select *
  from deivid_ttcorp:movim_tec_pri_ttco
 where 1=2
  into temp tmp_movim_tec_pri_ttco;
create index idx_tmp_movim_tec_pri_ttco_1 on tmp_movim_tec_pri_ttco(id_mov_tecnico_anc);
 
select *
  from deivid_ttcorp:movim_reaseguro_pr
 where 1=2
  into temp tmp_movim_reaseguro_pr;
create index idx_tmp_movim_reaseguro_pr_1 on tmp_movim_reaseguro_pr(id_mov_reas_ancon);
create index idx_tmp_movim_reaseguro_pr_2 on tmp_movim_reaseguro_pr(id_mov_tecnico_ancon);

select *
  from deivid_ttcorp:reas_caract_pri
 where 1=2
  into temp tmp_reas_caract_pri;

create index idx_tmp_reas_caract_pri_1 on tmp_reas_caract_pri(id_reas_caract_ancon);
create index idx_tmp_reas_caract_pri_2 on tmp_reas_caract_pri(id_mov_reas_ancon);
  
  
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
		   b.cod_subramo,
		   b.serie,
		   a.no_factura,
		   a.periodo,
		   b.cod_contratante,
		   a.cod_tipoprod,
		   b.cod_grupo,
		   a.user_added,
		   a.date_added,
		   a.impuesto,
		   a.cod_sucursal,
		   b.tiene_impuesto,
		   a.prima_neta,
		   b.nueva_renov,
		   a.prima_suscrita
	  into _no_poliza,
		   _no_endoso,
		   _id_poliza,
		   _fec_inivig,
		   _fec_finvig,
		   _fec_emision,
		   _cod_ramo,
		   _cod_subramo,
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
		   _nueva_renov,
		   _prima_suscrita
	  from endedmae a, emipomae b
	 where a.no_poliza = b.no_poliza
	   and a.periodo >= a_periodo_desde
	   and a.periodo <= a_periodo_hasta
	   and a.prima_neta <> 0
	   and a.actualizado = 1
	   --and a.no_factura in ('01-1504982','01-1504991','01-1504952')
	
	begin work;

	let _num_ano = _periodo[1,4];
	let _num_mes = _periodo[6,7];
	let _id_relac_cliente = _cod_contratante;

	if _nueva_renov is null then
		drop table tmp_movim_tec_pri_ttco;
		drop table tmp_movim_reaseguro_pr;
		drop table tmp_reas_caract_pri;
		rollback work;		
		return 1,'No Existe indicador de Nueva-Renovacion. no_poliza: ' || _no_poliza || 'no_endoso: ' ||  _no_endoso;
	end if
	
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
	
	if _cod_ramo = '018' then	-- VerificaciÃ³n de endedcob para pÃ³lizas de Salud
		select count(*)
		  into _cnt_endedcob
		  from endedcob 
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;
		   --and no_unidad = _id_certificado;

		if _cnt_endedcob is null then
			let _cnt_endedcob = 0;
		end if

		if _cnt_endedcob = 0 then
			call sp_actuario22a(_id_recibo) returning _error,_error_desc;
			
			if _error <> 0 then
				{drop table tmp_movim_tec_pri_ttco;
				drop table tmp_movim_reaseguro_pr;
				drop table tmp_reas_caract_pri;	 }
				rollback work;
				
				let _error_desc = trim(_error_desc) || 'no_poliza: ' ||_no_poliza || 'no_endoso: ' || _no_endoso;
				return _error,_error_desc;
			end if
		end if		
	end if

	--GeneraciÃ³n de la Tabla de DistribuciÃ³n de Reaseguro por Endoso.
	call sp_sis122(_no_poliza,_no_endoso) returning _error,_error_desc;
		
	if _error <> 0 then
		{drop table tmp_movim_tec_pri_ttco;
		drop table tmp_movim_reaseguro_pr;
		drop table tmp_reas_caract_pri;	}

		rollback work;

		let _error_desc = trim(_error_desc) || 'no_poliza: ' ||_no_poliza || 'no_endoso: ' || _no_endoso;
		return _error,_error_desc;
	end if
	
	let _porc_partic_ancon = 100;
	
	if _tipo_produccion = 2 then -- Coaseguro Mayoritario
		select porc_partic_coas
		  into _porc_partic_ancon
		  from endcoama
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and cod_coasegur = '036';	--Aseg. AncÃ³n.
		
		if _porc_partic_ancon is null then
			let _porc_partic_ancon = 100;
		end if
	end if
	
	--let _prima_neta_calc = _prima_suscrita / (_porc_partic_ancon /100);
	let _mto_prima_ac = 0.00;

	foreach
		select cod_agente,
			   porc_partic_agt,
			   porc_comis_agt
		  into _cod_agente,
			   _porc_partic_agt,
			   _porc_comis_agt
		  from endmoage
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		
		select tipo_agente
		  into _tipo_agente
		  from agtagent
		 where cod_agente = _cod_agente;

		if _tipo_agente = "O" then
			let _porc_comis_agt = 0.00;
		end if
		
		let _id_relac_productor = _cod_agente;

		foreach
			select no_unidad,
				   suma_asegurada
			  into _id_certificado,
				   _mto_suma
			  from endeduni
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso

			let _mto_prima = 0.00;

			foreach
				select cod_cober_reas,
					   sum(prima_rea)
				  into _cod_cober_reas,
					   _mto_prima
				  from tmp_reas
				 where no_unidad = _id_certificado
				 group by cod_cober_reas

				if _mto_prima is null then
					let _mto_prima = 0.00;
				end if

				let _mto_prima = _mto_prima / (_porc_partic_ancon /100);

				if _mto_prima = 0.00 then
					--continue foreach;
				end if

				let _mto_comision = 0.00;
				let _mto_prima = _mto_prima * (_porc_partic_agt / 100);
				let _mto_comision = _mto_prima  * (_porc_comis_agt / 100);

				let _mto_prima_ac = _mto_prima_ac + _mto_prima;

				let _id_mov_tecnico = _id_mov_tecnico + 1;
				let _cod_ramorea	= _cod_cober_reas;

				insert into tmp_movim_tec_pri_ttco(
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
						nueva_renov,
						cod_subramo,
						indcol,
						no_poliza,
						no_endoso,
						id_mov_tecnico_anc,
						cod_ramo_ancon,
						cod_ramorea_ancon,
						id_relac_cliente_ancon,
						id_relac_productor_ancon,
						ind_actualizado,
						flag)
				values	(_id_mov_tecnico,                        
						_cod_empresa,
						_num_ano,
						_num_mes,
						_num_serie,
						_cod_area_seguro,
						_cod_producto,
						null,
						null,
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
						null,
						null,
						_fec_operacion,
						_fec_registro,
						_cod_usuario,
						_cod_sucursal,
						_tipo_produccion,
						_tiene_impuesto,
						_nueva_renov,
						_cod_subramo,
						_indcol,
						_no_poliza,
						_no_endoso,
						_id_mov_tecnico,
						_cod_producto,
						_cod_ramorea,
						_id_relac_cliente,
						_id_relac_productor,
						0,0);

				call sp_actuario20(_id_mov_tecnico,_id_mov_tecnico,_id_mov_reas,_id_reas_caract) returning _error,_error_desc;

				select count(*)
				  into _cnt_existe
				  from tmp_movim_reaseguro_pr
				 where id_mov_tecnico_ancon = _id_mov_tecnico;

				if _cnt_existe is null then
					let _cnt_existe = 0;
				end if
				
				if _cnt_existe = 0 then
					update tmp_movim_tec_pri_ttco
					   set flag = 4
					 where id_mov_tecnico_anc = _id_mov_tecnico
					   and flag = 0;
				end if


				select max(id_mov_reas_ancon)
				  into _id_mov_reas
				  from tmp_movim_reaseguro_pr;
				
				select max(id_reas_caract_ancon)
				  into _id_reas_caract
				  from tmp_reas_caract_pri;

				if _error <> 0 then
					{drop table tmp_reas;
					drop table tmp_movim_tec_pri_ttco;
					drop table tmp_movim_reaseguro_pr;
					drop table tmp_reas_caract_pri;}
  
					rollback work;
					let _error_desc = trim(_error_desc) || 'no_poliza: ' || _no_poliza || 'no_endoso: ' ||  _no_endoso;
					return _error,_error_desc;
				end if
			end foreach
		end foreach
	end foreach

	if abs(_mto_prima_ac - _prima_neta_end ) > 0.55  then	--_prima_neta_calc
	    let _flag = 1;
		update tmp_movim_tec_pri_ttco
		   set flag      = _flag
		 where id_recibo = _id_recibo
		   and flag = 0;
	end if

	if _impuesto is null then
		let _impuesto = 0.00;
	end if

	if _impuesto <> 0.00 then
		let _cod_ramorea = 100;
		let _id_mov_tecnico = _id_mov_tecnico + 1;
		
		insert into tmp_movim_tec_pri_ttco(
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
				nueva_renov,
				cod_subramo,
				indcol,
				no_poliza,
				no_endoso,
				id_mov_tecnico_anc,
				cod_ramo_ancon,
				cod_ramorea_ancon,
				id_relac_cliente_ancon,
				id_relac_productor_ancon,
				ind_actualizado,
				flag)
		values	(_id_mov_tecnico,                        
				_cod_empresa,
				_num_ano,
				_num_mes,
				_num_serie,
				_cod_area_seguro,
				_cod_producto,
				null,
				null,
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
				null,
				null,
				_fec_operacion,
				_fec_registro,
				_cod_usuario,
				_cod_sucursal,
				_tipo_produccion,
				_tiene_impuesto,
				_nueva_renov,
				_cod_subramo,
				_indcol,
				_no_poliza,
				_no_endoso,
				_id_mov_tecnico,
				_cod_producto,
				_cod_ramorea,
				_id_relac_cliente,
				_id_relac_productor,
				0,0);
	end if

	let _mto_comision	= 0.00;
	let _mto_reserva	= 0.00;
	let _impuesto		= 0.00;
	let _mto_suma		= 0.00;
	let _mto_prima		= 0.00;

	drop table tmp_reas;
	commit work;
end foreach

--trace on;
begin work;
insert into deivid_ttcorp:movim_tec_pri_ttco
select * 
  from tmp_movim_tec_pri_ttco;


insert into deivid_ttcorp:movim_reaseguro_pr
select * 
  from tmp_movim_reaseguro_pr;

insert into deivid_ttcorp:reas_caract_pri
select * 
  from tmp_reas_caract_pri;

drop table tmp_movim_tec_pri_ttco;
drop table tmp_movim_reaseguro_pr;
drop table tmp_reas_caract_pri;

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
  from deivid_ttcorp:movim_tec_pri_ttco
 where flag in(1,2,4);

IF  _cnt = 0 THEN 
	select count(*)
	  into _cnt
	  from deivid_ttcorp:movim_reaseguro_pr
	 where flag in(3);
END IF

IF _cnt <> 0 THEN
	LET _mensaje = 'Se encontraron: '|| _cnt ||' registros con problemas.';
END IF
	 
return _cnt, _mensaje;	
end			
end procedure;