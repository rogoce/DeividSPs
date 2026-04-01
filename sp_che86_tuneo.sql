--*****************************************************************************************
-- Procedimiento que genera el Reporte para convencion a Hawaii 2018 para los corredores
--*****************************************************************************************
--CONVENCION HAWAII 2018	*******************************************************************************************************
--1. sp_sis421 carga la prima suscrita año anterior periodo del concurso en la tabla prisusap.
--2. sp_che86_aa carga la tabla fis_concurso1 con los valores del año pasado periodo del concurso. Esta tabla no se borra, para que las cifras año pasado periodo concurso no se muevan.
--3. En el procedimiento sp_che86 que es el que corre diariamente, se borra la tabla milan08 y la tabla fis_concurso. Se carga fis_concurso a partir de fis_concurso1 y sigue el proceso de carga de datos,
--   buscando año actual periodo del concurso y año pasado periodo del concurso a la fecha(es decir al mes que va corriendo año actual).


DROP PROCEDURE sp_che86_tuneo;
CREATE PROCEDURE sp_che86_tuneo(a_compania CHAR(3), a_sucursal CHAR(3))
RETURNING SMALLINT;

DEFINE _no_poliza       CHAR(10);
DEFINE _monto           DEC(16,2);
DEFINE _fecha           DATE;     
DEFINE _prima,_monto2           DEC(16,2);
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
define _cod_agente_tmp  char(5);
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
DEFINE _monto_dev           DEC(16,2);
define _pagado,my_sessionid integer;
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

set isolation to dirty read;
--return 0; --se detuvo la corrida 04/10/2017 Armando

--SET DEBUG FILE TO "sp_che86.trc";
--TRACE ON;

begin 
on exception set _error, _error_isam, _error_desc
	return _error;
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
  
  let my_sessionid = DBINFO('sessionid');
  
{ SELECT DBINFO('sessionid') AS my_sessionid
   INTO my_sessionid
   FROM systables
  WHERE tabname = 'systables'; }

--Para que tome en cuenta el periodo anterior mientras no se haya cerrado.
if (today - _fecha_cierre) > 1 then
	let a_periodo = a_periodo;
else
	let a_periodo = _emi_periodo;
end if

--*****************************
-- Periodo Inicial del Concurso

let _per_ini      = "2017-10";
let _fecha_fin_ap = sp_sis36(_per_ini);	--31/10/2017

-- Periodo Final del Concurso

if a_periodo > "2018-09" then
	let a_periodo = "2018-09";
end if

let a_periodo = '2018-05';

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

SET ISOLATION TO DIRTY READ;

delete from milan08;
delete from fis_concurso;

--Insercion de registros del año pasado periodo del concurso

begin
	on exception in(-535)

	end exception 	
	begin work;
end

INSERT INTO fis_concurso
SELECT * FROM fis_concurso1;

COMMIT work;

begin
	on exception in(-535)

	end exception 	
	begin work;
end

let _nombre_tipo = "";
--**********************************************************************************************
-- Prima Pagada Este AÑO 
--**********************************************************************************************
{INSERT INTO log_jb (mensaje) values ('Entrando a Ciclo Prima Pagada este año...1.');
foreach
	select doc_remesa,
		   sum(prima_neta)
	  into _no_documento,
		   _monto
	  from cobredet
	 where periodo     >= _per_ini			--2017-10
	   and periodo     <= a_periodo			--2018-09
	   and actualizado = 1
	   and tipo_mov    in ("P", "N")
	  group by doc_remesa 

	let _no_poliza = sp_sis21(_no_documento);

	select cod_tipoprod,
	       cod_formapag,
		   prima_suscrita,
		   cod_ramo,
		   cod_perpago,
		   estatus_poliza,
		   cod_grupo
	  into _cod_tipoprod,
	       _cod_formapag,
		   _prima_suscri,
		   _cod_ramo,
		   _cod_perpago,
		   _estatus_poliza,
		   _cod_grupo
	  from emipomae
	 where no_poliza = _no_poliza;

	let _monto_fac_ac = 0.00;
	
	select sum(d.prima_neta * (c.porc_partic_prima/100) * (c.porc_proporcion/100))
	  into _monto_fac_ac
	  from cobredet d,cobreaco c, reacomae r
	 where c.no_remesa = d.no_remesa
	   and c.renglon = d.renglon
	   and r.cod_contrato = c.cod_contrato
	   and d.doc_remesa = _no_documento
	   and d.actualizado = 1
	   and d.tipo_mov in ("P", "N")
	   and d.periodo >= _per_ini			--2017-10
	   and d.periodo <= a_periodo			--2018-09
	   and r.tipo_contrato = 3;

	if _monto_fac_ac is null then
		let _monto_fac_ac = 0.00;
	end if

	let _monto = _monto - _monto_fac_ac;

	if _cod_tipoprod = "001" then
		
		if _cod_grupo in('00000','1000') then --Grupo del estado no aplica
			continue foreach;
		end if
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
	
	
	
	--Quitar facultativo cedido
	--foreach
		

		{if _porc_partic_prima is null then
			let _porc_partic_prima = 0.00;
		end if
		
		let _monto_fac = _monto * (_porc_partic_prima/100) * (_porc_proporcion/100);
		let _monto_fac_ac = _monto_fac_ac + _monto_fac;
	end foreach}
{	

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
	let _valor = sp_sis101a(_no_documento,'01/10/2017','30/09/2018',my_sessionid); --se cambia a tabla fisica 05/06/2018
	foreach
		select cod_agente,
		       porcentaje
		  into _cod_agente,
               _porc_partic_agt
		  from con_corr
		 where sessionid = my_sessionid
		  
		let _monto2 = 0.00;
		let _monto2 = _monto * _porc_partic_agt /100;
		insert into fis_concurso(no_documento, pri_pag,tipo,cod_agente)
		values (_no_documento, _monto2, 1, _cod_agente);
	end foreach
end foreach

INSERT INTO log_jb (mensaje) values ('Saliendo del Ciclo Prima Pagada este año...1.');}

INSERT INTO log_jb (mensaje, hora) values ('Saliendo del Ciclo Prima Suscrita año pasado...4.', CURRENT);
--**********************************************************************************************
-- Siniestros Pagados AÑO ACTUAL
--**********************************************************************************************
call sp_rec01(a_compania, a_sucursal, _per_ini, a_periodo) returning _filtros;

INSERT INTO log_jb (mensaje, hora) values ('Entrando al Ciclo Siniestros pagados año actual...5.', CURRENT);

foreach
 select doc_poliza,
        pagado_bruto   
   into _no_documento,
        _sin_pag_aa
   from tmp_sinis

	let _no_poliza = sp_sis21(_no_documento);
	let _valor = sp_sis101a(_no_documento,'01/10/2017','30/09/2018',my_sessionid);
	foreach
		select cod_agente,
		       porcentaje
		  into _cod_agente,
               _porcentaje
		  from con_corr
 		 where sessionid = my_sessionid 
	
		let _monto2 = 0.00;  
		let _monto2 = _sin_pag_aa * _porcentaje / 100;  
		insert into fis_concurso(no_documento, sin_pag_aa, cod_agente)
		values (_no_documento, _monto2, _cod_agente);
	end foreach
end foreach
drop table tmp_sinis;

INSERT INTO log_jb (mensaje, hora) values ('Saliendo del Ciclo Siniestros pagados año actual...5.', CURRENT);

COMMIT work;
end
return 0;
END PROCEDURE; 