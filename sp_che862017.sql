--*****************************************************************************************
-- Procedimiento que genera el Reporte para convencion a Hawaii 2018 para los corredores
--*****************************************************************************************

DROP PROCEDURE sp_che862017;
CREATE PROCEDURE sp_che862017(a_compania CHAR(3), a_sucursal CHAR(3))
RETURNING SMALLINT;

DEFINE _no_poliza       CHAR(10);
DEFINE _monto           DEC(16,2);
DEFINE _fecha           DATE;     
DEFINE _prima,_monto2   DEC(16,2);
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
define _cnt             integer;
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
define _pri_sus_pag_ap  DEC(16,2);
define _pri_pag_ap      DEC(16,2);
define _pri_can_ap      DEC(16,2);
define _pri_dev_ap      DEC(16,2);
define _monto_90_aa     DEC(16,2);
define _monto_90_ap     DEC(16,2);

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
define _porc_proporcion,_prima_suscrita2    dec(16,2);
define _monto_fac_ac	dec(16,2);
define _monto_fac       dec(16,2);
define _no_endoso       char(10);
define _prima_fac       dec(16,2);
define _prima_suscri    dec(16,2);
define _meses           smallint;
define _valor           decimal(16,2);
define _cod_perpago		char(3);
define _fecha_proceso	datetime year to fraction(5);
define _pri_sus_ap      decimal(16,2);
define _per_siguiente   char(7);
define _fecha_fin_ap    date;
define _porc_partic_agt decimal(16,4);
define _porcentaje decimal(16,4);

--SET DEBUG FILE TO "sp_che862017.trc";
--TRACE ON;

begin 
on exception set _error, _error_isam, _error_desc
	return _error;--,current;
end exception

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

--Para que tome en cuenta el periodo anterior mientras no se haya cerrado.
if (today - _fecha_cierre) > 1 then
	let a_periodo = a_periodo;
else
	let a_periodo = _emi_periodo;
end if

--*****************************
-- Periodo Inicial del Concurso
--*****************************
let _per_ini      = "2017-10";
let _fecha_fin_ap = sp_sis36(_per_ini);	--31/10/2017

-- Periodo Final del Concurso

if a_periodo > "2018-09" then
	let a_periodo = "2018-09";
end if

-- Periodo Pasado
let _ano            = _per_ini[1,4];		  --2017
let _ano            = _ano - 1;				  --2016
let _per_ini_ap     = _ano || _per_ini[5,7];  --2016-10

let _ano            = a_periodo[1,4];		  --2018
let _ano            = _ano - 1;				  --2017
let _per_fin_ap     = _ano || a_periodo[5,7]; --2017-01

-- Diciembre

let _per_fin_dic    = _per_ini[1,4] || "-12"; --2017-12

-- Fechas de los Periodos

let _fecha_aa_ini = mdy(_per_ini[6,7], 1, _per_ini[1,4]);        --es del 01/10/2017

let _fecha_ap_ini = mdy(_per_ini_ap[6,7], 1, _per_ini_ap[1,4]);	  --es del 01/10/2016

let _fecha_aa     = sp_sis36(a_periodo);  --31/01/2018

let _fecha_ap     = sp_sis36(_per_fin_ap); --31/01/2017

delete from milan08;
delete from fis_concurso;

--Insercion de registros del año pasado periodo del concurso
INSERT INTO fis_concurso
SELECT * FROM fis_concurso1;

SET ISOLATION TO DIRTY READ;

