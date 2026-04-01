--***********************************************
--Carga tabla deivid_ttcorp:reserva_riesgo_curso
--Armando Moreno M.		10/02/2025
--***********************************************

drop procedure sp_reserva_riesgo;
create procedure sp_reserva_riesgo(a_periodo char(7))
returning integer,varchar(250);

BEGIN

define _error_desc					varchar(250);
define _cod_usuario					varchar(30);
define _id_certificado				varchar(25);
define _id_recibo					varchar(25);
define _id_poliza					varchar(25);
define _cod_moneda					varchar(3);
define _tipo_poliza,_cod_ramo_reas	varchar(3);
define _cod_contratante				char(10);
define _no_poliza					char(10);
define _periodo,_par_periodo_act	char(7);
define _cod_agente					char(5);
define _cod_grupo					char(5);
define _no_endoso					char(5);
define _cod_cober_reas				char(3);
define _cod_tipoprod				char(3);
define _cod_sucursal        		char(3);
define _cod_endomov					char(3);
define _cod_subramo         		char(3);
define _cod_ramo					char(3);
define _nueva_renov					char(1);
define _tipo_agente            		char(1);
define _indcol              		char(1);
define _mto_comision				dec(18,2);
define _mto_prima_ac,_mto_partic	dec(16,2);
define _mto_reserva					dec(18,2);
define _mto_prima					dec(18,2);
define _mto_suma					dec(18,2);
define _prima_neta_calc				dec(18,2);
define _prima_neta_end				dec(18,2);
define _prima_suscrita,_mto_imp_rec	dec(16,2);
define _impuesto,_mto_comis_gan		dec(16,2);
define _porc_partic_ancon			dec(7,4);
define _por_tasa					dec(7,3);
define _porc_partic_agt,_porc_impuesto,_porc_cont_partic	dec(5,2);
define _porc_comis_agt,_porc_imp,_porc_comis_gan			dec(5,2);
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
define _num_serie,_serie			smallint;
define _ramo_sis,_estatus_pol		smallint;
define _tipo_contrato				smallint;
define _num_mes,_cnt				smallint;
define _flag,_imp_gob				smallint;
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
define _cnt_existe                  integer;
define _mensaje,_n_ramo,_n_ramo_reas  char(50);
define _cod_contrato				char(5);

on exception set _error,_error_isam,_error_desc
	--rollback work;
	let _error_desc = trim(_error_desc) || 'no_poliza: ' || _no_poliza || 'no_endoso: ' ||  _no_endoso;
	return _error,_error_desc;
end exception

--set debug file to "sp_reserva_riesgo.trc";
--trace on;

set isolation to dirty read;

let _fec_operacion	= sp_sis36(a_periodo);
let _mensaje        = 'Inserción Exitosa';

--**********************ACTUALIZA EL PERIODO ACTUAL A TABLA CONTROL, PARA LA MAYORIZACION.*******
select par_periodo_act
  into _par_periodo_act
  from parparam;

update emirepar
   set periodo_verifica = _par_periodo_act;
--*************************************************

delete from deivid_ttcorp:reserva_riesgo_curso
where periodo = a_periodo;

select max(id_mov_tecnico)
  into _id_mov_tecnico
  from deivid_ttcorp:reserva_riesgo_curso;
 
if _id_mov_tecnico is null then
	let _id_mov_tecnico = 0;
