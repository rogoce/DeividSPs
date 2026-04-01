-- Procedimiento que carga el Reporte de Indicadores para Multinacional
 
-- Creado     :	13/11/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_bo043_prueba2;		
create procedure "informix".sp_bo043_prueba2()
returning integer,
		  char(100);

define _emi_periodo		char(7);
define _cob_periodo		char(7);

define _per_ini_aa			char(7);
define _per_fin_aa			char(7);
define _per_ini_ap			char(7);
define _per_fin_ap			char(7);
define _per_fin_dic		char(7);
define _ano, _ano_act	integer;
define _mes_evaluar		smallint;
define _ano_evaluar		smallint;
define _fecha_cierre		date;
define _fecha_evaluar		date;

define _mes_pnd			smallint;
define _ano_pnd			smallint;
define _periodo_pnd1		char(7);
define _periodo_pnd2		char(7);
define _periodo_reno		char(7);

define _fecha_ini_ap		date;
define _fecha_fin_ap		date;
define _fecha_ini_aa		date;
define _fecha_fin_aa		date;

define _no_documento		char(20);
define _no_poliza			char(10);
define _no_reclamo			char(10);
define _no_requis			char(10);
define _monto				dec(16,2);
define _pos_ramo			smallint;
define _cod_ramo			char(3);
define _cod_subramo		char(3);
define _cod_tipoprod		char(3);
define _porc_coaseguro	dec(16,4);
define _cod_coasegur		char(3);
define _cod_cliente		char(10);
define _fronting			smallint;
define _cod_grupo			char(5);

define _pri_cob_ap			dec(16,2);
define _pri_cob_aa			dec(16,2);
define _pri_cob_map		dec(16,2);
define _pri_cob_maa		dec(16,2);
define _pri_dev_ap			dec(16,2);
define _pri_dev_aa			dec(16,2);
define _pri_sus_ap			dec(16,2);
define _pri_sus_aa			dec(16,2);
define _pri_sus_map		dec(16,2);
define _pri_sus_maa		dec(16,2);

define _pri_sus_ap_mes	dec(16,2);
define _pri_sus_map_mes	dec(16,2);
define _pri_cob_ap_mes	dec(16,2);
define _pri_cob_neto_aa	dec(16,2);

define _vigen_ini			date;
define _vigen_fin			date;
define _fecha_pago			date;
define _fecha_dic_ap		date;
define _fecha_hoy			date;
define _factor_vig			dec(16,2);
define _dias1,_dia,_mes		integer;
define _dias2				integer;

define _nueva_renov		    char(1);
define _cant_nueva			smallint;
define _cant_renov			smallint;

define _no_pol_ren_ap		integer;
define _no_pol_nue_ap		integer;
define _no_pol_tot_ap		integer;
define _no_pol_ren_aa		integer;
define _no_pol_nue_aa		integer;
define _no_pol_tot_aa		integer;

define _no_pol_ren_ap_per	integer;
define _no_pol_nue_ap_per	integer;
define _no_pol_ren_aa_per	integer;

define _ano_ant			integer;
define _vigencia_ant		date;
define _vigencia_act		date;

define _com_pag_ap			dec(16,2);
define _com_pag_aa			dec(16,2);
define _monto_che			dec(16,2);
define _tipo_agente		char(1);
define _cod_agente			char(5);
define _no_remesa			char(10);
define _renglon			smallint;
define _porc_partic_agt 	dec(5,2);
define _porc_comis_agt	dec(5,2);
define _user_added			char(8);

define _sin_ocu_ap			integer;
define _sin_ocu_aa			integer;
define _sin_pag_ap			dec(16,2);
define _sin_pag_aa			dec(16,2);
define _sin_pen_ap			dec(16,2);
define _sin_pen_aa			dec(16,2);
define _sin_pen_dic		dec(16,2);
define _sin_pen_12avos	dec(16,2);
define _sin_var_aa			dec(16,2);
define _sin_var_ap			dec(16,2);
define _sin_ocu_ap_tu		integer;
define _sin_ocu_aa_tu		integer;

