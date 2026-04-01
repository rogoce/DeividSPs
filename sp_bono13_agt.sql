--************************************************************************************************************
-- Procedimiento que genera la tabla con la información para el Bono de Productividad para Comercializacion
--************************************************************************************************************
--execute procedure sp_bono13(2017,2,'DRODRIGU') *** Especial para sucursal, se sobreescribio en el original sp_bono13

drop procedure sp_bono13;
create procedure sp_bono13(a_ano smallint, a_trimestre smallint, a_usuario char(8))
returning	varchar(50) as Vendedor,
			dec(16,2)	as Prima_Cobrada_Nueva_AA,
			dec(16,2)	as Prima_Cobrada_Nueva_AP,
			dec(16,2)	as Prima_Cobrada_Total_AA,
			dec(16,2)	as Siniestros_Incurridos,
			dec(16,2)	as Prima_Susc_Nueva_AA,
			dec(16,2)	as Prima_Susc_Nueva_AP,
			dec(16,2)	as Presupuesto_Nuevas,
			integer		as Tot_Pol_Nuevas_AA, 
			integer		as Tot_Pol_Nuevas_AP,
			integer		as Tot_Pol_Renov_AA,	
			integer		as Tot_Pol_Renov_AP,  
			integer		as Filt_Pol_Renov_AA, 
			integer		as Filt_Pol_Nueva_AP, 
			integer		as Filt_Pol_Renov_AP, 
			dec(5,2)	as Crecimiento_Pri_Cob_Nue,
			smallint	as Flag_Meta1,
			dec(5,2)	as Cumplimiento_Presupuesto,
			smallint	as Flag_Meta2,
			dec(5,2)	as Persistencia,
			smallint	as Flag_Meta3,
			dec(5,2)	as Siniestralidad,
			smallint	as Flag_Meta4,
			smallint	as Tot_Metas; 

define _filtros					varchar(255);
define _n_cliente				varchar(100);
define _nom_vendedor			varchar(50);
define _nombre_ramo				varchar(50);
define _error_desc				varchar(50);
define _periodo_desde			char(7);
define _periodo_hasta			char(7);
define _periodo_inic			char(7);
define _cod_vendedor			char(3);
define _cod_agente				char(5);
define _cod_ramo				char(3);
define _nueva_renov				char(1);
define _tipo					char(1);
define _cumpl_presupuesto		dec(5,2);
define _siniestralidad			dec(5,2);
define _persistencia			dec(5,2);
define _crec_pcn				dec(5,2);
define _meta1					dec(5,2);
define _meta2					dec(5,2);
define _meta3					dec(5,2);
define _meta4					dec(5,2);
define _tot_presupuesto_nuevas	dec(16,2);
define _tot_prima_suscrita_ap	dec(16,2);
define _tot_no_pol_ren_aa_per	dec(16,2);
define _tot_no_pol_nue_ap_per	dec(16,2);
define _tot_no_pol_ren_ap_per	dec(16,2);
define _tot_pri_cob_nue_aa		dec(16,2);
define _tot_pri_cob_nue_ap		dec(16,2);
define _tot_tot_pri_cob_aa		dec(16,2);
define _tot_prima_suscrita		dec(16,2);
define _tot_no_pol_nue_aa		dec(16,2);
define _tot_no_pol_nue_ap		dec(16,2);
define _tot_no_pol_ren_aa		dec(16,2);
define _tot_no_pol_ren_ap		dec(16,2);
define _prima_suscrita_ap		dec(16,2);
define _presupuesto_nuevas		dec(16,2);
define _pri_cob_nue_aa			dec(16,2);
define _pri_cob_nue_ap			dec(16,2);
define _prima_suscrita			dec(16,2);
define _tot_pri_cob_aa			dec(16,2);
define _prima_sus_pag			dec(16,2);
define _tot_sini_incu			dec(16,2);
define _pri_pag_ap				dec(16,2);
define _sin_pag_aa				dec(16,2);
define _sin_pen_aa				dec(16,2);
define _sini_incu				dec(16,2);
define _monto					dec(16,2);
define _flag_meta1				smallint; 
define _flag_meta2				smallint; 
define _flag_meta3				smallint; 
define _flag_meta4				smallint; 
define _tot_metas				smallint;
define _flag_tot				smallint; 
define _no_pol_nue_ap_per		integer;
define _no_pol_ren_aa_per		integer;
define _no_pol_ren_ap_per		integer;
define _no_pol_ren_ap			integer;
define _no_pol_nue_aa			integer;
define _no_pol_nue_ap			integer;
define _no_pol_ren_aa			integer;
define _error_isam				integer;
define _error					integer;
define _vigencia_final			date;
define _vigencia_inic			date;
define _fecha_aa_ini			date;
define _fecha_ap_ini			date;
define _fecha_cierre			date;
define _fecha_fin_ap			date;
define _fecha_aa				date;
define _fecha_ap				date;
define _fecha					date;
define _fecha_proceso			datetime year to fraction(5);

