--***************************************************************************************
-- Procedimiento que genera el Reporte para convencion a PARIS 2024 para los corredores
--***************************************************************************************
--CONVENCION PARIS 2024
--1. sp_sis421       = carga la prima suscrita año anterior periodo del concurso en la tabla prisusap.
--2. sp_che86_clasif = clasificacion de los corredores por rango.
--3. sp_che86_aa     = carga la tabla fis_concurso1 con los valores del año pasado periodo del concurso. Esta tabla no se borra, para que las cifras año pasado periodo concurso no se muevan.
--4. En el procedimiento sp_che86 que es el que corre diariamente, se borra la tabla milan08 y la tabla fis_concurso. Se carga fis_concurso a partir de fis_concurso1 y sigue el proceso de carga de datos,
--   buscando año actual periodo del concurso y año pasado periodo del concurso a la fecha(es decir al mes que va corriendo año actual).


DROP PROCEDURE sp_che86;
CREATE PROCEDURE sp_che86(a_compania CHAR(3), a_sucursal CHAR(3))
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
DEFINE _tipo_forma,_flag1      SMALLINT;
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
define _prima_can,_pri_dev_aa		DEC(16,2);
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
define _fecha_aa,_fecha_dic_aa        date;
define _fecha_ap_ini    date;
define _fecha_ap,_fecha_dic_ap        date;
define _vigente         smallint;
define v_filtros        varchar(255);
define a_periodo        char(7);
define _n_cliente       varchar(100);
define _nueva_renov     char(1);
define _periodo_reno    char(7);
define _vigen_ini,_date_added	date;
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
define _unificar,_fronting     smallint;

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
define _valor,_monto3   decimal(16,2);
define _cod_perpago		char(3);
define _fecha_proceso	datetime year to fraction(5);
define _pri_sus_ap      decimal(16,2);
define _per_siguiente   char(7);
--define _fecha_fin_ap    date;
define _porc_partic_agt decimal(16,4);
define _porcentaje decimal(16,4);
define _mensaje         varchar(100);

set isolation to dirty read;
--return 0; 
--SET DEBUG FILE TO "sp_che86.trc";
--TRACE ON;

begin 
on exception set _error, _error_isam, _error_desc
	rollback work;
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
let _pri_dev_aa     = 0;
let _fronting       = 0;

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
let _per_ini      = "2023-01";

-- Periodo Final del Concurso
if a_periodo > "2023-12" then
	let a_periodo = "2023-12";
end if

-- Periodo Pasado
let _ano            = _per_ini[1,4];		  --2022
let _ano            = _ano - 1;				  --2021
let _per_ini_ap     = _ano || _per_ini[5,7];  --2021-01

let _ano            = a_periodo[1,4];		  --2022
let _ano            = _ano - 1;				  --2021
let _per_fin_ap     = _ano || a_periodo[5,7]; --2021-01

--Diciembre año pasado
let _per_fin_dic  = _ano || "-12";
let _fecha_dic_ap = sp_sis36(_per_fin_dic);

-- Diciembre año actual
let _per_fin_dic  = _per_ini[1,4] || "-12";
let _fecha_dic_aa     = sp_sis36(_per_fin_dic);

-- Fechas de los Periodos
let _fecha_aa_ini = mdy(_per_ini[6,7], 1, _per_ini[1,4]);         --es del 01/01/2022
let _fecha_ap_ini = mdy(_per_ini_ap[6,7], 1, _per_ini_ap[1,4]);	  --es del 01/01/2021
let _fecha_aa     = sp_sis36(a_periodo);   --31/01/2022
let _fecha_ap     = sp_sis36(_per_fin_ap); --31/01/2021

SET ISOLATION TO DIRTY READ;

delete from fis_concurso;

--Insercion de registros del año pasado periodo del concurso
begin
	on exception in(-535)
	end exception 	
	begin work;
end
commit work;

