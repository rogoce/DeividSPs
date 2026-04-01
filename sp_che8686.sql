--******************************************************************************************************************************
-- Procedimiento que genera el Reporte para consurso a Barcelona 2015 para los corredores
--******************************************************************************************************************************

-- Creado    : 16/02/2012 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_che8686;

CREATE PROCEDURE sp_che8686(a_compania CHAR(3), a_sucursal CHAR(3))
RETURNING SMALLINT;--,datetime year to fraction(5);

DEFINE _no_poliza       CHAR(10);
DEFINE _monto           DEC(16,2);
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
define _porc_proporcion    dec(16,2);
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


 --return 0; --se detuvo la corrida 01/10/2015 Armando

--SET DEBUG FILE TO "sp_che86.trc";
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

let _per_ini = "2015-10";

-- Periodo Final del Concurso

if a_periodo > "2016-09" then    --"2015-10"
	let a_periodo = "2016-09";
end if

--let a_periodo = "2014-10"; -- Demetrio Borrar

-- Periodo Pasado
let _ano            = _per_ini[1,4];		  --2015
let _ano            = _ano - 1;				  --2014
let _per_ini_ap     = _ano || _per_ini[5,7];  --2014-10

let _ano            = a_periodo[1,4];		  --2016
let _ano            = _ano - 1;				  --2015
let _per_fin_ap     = _ano || a_periodo[5,7]; --2015-09

-- Diciembre

let _per_fin_dic    = _per_ini[1,4] || "-12"; --2015-12

-- Fechas de los Periodos

let _fecha_aa_ini = mdy(_per_ini[6,7], 1, _per_ini[1,4]);        --es del 01/10/2014

let _fecha_ap_ini = mdy(_per_ini_ap[6,7], 1, _per_ini_ap[1,4]);	 --es del 01/10/2013

let _fecha_aa     = sp_sis36(a_periodo);  --30/09/2015
--let _fecha_aa     = "15/10/2014";	 --esto es para extender el concurso -- Demetrio Borrar

let _fecha_ap     = sp_sis36(_per_fin_ap); --30/09/2014
--let _fecha_ap     = "15/10/2013";	 --esto es para extender el concurso

delete from milan088;
--truncate table milan08;

create temp table tmp_concurso(
no_documento		char(20),
pri_sus_pag			dec(16,2) 	default 0,
pri_pag				dec(16,2) 	default 0,
pri_can				dec(16,2) 	default 0,
pri_dev  			dec(16,2) 	default 0,
sin_pag_aa      	dec(16,2) 	default 0,
sin_pen_aa      	dec(16,2) 	default 0,
sin_pen_ap      	dec(16,2) 	default 0,
no_pol_ren_aa		integer 	default 0,
no_pol_ren_ap		integer 	default 0,
no_pol_nue_aa		integer		default 0,
no_pol_nue_ap		integer		default 0,
no_pol_nue_ap_per	integer		default 0,
pri_sus_pag_ap		dec(16,2) 	default 0,
pri_pag_ap			dec(16,2) 	default 0,
pri_can_ap			dec(16,2) 	default 0,
pri_dev_ap 			dec(16,2) 	default 0,
no_pol_ren_aa_per	integer		default 0,
no_pol_ren_ap_per	integer		default 0,
tipo                integer
) with no log;

create index tmp_concurso_1 on tmp_concurso(no_documento);
create index tmp_concurso_2 on tmp_concurso(tipo);

SET ISOLATION TO DIRTY READ;

let _nombre_tipo = "";
--**********************************************************************************************
-- Prima Suscrita Anno Pasado periodo del concurso
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
	and periodo between _per_ini_ap and _per_fin_ap		--2014-10    a     2015-09
	
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
	
	insert into tmp_concurso(no_documento, pri_dev_ap)
	values (_no_documento, _prima_suscrita);

end foreach

--**********************************************************************************************
-- Prima Suscrita Anno Pasado todo el año		SP_SIS421						***************************************************
--**********************************************************************************************

INSERT INTO tmp_concurso(no_documento, pri_dev) 
SELECT no_documento, prima_suscrita FROM prisusap;