define _tsuc_pri_cob_nue_aa		dec(16,2);
define _tsuc_pri_cob_nue_ap		dec(16,2);
define _tsuc_tot_pri_cob_aa		dec(16,2);
define _tsuc_prima_suscrita		dec(16,2);
define _tsuc_prima_suscrita_ap	dec(16,2);		
define _tsuc_no_pol_nue_aa		dec(16,2);	
define _tsuc_no_pol_nue_ap		dec(16,2);
define _tsuc_no_pol_ren_aa		dec(16,2);
define _tsuc_no_pol_ren_ap		dec(16,2);
define _tsuc_no_pol_ren_aa_per	dec(16,2);
define _tsuc_no_pol_nue_ap_per	dec(16,2);
define _tsuc_no_pol_ren_ap_per	dec(16,2);
define _tsuc_sini_incu			dec(16,2);
define _tsuc_presupuesto_nuevas	dec(16,2);

define _cod_agente_tmp  char(5);

let _meta1 = 0.15;
let _meta2 = 1.00;
let _meta3 = 0.80;
let _meta4 = 0.55;
let _flag_tot = 0;

--return 0; 

--set debug file to "sp_bono13.trc";
--trace on;

{return	'',
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0.00,
			0,
			0.00,
			0,
			0.00,
			0,
			0.00,
			0,
			0;}

select min(periodo1)
  into _periodo_desde
  from tribono
 where ano = a_ano;

select periodo1,
	   periodo3
  into _periodo_inic,
	   _periodo_hasta
  from tribono
 where ano = a_ano 
   and trimestre = a_trimestre;

begin 
on exception set _error, _error_isam, _error_desc
	return	_error_desc,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			0.00,
			_error,
			0,
			0,
			0,
			0,
			0,
			0,
			0.00,
			0,
			0.00,
			0,
			0.00,
			0,
			0.00,
			0,
			0;--,current;
end exception

drop table if exists tmp_bono_comerc;
create temp table tmp_bono_comerc(
cod_vendedor		char(5),
nombre_vendedor		varchar(30),
pri_cob_nueva_aa	dec(16,2) 	default 0,
pri_cob_nueva_ap	dec(16,2) 	default 0,
pri_cob_tot_aa		dec(16,2) 	default 0,
pri_sus_aa			dec(16,2) 	default 0,
pri_sus_ap			dec(16,2) 	default 0,
no_pol_nue_aa		integer		default 0,
no_pol_nue_ap		integer		default 0,
no_pol_ren_aa		integer 	default 0,
no_pol_ren_ap		integer 	default 0,
no_pol_ren_aa_per	integer		default 0,
no_pol_nue_ap_per	integer		default 0,
no_pol_ren_ap_per	integer		default 0,
incurrido	      	dec(16,2) 	default 0,
primary key (cod_vendedor)) with no log;

select cod_vendedor
  into _cod_vendedor
  from agtvende
 where usuario = a_usuario
   and activo = 1;