let _nombre_tipo = "";
--**********************************************************************************************
-- Prima Pagada Este AÑO 
--**********************************************************************************************
foreach
	select doc_remesa,
		   prima_neta,
		   fecha,
		   no_remesa,
		   renglon
	  into _no_documento,
		   _monto,
		   _fecha_pago,
		   _no_remesa,
		   _renglon
	  from cobredet
	 where periodo     >= _per_ini			--2017-10
	   and periodo     <= a_periodo			--2018-09
	   and actualizado = 1
	   and tipo_mov    in ("P", "N")

	let _no_poliza = sp_sis21(_no_documento);

	select cod_tipoprod,
	       cod_formapag,
		   prima_suscrita,
		   cod_ramo,
		   cod_perpago,
		   estatus_poliza
	  into _cod_tipoprod,
	       _cod_formapag,
		   _prima_suscri,
		   _cod_ramo,
		   _cod_perpago,
		   _estatus_poliza
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "001" then

		select porc_partic_coas
		  into _porc_coaseguro
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = _cod_coasegur;

		if _porc_coaseguro is null then
			let _porc_coaseguro = 0.00;		          
		end if

		let _monto = _monto * (_porc_coaseguro / 100);
	end if

	-- devoluciones de prima
	foreach
		select monto,
			   no_requis
		  into _monto_dev, 
			   _no_requis
		  from chqchpol
		 where no_poliza = _no_poliza
		 
		select pagado,
			   fecha_anulado
		  into _pagado,
			   _fecha_anulado
		  from chqchmae
		 where no_requis = _no_requis
		   and fecha_impresion between '01/10/2017' and '30/09/2018';

		if _pagado = 1 then
			if _fecha_anulado is not null then
				if _fecha_anulado >= '01/10/2017' and _fecha_anulado <= '30/09/2018' then
					let _monto_dev = 0;
				end if
			end if			
		else
			let _monto_dev = 0;
		end if	

		if _monto_dev is null then
			let _monto_dev = 0;
		end if

		let _monto = _monto - _monto_dev;
	end foreach	
	--fin de devoluciones de primas
	
	let _monto_fac_ac = 0.00;
	
	--Quitar facultativo cedido
	foreach
		select porc_partic_prima,
			   porc_proporcion
		  into _porc_partic_prima,
			   _porc_proporcion
		  from cobreaco c, reacomae r
		 where c.no_remesa = _no_remesa
		   and c.renglon = _renglon
		   and r.cod_contrato = c.cod_contrato
		   and r.tipo_contrato = 3

		if _porc_partic_prima is null then
			let _porc_partic_prima = 0.00;
		end if
		
		let _monto_fac = _monto * (_porc_partic_prima/100) * (_porc_proporcion/100);
		let _monto_fac_ac = _monto_fac_ac + _monto_fac;
	end foreach
	
	let _monto = _monto - _monto_fac_ac;

	if _cod_formapag in('003','005') then	--Es TCR o ACH
		if _estatus_poliza in (2,4) then
			continue foreach;	--POLIZA ANULADA O CANCELADA, NO SE DEBE TOMAR EN CUENTA SI ES ELECTRONICO
		end if

		select count(*)
		  into _cnt
		  from fis_concurso 
		 WHERE no_documento = _no_documento
		   AND tipo = 1;
		if _cnt is null then
			let _cnt = 0;
		end if	
		if _cnt > 0 then
			continue foreach;
		end if
		
		if _cod_ramo = '018' then
				select meses
				  into _meses
				  from cobperpa
				 where cod_perpago = _cod_perpago;

				let _valor = 0;

				if _cod_perpago = '001' then
					let _meses = 1;
				end if

				if _cod_perpago = '008' or _cod_perpago = '006' then	--Es anual o inmediata, ya esta el 100% de la prima
					let _meses = 12;
				end if

				let _valor = 12 / _meses;
				let _prima_suscri = _prima_suscri * _valor;
				let _monto = _prima_suscri;
		else
				let _monto = _prima_suscri;
		end if
		--Quitar el facultativo cedido
		select sum(c.prima)
		  into _prima_fac
		  from emifacon c, reacomae r
		 where c.no_poliza = _no_poliza
		   and c.no_endoso = '00000'
		   and r.cod_contrato = c.cod_contrato
		   and r.tipo_contrato = 3;
		   
		if _prima_fac is null then
			let _prima_fac = 0.00;
		end if
		let _monto = _monto - _prima_fac;
	end if
	let _valor = sp_sis101a(_no_documento,'01/10/2017','30/09/2018');	--Crea tabla con el corredor tmp_corr
	foreach
	
		select cod_agente,
		       porcentaje
		  into _cod_agente,
               _porc_partic_agt
		  from tmp_corr
		  
		let _monto2 = 0.00;
		let _monto2 = _monto * _porc_partic_agt /100;
		insert into fis_concurso(no_documento, pri_pag,tipo,cod_agente)
		values (_no_documento, _monto2, 1, _cod_agente);
	end foreach
	drop table tmp_corr;
