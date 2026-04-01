--**************************************************************************************
-- Procedimiento que genera el Reporte para consurso a Paris 2014 para los corredores
--**************************************************************************************

-- Creado    : 16/02/2012 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che86;

CREATE PROCEDURE sp_che86(a_compania CHAR(3), a_sucursal CHAR(3))
RETURNING SMALLINT;

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

define _no_pol_nue_ap_per	integer;
define _no_pol_ren_aa_per	integer;
define _no_pol_ren_ap_per	integer;

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



-- return 0; --se detuvo la corrida 08/11/2013 Armando

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
let	_pri_dev		= 0;
let _monto_90_ap    = 0;

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
-- Periodo Inicial del Consurso

let _per_ini = "2013-10";

-- Periodo Final del Consurso

if a_periodo > "2014-09" then
	let a_periodo = "2014-09";
end if

-- Periodo Pasado

let _ano            = _per_ini[1,4];		  --2012
let _ano            = _ano - 1;				  --2011
let _per_ini_ap     = _ano || _per_ini[5,7];  --2011-11

let _ano            = a_periodo[1,4];		  --2013
let _ano            = _ano - 1;				  --2012
let _per_fin_ap     = _ano || a_periodo[5,7]; --2012-10

-- Diciembre

let _per_fin_dic    = _per_ini[1,4] || "-12"; --2012-12

-- Fechas de los Periodos

let _fecha_aa_ini = mdy(_per_ini[6,7], 1, _per_ini[1,4]);        --es del 01/11/2012

let _fecha_ap_ini = mdy(_per_ini_ap[6,7], 1, _per_ini_ap[1,4]);	 --es del 01/11/2011

let _fecha_aa     = sp_sis36(a_periodo);  --31/10/2013
--let _fecha_aa     = "21/10/2012";	 --esto es para extender el concurso

let _fecha_ap     = sp_sis36(_per_fin_ap); --31/10/2012
--let _fecha_ap     = "21/10/2011";	 --esto es para extender el concurso

delete from milan08;

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
no_pol_ren_ap_per	integer		default 0
) with no log;

SET ISOLATION TO DIRTY READ;

--**********************
-- Prima Pagada Este Anno 
--**********************
foreach
 select doc_remesa,
        prima_neta,
		fecha,
		renglon
   into _no_documento,
   		_monto,
		_fecha_pago,
		_renglon
   from cobredet
  where periodo     >= _per_ini		
    and periodo     <= a_periodo
	and actualizado = 1
	and tipo_mov    in ("P", "N")

	let _no_poliza = sp_sis21(_no_documento);

	select cod_tipoprod
	  into _cod_tipoprod
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

	insert into tmp_concurso(no_documento, pri_pag)
	values (_no_documento, _monto);

end foreach

--************************
-- Prima Pagada Anno Pasado
--************************
foreach
 select doc_remesa,
        prima_neta,
		fecha,
		renglon
   into _no_documento,
   		_monto,
		_fecha_pago,
		_renglon
   from cobredet
  where periodo     >= _per_ini_ap
    and periodo     <= _per_fin_ap
	and actualizado = 1
	and tipo_mov    in ("P", "N")

   {	if _fecha_pago > "21/10/2010" then  --Esto se incluyo para que tome registros hasta el 21/10/2010
		continue foreach;
	end if}

	let _no_poliza = sp_sis21(_no_documento);

	select cod_tipoprod
	  into _cod_tipoprod
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

	insert into tmp_concurso(no_documento, pri_pag_ap)
	values (_no_documento, _monto);

end foreach

--**********************
-- Prima Suscrita Actual
--**********************
foreach
 select no_documento,
		sum(prima_suscrita)
   into _no_documento,
		_prima_suscrita
   from endedmae
  where actualizado  = 1
	and periodo between _per_ini and a_periodo
  group by no_documento
	

	insert into tmp_concurso(no_documento, pri_sus_pag)
	values (_no_documento, _prima_suscrita);

end foreach

--***************************
-- Prima Suscrita Anno Pasado
--***************************
foreach
 select no_documento,
		sum(prima_suscrita)
   into _no_documento,
		_prima_suscrita
   from endedmae
  where actualizado  = 1
	and periodo between _per_ini_ap and _per_fin_ap
	group by no_documento
	

	insert into tmp_concurso(no_documento, pri_dev_ap)
	values (_no_documento, _prima_suscrita);

end foreach