let _nombre_tipo = "";
--*************************************************************************************
-- Prima neta cobrada devengada periodo convencion 2023-01 Al periodo se esta evaluando
--*************************************************************************************
INSERT INTO log_jb (mensaje, hora,hora_real) values ('Entr Ciclo Prima Pagada Dev periodo convencion.1', CURRENT,CURRENT);
foreach
	select doc_remesa
	  into _no_documento
	  from cobredet
	 where periodo     >= _per_ini
	   and periodo     <= a_periodo
	   and actualizado = 1
	   and tipo_mov    in ("P", "N")
	 group by doc_remesa
	 order by doc_remesa

	let _valor = sp_sis101a(_no_documento,'01/01/2023','31/12/2023', my_sessionid);
	call sp_dev06f(_no_documento,_fecha_aa,'01/01/2023',_fecha_aa) returning _valor,_mensaje,_pri_dev_aa;
	if _pri_dev_aa is null then
		let _pri_dev_aa = 0.00;
	end if
	foreach
		select cod_agente,
		       porcentaje
		  into _cod_agente,
               _porc_partic_agt
		  from con_corr
		 where sessionid = my_sessionid
		let _monto2 = 0.00;
		let _monto2 = _pri_dev_aa * _porc_partic_agt /100;
		begin work;
		insert into fis_concurso(no_documento, pri_dev_ap, tipo,cod_agente) --pri_pag = corresponde a prima neta cobrada devengada
		values (_no_documento, _monto2, 8,_cod_agente);
		commit work;
	end foreach
end foreach

INSERT INTO log_jb (mensaje, hora,hora_real) values ('Sal de Ciclo Prima Pag Dev periodo convencion.1', CURRENT,CURRENT);
--**********************************************************************
--polizas que no estan en fis_concurso y que la vigencia final es >= al inicio de la convencion.
INSERT INTO log_jb (mensaje, hora,hora_real) values ('Entr Ciclo pol Dev nva condicion.11', CURRENT,CURRENT);
foreach
	select no_documento
	  into _no_documento
	  from emipoliza
	 where vigencia_fin >= '01/01/2023'
	   and vigencia_inic < '01/01/2023'
	   and no_documento not in(
	   select distinct doc_remesa
		 from cobredet
		where periodo     >= '2023-01'
		  and periodo     <= '2023-12'
		  and actualizado = 1
		  and tipo_mov    in ("P", "N"))

	let _valor = sp_sis101a(_no_documento,'01/01/2023','31/12/2023', my_sessionid);
	call sp_dev06f(_no_documento,_fecha_aa,'01/01/2023',_fecha_aa) returning _valor,_mensaje,_pri_dev_aa;
	if _pri_dev_aa is null then
		let _pri_dev_aa = 0.00;
	end if
	foreach
		select cod_agente,
		       porcentaje
		  into _cod_agente,
               _porc_partic_agt
		  from con_corr
		 where sessionid = my_sessionid
		let _monto2 = 0.00;
		let _monto2 = _pri_dev_aa * _porc_partic_agt /100;
		begin work;
		insert into fis_concurso(no_documento, pri_dev_ap, tipo,cod_agente) --pri_pag = corresponde a prima neta cobrada devengada
		values (_no_documento, _monto2, 8,_cod_agente);
		commit work;
	end foreach
end foreach
begin
	on exception in(-535)
	end exception 	
	begin work;
end
INSERT INTO log_jb (mensaje, hora,hora_real) values ('Sal de Ciclo pol Dev nva condicion.11', CURRENT,CURRENT);	   
--**********************************************************************
-- Prima Pagada periodo convencion 2023-01 Al periodo se esta evaluando
--**********************************************************************
INSERT INTO log_jb (mensaje, hora,hora_real) values ('Entr a Ciclo Prima Pagada periodo convencion.2', CURRENT,CURRENT);
foreach
	select doc_remesa,
		   sum(prima_neta)
	  into _no_documento,
		   _monto
	  from cobredet
	 where periodo     >= _per_ini
	   and periodo     <= a_periodo
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
	   and d.periodo >= _per_ini
	   and d.periodo <= a_periodo
	   and r.tipo_contrato = 3;

	if _monto_fac_ac is null then
		let _monto_fac_ac = 0.00;
	end if

	let _monto = _monto - _monto_fac_ac;

	if _cod_tipoprod = "001" then	          --Coas. Mayoritario
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
		   and fecha_impresion between '01/01/2023' and '31/12/2023';

		if _pagado = 1 then
			if _fecha_anulado is not null then
				if _fecha_anulado >= '01/01/2023' and _fecha_anulado <= '31/12/2023' then
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
	if _cod_formapag in('003','005') then	--Es TCR o ACH
		if _estatus_poliza in (2,4) then
			continue foreach;	--POLIZA ANULADA O CANCELADA, NO SE DEBE TOMAR EN CUENTA SI ES ELECTRONICO
		end if
		let _flag1 = 0;
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
			if abs(_monto) > abs(_prima_suscri) then
				let _flag1 = 1;	--Se marca para saber que ya se le quito el facultivo.
			else
				let _monto = _prima_suscri;
			end if
		end if
		--Quitar el facultativo cedido
		if _flag1 = 0 then
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
	end if
	let _valor = sp_sis101a(_no_documento,'01/01/2023','31/12/2023',my_sessionid); --se cambia a tabla fisica 05/06/2018
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
		values (_no_documento, _monto2, 2, _cod_agente);
	end foreach
