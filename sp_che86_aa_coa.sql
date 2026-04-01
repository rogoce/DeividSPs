--*****************************************************************************************
-- Procedimiento que genera el Reporte para convencion a UNKNOWN 2025 para los corredores
-- Genera la informacion del año anterior periodo del concurso para sacar a los corredores y quede congelada la info.
--*****************************************************************************************
DROP PROCEDURE sp_che86_aa_coa;
CREATE PROCEDURE sp_che86_aa_coa(a_compania CHAR(3), a_sucursal CHAR(3))
RETURNING SMALLINT;

DEFINE _no_poliza       CHAR(10);
DEFINE _monto,_monto2   DEC(16,2);
DEFINE _fecha           DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2);
DEFINE _porc_comis2     DEC(5,2);
DEFINE _porc_coas_ancon DEC(5,2);
DEFINE _sobrecomision   DEC(16,2);
DEFINE _nombre          CHAR(50); 
DEFINE _no_documento    CHAR(20); 
DEFINE _no_requis       CHAR(10); 
DEFINE _cod_tipoprod    CHAR(3);  
DEFINE _tipo_prod       SMALLINT; 
DEFINE _cod_tiporamo    CHAR(3);
DEFINE _tipo_ramo       SMALLINT; 
DEFINE _cod_ramo        CHAR(3);  
DEFINE _nombre_ramo     CHAR(50);  
DEFINE _cod_subramo     CHAR(3);  
DEFINE _no_licencia     CHAR(10); 
DEFINE _tipo_mov        CHAR(1);  
DEFINE _incobrable		SMALLINT;
DEFINE _tipo_pago     	SMALLINT;
DEFINE _tipo_agente     CHAR(1);
DEFINE _cod_producto	char(5);
DEFINE _cod_formapag    char(3);
DEFINE _tipo_forma      SMALLINT;
DEFINE v_prima_orig     DEC(16,2);
DEFINE v_saldo          DEC(16,2);
DEFINE v_por_vencer     DEC(16,2);
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente      DEC(16,2);
DEFINE v_monto_30       DEC(16,2);
DEFINE v_monto_60       DEC(16,2);
define v_monto_90       DEC(16,2);
define _cnt,my_sessionid integer;
define _cod_grupo       char(5);
define _cedula_agt      char(30);
define _cedula_paga		char(30);
define _cedula_cont		char(30);
define _cod_pagador     char(10);
define _cod_contratante char(10);
define _estatus_licencia char(1);
define _per_ini 		char(7);
define _per_ini_ap 		char(7);
define _per_fin_ap 		char(7);
define _pri_sus 		DEC(16,2);
define _filtros			char(255);
define _per_fin_dic     char(7);
define _prima_sus_pag   DEC(16,2);
define _sini_incu		DEC(16,2);
define _siniestralidad  DEC(16,2);
define _fecha_pago      date;
define _renglon         integer;
define _porc_coaseguro	dec(16,4);
define _prima_can		DEC(16,2);
define _sin_pag_aa		DEC(16,2);
define _no_reclamo		char(10);
define _sin_pen_dic		DEC(16,2);
define _sin_pen_aa      DEC(16,2);
define _pri_pag         DEC(16,2);
define _pri_can         DEC(16,2);
define _pri_dev         DEC(16,2);
define _prima_orig      DEC(16,2);
define _prima_suscrita  DEC(16,2);
define _prima_dev_cor  DEC(16,2);
define _prima_suscri  DEC(16,2);
define _flag            smallint;
define _cod_coasegur	char(3);
define _cod_agente   	char(5);
define _cantidad        integer;
define _fecha_aa_ini    date;
define _fecha_aa        date;
define _fecha_ap_ini    date;
define _fecha_ap        date;
define _vigente         smallint;
define v_filtros        varchar(255);
define a_periodo        char(7);
define _n_cliente       varchar(100);
define _nueva_renov     char(1);
define _periodo_reno    char(7);
define _vigen_ini		date;
define _vigencia_ant	date;
define _vigencia_act	date;
define _no_pol_ren_aa	integer;
define _no_pol_ren_ap	integer;