define _nombre_agente		char(50);
define _cod_agencia		char(3);
define _centro_costo		char(3);
define _suc_promotoria	char(3);
define _cod_vendedor		char(3);
define _nombre_vendedor	char(50);
define _estatus_poliza	smallint;
define _nombre_ramo		char(50);
define _nombre_agencia	char(50);
define _nombre_promot		char(50);

define _filtros			char(255);

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);
define _numrecla			char(18);
define _ramo				char(3);

define _pri_sus_ret_ap		dec(16,2);
define _pri_sus_can_ap 		dec(16,2);
define _pri_sus_ret_ap_mes	dec(16,2);
define _pri_sus_can_ap_mes	dec(16,2);
define _pri_sus_ret_aa		dec(16,2);
define _pri_sus_can_aa		dec(16,2);
define _pri_ret_map			dec(16,2);
define _pri_can_map			dec(16,2);
define _pri_ret_map_mes		dec(16,2);
define _pri_sus_can_map_mes	dec(16,2);
define _pri_ret_maa			dec(16,2);
define _pri_sus_can_maa		dec(16,2);
define _prima_can			dec(16,2);
define _sin_ret_pag_ap     dec(16,2);
define _sin_ret_pag_aa     dec(16,2);
define _sin_ret_pen_aa	   dec(16,2);
define _sin_ret_pen_ap	   dec(16,2);
define _sin_ret_var_ap	   dec(16,2);
define _sin_ret_var_aa	   dec(16,2);
define _exigible		   dec(16,2);
define _tipo_prod          smallint;
define _colectiva		   char(1);
define _colectivo		   char(1);
define _cod_endomov        char(3);
define _tipo_mov           smallint;
define _comis_cobranza     dec(16,2);
define _comis_web     	   dec(16,2);
define _gasto_fin          dec(16,2);
define _porc_gasto		   dec(16,2);
define _n_subramo          char(50);
define _fecha_menos_ini    date;
define _fecha_menos_fin    date;
define _fecha_menos_ini_ap date;
define _fecha_menos_fin_ap date;


--set debug file to "sp_bo043.trc";
--trace on;
--trace "1";

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
--	return _error, _error_isam || " " || _error_desc;
	return _error, _error_desc;
end exception

-- Definiciones Iniciales

--delete from deivid_bo:boindmul;
--delete from deivid_bo:boindancon;

create temp table tmp_multi(
no_documento		char(20),
pri_cob_ap			dec(16,2) 	default 0,
pri_cob_aa			dec(16,2) 	default 0,
pri_dev_aa			dec(16,2) 	default 0,
no_pol_ren_ap		integer 	default 0,
no_pol_nue_ap		integer		default 0,
no_pol_tot_ap		integer 	default 0,
no_pol_ren_aa		integer 	default 0,
no_pol_nue_aa		integer		default 0,
no_pol_tot_aa		integer 	default 0,
com_pag_ap			dec(16,2)	default 0,
com_pag_aa			dec(16,2)	default 0,
sin_ocu_ap			integer		default 0,
sin_ocu_aa			integer		default 0,
sin_pag_ap			dec(16,2)	default 0,
sin_pag_aa			dec(16,2)	default 0,
sin_pen_ap			dec(16,2)	default 0,
sin_pen_aa			dec(16,2)	default 0,
sin_pen_dic			dec(16,2)	default 0,
pri_sus_ap			dec(16,2) 	default 0,
pri_sus_aa			dec(16,2) 	default 0,
sin_pen_12avos		dec(16,2)	default 0,
pri_sus_map			dec(16,2) 	default 0,
pri_sus_maa			dec(16,2) 	default 0,
no_pol_ren_ap_per	integer 	default 0,
no_pol_nue_ap_per	integer		default 0,
no_pol_ren_aa_per	integer 	default 0,
pri_sus_ap_mes		dec(16,2) 	default 0,
pri_sus_map_mes		dec(16,2) 	default 0,
pri_cob_ap_mes		dec(16,2) 	default 0,
pri_cob_neto_aa		dec(16,2) 	default 0,
sin_var_aa			dec(16,2) 	default 0,
sin_var_ap			dec(16,2) 	default 0,
pri_cob_maa			dec(16,2) 	default 0,
pri_cob_map			dec(16,2) 	default 0,
pri_dev_ap			dec(16,2) 	default 0,
pri_sus_ret_ap		dec(16,2) default 0,
pri_sus_can_ap 		dec(16,2) default 0,
pri_sus_ret_ap_mes	dec(16,2) default 0,
pri_sus_can_ap_mes	dec(16,2) default 0,
pri_sus_ret_aa		dec(16,2) default 0,
pri_sus_can_aa		dec(16,2) default 0,
pri_ret_map			dec(16,2) default 0,
pri_can_map			dec(16,2) default 0,
pri_ret_map_mes		dec(16,2) default 0,
pri_sus_can_map_mes	dec(16,2) default 0,
pri_ret_maa			dec(16,2) default 0,
pri_sus_can_maa		dec(16,2) default 0,
sin_ret_pag_ap      dec(16,2) default 0,
sin_ret_pag_aa      dec(16,2) default 0,
sin_ret_pen_aa		dec(16,2) default 0,
sin_ret_pen_ap		dec(16,2) default 0,
sin_ret_var_ap		dec(16,2) default 0,
sin_ret_var_aa		dec(16,2) default 0
) with no log;