end foreach

INSERT INTO log_jb (mensaje, hora,hora_real) values ('Sal Ciclo Prima Pagada periodo convencion.2', CURRENT,CURRENT);
INSERT INTO log_jb (mensaje, hora,hora_real) values ('Haciendo insert a Fis_Concurso...3.', CURRENT,CURRENT);
INSERT INTO fis_concurso
SELECT * FROM fis_concurso1;
INSERT INTO log_jb (mensaje, hora,hora_real) values ('Saliendo insert a Fis_Concurso...3.', CURRENT,CURRENT);
COMMIT WORK;
begin
	on exception in(-535)
	end exception 	
	begin work;
end
--**********************************************************************************************
-- Siniestros Pagados AÑO ACTUAL
--**********************************************************************************************
call sp_rec01(a_compania, a_sucursal, _per_ini, a_periodo) returning _filtros;

INSERT INTO log_jb (mensaje, hora,hora_real) values ('Entr Ciclo Siniestros pagados año actual.4', CURRENT,CURRENT);

foreach
 select doc_poliza,
        pagado_bruto   
   into _no_documento,
        _sin_pag_aa
   from tmp_sinis

	let _no_poliza = sp_sis21(_no_documento);
	let _valor = sp_sis101a(_no_documento,'01/01/2023','31/12/2023',my_sessionid);
	foreach
		select cod_agente,
		       porcentaje
		  into _cod_agente,
               _porcentaje
		  from con_corr
 		 where sessionid = my_sessionid 
	
		let _monto2 = 0.00;  
		let _monto2 = _sin_pag_aa * _porcentaje / 100;
		insert into fis_concurso(no_documento, sin_pag_aa,tipo, cod_agente)
		values (_no_documento, _monto2, 3,_cod_agente);
	end foreach
end foreach
drop table tmp_sinis;

INSERT INTO log_jb (mensaje, hora,hora_real) values ('Sal Ciclo Siniestros pagados año actual.4', CURRENT,CURRENT);
--**********************************************************************************************
-- Siniestros Pendientes AÑO ACTUAL
--**********************************************************************************************
INSERT INTO log_jb (mensaje, hora,hora_real) values ('Entr Ciclo Siniestros pendientes año actual.5', CURRENT,CURRENT);
foreach 
 select no_reclamo,		
        SUM(variacion)
   into _no_reclamo,	
        _sin_pen_aa
   from rectrmae 
  where cod_compania = a_compania
    and periodo      <= a_periodo
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
	let _valor = sp_sis101a(_no_documento,'01/01/2023','31/12/2023',my_sessionid);
	foreach
		select cod_agente,
		       porcentaje
		  into _cod_agente,
               _porcentaje
		  from con_corr
  		 where sessionid = my_sessionid
		 
		let _monto2 = 0.00;  
		let _monto2 = _sin_pen_aa * _porcentaje /100;  
		insert into fis_concurso(no_documento, sin_pen_aa, tipo, cod_agente)
		values (_no_documento, _monto2, 4, _cod_agente);
	end foreach