if _cod_vendedor is null then
	let _cod_vendedor = '';
end if

let _filtros = '';

if _cod_vendedor = '' then
	let _flag_tot = 1;
    --Se excluye 070 Rodolfo correo de Anette 16/10/18
	foreach
		select cod_vendedor
		  into _cod_vendedor
		  from agtvende
		 where cod_vendedor not in ('047','041','071','072','073','074','075','076','077','069')  --se quita 050 de esta linea, por instr. de Analisa correo 15/10/2018		  //HGIRON: solicitud no mostrar '071','072','073','074','075','076','077' JBRITO 05/04/2019
		 -- Caso F9:33488 habilitar 070-Rodolfo Combe :RGORDON

		let _filtros = _filtros || trim(_cod_vendedor) || ',';
	end foreach

	let _filtros = _filtros || ';';
else
	let _filtros = _cod_vendedor || ';';
end if

drop table if exists tmp_codigos;
let _tipo = sp_sis04(_filtros); -- separa los valores del string

foreach --with hold
	select cod_agente,
		   cod_ramo,
		   nombre_vendedor,
		   nueva_renov,
		   pri_pag_aa,
		   pri_pag_ap,
		   prima_suscrita,
		   prima_suscrita_ap,
		   sinis_inc,
		   no_pol_nue_aa,
		   no_pol_nue_ap,
		   no_pol_ren_aa,
		   no_pol_ren_ap,
		   vigenteap_per,
		   renovaa_per,
		   renovap_per
	  into _cod_agente,
		   _cod_ramo,
		   _nom_vendedor,
		   _nueva_renov,
		   _tot_pri_cob_aa,
		   _pri_pag_ap,
		   _prima_suscrita,
		   _prima_suscrita_ap,
		   _sini_incu,
		   _no_pol_nue_aa,
		   _no_pol_nue_ap,
		   _no_pol_ren_aa,
		   _no_pol_ren_ap,
		   _no_pol_nue_ap_per,
		   _no_pol_ren_aa_per,
		   _no_pol_ren_ap_per
	  from bono_comerc
	 where periodo between _periodo_desde and _periodo_hasta
	   and cod_ramo <> '008'
	 order by 1

	--begin work;
    {if _cod_vendedor = '050' then
		let _nom_vendedor = 'ZONA 4 - RICARDO ACEVEDO';  --JBRITO:04/02/2020 INACTIVAR RACEVEDO
	end if}
	if _cod_ramo = '016' then
		let _no_pol_nue_aa = 0;
		let _no_pol_nue_ap = 0;
		let _no_pol_ren_aa = 0;
		let _no_pol_ren_ap = 0;
		let _no_pol_nue_ap_per = 0;
		let _no_pol_ren_aa_per = 0;
		let _no_pol_ren_ap_per = 0;
	end if

	let _pri_cob_nue_ap = 0.00;
	let _pri_cob_nue_aa = 0.00;

	if _nueva_renov = 'N' then
		let _pri_cob_nue_ap = _pri_pag_ap;
		let _pri_cob_nue_aa = _tot_pri_cob_aa;
	end if
	
	--********  Unificacion de Agente *******16/11/2020JBRITO
	let _cod_agente_tmp = _cod_agente;
	call sp_che168(_cod_agente_tmp) returning _error,_cod_agente;	
	
	begin
		on exception in(-239)
			update tmp_bono_comerc
			   set pri_cob_nueva_aa = pri_cob_nueva_aa + _pri_cob_nue_aa,
				   pri_cob_nueva_ap = pri_cob_nueva_ap + _pri_cob_nue_ap,
				   pri_cob_tot_aa = pri_cob_tot_aa +_tot_pri_cob_aa,
				   pri_sus_aa = pri_sus_aa + _prima_suscrita,
				   pri_sus_ap = pri_sus_ap + _prima_suscrita_ap,
				   no_pol_nue_aa = no_pol_nue_aa + _no_pol_nue_aa,
				   no_pol_nue_ap = no_pol_nue_ap + _no_pol_nue_ap,
				   no_pol_ren_aa = no_pol_ren_aa + _no_pol_ren_aa,
				   no_pol_ren_ap = no_pol_ren_ap + _no_pol_ren_ap,
				   no_pol_ren_aa_per = no_pol_ren_aa_per + _no_pol_ren_aa_per,
				   no_pol_nue_ap_per = no_pol_nue_ap_per + _no_pol_nue_ap_per,
				   no_pol_ren_ap_per = no_pol_ren_ap_per + _no_pol_ren_ap_per,
				   incurrido = incurrido + _sini_incu
			 where cod_vendedor = _cod_agente;
		end exception

		insert into tmp_bono_comerc(
				cod_vendedor,
				nombre_vendedor,
				pri_cob_nueva_aa,
				pri_cob_nueva_ap,
				pri_cob_tot_aa,
				pri_sus_aa,
				pri_sus_ap,
				no_pol_nue_aa,
				no_pol_nue_ap,
				no_pol_ren_aa,
				no_pol_ren_ap,
				no_pol_ren_aa_per,
				no_pol_nue_ap_per,
				no_pol_ren_ap_per,
				incurrido)
		values(	_cod_agente,
				_nom_vendedor,
				_pri_cob_nue_aa,
				_pri_cob_nue_ap,
				_tot_pri_cob_aa,
				_prima_suscrita,
				_prima_suscrita_ap,
				_no_pol_nue_aa,
				_no_pol_nue_ap,
				_no_pol_ren_aa,
				_no_pol_ren_ap,
				_no_pol_ren_aa_per,
				_no_pol_nue_ap_per,
				_no_pol_ren_ap_per,
				_sini_incu);
	end 
	
	--commit work;