end if

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
		   a.cod_sucursal,
		   b.tiene_impuesto,
		   a.prima_neta,
		   a.prima_suscrita,
		   a.cod_endomov
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
		   _cod_sucursal,
		   _tiene_impuesto,
		   _prima_neta_end,
		   _prima_suscrita,
		   _cod_endomov
	  from endedmae a, emipomae b
	 where a.no_poliza = b.no_poliza
	   and ((a.vigencia_inic <= _fec_operacion and a.vigencia_final > _fec_operacion) or a.periodo = a_periodo)
	   and a.actualizado = 1
	   and a.fecha_emision <= _fec_operacion
	 order by a.no_poliza,a.no_endoso
	   
	select imp_gob
	  into _imp_gob
	  from prdramo
	 where cod_ramo = _cod_ramo;
	if _imp_gob = 1 then
		let _porc_impuesto = 2/100;
	else
		let _porc_impuesto = 0;
	end if

	select tipo_produccion
	  into _tipo_produccion
	  from emitipro
	 where cod_tipoprod = _cod_tipoprod;
	 
	--Generación de la Tabla de Distribución de Reaseguro por Endoso.
	call sp_sis122(_no_poliza,_no_endoso) returning _error,_error_desc;
		
	if _error <> 0 then
		--rollback work;
		let _error_desc = trim(_error_desc) || 'no_poliza: ' ||_no_poliza || 'no_endoso: ' || _no_endoso;
		return _error,_error_desc;
	end if

	let _mto_prima_ac = 0.00;
	let _mto_comision = 0.00;
	let _mto_imp_rec  = 0.00;

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
		
		let _prima_suscrita = 0.00;
		let _mto_comision   = 0.00;
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
				select sum(t.prima_rea),
				       t.cod_cober_reas,
					   t.cod_contrato,
					   r.tipo_contrato,
					   r.serie
				  into _mto_prima,
                       _cod_cober_reas,
                       _cod_contrato,
					   _tipo_contrato,
					   _serie
				from tmp_reas t, reacomae r
				where t.cod_contrato = r.cod_contrato
				  and t.no_unidad    = _id_certificado
			  group by t.cod_cober_reas,t.cod_contrato,r.tipo_contrato,r.serie
		      having sum(t.prima_rea) <> 0

				if _mto_prima is null then
					let _mto_prima = 0.00;
				end if
				
				let _prima_suscrita = _mto_prima;
				let _mto_prima      = _mto_prima * (_porc_partic_agt / 100);
				let _prima_suscrita = _prima_suscrita * (_porc_partic_agt / 100);
				let _mto_comision   = _prima_suscrita * (_porc_comis_agt / 100);
				let _impuesto       = _prima_suscrita * _porc_impuesto;
				if _tipo_contrato = 1 then	--retencion
					let _mto_comis_gan = 0.00;
					let _mto_imp_rec   = 0.00;
					let _mto_prima     = 0.00;
				else
					let _mto_comis_gan = 0.00;
					--comision ganada
					let _porc_comis_gan   = 0.00;
					let _porc_cont_partic = 0.00;
					let _mto_partic       = 0.00;
					foreach
						select porc_comision,
						       porc_cont_partic
						  into _porc_comis_gan,
						       _porc_cont_partic
						  from reacoase
						 where cod_contrato   = _cod_contrato
						   and cod_cober_reas = _cod_cober_reas
						   
						if _cod_ramo in('002','020','023') then
							--A solicitud de LM se cambia a 25 para auto la comision.
							if _porc_comis_gan = 35 then
								let _porc_comis_gan = 25;
							end if
						end if						
						let _mto_partic    = _mto_prima  * (_porc_cont_partic / 100);
						let _mto_comis_gan = _mto_comis_gan + _mto_partic  * (_porc_comis_gan / 100);	   
					end foreach
					if _porc_comis_gan is null then
						let _mto_comis_gan = 0.00;
						let _porc_comis_gan = 0;
					end if
					--impuesto recuperado
					let _porc_imp = 0.00;
					select porc_impuesto
					  into _porc_imp
					  from reacocob
					 where cod_contrato   = _cod_contrato
					   and cod_cober_reas = _cod_cober_reas;
					   
					if _porc_imp is null or _porc_imp = 0 then
						let _porc_imp = 0;
						let _mto_imp_rec = 0.00;
					else	
						let _mto_imp_rec = _mto_prima  * (_porc_imp / 100);
					end if
				end if
				
				let _id_mov_tecnico = _id_mov_tecnico + 1;
				
				select nombre into _n_ramo from prdramo where cod_ramo = _cod_ramo;
				
				select nombre into _n_ramo_reas from reacobre where cod_cober_reas = _cod_cober_reas;

				insert into deivid_ttcorp:reserva_riesgo_curso(
						id_mov_tecnico,                        
						cod_ramo,
						cod_ramo_reas,
						id_poliza,
						id_recibo,
						id_certificado,
						fec_inivig,
						fec_finvig,
						prima_suscrita,
						comision_corr,
						impuesto,
						prima_cedida,
						comision_reas,
						impuesto_reaseg,
						periodo,
						n_ramo,
						n_ramo_reas,
						periodo_factura,
						serie
						)
				values	(_id_mov_tecnico,
				         _cod_ramo,
						 _cod_cober_reas,
						_id_poliza,
						_id_recibo,
						_id_certificado,
						_fec_inivig,
						_fec_finvig,
						_prima_suscrita,
						_mto_comision,
						_impuesto,
						_mto_prima,
						_mto_comis_gan,
						_mto_imp_rec,
						a_periodo,
						_n_ramo,
						_n_ramo_reas,
						_periodo,
						_serie
						);
			end foreach
		end foreach
	end foreach
	drop table tmp_reas;
	--commit work;
end foreach
--*************************PROCESAR EL RESTO DE COLUMNAS********
Call sp_reserva_riesgo_act(a_periodo) returning _error,_mensaje;

return _error, _mensaje;	
end			
end procedure;