end foreach
INSERT INTO log_jb (mensaje, hora,hora_real) values ('Sal Ciclo Siniestros pendientes año actual.5', CURRENT,CURRENT);
--**********************************************************************************************
-- Siniestros Pendientes Ano Pasado al corte
--**********************************************************************************************
{foreach 
	select no_reclamo,		
		   SUM(variacion)
	  into _no_reclamo,	
		   _sin_pen_dic
	  from rectrmae 
	 where cod_compania = a_compania
	   and periodo      <= '2019-09'
	   and actualizado  = 1
	 group by no_reclamo
	having sum(variacion) > 0 
	 
	if _no_reclamo = '458103' then
		let _sin_pen_dic = 0.00;
	end if

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

	let _sin_pen_dic = _sin_pen_dic * (_porc_coaseguro / 100);
	
	let _valor = sp_sis101a(_no_documento,'01/10/2018','30/09/2019',my_sessionid);	--Crea tabla tmp_corr con el corredor
	foreach
		select cod_agente,
			   porcentaje
		  into _cod_agente,
			   _porcentaje
		  from con_corr
		 where sessionid = my_sessionid
		  
		let _monto2 = 0.00;  
		let _monto2 = _sin_pen_dic * _porcentaje /100;  
		insert into fis_concurso(no_documento, sin_pen_ap, cod_agente, tipo)
		values (_no_documento, _monto2, _cod_agente,6);
	end foreach
end foreach}

---**********************************************************************************************
-- Polizas Nuevas ACTUAL a la fecha
call sp_bo077conv(_fecha_aa_ini, _fecha_aa) returning _error, _error_desc;
---**********************************************************************************************

INSERT INTO log_jb (mensaje, hora,hora_real) values ('Entrando al Ciclo Nuevas año actual...6.', CURRENT,CURRENT);
foreach
		select no_documento,
			   sum(no_pol_nueva)
		  into _no_documento,
			   _no_pol_nue_aa
		  from tmp_persis
		 group by no_documento

		let _valor = sp_sis101a(_no_documento,'01/01/2023','31/12/2023',my_sessionid);

		foreach
			select cod_agente
			  into _cod_agente
			  from con_corr
		     where sessionid = my_sessionid
			
			insert into fis_concurso(
			no_documento, 
			no_pol_nue_aa, 
			cod_agente,
			tipo
			)
			values(
			_no_documento, 
			_no_pol_nue_aa,
			_cod_agente,
			5
			);
		end foreach
end foreach
drop table tmp_persis;
INSERT INTO log_jb (mensaje, hora,hora_real) values ('Saliendo del Ciclo Nuevas año actual...6.', CURRENT,CURRENT);

--**PERSISTENCIA**
--************************************************************************
-- Polizas Nuevas y Renovadas AÑO PASADO inicio del concurso a la fecha
--************************************************************************
call sp_bo077_2('01/01/2022', _fecha_ap, _fecha_aa) returning _error, _error_desc;

INSERT INTO log_jb (mensaje, hora,hora_real) values ('Entr Ciclo Nuevas y Renovadas año pasado persis.7', CURRENT,CURRENT);
foreach
	select no_documento,
	       sum(no_pol_nueva_per),
		   sum(no_pol_renov_per)
	  into _no_documento,
		   _no_pol_nue_ap_per,
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

	let _valor = sp_sis101a(_no_documento,'01/01/2022','31/12/2022',my_sessionid);
	foreach
		select cod_agente
		  into _cod_agente
		  from con_corr
		 where sessionid = my_sessionid 
	
		insert into fis_concurso(
		no_documento, 
		no_pol_nue_ap_per,
		no_pol_ren_ap_per,
		cod_agente
		)
		values(
		_no_documento, 
		_no_pol_nue_ap_per,
		_no_pol_ren_ap_per,
		_cod_agente
		);
	end foreach
end foreach
drop table tmp_persis;

INSERT INTO log_jb (mensaje, hora,hora_real) values ('Sal Ciclo Nuevas y Renovadas año pasado persis.7', CURRENT,CURRENT);
----**********************************************************************************************
-- Polizas Renovadas AÑO ACTUAL a la fecha persistencia
----**********************************************************************************************
call sp_bo077_2('01/01/2023', _fecha_aa, _fecha_aa) returning _error, _error_desc;