end foreach

let _tot_prima_suscrita_ap = 0.00;
let _tot_no_pol_ren_aa_per = 0.00;
let _tot_no_pol_nue_ap_per = 0.00;
let _tot_no_pol_ren_ap_per = 0.00;
let _tot_pri_cob_nue_aa = 0.00;
let _tot_pri_cob_nue_ap = 0.00;
let _tot_tot_pri_cob_aa = 0.00;
let _tot_prima_suscrita = 0.00;
let _tot_no_pol_nue_aa = 0.00;
let _tot_no_pol_nue_ap = 0.00;
let _tot_no_pol_ren_aa = 0.00;
let _tot_no_pol_ren_ap = 0.00;
let _tot_sini_incu = 0.00;
let _tot_presupuesto_nuevas = 0.00;

let _tsuc_prima_suscrita_ap = 0.00;
let _tsuc_no_pol_ren_aa_per = 0.00;
let _tsuc_no_pol_nue_ap_per = 0.00;
let _tsuc_no_pol_ren_ap_per = 0.00;
let _tsuc_pri_cob_nue_aa = 0.00;
let _tsuc_pri_cob_nue_ap = 0.00;
let _tsuc_tot_pri_cob_aa = 0.00;
let _tsuc_prima_suscrita = 0.00;
let _tsuc_no_pol_nue_aa = 0.00;
let _tsuc_no_pol_nue_ap = 0.00;
let _tsuc_no_pol_ren_aa = 0.00;
let _tsuc_no_pol_ren_ap = 0.00;
let _tsuc_sini_incu = 0.00;
let _tsuc_presupuesto_nuevas = 0.00;


