-- Procedimiento que carga el Reporte de Indicadores para Multinacional
 
-- Creado     :	13/11/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo043amm;		
create procedure sp_bo043amm()
returning date,date,date,char(7),char(7),char(7),char(7);

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
define _dias1				integer;
define _dias2				integer;

define _nueva_renov		char(1);
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
define _mes,_dia           integer;
define _fecha_menos_ini_ap date;
define _fecha_menos_fin_ap date;


--set debug file to "sp_bo043.trc";

set isolation to dirty read;

begin

-- Definiciones Iniciales

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

--Correr un periodo especifico 
--let _per_fin_aa = "2019-10";

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

let _dia = day(_fecha_fin_aa);
if _mes = 2 then
	let _dia = 28;
	let _fecha_menos_fin = MDY(month(_fecha_menos_fin), _dia, year(_fecha_menos_fin));
else
    if _mes in(4,6,9,11) And day(_fecha_fin_aa) = 31 then
		let _dia = 30;
	end if
	let _fecha_menos_fin = MDY(month(_fecha_menos_fin), _dia, year(_fecha_menos_fin));
end if
--Año Pasado
let _ano = year(_fecha_menos_ini);
let _ano = _ano - 1;
let _fecha_menos_ini_ap = MDY(month(_fecha_menos_ini), day(_fecha_menos_ini), _ano);

let _ano = year(_fecha_menos_fin);
let _ano = _ano - 1;
let _fecha_menos_fin_ap = MDY(month(_fecha_menos_fin), day(_fecha_menos_fin), _ano);

return _fecha_menos_ini,_fecha_menos_fin,_fecha_fin_aa,_per_ini_ap,_per_fin_ap,_per_ini_aa,_per_fin_aa;
end 
end procedure
