drop procedure sp_reserva_riesgo_act;
create procedure sp_reserva_riesgo_act(a_periodo char(7))
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
define _periodo,_periodo_fac		char(7);
define _cod_agente					char(5);
define _res_origen					char(5);
define _no_endoso					char(5);
define _cod_cober_reas				char(3);
define _cod_tipoprod				char(3);
define _cod_sucursal        		char(3);
define _cod_endomov					char(3);
define _cod_subramo         		char(3);
define _cod_ramo,_cod_ramo_agrupa   char(3);
define _nueva_renov					char(1);
define _tipo_agente            		char(1);
define _indcol              		char(1);
define _saldo						dec(16,2);
define _mto_prima_ac,_mto_partic	dec(16,2);
define _mto_reserva					dec(18,2);
define _mto_prima					dec(18,2);
define _mto_suma					dec(18,2);
define _prima_neta_calc				dec(18,2);
define _prima_neta_end				dec(18,2);
define _prima_suscrita,_mto_imp_rec	dec(16,2);
define _impuesto,_mto_comis_gan,_res_debito		dec(16,2);
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
define _cod_empresa,_valor					smallint;
define _num_serie,_indiv_col		smallint;
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
define _fec_finvig,_res_fechatrx    date;
define _cnt_existe,_res_notrx       integer;
define _mensaje,_n_ramo,_n_ramo_reas  char(50);
define _cod_contrato				char(5);
define _estatus_poliza              char(4);
define _proporcion                  dec(12,10);
define _comision_corr,_prima_cedida,_comision_reas,_impuesto_reaseg dec(16,2);
define _prima_suscrita_p,_prima_susc_neta,_rrc_cedida,_rrc_100,_gasto_adq,_prima_cedida_neta             dec(16,2);

on exception set _error,_error_isam,_error_desc
	let _error_desc = trim(_error_desc); --|| 'no_poliza: ' || _no_poliza || 'no_endoso: ' ||  _no_endoso;
	return _error,_error_desc;
end exception

--set debug file to "sp_reserva_riesgo.trc";
--trace on;

set isolation to dirty read;

let _no_poliza = "";

drop table if exists tmp_mov_ramo;
create temp table tmp_mov_ramo(
	cod_ramo					char(3),
	saldo				        dec(16,2),
	prima_suscrita              dec(16,2) default 0
	) with no log;
create index i_tmp_mov_ramo_idx on tmp_mov_ramo(cod_ramo);

let _fec_operacion	= sp_sis36(a_periodo);
let _mensaje        = 'Actaulizacion Exitosa';

--****Data para Otros costos de adq.
let _valor = DetalleContableGastosAdq_rrc(a_periodo,a_periodo); --Crea tabla tmp_mov_cuentas

--Agrupacion del saldo
foreach
	select s.cod_ramo,
	       sum(t.saldo)
	  into _cod_ramo,
           _saldo	  
	  from tmp_mov_cuentas t, ssr_mapi s
	 where t.res_cuenta = s.cta_cuenta
	   and t.res_mayor in('420','564','570')
	 group by s.cod_ramo
	 order by s.cod_ramo
	
	insert into tmp_mov_ramo(
	cod_ramo,
	saldo)
	values(
	_cod_ramo,
	_saldo
	);
end foreach
--Agrupacion de la Prima Suscrita
foreach
	select s.cod_ramo_agrupado,
	       sum(t.prima_suscrita)
      into _cod_ramo,
           _prima_suscrita	  
	  from deivid_ttcorp:reserva_riesgo_curso t, prdramo s
	 where t.cod_ramo = s.cod_ramo
	   and t.periodo = a_periodo
	   and t.periodo_factura = a_periodo
	 group by s.cod_ramo_agrupado
	 order by s.cod_ramo_agrupado
	
	update tmp_mov_ramo
	   set prima_suscrita = _prima_suscrita
	 where cod_ramo       = _cod_ramo;
	 
end foreach

foreach with hold
	select id_mov_tecnico,
	       prima_suscrita,
		   cod_ramo,
		   comision_corr,
		   impuesto,
		   prima_cedida,
		   comision_reas,
		   impuesto_reaseg,
		   fec_finvig,
		   fec_inivig,
		   periodo_factura
	  into _id_mov_tecnico,
		   _prima_suscrita,
		   _cod_ramo,
		   _comision_corr,
		   _impuesto,
		   _prima_cedida,
		   _comision_reas,
		   _impuesto_reaseg,
		   _fec_finvig,
		   _fec_inivig,
		   _periodo_fac
	  from deivid_ttcorp:reserva_riesgo_curso
	 where periodo = a_periodo
 
	select cod_ramo_agrupado
	  into _cod_ramo_agrupa
	  from prdramo
	 where cod_ramo = _cod_ramo;
	
	--***Calculos
	let _gasto_adq  = 0;
	let _proporcion = 0;
	let _rrc_cedida = 0;

	if _periodo_fac = a_periodo then
		select prima_suscrita,
			   saldo
		  into _prima_suscrita_p,
			   _saldo
		  from tmp_mov_ramo
		 where cod_ramo = _cod_ramo_agrupa;
	
		let _proporcion = _prima_suscrita /	_prima_suscrita_p;
		let _gasto_adq  = _proporcion * _saldo;
	end if

	let _prima_susc_neta = _prima_suscrita - _comision_corr - _impuesto - _gasto_adq;
	
	if _fec_finvig <= _fec_operacion then
		let _rrc_100 = 0;
	else
		let _rrc_100 = (_fec_finvig - _fec_operacion) / (_fec_finvig - _fec_inivig) * _prima_susc_neta;
	end if
	
	let _prima_cedida_neta = _prima_cedida - _comision_reas - _impuesto_reaseg;
	
	if _fec_finvig <= _fec_operacion then
		let _rrc_100 = 0;
	else
		let _rrc_cedida = (_fec_finvig - _fec_operacion) / (_fec_finvig - _fec_inivig) * _prima_cedida_neta;
	end if
	
	if _cod_ramo = '019' then	--vida Individual no se toma en cuenta para la RRC
		let _rrc_100    = 0;
		let _rrc_cedida = 0;
	end if
	
	update deivid_ttcorp:reserva_riesgo_curso
	   set proporcion_ramo = _proporcion,
	       gastos_adq      = _gasto_adq,
		   p_susc_neta     = _prima_susc_neta,
		   rrc_100         = _rrc_100,
		   p_cedida_neta   = _prima_cedida_neta,
		   rrc_cedida      = _rrc_cedida
	 where id_mov_tecnico  = _id_mov_tecnico;
		
end foreach
return 0, _mensaje;	
end			
end procedure;