INSERT INTO log_jb (mensaje, hora,hora_real) values ('Entr Ciclo Renovadas año actual persis.8', CURRENT,CURRENT);
foreach
	select no_documento,
		   sum(no_pol_renov_per)
	  into _no_documento,
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
	let _valor = sp_sis101a(_no_documento,'01/01/2023','31/12/2023',my_sessionid);
	foreach
		select cod_agente
		  into _cod_agente
		  from con_corr
		 where sessionid = my_sessionid
		
		insert into fis_concurso(
		no_documento, 
		no_pol_ren_aa_per,
		cod_agente
		)
		values(
		_no_documento, 
		_no_pol_ren_aa_per,
		_cod_agente
		);
		
	end foreach
end foreach
drop table tmp_persis;
INSERT INTO log_jb (mensaje, hora,hora_real) values ('Sal Ciclo Renovadas año actual persis.8', CURRENT,CURRENT);
INSERT INTO log_jb (mensaje, hora,hora_real) values ('Entr Ciclo Group by Fis_Concurso.9', CURRENT,CURRENT);
--*******************
delete from milan08;
--*******************
foreach
	select no_documento,
		   cod_agente,
		   sum(pri_pag),
   		   sum(pri_can),
		   sum(pri_dev),
		   sum(sin_pag_aa),
		   sum(sin_pen_aa),			--7
		   sum(sin_pen_ap),
		   sum(no_pol_ren_aa),
		   sum(no_pol_ren_ap),		--10
		   sum(no_pol_nue_aa),		--11
		   sum(no_pol_nue_ap),
		   sum(no_pol_nue_ap_per),	--13
		   sum(pri_pag_ap),
		   sum(pri_can_ap),
		   sum(pri_dev_ap),			--PNCD actual
		   sum(pri_sus_pag),
		   sum(no_pol_ren_aa_per),	--18 renovadas año actual persistencia
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
		   _no_pol_nue_aa,	   --11 polizas nuevas AA
		   _no_pol_nue_ap,
		   _no_pol_nue_ap_per, --polizas nuevas AP persistencia
		   _pri_pag_ap,
		   _pri_can_ap,
		   _pri_dev_ap,
		   _prima_suscrita,
		   _no_pol_ren_aa_per,	--18 renovadas año actual persistencia
		   _no_pol_ren_ap_per,
		   _monto_90_ap,
		   _monto_90_aa
	  from fis_concurso
	 group by no_documento,cod_agente
	 order by no_documento,cod_agente

    let _no_poliza = sp_sis21(_no_documento);

    let _cnt = 0;

	select cod_grupo, 
	       cod_ramo, 
	       cod_pagador, 
	       cod_contratante, 
	       cod_tipoprod,
		   sucursal_origen,
		   cod_subramo,
		   fronting
	  into _cod_grupo,
	       _cod_ramo,
	       _cod_pagador,
	       _cod_contratante,
	       _cod_tipoprod,
		   _cod_agencia,
		   _cod_subramo,
		   _fronting
	  from emipomae
	 where no_poliza = _no_poliza;
	
	if _fronting is null then
		let _fronting = 0;
	end if
    if _fronting = 1 then
		continue foreach;
	end if
	select concurso
	  into _concurso
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo; 			

	if _concurso = 0 then -- Excluir del Concurso
	    if _cod_ramo = '018' and _cod_agente = '00259' and _cod_grupo = '1126' then	--Correo Analisa 04/07/2019
		else
			continue foreach;
		end if
	end if  	
	if _cod_tipoprod = "004" then	--Excluir Reaseguro Asumido
		continue foreach;
	end if
    if _cod_ramo = '001' and _cod_subramo = '006' then  -- Se excluye Zona L.,France F. y Cocosolito. Ramo Incendio
		continue foreach;
	end if	
    if _cod_ramo = '003' and _cod_subramo = '005' then  -- Se excluye Zona L.,France F. y Cocosolito. Ramo Multiriesgo
		continue foreach;
	end if

	if _cod_grupo in('00000','1000') then --Grupo del estado no aplica
		continue foreach;
	end if

    let _cnt = 0;

	-- Siniestros Incurridos
		
	let _sini_incu = _sin_pag_aa + _sin_pen_aa - _sin_pen_dic;

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select cedula,
	       nombre
	  into _cedula_cont,
	       _n_cliente
	  from cliclien
	 where cod_cliente = _cod_contratante;

    let _flag = 0;

	--********  Unificacion de Agente *******
	let _cod_agente_tmp = _cod_agente;
	call sp_che168(_cod_agente_tmp) returning _error,_cod_agente;

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
	n_cliente,		--10 *
	periodo,		--11 *
	renovaa,		--12 * renovadas anno actual 
	renovap,		--13 * renovadas anno pasado 
	pri_pag_aa,		--14 * prima suscrita
	pri_can_aa,		--15 * prima suscrita periodo del concurso al mes que esta corriendo
	pri_dev_aa,		--16 * prima suscrita año pasado periodo del concurso
	monto_90_aa,	--17
	pri_pag_ap,		--18 * prima neta cobrada devengada periodo del concurso actual
	pri_can_ap,		--19 * prima cobrada año pasado periodo del concurso
	pri_dev_ap,		--20 * prima suscrita anno pasado
	monto_90_ap,	--21
	cod_vendedor,	--22 *
	nombre_vendedor,--23 *
	cod_ramo,		--24 *
	nombre_ramo,	--25 *
	tipo_agente,	--26 *
	vigenteap_per,	--27 * polizas nuvas año pasado persistencia
	renovaa_per,	--28 * renovadas año actual persistencia
	renovap_per		--29 * renovadas año pasado persistencia
	)				
	values(
	_cod_agente, 	   --1
	_no_documento, 	   --2
	_pri_pag,   	   --3
	_pri_pag_ap,       --4
	_sini_incu, 	   --5
	_nombre, 		   --6
	_no_pol_nue_aa,    --7
	0,                 --8
	_cod_contratante,  --9
	_n_cliente,		   --10
	a_periodo,		   --11
	_no_pol_ren_aa,	   --12
	_no_pol_ren_ap,	   --13
	_prima_suscrita,   --14
	_pri_can,		   --15
	_pri_dev,		   --16
	_monto_90_aa,	   --17
	_pri_dev_ap,   	   --18
	_pri_can_ap,	   --19
	0,	               --20
	0,	   			   --21
	_cod_vendedor,	   --22
	_nombre_vendedor,  --23
	_cod_ramo,		   --24
	_nombre_ramo,	   --25
	_nombre_tipo,	   --26
	_no_pol_nue_ap_per,--27
	_no_pol_ren_aa_per,--28
	_no_pol_ren_ap_per --29
	);