foreach
 select no_documento,
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
		sum(no_pol_ren_ap_per)
   into _no_documento,
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
		_no_pol_ren_ap_per
   from tmp_concurso
  group by no_documento
  order by no_documento

   let _no_poliza = sp_sis21(_no_documento);

   let _cnt = 0;

   --rehabilitada o cancelada en el periodo del concurso no va

   select count(*)
     into _cnt
     from endedmae
    where no_poliza     = _no_poliza
	  and actualizado   = 1
      and cod_endomov in ('003','002')  	
      and fecha_emision >= '01/10/2015'
      and fecha_emision <= '30/09/2016';

   if _cnt > 0 then
		--continue foreach;
	    let _pri_pag = 0;
	    let _pri_can = 0;
		let _sin_pag_aa = 0;
	    let _sin_pen_aa = 0;
		let _sin_pen_dic = 0;
		let _no_pol_ren_aa = 0;
		let _no_pol_ren_ap = 0;
		let _no_pol_nue_aa = 0;
		let _no_pol_nue_ap = 0;
		let _no_pol_nue_ap_per = 0;
	    let _pri_pag_ap = 0;
	    let _pri_can_ap = 0;
		let _pri_dev_ap = 0;
		let _prima_suscrita = 0;
		let _no_pol_ren_aa_per = 0;
		let _no_pol_ren_ap_per = 0;		
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


	select nombre,
	       porc_res_mat
	  into _nombre_ramo,
	       _porc_res_mat
	  from prdramo
	 where cod_ramo = _cod_ramo;


	 select cedula,
	        nombre
	   into _cedula_cont,
	        _n_cliente
	   from cliclien
	  where cod_cliente = _cod_contratante;

     let _flag = 0;

	foreach

		 select cod_agente
		   into _cod_agente
		   from emipoagt
		  where no_poliza = _no_poliza

		 if _cod_agente in('01481') then 		--Unificar Jose Caballero a Marta Caballero

		    let _cod_agente = "01555";

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
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 /*
       let _unificar = 0;	 --01221 Maribel Pineda a 01727 PJ Seg.Asemar	:10/06/2010 Gina 

		SELECT count(*)
		  INTO _unificar
		  FROM agtagent 
		 WHERE cod_agente      = _cod_agente
		   AND agente_agrupado = "01727";

		   if _unificar <> 0 then
			   let _cod_agente = "01727";
		   end if
*/		   
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	   --1  Jovani Mora(00636), Quitza Paz(00732), Rogelio Becerra (00865) , Alberto Camacho (00731) a Servicios Internacionales (01435)	 --
	       if _cod_agente in ("00636","00732","00865","00731") then
			  let _cod_agente = "01435";
		   end if
 
	   --3 Doulos Insurance Consultants  (DICSA)(01048,01837) ,Logos Insurance(01569,01838), Juan Carlos Sanchez(01315,01834), Chung Wai Chun(00623,01836), Katia Mariza Dam de Spagnuolo(01575,01835)
	       if _cod_agente in ("01837","01569","01838","01315","01834","00623","01836","01575","01835","02201") then  --- falta 02201 LATTY
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

		if _cod_agente IN ("00133","01746","01749","01852","02004","02075","02124") then  
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
		
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
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
		if _cod_agente in("00076") then
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
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
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
			exit foreach;
		END IF

		IF _estatus_licencia <> "A" then  -- El corredor debe estar activo
		    let _flag = 1;
			exit foreach;
		END IF

		if _cod_agente = "00180" and   -- Tecnica de Seguros
		   _cod_ramo   = "016"	 and  -- Colectivo de vida
		   _cod_grupo  = "01016" then  -- Grupo Suntracs
		    let _flag = 1;
			exit foreach;
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

		insert into milan088( 
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
		pri_can_aa,		--15
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
		renovaa_per,
		renovap_per
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
		_pri_dev,		   --16	--prima suscrita año anterior completo
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
		_no_pol_ren_aa_per,
		_no_pol_ren_ap_per
		);

		exit foreach;
	end foreach
end foreach

--Aplicar Rango a los corredores tomando como base la Primas Suscrita año pasado ( 2014)
foreach
	  select cod_agente,
		 sum(pri_dev_aa),   
		 sum(pri_pag_aa),
		 sum(pri_dev_ap)
		into _cod_agente,
			 _pri_dev_ap,
			 _prima_suscrita,
			 _pri_sus_ap
		from milan088
	   group by 1
	   order by 1
	  
		 if _pri_dev_ap > 500000 then
			let _nombre_tipo = "Rango 1";
		 elif _pri_dev_ap >= 250000 then
			let _nombre_tipo = "Rango 2";
		 elif _pri_dev_ap >= 150000 then
			let _nombre_tipo = "Rango 3";
		 else
			let _nombre_tipo = "Rango 4";
		 end if

	 if _pri_sus_ap <= 0 then--ES AGENTE NUEVO, LO COLOCO EN RANGO 5
		let _nombre_tipo = "Rango 5";
	 end if
	 
	 update milan088
		set tipo_agente = _nombre_tipo
	  where cod_agente  = _cod_agente;
	 
end foreach
--drop table tmp_concurso;
end
return 0;
END PROCEDURE; 