--*********************************
-- Siniestros Pagados Anno Actual --
--*********************************
call sp_rec01(a_compania, a_sucursal, _per_ini, a_periodo) returning _filtros;

foreach
 select doc_poliza,
        pagado_bruto   
   into _no_documento,
        _sin_pag_aa
   from tmp_sinis

	insert into tmp_concurso(no_documento, sin_pag_aa)
	values (_no_documento, _sin_pag_aa);

end foreach

drop table tmp_sinis;

--**********************************************
-- Siniestros Pendientes Diciembre Anno Pasado --
--**********************************************
foreach 
 select no_reclamo,		
        SUM(variacion)
   into _no_reclamo,	
        _sin_pen_dic
   from rectrmae 
  where cod_compania = a_compania
    and periodo      <= _per_fin_dic 
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

	let _sin_pen_dic = _sin_pen_dic * (_porc_coaseguro / 100);

	insert into tmp_concurso(no_documento, sin_pen_ap)
	values (_no_documento, _sin_pen_dic);

end foreach

--************************************
-- Siniestros Pendientes Anno Actual --
--************************************
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

	insert into tmp_concurso(no_documento, sin_pen_aa)
	values (_no_documento, _sin_pen_aa);

end foreach

-----------------------------------------
-- Polizas Nuevas y Renovadas Anno Pasado
-----------------------------------------