-- Periodos de Comparacion

select par_periodo_ant,
	   par_periodo_act,
	   par_ase_lider,
	   fecha_cierre
  into _emi_periodo,
       _cob_periodo,
	   _cod_coasegur,
	   _fecha_cierre
  from parparam;  

-- Año Actual

if (today - _fecha_cierre) > 1 then
	let _per_fin_aa	= _cob_periodo;
else
	let _per_fin_aa	= _emi_periodo;
end if

let _n_subramo = ""; 

let _ano          = _per_fin_aa[1,4];
let _ano_act      = _ano;
let _per_ini_aa   = _ano || "-01";

let _fecha_ini_aa = MDY(1, 1, _ano);
let _fecha_fin_aa = sp_sis36(_per_fin_aa);

let _mes_evaluar  = _per_fin_aa[6,7];

let _fecha_hoy    = sp_sis36(_per_fin_aa);

if _fecha_hoy > today then
	let _fecha_hoy = today;
end if

-- Año Pasado

let _ano = _ano - 1;

let _per_fin_ap   = _ano || _per_fin_aa[5,7];
let _per_ini_ap   = _ano || "-01";

let _fecha_dic_ap = MDY(12, 31, _ano);
let _per_fin_dic  = _ano || "-12";

let _fecha_ini_ap = MDY(1, 1, _ano);
let _fecha_fin_ap = sp_sis36(_per_fin_ap);

let _fecha_evaluar = sp_bo078(_per_fin_aa, _per_fin_ap);

--**********************************
--Cambios Propuestos por Cruzabel
--**********************************
let _fecha_menos_ini = MDY(month(_fecha_fin_aa), 1, year(_fecha_fin_aa));
let _fecha_menos_ini = _fecha_menos_ini - 14 units month;

let _fecha_menos_fin = MDY(month(_fecha_fin_aa), 1, year(_fecha_fin_aa));
let _fecha_menos_fin = _fecha_menos_fin - 3 units month;
let _mes = month(_fecha_menos_fin);
if _mes = 2 then
	let _dia = 28;
	let _fecha_menos_fin = MDY(month(_fecha_menos_fin), _dia, year(_fecha_menos_fin));
else
	let _fecha_menos_fin = MDY(month(_fecha_menos_fin), day(_fecha_fin_aa), year(_fecha_menos_fin));
end if
--Año Pasado
let _ano = year(_fecha_menos_ini);
let _ano = _ano - 1;
let _fecha_menos_ini_ap = MDY(month(_fecha_menos_ini), day(_fecha_menos_ini), _ano);

let _ano = year(_fecha_menos_fin);
let _ano = _ano - 1;
let _fecha_menos_fin_ap = MDY(month(_fecha_menos_fin), day(_fecha_menos_fin), _ano);
--**************************************
-- Polizas Nuevas y Renovadas Año Pasado
--01/01/2018 - 30/04/2018

call sp_bo077_2(_fecha_ini_ap, _fecha_fin_ap) returning _error, _error_desc;