define _no_pol_nue_aa	integer;
define _no_pol_nue_ap	integer;

define _no_pol_nue_ap_per integer;
define _no_pol_ren_aa_per integer;
define _no_pol_ren_ap_per integer;

define _estatus_poliza	smallint;
define _cnt_zl				smallint;
define _cnt_gob			smallint;
define _pri_sus_pag_ap  DEC(16,2);
define _pri_pag_ap      DEC(16,2);
define _pri_can_ap      DEC(16,2);
define _pri_dev_ap      DEC(16,2);
define _monto_90_aa     DEC(16,2);
define _monto_90_ap     DEC(16,2);
define _monto_cob			DEC(16,2);
define _impuesto			DEC(16,2);

define _ano				smallint;
define _ano_ant			smallint;

define _cod_agencia		char(3);
define _suc_promotoria	char(3);
define _cod_vendedor	char(3);
define _nombre_vendedor	char(50);
define _vigencia_inic	date;
define _vigencia_final	date;
define _tipo_persona	char(1);
define _nombre_tipo		char(15);
define _concurso		smallint;

define _porc_res_mat	dec(5,2);
define _agente_agrupado char(5);
define _unificar        smallint;

define _per_fin_aa		char(7);
define _mes_evaluar		smallint;
define _ano_evaluar		smallint;
define _mes_pnd			smallint;
define _periodo_pnd1	char(7);
define _periodo_pnd2	char(7);

define _error           integer;
define _error_isam      integer;
define _error_desc      char(50);

define _fecha_cierre	date;
define _emi_periodo   	char(7);

DEFINE _monto_dev        DEC(16,2);
define _pagado           integer;
define _fecha_anulado    date;
define _no_remesa        char(10);
define _porc_partic_prima  dec(16,2);
define _porc_proporcion    dec(16,2);
define _monto_fac_ac	dec(16,2);
define _impuesto_cor	dec(16,2);
define _monto_fac       dec(16,2);
define _no_endoso       char(10);
define _prima_net_cor       dec(16,2);
define _prima_fac_cor       dec(16,2);
define _prima_coa_cor       dec(16,2);
define _prima_cen_cor       dec(16,2);
define _prima_fac       dec(16,2);
define _prima_neta    dec(16,2);
define _monto_coa    dec(16,2);
define _monto_cen    dec(16,2);
define _meses           smallint;
define _valor           decimal(16,2);
define _cod_perpago		char(3);
define _fecha_proceso	datetime year to fraction(5);
define _pri_sus_ap      decimal(16,2);
define _per_siguiente   char(7);
define _fecha_fin_ap    date;
define _porcentaje      decimal(16,4);


{SET DEBUG FILE TO "sp_che86.trc";
TRACE ON;}

begin 

let _error          = 0;
let _prima_can      = 0;
let _pri_can        = 0;
let _siniestralidad = 0;
let _sini_incu      = 0;
let _prima_sus_pag  = 0;
let _pri_dev        = 0;
let _cnt            = 0;
let _pri_pag        = 0;
let _sin_pen_dic    = 0;
let _sin_pen_aa     = 0;
let _sin_pag_aa     = 0;
let v_por_vencer    = 0;
let v_exigible	    = 0;
let v_corriente	    = 0;
let v_monto_30	    = 0;
let v_monto_60	    = 0;
let v_monto_90	    = 0;
let v_saldo         = 0;
let _cantidad       = 0;
let _prima_orig     = 0;
let _pri_sus_pag_ap = 0;
let _monto_90_aa    = 0;
let _pri_can		= 0;
let _monto_90_ap    = 0;
let _monto_fac_ac   = 0;
let _monto_fac      = 0;
let _prima_fac      = 0;
let _prima_suscri   = 0;
let _pri_sus_ap     = 0;