foreach
	select cod_vendedor,
		   nombre_vendedor,
		   pri_cob_nueva_aa,
		   pri_cob_nueva_ap,
		   pri_cob_tot_aa,
		   pri_sus_aa,
		   pri_sus_ap,
		   no_pol_nue_aa,
		   no_pol_nue_ap,
		   no_pol_ren_aa,
		   no_pol_ren_ap,
		   no_pol_ren_aa_per,
		   no_pol_nue_ap_per,
		   no_pol_ren_ap_per,
		   incurrido
	  into _cod_agente,
		   _nom_vendedor,
		   _pri_cob_nue_aa,
		   _pri_cob_nue_ap,
		   _tot_pri_cob_aa,
		   _prima_suscrita,
		   _prima_suscrita_ap,
		   _no_pol_nue_aa,
		   _no_pol_nue_ap,
		   _no_pol_ren_aa,
		   _no_pol_ren_ap,
		   _no_pol_ren_aa_per,
		   _no_pol_nue_ap_per,
		   _no_pol_ren_ap_per,
		   _sini_incu
	  from tmp_bono_comerc
	 order by 2

	select sum(ventas_nuevas)
	  into _presupuesto_nuevas
	  from deivid_bo:preventas
	 where cod_agente = _cod_agente
	   and cod_ramo <> '008'
	   and periodo between _periodo_desde and _periodo_hasta;

	if _presupuesto_nuevas is null then
		let _presupuesto_nuevas = 0.00;
	end if
	
	select nombre
	  into _nom_vendedor
	  from agtagent
	 where cod_agente = _cod_agente;

	let _cumpl_presupuesto = 0.00;
	let _siniestralidad = 0.00;
	let _persistencia = 0.00;
	let _crec_pcn = 0.00;
	let _flag_meta1 = 0;
	let _flag_meta2 = 0;
	let _flag_meta3 = 0;
	let _flag_meta4 = 0;
	let _tot_metas = 0;

	if _pri_cob_nue_ap <> 0.00 then
		let _crec_pcn = round((_pri_cob_nue_aa/_pri_cob_nue_ap) -1,2); --Crecimiento de Prima Cobrada Nueva
	end if

	if _crec_pcn >= _meta1 then
		let _flag_meta1 = 1;
	end if

	if _presupuesto_nuevas <> 0.00 then
		let _cumpl_presupuesto = round(_prima_suscrita/_presupuesto_nuevas,2); --% de Cumplimiento de Presupuesto Nuevas
	end if

	if _cumpl_presupuesto >= _meta2 then 
		let _flag_meta2 = 1;
	end if

	if (_no_pol_nue_ap_per + _no_pol_ren_ap_per) <> 0 then
		let _persistencia = round(_no_pol_ren_aa_per/(_no_pol_nue_ap_per + _no_pol_ren_ap_per),2); --Persistencia
	end if

	if _persistencia >= _meta3 then
		let _flag_meta3 = 1;
	end if

	if _tot_pri_cob_aa <> 0.00 then
		let _siniestralidad = round(_sini_incu/_tot_pri_cob_aa,2); --Siniestralidad
	end if

	if _siniestralidad <= _meta4 then
		let _flag_meta4 = 1;
	end if

	let _tot_metas = _flag_meta1 + _flag_meta2 + _flag_meta3 + _flag_meta4;

	let _tot_pri_cob_nue_aa = _tot_pri_cob_nue_aa + _pri_cob_nue_aa;
	let _tot_pri_cob_nue_ap = _tot_pri_cob_nue_ap + _pri_cob_nue_ap;
	let _tot_tot_pri_cob_aa = _tot_tot_pri_cob_aa + _tot_pri_cob_aa;
	let _tot_prima_suscrita = _tot_prima_suscrita + _prima_suscrita;
	let _tot_prima_suscrita_ap = _tot_prima_suscrita_ap + _prima_suscrita_ap;
	let _tot_no_pol_nue_aa = _tot_no_pol_nue_aa + _no_pol_nue_aa;
	let _tot_no_pol_nue_ap = _tot_no_pol_nue_ap + _no_pol_nue_ap;
	let _tot_no_pol_ren_aa = _tot_no_pol_ren_aa + _no_pol_ren_aa;
	let _tot_no_pol_ren_ap = _tot_no_pol_ren_ap + _no_pol_ren_ap;
	let _tot_no_pol_ren_aa_per = _tot_no_pol_ren_aa_per + _no_pol_ren_aa_per;
	let _tot_no_pol_nue_ap_per = _tot_no_pol_nue_ap_per + _no_pol_nue_ap_per;
	let _tot_no_pol_ren_ap_per = _tot_no_pol_ren_ap_per + _no_pol_ren_ap_per;
	let _tot_sini_incu = _tot_sini_incu + _sini_incu;
	let _tot_presupuesto_nuevas = _tot_presupuesto_nuevas + _presupuesto_nuevas;
	
	{if trim(_cod_vendedor) in ('041','055','058') then
		let _tsuc_pri_cob_nue_aa = _tsuc_pri_cob_nue_aa + _pri_cob_nue_aa;
		let _tsuc_pri_cob_nue_ap = _tsuc_pri_cob_nue_ap + _pri_cob_nue_ap;
		let _tsuc_tot_pri_cob_aa = _tsuc_tot_pri_cob_aa + _tot_pri_cob_aa;
		let _tsuc_prima_suscrita = _tsuc_prima_suscrita + _prima_suscrita;
		let _tsuc_prima_suscrita_ap = _tsuc_prima_suscrita_ap + _prima_suscrita_ap;
		let _tsuc_no_pol_nue_aa = _tsuc_no_pol_nue_aa + _no_pol_nue_aa;
		let _tsuc_no_pol_nue_ap = _tsuc_no_pol_nue_ap + _no_pol_nue_ap;
		let _tsuc_no_pol_ren_aa = _tsuc_no_pol_ren_aa + _no_pol_ren_aa;
		let _tsuc_no_pol_ren_ap = _tsuc_no_pol_ren_ap + _no_pol_ren_ap;
		let _tsuc_no_pol_ren_aa_per = _tsuc_no_pol_ren_aa_per + _no_pol_ren_aa_per;
		let _tsuc_no_pol_nue_ap_per = _tsuc_no_pol_nue_ap_per + _no_pol_nue_ap_per;
		let _tsuc_no_pol_ren_ap_per = _tsuc_no_pol_ren_ap_per + _no_pol_ren_ap_per;
		let _tsuc_sini_incu = _tsuc_sini_incu + _sini_incu;
		let _tsuc_presupuesto_nuevas = _tsuc_presupuesto_nuevas + _presupuesto_nuevas;
	end if}

	return	_nom_vendedor,
			_pri_cob_nue_aa,
			_pri_cob_nue_ap,
			_tot_pri_cob_aa,
			_sini_incu,
			_prima_suscrita,
			_prima_suscrita_ap,
			_presupuesto_nuevas,
			_no_pol_nue_aa,
			_no_pol_nue_ap,
			_no_pol_ren_aa,
			_no_pol_ren_ap,
			_no_pol_ren_aa_per,
			_no_pol_nue_ap_per,
			_no_pol_ren_ap_per,
			_crec_pcn,
			_flag_meta1,
			_cumpl_presupuesto,
			_flag_meta2,
			_persistencia,
			_flag_meta3,
			_siniestralidad,
			_flag_meta4,
			_tot_metas with resume;