foreach
	select no_documento,
 	       sum(no_pol_nueva),
	       sum(no_pol_nueva_per),
		   sum(no_pol_renov),
		   sum(no_pol_renov_per)
	  into _no_documento,
		   _no_pol_nue_ap,			--Nueva Año Anterior
		   _no_pol_nue_ap_per,
		   _no_pol_ren_ap,
		   _no_pol_ren_ap_per
	  from tmp_persis
	 group by no_documento

	if _no_documento[1,2] = "18" then
		let _no_pol_nue_ap_per = 0;
		let _no_pol_ren_ap_per = 0;
	end if
	insert into tmp_multi(
	no_documento, 
	no_pol_nue_ap, 
	no_pol_nue_ap_per,
	no_pol_ren_ap,
	no_pol_ren_ap_per
	)
	values(
	_no_documento, 
	_no_pol_nue_ap,
	_no_pol_nue_ap_per,
	_no_pol_ren_ap,
	_no_pol_ren_ap_per
	);
end foreach
drop table tmp_persis;

-- Polizas Nuevas y Renovadas Año Actual
-- '01/01/2019' - '30/04/2019'

{call sp_bo077_2(_fecha_ini_aa, _fecha_fin_aa) returning _error, _error_desc;

foreach
 select no_documento,
        sum(no_pol_nueva),
		sum(no_pol_renov),
		sum(no_pol_renov_per)
   into _no_documento,
		_no_pol_nue_aa,
		_no_pol_ren_aa,
		_no_pol_ren_aa_per
   from tmp_persis
  group by no_documento
  
	if _no_documento[1,2] = "18" then
		let _no_pol_ren_aa_per = 0;
	end if

		insert into tmp_multi(
		no_documento, 
		no_pol_nue_aa, 
		no_pol_ren_aa,
		no_pol_ren_aa_per
		)
		values(
		_no_documento, 
		_no_pol_nue_aa,			--Nueva Año Actual
		_no_pol_ren_aa,
		_no_pol_ren_aa_per
		);

end foreach
drop table tmp_persis;

--*********************************************
-- Polizas Nuevas y Renovadas Año Pasado SALUD
--01/02/2017 - 30/01/2018

call sp_bo077_2(_fecha_menos_ini_ap, _fecha_menos_fin_ap) returning _error, _error_desc;

foreach
	select no_documento,
	       sum(no_pol_nueva_per),
		   sum(no_pol_renov_per)
	  into _no_documento,
		   _no_pol_nue_ap_per,
		   _no_pol_ren_ap_per
	  from tmp_persis
	 where no_documento[1,2] = '18'
	 group by no_documento

	insert into tmp_multi(
	no_documento, 
	no_pol_nue_ap_per,
	no_pol_ren_ap_per
	)
	values(
	_no_documento, 
	_no_pol_nue_ap_per,
	_no_pol_ren_ap_per
	);
end foreach
drop table tmp_persis;

-- Polizas Renovadas Año Actual
-- '01/02/2018' - '30/01/2019'

call sp_bo077_2(_fecha_menos_ini, _fecha_menos_fin) returning _error, _error_desc;

foreach
	select no_documento,
	       sum(no_pol_renov_per)
	  into _no_documento,
	       _no_pol_ren_aa_per
	  from tmp_persis
     where no_documento[1,2] = '18'
	 group by no_documento
  
	insert into tmp_multi(
	no_documento, 
	no_pol_ren_aa_per
	)
	values(
	_no_documento, 
	_no_pol_ren_aa_per
	);

end foreach
drop table tmp_persis;

let _pos_ramo = 1;
foreach								--Se agrego este ciclo, debido a que arrojaba error -229 debido a la cantidad de registros almacenado al momento de hacer el sum. 03/12/2015
	select distinct no_documento[1,2]
	  into _ramo
	  from tmp_multi
	 where no_documento[1,2] = '18' 

	foreach
		select no_documento,		--1
			   sum(no_pol_ren_ap),	--2
			   sum(no_pol_nue_ap),	--3
			   sum(no_pol_tot_ap),	--4
			   sum(no_pol_ren_aa),	--5
			   sum(no_pol_nue_aa),	--6
			   sum(no_pol_tot_aa),	--7
			   sum(no_pol_ren_ap_per),	--8
			   sum(no_pol_nue_ap_per),	--9
			   sum(no_pol_ren_aa_per)	--10
		  into _no_documento,		--1
			   _no_pol_ren_ap,		--2
			   _no_pol_nue_ap,		--3
			   _no_pol_tot_ap,		--4
			   _no_pol_ren_aa,		--5
			   _no_pol_nue_aa,		--6
			   _no_pol_tot_aa,		--7
			   _no_pol_ren_ap_per,	--8
			   _no_pol_nue_ap_per,	--9
			   _no_pol_ren_aa_per	--10
		  from tmp_multi
		 where no_documento[1,2] = _ramo
		 group by no_documento

		-- Validaciones para Persistencia

		if _no_pol_ren_ap_per > 1 then
			let _no_pol_ren_ap_per = 1;
		end if

		if _no_pol_nue_ap_per > 1 then
			let _no_pol_nue_ap_per = 1;
		end if

		if _no_pol_ren_aa_per > 1 then
			let _no_pol_ren_aa_per = 1;
		end if

		if _no_pol_ren_aa_per = 1 and 
		   _no_pol_ren_ap_per = 0 and 
		   _no_pol_nue_ap_per = 0 then
			let _no_pol_ren_ap_per = 1;
		end if

		if _no_pol_ren_ap_per = 1 and 
		   _no_pol_nue_ap_per = 1 then
			let _no_pol_nue_ap_per = 0;
		end if

		-- Año Pasado

		if _no_pol_ren_ap > 1 then
			let _no_pol_ren_ap = 1;
		end if

		if _no_pol_nue_ap > 1 then
			let _no_pol_nue_ap = 1;
		end if

		let _no_pol_tot_ap = _no_pol_ren_ap + _no_pol_nue_ap;

		if _no_pol_tot_ap > 1 then
			let _no_pol_tot_ap = 1;
			let _no_pol_ren_ap = 0;
		end if

		-- Año Actual

		if _no_pol_ren_aa > 1 then
			let _no_pol_ren_aa = 1;
		end if

		if _no_pol_nue_aa > 1 then
			let _no_pol_nue_aa = 1;
		end if

		let _no_pol_tot_aa = _no_pol_ren_aa + _no_pol_nue_aa;

		if _no_pol_tot_aa > 1 then
			let _no_pol_tot_aa = 1;
			let _no_pol_ren_aa = 0;
		end if

		if _no_pol_ren_aa > _no_pol_tot_ap then
			let _no_pol_ren_aa = 0;
			let _no_pol_nue_aa = 1;
		end if		

		-- Informacion Necesaria para las Promotorias

		select sucursal_promotoria,
			   centro_costo
		  into _suc_promotoria,
			   _centro_costo
		  from insagen
		 where codigo_agencia = _cod_agencia;

		select descripcion
		  into _nombre_agencia
		  from insagen
		 where codigo_agencia = _centro_costo;

		foreach
		 select cod_agente
		   into _cod_agente
		   from emipoagt
		  where no_poliza = _no_poliza
		  order by porc_partic_agt desc
			exit foreach;
		end foreach

		select nombre
		  into _nombre_agente
		  from agtagent
		 where cod_agente = _cod_agente;

		select cod_vendedor
		  into _cod_vendedor
		  from parpromo
		 where cod_agente  = _cod_agente
		   and cod_agencia = _suc_promotoria
		   and cod_ramo	   = _cod_ramo;

		select nombre
		  into _nombre_vendedor
		  from agtvende
		 where cod_vendedor = _cod_vendedor;
		 
		select exigible into _exigible from emipoliza where no_documento = _no_documento;
		if _exigible is null then
			let _exigible = 0.00;
		end if
		let _comis_cobranza = 0.00;
		select sum(comision)
		  into _comis_cobranza
		  from chqboni
		 where no_documento = _no_documento
           and cod_agente   = _cod_agente
           and periodo      >= _per_ini_aa
		   and periodo      <= _emi_periodo;  --tiene el periodo anterior
		if _comis_cobranza is null then
			let _comis_cobranza = 0.00;
		end if
		let _comis_web = 0.00;
		select sum(comision)
		  into _comis_web
		  from chqweb
		 where no_documento = _no_documento
           and cod_agente   = _cod_agente
           and periodo      >= _per_ini_aa
		   and periodo      <= _emi_periodo;
		if _comis_web is null then
			let _comis_web = 0.00;
		end if
		--colocar la programacion para los gastos
		select nombre into _n_subramo from prdsubra where cod_ramo = _cod_ramo and cod_subramo = _cod_subramo;
		
		insert into deivid_bo:boindmul(
		no_documento,
		pri_cob_ap,
		pri_cob_aa,
		pri_dev_aa,
		no_pol_ren_ap,
		no_pol_nue_ap,
		no_pol_tot_ap,
		no_pol_ren_aa,
		no_pol_nue_aa,
		no_pol_tot_aa,
		no_poliza,
		com_pag_ap,
		com_pag_aa,
		sin_ocu_ap,
		sin_ocu_aa,
		sin_pag_ap,
		sin_pag_aa,
		sin_pen_ap,
		sin_pen_dic,
		sin_pen_aa,
		pri_sus_ap,
		pri_sus_aa,
		sin_pen_12avos,
		periodo,
		pos_ramo,
		nombre_vendedor,
		nombre_agente,
		cod_ramo,
		nombre_ramo,
		cod_agencia,
		nombre_agencia,
		sucursal_promotoria,
		pri_sus_map,
		pri_sus_maa,
		no_pol_ren_ap_per,
		no_pol_nue_ap_per,
		no_pol_ren_aa_per,
		pri_sus_ap_mes,
		pri_sus_map_mes,
		pri_cob_ap_mes,
		pri_cob_neto_aa,
		sin_var_aa,
		sin_var_ap,
		pri_cob_maa,
		pri_cob_map,
		pri_dev_ap,
		sin_ocu_ap_tu,
		sin_ocu_aa_tu,
		cod_subramo,
		pri_sus_ret_aa,
		sin_ret_pag_aa,
		sin_ret_var_aa,
		pri_sus_ret_ap,
		sin_ret_pag_ap,
		sin_ret_var_ap,
		colectivo
		)
		values (
		_no_documento,
		_pri_cob_ap,
		_pri_cob_aa,
		_pri_dev_aa,
		_no_pol_ren_ap,
		_no_pol_nue_ap,
		_no_pol_tot_ap,
		_no_pol_ren_aa,
		_no_pol_nue_aa,
		_no_pol_tot_aa,
		_no_poliza,
		_com_pag_ap,
		_com_pag_aa,
		_sin_ocu_ap,
		_sin_ocu_aa,
		_sin_pag_ap,
		_sin_pag_aa,
		_sin_pen_ap,
		_sin_pen_dic,
		_sin_pen_aa,
		_pri_sus_ap,
		_pri_sus_aa,
		_sin_pen_12avos,
		_per_fin_aa,
		_pos_ramo,
		_nombre_vendedor,
		_nombre_agente,
		_cod_ramo,
		_nombre_ramo,
		_centro_costo,
		_nombre_agencia,
		_nombre_promot,
		_pri_sus_map,
		_pri_sus_maa,
		_no_pol_ren_ap_per,
		_no_pol_nue_ap_per,
		_no_pol_ren_aa_per,
		_pri_sus_ap_mes,
		_pri_sus_map_mes,
		_pri_cob_ap_mes,
		_pri_cob_neto_aa,
		_sin_var_aa,
		_sin_var_ap,
		_pri_cob_maa,
		_pri_cob_map,
		_pri_dev_ap,
		_sin_ocu_ap_tu,
		_sin_ocu_aa_tu,
		_n_subramo,
		_pri_sus_ret_aa,
		_sin_ret_pag_aa,
		_sin_ret_var_aa,
		_pri_sus_ret_ap,
		_sin_ret_pag_ap,
		_sin_ret_var_ap,
		_colectivo
		);
	end foreach
end foreach
drop table tmp_multi;}
end
return 0, "Actualizacion Exitosa";

end procedure