call sp_bo077(_fecha_ap_ini, _fecha_ap) returning _error, _error_desc;

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

		insert into tmp_concurso(
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

-----------------------------------------
-- Polizas Nuevas y Renovadas Anno Actual
-----------------------------------------

call sp_bo077(_fecha_aa_ini, _fecha_aa) returning _error, _error_desc;

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

		insert into tmp_concurso(
		no_documento, 
		no_pol_nue_aa, 
		no_pol_ren_aa,
		no_pol_ren_aa_per
		)
		values(
		_no_documento, 
		_no_pol_nue_aa,
		_no_pol_ren_aa,
		_no_pol_ren_aa_per
		);

end foreach

drop table tmp_persis;

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
      and fecha_emision >= '01/10/2013'	
      and fecha_emision <= '30/09/2014';

   if _cnt > 0 then
		continue foreach;
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

	{ if _cod_grupo in("00000","1000") then -- Excluir Estado
		continue foreach;
	 end if  	}

	if _cod_tipoprod = "004" then
		continue foreach;
	end if

    let _cnt = 0;

	select count(*)
	  into _cnt
	  from emifafac
	 where no_poliza = _no_poliza;

	 if _cnt > 0 then		-- Excluir Facultativos
		 continue foreach;
	 end if

	-- Morosidades Mayores a 90 Dias (No Se Incluyen)

	call sp_cob33(a_compania, a_sucursal, _no_documento, a_periodo, _fecha_aa)
	     returning v_por_vencer,    
	               v_exigible,      
	               v_corriente,    
	               v_monto_30,      
	               v_monto_60,      
	               v_monto_90,
	               v_saldo;   

	if v_monto_90 > 0 then
		continue foreach;
	end if

	-- Siniestros Incurridos
		
	let _sini_incu = _sin_pag_aa + _sin_pen_aa - _sin_pen_dic;

	select nombre,
	       porc_res_mat
	  into _nombre_ramo,
	       _porc_res_mat
	  from prdramo
	 where cod_ramo = _cod_ramo;

	-- Prima Devengada (No aplica para Madrid 2011)
	-- Prima Devengada (No aplica para Grecia 2012)

--	let _porc_res_mat   = 100 - _porc_res_mat;
--	let _prima_suscrita = _prima_suscrita * _porc_res_mat / 100;

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

	foreach

		 select cod_agente
		   into _cod_agente
		   from emipoagt
		  where no_poliza = _no_poliza

		 if _cod_agente in('01481') then --Unificar Jose Caballero a Marta Caballero

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

        let _unificar = 0;	 --01221 Maribel Pineda a 01727 PJ Seg.Asemar	:10/06/2010 Gina 

		SELECT count(*)
		  INTO _unificar
		  FROM agtagent 
		 WHERE cod_agente      = _cod_agente
		   AND agente_agrupado = "01727";

		   if _unificar <> 0 then
			   let _cod_agente = "01727";
		   end if

	   --1  Jovani Mora(00636), Quitza Paz(00732), Rogelio Becerra (00865) , Alberto Camacho (00731) a Servicios Internacionales (01435)	 --
	       if _cod_agente in ("00636","00732","00865","00731") then
			  let _cod_agente = "01435";
		   end if
 
	   --3 Doulos Insurance Consultants  (DICSA)(01048,01837) ,Logos Insurance(01569,01838), Juan Carlos Sanchez(01315,01834), Chung Wai Chun(00623,01836), Katia Mariza Dam de Spagnuolo(01575,01835)
	       if _cod_agente in ("01837","01569","01838","01315","01834","00623","01836","01575","01835") then
			  let _cod_agente = "01048";
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

		IF _tipo_agente <> "A" then	-- Solo agentes
		    let _flag = 1;
			exit foreach;
		END IF

		IF _estatus_licencia <> "A" then  -- El corredor debe estar activo
		    let _flag = 1;
			exit foreach;
		END IF

		if _cod_agente = "00180" and  -- Tecnica de Seguros
		   _cod_ramo   = "016"	 and  -- Colectivo de vida
		   _cod_grupo  = "01016" then -- Grupo Suntracs
		    let _flag = 1;
			exit foreach;
		end if

		if _cod_agente IN("00874","00620","00226","00119","02121","00030","00081") then  -- Ser Company correo 7/10/2011 leticia. cambiar a individual
			let _tipo_persona = "N";													-- El resto, se puso para Grecia segun Solicitud 28/02/2012
		end if

		if _cod_agente IN("01618") then  -- Liberty Insurance 06/05/2013 Leticia. cambiar a individual
			let _tipo_persona = "N";													
		end if

		if _cod_agente IN("00946") then  -- Tuesca & Asoc. 31/05/2013 Leticia. cambiar a individual
			let _tipo_persona = "N";													
		end if

		if _cod_agente IN("01398") then  -- Agentes de Seguros y Negocios
			let _tipo_persona = "N";													
		end if

		if _cod_agente IN("00629") then  -- Global Insurance Corp.
			let _tipo_persona = "N";													
		end if

		if _cod_agente IN("01210") then  -- D&S Insurance
			let _tipo_persona = "N";													
		end if

		if _cod_agente IN("00809") then  -- M.T. Producciones de Seguros
			let _tipo_persona = "N";
		end if

		if _cod_agente IN("00883") then  -- Palma Y company
			let _tipo_persona = "N";
		end if

		if _cod_agente IN("00036") then  -- Productores y asesores de servicios
			let _tipo_persona = "N";
		end if

		if _cod_agente IN("01179") then  -- Seguros Escasty
			let _tipo_persona = "N";
		end if

		if _cod_agente IN("00908") then  -- Seguros Y Valores Paniza.
			let _tipo_persona = "N";
		end if

		if _cod_agente IN("00016") then  -- Servitec Internacional.
			let _tipo_persona = "N";
		end if

		if _cod_agente IN("00820") then  -- Invers. Digsa.
			let _tipo_persona = "N";
		end if

		if _cod_agente IN("01916") then  -- Seguros y Asesoria Maritima
			let _tipo_persona = "N";
		end if

		if _cod_agente IN("02056") then  -- Integra
			let _tipo_persona = "N";
		end if

		if _cod_agente IN("00821") then  -- KAI KAI Y ASOC.
			let _tipo_persona = "N";
		end if

		if _cod_agente IN("00492") then  -- Los ases del seguro
			let _tipo_persona = "N";
		end if

		if _tipo_persona = "N" then
			let _nombre_tipo = "INDIVIDUALES";
		else
			let _nombre_tipo = "BROKERS";
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

		{
		select cod_vendedor
		  into _cod_vendedor
		  from parpromo
		 where cod_agente  = _cod_agente
		   and cod_agencia = _suc_promotoria
		   and cod_ramo	   = _cod_ramo;
		}

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
		pri_can_aa,		--15
		pri_dev_aa,		--16
		monto_90_aa,	--17
		pri_pag_ap,		--18  
		pri_can_ap,		--19
		pri_dev_ap,		--20 * prima suscrita anno pasado
		monto_90_ap,	--21
		cod_vendedor,	--22 *
		nombre_vendedor,--23 *
		cod_ramo,		--24 *
		nombre_ramo,	--25 *
		tipo_agente,	--26 *
		vigenteap_per,	--27 *
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
		_pri_dev,		   --16
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
		_no_pol_nue_ap_per, --27
		_no_pol_ren_aa_per,
		_no_pol_ren_ap_per
		);

	 end foreach

end foreach

drop table tmp_concurso;

end

return 0;

END PROCEDURE; 