end foreach
--**********************************************************************************************
-- Prima Pagada AÑO PASADO a la fecha
--**********************************************************************************************
foreach
 select doc_remesa,
        prima_neta,
		fecha,
		renglon,
		no_poliza,
		no_remesa
   into _no_documento,
   		_monto,
		_fecha_pago,
		_renglon,
		_no_poliza,
		_no_remesa
   from cobredet
  where periodo     >= _per_ini_ap		--2016-10
    and periodo     <= _per_fin_ap		--2017-01
	and actualizado = 1
	and tipo_mov    in ("P", "N")

	select cod_tipoprod,
	       cod_formapag,
		   prima_suscrita,
		   cod_ramo,
		   cod_perpago,
		   estatus_poliza
	  into _cod_tipoprod,
	       _cod_formapag,
		   _prima_suscri,
		   _cod_ramo,
		   _cod_perpago,
		   _estatus_poliza
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "001" then
		select porc_partic_coas
		  into _porc_coaseguro
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = _cod_coasegur;

		if _porc_coaseguro is null then
			let _porc_coaseguro = 0.00;
		end if

		let _monto = _monto * (_porc_coaseguro / 100);
	end if

	let _monto_fac_ac = 0.00;
	
	--Quitar facultativo cedido
	foreach
		select porc_partic_prima,
			   porc_proporcion
		  into _porc_partic_prima,
			   _porc_proporcion
		  from cobreaco c, reacomae r
		 where c.no_remesa = _no_remesa
		   and c.renglon = _renglon
		   and r.cod_contrato = c.cod_contrato
		   and r.tipo_contrato = 3

		if _porc_partic_prima is null then
			let _porc_partic_prima = 0.00;
		end if
		
		let _monto_fac = _monto * (_porc_partic_prima/100) * (_porc_proporcion/100);
		let _monto_fac_ac = _monto_fac_ac +_monto_fac;
	end foreach
	
	let _monto = _monto - _monto_fac_ac;

	if _cod_formapag in('003','005') then	--Es TCR o ACH
		select count(*)
		  into _cnt
		  from fis_concurso 
		 WHERE no_documento = _no_documento
		   AND tipo         = 2;
		 
		if _cnt > 0 then
			continue foreach;
		end if
		
		if _cod_ramo = '018' then
				select meses
				  into _meses
				  from cobperpa
				 where cod_perpago = _cod_perpago;
				let _valor = 0;
				if _cod_perpago = '001' then
					let _meses = 1;
				end if
				if _cod_perpago = '008' or _cod_perpago = '006' then	--Es anual o inmediata, ya esta el 100% de la prima
					let _meses = 12;
				end if	
				let _valor = 12 / _meses;
				let _prima_suscri = _prima_suscri * _valor;
				let _monto = _prima_suscri;
		else
				let _monto = _prima_suscri;
		end if
		--Quitar el facultativo cedido
		select sum(c.prima)
		  into _prima_fac
		  from emifacon c, reacomae r
		 where c.no_poliza = _no_poliza
		   and c.no_endoso = '00000'
		   and r.cod_contrato = c.cod_contrato
		   and r.tipo_contrato = 3;
		   
		if _prima_fac is null then
			let _prima_fac = 0.00;
		end if
		let _monto = _monto - _prima_fac;
	end if

	let _valor = sp_sis101a(_no_documento,'01/10/2016','30/09/2017');	--Crea tabla con el corredor tmp_corr
	foreach
		select cod_agente,
		       porcentaje
		  into _cod_agente,
               _porcentaje
		  from tmp_corr
		let _monto2 = 0.00;  
		let _monto2 = _monto * _porcentaje /100;  
		insert into fis_concurso(no_documento, pri_pag_ap, cod_agente,pri_can_ap,tipo)
		values (_no_documento, _monto2, _cod_agente,_monto2,2);
	end foreach
	drop table tmp_corr;
end foreach
--**********************************************************************************************
--**********************************************************************************************
-- Prima Suscrita ACTUAL periodo del concurso  2017-10 A 2018-09
--**********************************************************************************************
foreach
	select no_poliza,
		   no_endoso,
		   no_documento,
		   prima_suscrita
	  into _no_poliza,
		   _no_endoso,
		   _no_documento,		   
		   _prima_suscrita
	  from endedmae
	 where actualizado  = 1
	   and periodo between _per_ini and a_periodo
	   
	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;
	
	if _cod_tipoprod = "001" then	--Coaseguro Mayoritario, se debe sacar solo la parte de ancon.
		select porc_partic_coas
		  into _porc_coaseguro
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = '036';

		if _porc_coaseguro is null then
			let _porc_coaseguro = 0.00;
		end if

		let _prima_suscrita = _prima_suscrita * (_porc_coaseguro / 100);
	end if
	
	select sum(c.prima)
	  into _prima_fac
	  from emifacon c, reacomae r
	 where c.no_poliza = _no_poliza
	   and c.no_endoso = _no_endoso
	   and r.cod_contrato = c.cod_contrato
	   and r.tipo_contrato = 3;
	   
	if _prima_fac is null then
		let _prima_fac = 0.00;
	end if
	
	let _prima_suscrita = _prima_suscrita - _prima_fac;

	foreach
			select cod_agente,
				   porc_partic_agt
			  into _cod_agente,
				   _porcentaje
			  from endmoage
			 where no_poliza = _no_poliza
               and no_endoso = _no_endoso
			   
		    let _prima_suscrita2 = 0.00;
			let _prima_suscrita2 = _prima_suscrita * _porcentaje /100;  
			insert into fis_concurso(no_documento, pri_sus_pag, cod_agente)
			values (_no_documento, _prima_suscrita2, _cod_agente);
			
	end foreach
end foreach
--*************************************************************************************************
-- PRIMA SUSCRITA AÑO PASADO PERIODO DEL CONCURSO AL MES ACTUAL
--*************************************************************************************************
foreach
 select no_poliza,
		no_endoso,
		no_documento,
		prima_suscrita
   into _no_poliza,
		_no_endoso,
		_no_documento,		   
		_prima_suscrita
   from endedmae
  where actualizado  = 1
	and periodo between '2016-10' And _per_fin_ap
	
	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;
	
	if _cod_tipoprod = "001" then	--Coaseguro Mayoritario, se debe sacar solo la parte de ancon.
		select porc_partic_coas
		  into _porc_coaseguro
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = '036';

		if _porc_coaseguro is null then
			let _porc_coaseguro = 0.00;
		end if

		let _prima_suscrita = _prima_suscrita * (_porc_coaseguro / 100);
	end if
	let _prima_fac = 0.00;
	select sum(c.prima)
	  into _prima_fac
	  from emifacon c, reacomae r
	 where c.no_poliza = _no_poliza
	   and c.no_endoso = _no_endoso
	   and r.cod_contrato = c.cod_contrato
	   and r.tipo_contrato = 3;
	   
	if _prima_fac is null then
		let _prima_fac = 0.00;
	end if
	
	let _prima_suscrita = _prima_suscrita - _prima_fac;

	foreach
			select cod_agente,
				   porc_partic_agt
			  into _cod_agente,
				   _porcentaje
			  from endmoage
			 where no_poliza = _no_poliza
               and no_endoso = _no_endoso
			   
		    let _prima_suscrita2 = 0.00;
			let _prima_suscrita2 = _prima_suscrita * _porcentaje /100;  
			insert into fis_concurso(no_documento, pri_can, cod_agente)
			values (_no_documento, _prima_suscrita2, _cod_agente);
			
	end foreach