end foreach

INSERT INTO log_jb (mensaje, hora,hora_real) values ('Sal Ciclo Group by Fis_Concurso.9', CURRENT,CURRENT);
--Aplicar Rango a los corredores tomando como base la Primas Suscrita año pasado periodo del concurso. (2016-10 a 2017-09)

INSERT INTO log_jb (mensaje, hora,hora_real) values ('Entr Ciclo ubicacion de agentes.10', CURRENT,CURRENT);
delete from con_corr
 where sessionid = my_sessionid;
 
foreach
    select cod_agente,
	       sum(pri_dev_aa)
	  into _cod_agente,
		   _pri_dev_ap
	  from milan08
     group by 1
     order by 1
	 
	select date_added
      into _date_added
      from agtagent
     where cod_agente = _cod_agente;	  
	  
	if _pri_dev_ap > 500000 then
		let _nombre_tipo = "Rango 1";
	elif _pri_dev_ap >= 250000 then
		let _nombre_tipo = "Rango 2";
	elif _pri_dev_ap >= 150000 then
		let _nombre_tipo = "Rango 3";
	elif _pri_dev_ap >= 120000 then
		let _nombre_tipo = "Rango 4";
	else
		let _nombre_tipo = "Rango 5";
	end if

	if year(_date_added) = 2023 then --ES AGENTE NUEVO, LO COLOCO EN RANGO 6
		let _nombre_tipo = "Rango 6";
	end if
	 
	update milan08
	   set tipo_agente = _nombre_tipo
	 where cod_agente  = _cod_agente;
end foreach
INSERT INTO log_jb (mensaje, hora,hora_real) values ('Sal Ciclo ubicacion de agentes.10', CURRENT,CURRENT);
COMMIT work;
end
return 0;
END PROCEDURE;