end foreach
{
--Cálculo del total para la meta de la Gerencia Sucursal
if _flag_tot = 1 then
	
	let _nom_vendedor = 'GERENCIA SUCURSAL';
	let _flag_meta1 = 0;
	let _flag_meta2 = 0;
	let _flag_meta3 = 0;
	let _flag_meta4 = 0;
	let _tot_metas = 0;

	let _crec_pcn = round((_tsuc_pri_cob_nue_aa/_tsuc_pri_cob_nue_ap) -1,2); --Crecimiento de Prima Cobrada Nueva

	if _crec_pcn >= _meta1 then
		let _flag_meta1 = 1;
	end if

	let _cumpl_presupuesto = round(_tsuc_prima_suscrita/_tsuc_presupuesto_nuevas,2); --% de Cumplimiento de Presupuesto Nuevas

	if _cumpl_presupuesto >= _meta2 then 
		let _flag_meta2 = 1;
	end if

	let _persistencia = round(_tsuc_no_pol_ren_aa_per/(_tsuc_no_pol_nue_ap_per + _tsuc_no_pol_ren_ap_per),2); --Persistencia

	if _persistencia >= _meta3 then
		let _flag_meta3 = 1;
	end if

	let _siniestralidad = round(_tsuc_sini_incu/_tsuc_tot_pri_cob_aa,2); --Siniestralidad

	if _siniestralidad <= _meta4 then
		let _flag_meta4 = 1;
	end if

	let _tot_metas = _flag_meta1 + _flag_meta2 + _flag_meta3 + _flag_meta4;
	
	return	_nom_vendedor,
			_tsuc_pri_cob_nue_aa,
			_tsuc_pri_cob_nue_ap,
			_tsuc_tot_pri_cob_aa,
			_tsuc_sini_incu,
			_tsuc_prima_suscrita,
			_tsuc_prima_suscrita_ap,
			_tsuc_presupuesto_nuevas,
			_tsuc_no_pol_nue_aa,
			_tsuc_no_pol_nue_ap,
			_tsuc_no_pol_ren_aa,
			_tsuc_no_pol_ren_ap,
			_tsuc_no_pol_ren_aa_per,
			_tsuc_no_pol_nue_ap_per,
			_tsuc_no_pol_ren_ap_per,
			_crec_pcn,
			_flag_meta1,
			_cumpl_presupuesto,
			_flag_meta2,
			_persistencia,
			_flag_meta3,
			_siniestralidad,
			_flag_meta4,
			_tot_metas with resume;
end if
}
--Cálculo del total para la meta de la Gerencia Comercial
if _flag_tot = 1 then
	
	let _nom_vendedor = 'TOTAL';
	let _flag_meta1 = 0;
	let _flag_meta2 = 0;
	let _flag_meta3 = 0;
	let _flag_meta4 = 0;
	let _tot_metas = 0;

	let _crec_pcn = round((_tot_pri_cob_nue_aa/_tot_pri_cob_nue_ap) -1,2); --Crecimiento de Prima Cobrada Nueva

	if _crec_pcn >= _meta1 then
		let _flag_meta1 = 1;
	end if

	let _cumpl_presupuesto = round(_tot_prima_suscrita/_tot_presupuesto_nuevas,2); --% de Cumplimiento de Presupuesto Nuevas

	if _cumpl_presupuesto >= _meta2 then 
		let _flag_meta2 = 1;
	end if

	let _persistencia = round(_tot_no_pol_ren_aa_per/(_tot_no_pol_nue_ap_per + _tot_no_pol_ren_ap_per),2); --Persistencia

	if _persistencia >= _meta3 then
		let _flag_meta3 = 1;
	end if

	let _siniestralidad = round(_tot_sini_incu/_tot_tot_pri_cob_aa,2); --Siniestralidad

	if _siniestralidad <= _meta4 then
		let _flag_meta4 = 1;
	end if

	let _tot_metas = _flag_meta1 + _flag_meta2 + _flag_meta3 + _flag_meta4;
	
	return	_nom_vendedor,
			_tot_pri_cob_nue_aa,
			_tot_pri_cob_nue_ap,
			_tot_tot_pri_cob_aa,
			_tot_sini_incu,
			_tot_prima_suscrita,
			_tot_prima_suscrita_ap,
			_tot_presupuesto_nuevas,
			_tot_no_pol_nue_aa,
			_tot_no_pol_nue_ap,
			_tot_no_pol_ren_aa,
			_tot_no_pol_ren_ap,
			_tot_no_pol_ren_aa_per,
			_tot_no_pol_nue_ap_per,
			_tot_no_pol_ren_ap_per,
			_crec_pcn,
			_flag_meta1,
			_cumpl_presupuesto,
			_flag_meta2,
			_persistencia,
			_flag_meta3,
			_siniestralidad,
			_flag_meta4,
			_tot_metas ;
end if

drop table if exists tmp_codigos;
drop table if exists tmp_bono_comerc;
end
end procedure;