end foreach
--**********************************************************************************************
-- Siniestros Pagados AÑO ACTUAL
--**********************************************************************************************
call sp_rec01(a_compania, a_sucursal, _per_ini, a_periodo) returning _filtros;

foreach
 select doc_poliza,
        pagado_bruto   
   into _no_documento,
        _sin_pag_aa
   from tmp_sinis

	let _no_poliza = sp_sis21(_no_documento);
	let _valor = sp_sis101a(_no_documento,'01/10/2017','30/09/2018');	--Crea tabla con el corredor tmp_corr
	foreach
	
		select cod_agente,
		       porcentaje
		  into _cod_agente,
               _porcentaje
		  from tmp_corr
	
		let _monto2 = 0.00;  
		let _monto2 = _sin_pag_aa * _porcentaje / 100;  
		insert into fis_concurso(no_documento, sin_pag_aa, cod_agente)
		values (_no_documento, _monto2, _cod_agente);
	end foreach
end foreach

drop table tmp_sinis;
--**********************************************************************************************
-- Siniestros Pendientes AÑO ACTUAL
--**********************************************************************************************
foreach 
 select no_reclamo,		
        SUM(variacion)
   into _no_reclamo,	
        _sin_pen_aa
   from rectrmae 
  where cod_compania = a_compania
    and periodo      <= a_periodo		--2018-09
	and actualizado  = 1
  group by no_reclamo
 having sum(variacion) > 0 

	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	select porc_partic_coas 
	  into _porc_coaseguro
      from reccoas
     where no_reclamo   = _no_reclamo
       and cod_coasegur = _cod_coasegur;

	if _porc_coaseguro is null then
		let _porc_coaseguro = 0;
	end if

	let _sin_pen_aa = _sin_pen_aa * (_porc_coaseguro / 100);
	let _valor = sp_sis101a(_no_documento,'01/10/2017','30/09/2018');	--Crea tabla con el corredor tmp_corr
	foreach
		select cod_agente,
		       porcentaje
		  into _cod_agente,
               _porcentaje
		  from tmp_corr
		 
		let _monto2 = 0.00;  
		let _monto2 = _sin_pen_aa * _porcentaje /100;  
		insert into fis_concurso(no_documento, sin_pen_aa, cod_agente)
		values (_no_documento, _monto2, _cod_agente);
	end foreach
end foreach
---**********************************************************************************************
-- Polizas Nuevas y Renovadas AÑO PASADO inicio del concurso a la fecha
---**********************************************************************************************
call sp_bo077(_fecha_ap_ini, _fecha_ap) returning _error, _error_desc;	-- 01/10/2016   A 31/01/2017

foreach
		select no_documento,
			   sum(no_pol_nueva),
			   sum(no_pol_nueva_per),
			   sum(no_pol_renov),
			   sum(no_pol_renov_per)
		  into _no_documento,
			   _no_pol_nue_ap,
			   _no_pol_nue_ap_per,
			   _no_pol_ren_ap,
			   _no_pol_ren_ap_per
		  from tmp_persis
		 group by no_documento

		let _no_poliza = sp_sis21(_no_documento);

		select cod_ramo,
			   cod_subramo
		  into _cod_ramo,
		       _cod_subramo
		  from emipomae
		 where no_poliza = _no_poliza;
		 
		if _cod_ramo = '020' then
			let _no_pol_nue_ap_per = 0;
			let _no_pol_ren_ap_per = 0;
		end if
		if _cod_ramo = '004' And _cod_subramo = '001' then
			let _no_pol_nue_ap_per = 0;
			let _no_pol_ren_ap_per = 0;
		end if

		let _valor = sp_sis101a(_no_documento,'01/10/2016','30/09/2017');	--Crea tabla con el corredor tmp_corr
		foreach
			select cod_agente
			  into _cod_agente
			  from tmp_corr
		
			insert into fis_concurso(
			no_documento, 
			no_pol_nue_ap, 
			no_pol_nue_ap_per,
			no_pol_ren_ap,
			no_pol_ren_ap_per,
			cod_agente
			)
			values(
			_no_documento, 
			_no_pol_nue_ap,
			_no_pol_nue_ap_per,
			_no_pol_ren_ap,
			_no_pol_ren_ap_per,
			_cod_agente
			);
		end foreach
		drop table tmp_corr;
end foreach