-- Periodo Actual

select par_ase_lider,
       par_periodo_act,
	   par_periodo_ant,
	   fecha_cierre
  into _cod_coasegur,
	   a_periodo,
	   _emi_periodo,
	   _fecha_cierre
  from parparam;
  
let my_sessionid = DBINFO('sessionid');

--Para que tome en cuenta el periodo anterior mientras no se haya cerrado.
if (today - _fecha_cierre) > 1 then
	let a_periodo = a_periodo;
else
	let a_periodo = _emi_periodo;
end if

--*****************************
-- Periodo Inicial del Concurso

let _per_ini      = "2024-01";

-- Periodo Final del Concurso

if a_periodo > "2024-12" then
	let a_periodo = "2024-12";
end if

-- Diciembre
let _per_fin_dic    = _per_ini[1,4] || "-12";

-- Fechas de los Periodos

SET ISOLATION TO DIRTY READ;

let _nombre_tipo = "";

--**********************************************************************************************
-- Prima Pagada Anno Pasado periodo del concurso 2022-01 A 2022-12
--**********************************************************************************************
foreach
	select cob.doc_remesa,
		    cob.prima_neta,
			cob.fecha,
			cob.renglon,
			cob.no_poliza,
			cob.no_remesa,
			cob.tipo_mov,
			emi.cod_tipoprod,
			emi.cod_ramo,
			emi.cod_subramo,
			emi.cod_grupo,
			cob.monto
	   into _no_documento,
		     _prima_neta,
			 _fecha_pago,
			 _renglon,
			 _no_poliza,
			 _no_remesa,
			 _tipo_mov,
			 _cod_tipoprod,
			 _cod_ramo,
			 _cod_subramo,
			 _cod_grupo,
			 _monto_cob
	   from cobredet cob
	  inner join emipomae emi on emi.no_poliza = cob.no_poliza
	  where cob.periodo >= '2024-01' --Parametro
	    and cob.periodo  <= '2024-12' --Parametro
		and cob.actualizado = 1
		and cob.tipo_mov in ("P","N","X")
	
	let _monto = 0.00;
	let _monto_fac_ac = 0.00;
	let _monto_coa = 0.00;
	let _monto_cen = 0.00;
	let _impuesto = 0.00;
	
	if _tipo_mov = 'X' then
		let _monto = 0.00;
		let _monto_fac_ac = 0.00;
		let _monto_coa = 0.00;
		let _impuesto = 0.00;
		let _monto_cen = _prima_neta;
	else
		
		let _monto_cen = 0.00;
		let _monto_coa = 0.00;
		let _monto = _prima_neta;
		let _impuesto = _monto_cob - _prima_neta;
		
		--Quitar Coaseguro Cedido
		if _cod_tipoprod = "001" then
			select porc_partic_coas
			  into _porc_coaseguro
			  from emicoama
			 where no_poliza    = _no_poliza
			   and cod_coasegur = _cod_coasegur;
					  
			if _porc_coaseguro is null then
				let _porc_coaseguro = 0.00;
			end if

			let _monto = _prima_neta * (_porc_coaseguro / 100);
			let _monto_coa = _prima_neta - _monto;
		end if
		
		--Quitar facultativo cedido
		foreach
			select porc_partic_prima,
				   porc_proporcion
			  into _porc_partic_prima,
				   _porc_proporcion
			  from cobreaco c, reacomae r
			 where c.no_remesa = _no_remesa
			   and c.renglon   = _renglon
			   and r.cod_contrato = c.cod_contrato
			   and r.tipo_contrato = 3

			if _porc_partic_prima is null then
				let _porc_partic_prima = 0.00;
			end if
			
			let _monto_fac = _monto * (_porc_partic_prima/100) * (_porc_proporcion/100);
			let _monto_fac_ac = _monto_fac_ac +_monto_fac;
		end foreach

		let _monto = _monto - _monto_fac_ac;
	end if
	
	let _cnt_zl = 0;
	let _cnt_gob = 0;
	
	if _cod_ramo = '001' and _cod_subramo = '006' then
		let _cnt_zl = 1;
	elif _cod_ramo = '003' and _cod_subramo = '005' then
		let _cnt_zl = 1;
	end if
	
	if _cod_grupo in ('00000','1000') then
		let _cnt_gob = 1;
	end if

	let _valor = sp_sis101a(_no_documento,'01/01/2024','31/12/2024',my_sessionid);	--Crea tabla tmp_corr con el corredor
	foreach
		select cod_agente,
		       porcentaje
		  into _cod_agente,
               _porcentaje
		  from con_corr
		 where sessionid = my_sessionid 
		  
		let _prima_net_cor = 0.00;  
		let _prima_fac_cor = 0.00;  
		let _prima_coa_cor = 0.00;  
		let _prima_cen_cor = 0.00;  
		let _impuesto_cor = 0.00;  
		
		let _prima_net_cor = _monto * _porcentaje /100;  
		let _impuesto_cor = _impuesto * _porcentaje /100;  
		let _prima_fac_cor = _monto_fac_ac * _porcentaje /100;  
		let _prima_coa_cor = _monto_coa * _porcentaje /100;  
		let _prima_cen_cor = _monto_cen * _porcentaje /100;
		
		insert into tmp_concurso1(no_documento, pri_sus_pag, pri_pag,pri_can,pri_dev,sin_pag_aa, cod_agente,tipo,no_pol_ren_aa,no_pol_ren_ap)
		values (_no_documento,_prima_net_cor, _prima_coa_cor,_prima_fac_cor,_prima_cen_cor,_impuesto_cor, _cod_agente,0,_cnt_zl,_cnt_gob);
	end foreach
