--*******************************************************
-- Procedimiento para el Bono de Productividad 

-- 2009 
-- 2010 
-- 2011 - 15/12/2011 - Demetrio Hurtado Almanza
--*******************************************************

-- Creado    : 30/03/2010 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis113;

CREATE PROCEDURE sp_sis113(
a_compania          CHAR(3),
a_sucursal          CHAR(3)
) RETURNING SMALLINT,
            char(50);

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
define _error           smallint;
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
define v_monto_90       DEC(16,2);
define _prima_orig      DEC(16,2);
define _flag            smallint;
define _cod_coasegur	char(3);
define _cod_agente   	char(5);
define _cantidad        integer;
define _fecha_aa_ini     date;
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

define _no_pol_nue_ap_per	integer;
define _no_pol_ren_aa_per	integer;
define _no_pol_ren_ap_per	integer;

define _fronting		smallint;
define _error_desc		char(50);

return 0,'DETENIDO';

--SET DEBUG FILE TO "sp_che86.trc";
--TRACE ON;

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

select par_ase_lider,
       par_periodo_ant
  into _cod_coasegur,
	   a_periodo
  from parparam
 where cod_compania = a_compania;

-- Año Actual

let a_periodo		= "2012-12";
let _ano            = a_periodo[1,4];
let _per_ini        = _ano || "-01";
let _fecha_aa_ini   = MDY(1, 1, _ano);
let _fecha_aa       = sp_sis36(a_periodo);

-- Año Pasado

let _ano            = _ano - 1;
let _per_ini_ap     = _ano || "-01";
let _per_fin_ap     = _ano || a_periodo[5,7];
let _per_fin_dic    = _ano || "-12";
let _fecha_ap_ini   = MDY(1, 1, _ano);
let _fecha_ap       = sp_sis36(_per_fin_ap);

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

--{
--**************************
-- Prima Suscrita Año Actual
--**************************
foreach
 select no_documento,
        prima_suscrita
   into _no_documento,
   		_monto
   from endedmae
  where periodo     between _per_ini and a_periodo
	and actualizado = 1
--	and no_factura not in ("01-1191171", "01-1190895")

	insert into tmp_concurso(no_documento, pri_pag)
	values (_no_documento, _monto);

end foreach

--**************************
-- Prima Suscrita Año Pasado
--**************************
foreach
 select no_documento,
        prima_suscrita
   into _no_documento,
   		_monto
   from endedmae
  where periodo     between _per_ini_ap and _per_fin_ap
	and actualizado = 1

	insert into tmp_concurso(no_documento, pri_pag_ap)
	values (_no_documento, _monto);

end foreach
--}

--{
--************************
-- Prima Pagada Año Actual
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
  where periodo     between _per_ini and a_periodo
	and actualizado = 1
	and tipo_mov    in ("P", "N")
	
	let _no_poliza = sp_sis21(_no_documento);

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "004" then
		continue foreach;
	end if

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

	insert into tmp_concurso(no_documento, pri_can)
	values (_no_documento, _monto);

end foreach
--}

--{
--*********************************
-- Siniestros Pagados Año Actual --
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
-- Siniestros Pendientes Diciembre Año Pasado --
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
-- Siniestros Pendientes Año Actual --
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
--}

-- Polizas Nuevas y Renovadas Año Pasado

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

-- Polizas Nuevas y Renovadas Año Actual

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


delete from bonprod09;

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
		_no_pol_ren_aa_per,
		_no_pol_ren_ap_per
   from tmp_concurso
  group by no_documento
  order by no_documento

	let _no_poliza    = null;
	let _no_documento = trim(_no_documento);
	
	foreach
	 select	no_poliza
	   into	_no_poliza
	   from	emipomae
	  where no_documento  = _no_documento
		and actualizado   = 1
		and vigencia_inic <= _fecha_aa
	  order by vigencia_final desc
		exit foreach;
	end foreach

	if _no_poliza is null then
		let _no_poliza = sp_sis21(_no_documento);
	end if

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


	 --{
	 select cedula
	   into _cedula_paga
	   from cliclien
	  where cod_cliente = _cod_pagador;

	 select cedula,
	        nombre
	   into _cedula_cont,
	        _n_cliente
	   from cliclien
	  where cod_cliente = _cod_contratante;
	 --}

	-- Procedimiento que genera la morosidad para una poliza
	-- basado en la prima neta
	
--	let _pri_can     = 0;
	let _pri_dev     = 0;
	let _monto_90_aa = 0;

--	let _pri_can_ap  = 0;
	let _pri_dev_ap  = 0;
	let _monto_90_ap = 0;

	let _prima_sus_pag  = _pri_pag;
	let _pri_sus_pag_ap = _pri_pag_ap;
	let _sini_incu      = _sin_pag_aa + _sin_pen_aa - _sin_pen_dic;

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	let _cod_agente = null;

	 foreach
	  select cod_agente
	    into _cod_agente
	    from emipoagt
	   where no_poliza = _no_poliza
		exit foreach;
	end foreach
		
	select nombre,
	       tipo_persona
	  into _nombre,
	       _tipo_persona
      from agtagent
	 where cod_agente = _cod_agente;

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

	-- Validaciones para Conteo de Polizas (Persistencia)

	if _no_pol_ren_aa_per > (_no_pol_ren_ap_per + _no_pol_nue_ap_per) then
		let _no_pol_ren_aa_per = _no_pol_ren_ap_per + _no_pol_nue_ap_per;
	end if

	if _no_pol_ren_aa_per > 1 then
		let _no_pol_ren_aa_per = 1;
	end if

	if _no_pol_ren_ap_per > 1 then
		let _no_pol_ren_ap_per = 1;
	end if

	if _no_pol_nue_ap_per > 1 then
		let _no_pol_nue_ap_per = 1;
	end if

	insert into bonprod09(
	cod_agente, 
	no_documento, 
	pri_sus_pag_aa, 
	pri_sus_pag_ap, 
	sini_inc, 
	n_agente, 
	vigenteaa,
	vigenteap, 
	cod_contratante, 
	n_cliente,
	periodo,
	renovaa,
	renovap,
	pri_pag_aa,
	pri_can_aa,
	pri_dev_aa,
	monto_90_aa,
	pri_pag_ap,
	pri_can_ap,
	pri_dev_ap,
	monto_90_ap,
	cod_vendedor,
	nombre_vendedor,
	cod_ramo,
	nombre_ramo,
	tipo_agente,
	vigenteap_per,
	renovaa_per,
	renovap_per,
	fronting

	)
	values(
	_cod_agente, 
	_no_documento, 
	_prima_sus_pag, 
	_pri_sus_pag_ap, 
	_sini_incu, 
	_nombre, 
	_no_pol_nue_aa, 
	_no_pol_nue_ap, 
	_cod_contratante, 
	_n_cliente,
	a_periodo,
	_no_pol_ren_aa,
	_no_pol_ren_ap,
	_pri_pag,
	_pri_can,
	_pri_dev,
	_monto_90_aa,
	_pri_pag_ap,
	_pri_can_ap,
	_pri_dev_ap,
	_monto_90_ap,
	_cod_vendedor,
	_nombre_vendedor,
	_cod_ramo,
	_nombre_ramo,
	_nombre_tipo,
	_no_pol_nue_ap_per,
	_no_pol_ren_aa_per,
	_no_pol_ren_ap_per,
	_fronting
	);

end foreach

drop table tmp_concurso;

return 0, "Actualizacion Exitosa";

end procedure;