drop table tmp_persis;
----**********************************************************************************************
-- Polizas Nuevas y Renovadas AÑO ACTUAL a la fecha
----**********************************************************************************************
call sp_bo077(_fecha_aa_ini, _fecha_aa) returning _error, _error_desc;	--01/10/2017    -    31/01/2018

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
  
		let _no_poliza = sp_sis21(_no_documento);

		select cod_ramo,cod_subramo
		  into _cod_ramo,_cod_subramo
		  from emipomae
		 where no_poliza = _no_poliza;
		 
		if _cod_ramo = '020' then
			let _no_pol_ren_aa_per = 0;
		end if
 		if _cod_ramo = '004' And _cod_subramo = '001' then
			let _no_pol_ren_aa_per = 0;
		end if
		let _valor = sp_sis101a(_no_documento,'01/10/2017','30/09/2018');	--Crea tabla con el corredor tmp_corr
		foreach
			select cod_agente
			  into _cod_agente
			  from tmp_corr
			
			insert into fis_concurso(
			no_documento, 
			no_pol_nue_aa, 
			no_pol_ren_aa,
			no_pol_ren_aa_per,
			cod_agente
			)
			values(
			_no_documento, 
			_no_pol_nue_aa,
			_no_pol_ren_aa,
			_no_pol_ren_aa_per,
			_cod_agente
			);
			
		end foreach
		drop table tmp_corr;
end foreach
drop table tmp_persis;