end foreach

foreach
	select pol.no_documento,
			pol.monto,
			chq.pagado,
			chq.fecha_anulado,
			emi.cod_ramo,
			emi.cod_subramo,
			emi.cod_grupo
	  into _no_documento,
		    _monto_dev, 
			_pagado,
			_fecha_anulado,
			_cod_ramo,
			_cod_subramo,
			_cod_grupo			 
	  from chqchpol pol
	 inner join chqchmae chq on chq.no_requis = pol.no_requis
	 inner join emipomae emi on emi.no_poliza = pol.no_poliza
	 where chq.fecha_impresion between '01/01/2024' and '31/12/2024'

	if _pagado = 1 then
		if _fecha_anulado is not null then
			if _fecha_anulado >= '01/01/2024' and _fecha_anulado <= '31/12/2024' then
				let _monto_dev = 0;
			end if
		end if			
	else
		let _monto_dev = 0;
	end if	
	if _monto_dev is null then
		let _monto_dev = 0;
	end if
	
	let _cnt_zl = 0;
	let _cnt_gob = 0;
	
	if _cod_ramo = '001' and _cod_subramo = '006' then
		let _cnt_zl = 1;
	elif _cod_ramo = '003' and _cod_subramo = '005' then
		let _cnt_zl = 1;
	end if
	
	if _cod_grupo in ('00000','1000') then
		let _cnt_gob = 1;
	end if

	
	let _valor = sp_sis101a(_no_documento,'01/01/2024','31/12/2024',my_sessionid);	--Crea tabla tmp_corr con el corredor
	foreach
		select cod_agente,
		       porcentaje
		  into _cod_agente,
               _porcentaje
		  from con_corr
		 where sessionid = my_sessionid 
		  
		let _prima_dev_cor = 0.00;  
		
		let _prima_dev_cor = _monto_dev * _porcentaje /100;  
		
		insert into tmp_concurso1(no_documento, sin_pen_aa, cod_agente,tipo,no_pol_ren_aa,no_pol_ren_ap)
		values (_no_documento,_prima_dev_cor, _cod_agente,0,_cnt_zl,_cnt_gob);
	end foreach
	
end foreach

return 0;
end
return 0;
END PROCEDURE; 