foreach
	select no_documento,
		   cod_agente,
		   sum(pri_pag),
		   sum(pri_can),
			sum(pri_dev),
			sum(sin_pag_aa),
			sum(sin_pen_aa),
			sum(sin_pen_ap),
			sum(no_pol_ren_aa),
			sum(no_pol_ren_ap),
			sum(no_pol_nue_aa),
			sum(no_pol_nue_ap),
			sum(no_pol_nue_ap_per),
			sum(pri_pag_ap),
			sum(pri_can_ap),
			sum(pri_dev_ap),
			sum(pri_sus_pag),
			sum(no_pol_ren_aa_per),
			sum(no_pol_ren_ap_per),
			sum(monto_90_ap),
			sum(monto_90_aa)
	   into _no_documento,
			_cod_agente,
			_pri_pag,
			_pri_can,
			_pri_dev,
			_sin_pag_aa,
			_sin_pen_aa,
			_sin_pen_dic,
			_no_pol_ren_aa,
			_no_pol_ren_ap,
			_no_pol_nue_aa,
			_no_pol_nue_ap,
			_no_pol_nue_ap_per,
			_pri_pag_ap,
			_pri_can_ap,
			_pri_dev_ap,
			_prima_suscrita,
			_no_pol_ren_aa_per,
			_no_pol_ren_ap_per,
			_monto_90_ap,
			_monto_90_aa
	   from fis_concurso
	  group by no_documento,cod_agente
	  order by no_documento,cod_agente

	let _no_poliza = sp_sis21(_no_documento);

    let _cnt = 0;
    --rehabilitada o cancelada en el periodo del concurso no va
    select count(*)
      into _cnt
      from endedmae
     where no_poliza     = _no_poliza
	   and actualizado   = 1
       and cod_endomov in ('003','002')  	
       and fecha_emision >= '01/10/2017'
       and fecha_emision <= '30/09/2018';

    if _cnt > 0 then
	    let _pri_pag           = 0;
		let _sin_pag_aa        = 0;
	    let _sin_pen_aa        = 0;
		let _no_pol_ren_aa     = 0;
		let _no_pol_nue_aa     = 0;
		let _prima_suscrita    = 0;
		let _no_pol_ren_aa_per = 0;
		--let _sin_pen_dic = 0;
		--let _no_pol_ren_ap = 0;
		--let _no_pol_nue_ap = 0;
		--let _no_pol_nue_ap_per = 0;
		--let _no_pol_ren_ap_per = 0;		
    end if

	select cod_grupo, 
	       cod_ramo, 
	       cod_pagador, 
	       cod_contratante, 
	       cod_tipoprod,
		   sucursal_origen,
		   cod_subramo
	  into _cod_grupo,
	       _cod_ramo,
	       _cod_pagador,
	       _cod_contratante,
	       _cod_tipoprod,
		   _cod_agencia,
		   _cod_subramo
	   from emipomae
	  where no_poliza = _no_poliza;

	select concurso
	  into _concurso
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo; 			

	if _concurso = 0 then -- Excluir del Concurso
		continue foreach;
	end if  	

	if _cod_tipoprod = "004" then	--Excluir Reaseguro Asumido
		continue foreach;
	end if

    let _cnt = 0;

	-- Siniestros Incurridos
		
	let _sini_incu = _sin_pag_aa + _sin_pen_aa - _sin_pen_dic;

	select nombre,
	       porc_res_mat
	  into _nombre_ramo,
	       _porc_res_mat
	  from prdramo
	 where cod_ramo = _cod_ramo;

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

	select cedula,
	       nombre
	  into _cedula_cont,
	       _n_cliente
	  from cliclien
	 where cod_cliente = _cod_contratante;

    let _flag = 0;

	--foreach

		--select cod_agente
		--  into _cod_agente
		--  from emipoagt
		-- where no_poliza = _no_poliza
		
		if _cod_agente in('02243') then 		--Unificar Inversiones y Seguros Panamericanos, S. A. (CH) a Inversiones y Seguros Panamericanos, S. A.
		    let _cod_agente = "00473";
		end if
	    if _cod_agente in('01481') then 		--Unificar Jose Caballero a Marta Caballero
		    let _cod_agente = "01555";
		end if
		if _cod_agente in('02302','02354') then --Unificar LIZSENELL GIONELLA BERNAL RAMIREZ, correo 24/03/17 Alicia
		    let _cod_agente = "02319";
		end if
		if _cod_agente in('01480','00492') then --Unificar Ricardo Caballero, los ases del seguro a Patricia Caballero
		    let _cod_agente = "01479";
		end if
		if _cod_agente in('02129','02130','02050','01001','01000','01002','01609','01005') then --Unificar Felix Abadia
		    let _cod_agente = "01001";
		end if
        let _unificar = 0;	 --Unificar FF Seguros	:25/04/2013 Leticia
		SELECT count(*)
		  INTO _unificar
		  FROM agtagent 
		 WHERE cod_agente      = _cod_agente
		   AND agente_agrupado = "01068";

	    if _unificar <> 0 then
		   let _cod_agente = "01068";
	    end if
		let _unificar = 0;	 --Unificar SOMOS SEGUROS	:08/05/2017 Correo de Analiza.

		SELECT count(*)
		  INTO _unificar
		  FROM agtagent 
		 WHERE cod_agente      = _cod_agente
		   AND agente_agrupado = "02420";

		if _unificar <> 0 then
		   let _cod_agente = "02420";
		end if		   
 	    --1  Jovani Mora(00636), Quitza Paz(00732),  Alberto Camacho (00731) a Servicios Internacionales (01435)	 --
	    --se quita a Rogelio Becerra (00865) segun correo de Analisa del 23/05/2017
	    if _cod_agente in ("00636","00732","00731") then
		  let _cod_agente = "01435";
	    end if
 	    --3 Doulos Insurance Consultants  (DICSA)(01048,01837) ,Logos Insurance(01569,01838), Juan Carlos Sanchez(01315,01834), Chung Wai Chun(00623,01836), Katia Mariza Dam de Spagnuolo(01575,01835)
		-- Se agregan los siguientes segun correo de Jose Pinzon del 29/05/2017
		--02349 Cristian Daniel Sanchez Restrepo
		--02252 Deby Maritza Chung Alie
		--02448 Dina M. Ortega de Quezada
		--02253 Leonardo Alfonso Chung Alie
		--02393 Sara Maria Dunn	   
	    if _cod_agente in ("01837","01569","01838","01315","01834","00623","01836","01575","01835","02201","02349","02252","02448","02253","02393") then  --- falta 02201 LATTY
		  let _cod_agente = "01048";
		end if	   
	    --  Afta Insurance Services(santiago)(02155), Asesora Tefi S.A.(00095), Ithiel Cesar Trib.(00130) , Seguros ICT, S.A(00235)
	    if _cod_agente in ("02155","00095","00130","00235") then	   --Cambio segun sol. 29/05/2014 por Leticia Escobar.
		  let _cod_agente = "01266";
		end if
		-- Solicitud de Leticia del 09/10/2013
		-- Unificar todos los KAM
		-- Demetrio Hurtado (02/10/2012)
		-- Se separa la unificacion por orden de leticia segun correo 12/04/2013, indica que se unen al final
		--"02082",se quita segun correo de Keyliam 19/07/2017
		if _cod_agente IN ("02360","02376","02293","02377","02378","02375","00133","01746","01749","01852","02004","02075","02124") then  
			let _cod_agente = "00218";													
		end if
		-- Solicitud de Leticia del 08/04/2013
		-- Unificar Noel Quintero y Joel Quintero
		-- Armando Moreno (08/04/2013)
		if _cod_agente = "01880" then
			let _cod_agente = "00395";													
		end if
		-- Solicitud de Leticia del 31/05/2013
		-- Unificar Tuesca & Asociados(00946) y Corporacion Comercial(00239)
		-- Armando Moreno (03/06/2013)
		if _cod_agente = "00239" then
			let _cod_agente = "00946";													
		end if
		-- Solicitud de Leticia del 29/09/2014
		-- Unificar SEMUSA(00270) con semusa chitre y Semusa Santiago(01853,01814)
		-- Armando Moreno (29/09/2014)
		if _cod_agente in("01853","01814") then
			let _cod_agente = "00270";													
		end if
		-- Solicitud de Leticia del 29/09/2014
		-- Unificar SSEGUROS NACIONALES(00125) con seguros nacionales david(02015)
		-- Armando Moreno (29/09/2014)
		if _cod_agente in("02015") then
			let _cod_agente = "00125";													
		end if
		-- Solicitud de Leticia del 29/09/2014
		-- Unificar DUCRUET(00035) con ducruet david(02154)
		-- Armando Moreno (29/09/2014)
		if _cod_agente in("02154") then
			let _cod_agente = "00035";													
		end if
		-- Solicitud de Leticia del 29/09/2014
		-- Unificar SEGUROS CENTRALIZADOS(00166) con seguro centralizados chiriqui(01745), seg. centr. chitre(01743), seg cent.colon(01744), seg. cent. santiago(01751)
		-- Armando Moreno (29/09/2014)
		if _cod_agente in("01745","01743","01744","01751","01851") then
			let _cod_agente = "00166";													
		end if
		-- Solicitud de Leticia del 29/09/2014
		-- Unificar SEGUROS TEMPUS(00474) con seg. tempus chitre(02081)
		-- Armando Moreno (29/09/2014)
		if _cod_agente in("02081") then
			let _cod_agente = "00474";													
		end if
		-- Solicitud de Leticia del 29/09/2014
		-- Unificar  lideres en seg. santiago(01990) con LIDERES EN SEGURO(01009)
 		-- Armando Moreno (29/09/2014)
		if _cod_agente in("01990") then
			let _cod_agente = "01009";
		end if
		-- Solicitud de Leticia del 29/09/2014
		-- Unificar  B&G INSURANCE GROUP CHITRE(02103) con B&G INSURANCE GROUP(01670) 
		-- Armando Moreno (29/09/2014)
		if _cod_agente in("02103") then
			let _cod_agente = "01670";
		end if
		-- Solicitud de Leticia del 29/09/2014
		-- Unificar SH ASESORES DE SEGUROS(01898) con sh asesores de seg chorrera(02196)
		-- Armando Moreno (29/09/2014)
		if _cod_agente in("02196") then
			let _cod_agente = "01898";
		end if
		-- Solicitud de Leticia del 29/09/2014
		-- Unificar GONZALEZ DE LA GUARDIA Y ASOC.(00291) con maria e. de la guardia(00197)
		-- Armando Moreno (29/09/2014)
		if _cod_agente in("00197") then
			let _cod_agente = "00291";
		end if
		-- Solicitud de Leticia del 20/02/2015
		-- Unificar Leysa Rodriguez(01904) Dalys de Rodriguez(00138) Mireya de Malo(01867) Sandra Caparroso(00965) con D.R. ASESORES DE SEGUROS(00011)
		if _cod_agente in("01904","00138","01867","00965") then
			let _cod_agente = "00011";
		end if
		-- Solicitud de Leticia del 20/02/2015
		-- Unificar Daysi de la Rosa(01948) con Corredores de Seguros de la Rosa(02208)
		if _cod_agente in("01948") then
			let _cod_agente = "02208";
		end if
		-- Solicitud de Leticia del 20/02/2015
		-- Unificar Asegure Corredor de Seguros(02102) con Lynette Lopez Arango(00817)
		if _cod_agente in("02102") then
			let _cod_agente = "00817";
		end if
		-- Solicitud de Leticia del 20/02/2015
		-- Unificar Asegure Corredor de Seguros(00517) con J2L Asesores(01440)
		if _cod_agente in("00517") then
			let _cod_agente = "01440";
		end if
		-- Solicitud de Leticia del 20/02/2015
		-- Unificar Hugo Caicedo (00525) con Blue Sea Insurance Brokers, Corp.(00779)
		if _cod_agente in("00525") then
			let _cod_agente = "00779";
		end if
		-- Solicitud de Leticia del 20/02/2015
		-- Unificar Abdiel Teran Della Togna (00076) con Conjuga Insurance Solutions(02119)
		if _cod_agente in("00076","00937") then
			let _cod_agente = "02119";
		end if
		-- Solicitud de Leticia del 20/02/2015
		-- Unificar Ureña y Ureña (00050) con Edgar Alberto Ureña Romero(00845)
		if _cod_agente in("00050") then
			let _cod_agente = "00845";
		end if
		-- Solicitud de Leticia del 20/02/2015
		-- Unificar Seguros y Asesoria Maritima (01916) con Roderick Subia(00793)
		if _cod_agente in("01916") then
			let _cod_agente = "00793";
		end if
		-- Solicitud de Leticia del 20/02/2015
		-- Unificar Carlos Manuel Mendez (00104) Carlos Manuel Mendez Dutari (02037) con Marcha Seguros, S.A.(00119)
		if _cod_agente in("00104","02037") then
			let _cod_agente = "00119";
		end if
		-- Solicitud de Matilde Rosario del 24/02/2015
		-- Unificar Sandra Eckardt. (01779) con  ECKARDT seguros, s. a.(02229)
		if _cod_agente in("01779") then
			let _cod_agente = "02229";
		end if
		-- Solicitud de Gabriela G. correo de Yessi 24/05/2017
		-- UNIFIQUEN A LA CORREDORA DAYRA IRENE CHAVEZ CRUZ CODIGO 01504 AL CODIGO 02424 A D.C ASESORES DE SEGUROS
		if _cod_agente in("01504") then
			let _cod_agente = "02424";
		end if
		select nombre,
		       tipo_pago,
		       tipo_agente,
			   estatus_licencia,
			   cedula,
			   agente_agrupado,
			   tipo_persona,
			   cod_vendedor
		  into _nombre,
		       _tipo_pago,
		       _tipo_agente,
			   _estatus_licencia,
			   _cedula_agt,
			   _agente_agrupado,
			   _tipo_persona,
			   _cod_vendedor
		  from agtagent
		 where cod_agente = _cod_agente;

		IF _tipo_agente <> "A" then	-- Solo Corredores
		    let _flag = 1;
			continue foreach;
		END IF

		IF _estatus_licencia <> "A" then  -- El corredor debe estar activo
		    let _flag = 1;
			continue foreach;
		END IF

		if _cod_agente = "00180" and   -- Tecnica de Seguros
		   _cod_ramo   = "016"	 and   -- Colectivo de vida
		   _cod_grupo  = "01016" then  -- Grupo Suntracs
		    let _flag = 1;
			continue foreach;
		end if

		-- Informacion Necesaria para las Promotorias

		select sucursal_promotoria
		  into _suc_promotoria
		  from insagen
		 where codigo_agencia = _cod_agencia;

		-- Modificacion solicitada por Leticia para el concurso

		select cod_vendedor
		  into _cod_vendedor
		  from agtagent
		 where cod_agente  = _cod_agente;


		select nombre 
		  into _nombre_vendedor 
		  from agtvende 
		 where cod_vendedor = _cod_vendedor; 

		insert into milan08( 
		cod_agente,     --1	 * 
		no_documento, 	--2	 * 
		pri_sus_pag_aa, --3	 * prima cobrada anno actual 
		pri_sus_pag_ap, --4	 * prima cobrada anno pasado 
		sini_inc, 		--5	 * siniestros incurridos 
		n_agente, 		--6	 *
		vigenteaa,		--7	 * nuevas anno actual 
		vigenteap, 		--8	 * nuevas anno pasado 
		cod_contratante,--9	 *
		n_cliente,		--10   *
		periodo,		--11   *
		renovaa,		--12   * renovadas anno actual 
		renovap,		--13   * renovadas anno pasado 
		pri_pag_aa,		--14   * prima suscrita
		pri_can_aa,		--15    * prima suscrita periodo del concurso al mes que esta corriendo
		pri_dev_aa,		--16
		monto_90_aa,	--17
		pri_pag_ap,		--18  
		pri_can_ap,		--19
		pri_dev_ap,		--20   * prima suscrita anno pasado
		monto_90_ap,	--21
		cod_vendedor,	--22   *
		nombre_vendedor,--23   *
		cod_ramo,		--24   *
		nombre_ramo,	--25   *
		tipo_agente,	--26   *
		vigenteap_per,	--27   *
		renovaa_per,	--28
		renovap_per		--29
		)				
		values(
		_cod_agente, 	   --1
		_no_documento, 	   --2
		_pri_pag,   	   --3
		_pri_pag_ap,       --4
		_sini_incu, 	   --5
		_nombre, 		   --6
		_no_pol_nue_aa,    --7
		_no_pol_nue_ap,    --8
		_cod_contratante,  --9
		_n_cliente,		   --10
		a_periodo,		   --11
		_no_pol_ren_aa,	   --12
		_no_pol_ren_ap,	   --13
		_prima_suscrita,   --14
		_pri_can,		   --15
		_pri_dev,		   --16	--prima suscrita año anterior periodo del concurso
		_monto_90_aa,	   --17
		_pri_sus_pag_ap,   --18
		_pri_can_ap,	   --19
		_pri_dev_ap,	   --20
		_monto_90_ap,	   --21
		_cod_vendedor,	   --22
		_nombre_vendedor,  --23
		_cod_ramo,		   --24
		_nombre_ramo,	   --25
		_nombre_tipo,	   --26
		_no_pol_nue_ap_per,--27
		_no_pol_ren_aa_per,--28
		_no_pol_ren_ap_per --29
		);

	--	exit foreach;
	--end foreach
end foreach
--Aplicar Rango a los corredores tomando como base la Primas Suscrita año pasado periodo del concurso. (2016-10 a 2017-09)
foreach
	  select cod_agente,
		 sum(pri_dev_aa)
		into _cod_agente,
			 _pri_dev_ap
		from milan08
	   group by 1
	   order by 1
	  
		if _pri_dev_ap > 500000 then
			let _nombre_tipo = "Rango 1";
		elif _pri_dev_ap > 250000 then
			let _nombre_tipo = "Rango 2";
		elif _pri_dev_ap > 150000 then
			let _nombre_tipo = "Rango 3";
		elif _pri_dev_ap > 100000 then
			let _nombre_tipo = "Rango 4";
		else
			let _nombre_tipo = "Rango 5";
		end if

	 if _pri_dev_ap <= 0 then--ES AGENTE NUEVO, LO COLOCO EN RANGO 6
		let _nombre_tipo = "Rango 6";
	 end if
	 
	 update milan08
		set tipo_agente = _nombre_tipo
	  where cod_agente  = _cod_agente;
	 
end foreach
end
return 0;
END PROCEDURE; 