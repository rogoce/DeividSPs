--***********************************************************************************
-- Bonificacion de rentabilidad al perido actual -- Tabla de rentabilidad progresiva	  -- ANTERIOR 14/12/2010
--***********************************************************************************
-- execute procedure sp_che115("001","001")
-- Creado    : 24/03/2010 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che115_bk;

CREATE PROCEDURE sp_che115_bk(
a_compania          CHAR(3),
a_sucursal          CHAR(3)
) RETURNING SMALLINT;
	  
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
define _error           smallint;
define _filtros			char(255);
define _per_fin_dic     char(7);
define _prima_sus_pag   DEC(16,2);
define _sini_incu		DEC(16,2);
define _siniestralidad  DEC(16,2);
define _incremento_psp  dec(16,2);
define _crecimiento     dec(16,2);
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

define _cod_tipo        char(1);
define _n_cod_tipo 	    char(50);
define _pri_sus_pag     dec(16,2);
define _valor_prima     dec(16,2);
define _porcentaje      dec(16,2);
define _prima_max       dec(16,2);
define _pri_devengada   dec(16,2);
DEFINE _unificar        smallint;


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
let _pri_sus_pag_ap = 0;
let _monto_90_aa    = 0;
let _pri_can		= 0;
let	_pri_dev		= 0;
let _monto_90_ap    = 0;
let _pri_devengada  = 0;

delete from rentabilidad;

select par_ase_lider,
       par_periodo_act
  into _cod_coasegur,
	   a_periodo
  from parparam
 where cod_compania = a_compania;

if a_periodo > "2010-12" then
	let a_periodo = "2010-12";
end if

let _per_ini        = "2010-01";
let _per_ini_ap     = "2009-01";
let _ano            = a_periodo[1,4];
let _ano            = _ano - 1;
let _per_fin_ap     = _ano || a_periodo[5,7];

let _per_fin_dic    = "2009-12";
let _fecha_aa_ini   = sp_sis36(_per_ini);
let _fecha_aa       = sp_sis36(a_periodo);
let _fecha_ap_ini   = sp_sis36(_per_ini_ap);
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

create temp table tmprenta(
cod_agente	        char(5),
periodo				char(7),
tipo				char(1),
prima_neta			dec(16,2) 	default 0,
comision			dec(16,2) 	default 0,
porcentaje			dec(16,2) 	default 0,
por_crecimiento		dec(16,2) 	default 0,
por_siniestro		dec(16,2) 	default 0,
prima_max			dec(16,2) 	default 0
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
  where periodo     between _per_ini and a_periodo -- 2010-01 a 2010-03
	and actualizado = 1
	and tipo_mov    in ("P", "N")

	let _no_poliza = sp_sis21(_no_documento);

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "004" or
	   _cod_tipoprod = "002" then
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
  where periodo     between _per_ini_ap and _per_fin_ap	  --2009-01  a  2009-03
	and actualizado = 1
	and tipo_mov    in ("P", "N")

	let _no_poliza = sp_sis21(_no_documento);

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "004" or
	   _cod_tipoprod = "002" then
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

	insert into tmp_concurso(no_documento, pri_pag_ap)
	values (_no_documento, _monto);

end foreach

--*********************
-- Prima Devengada  --	   falta restar el % por reserva de prima no devengada
--*********************

foreach
 select no_documento,
		sum(prima_suscrita)
   into _no_documento,
		_prima_suscrita
   from endedmae
  where actualizado  = 1
	and periodo between _per_ini and a_periodo	   -- 2010-01 a 2010-03
  group by no_documento


	insert into tmp_concurso(no_documento, pri_sus_pag)
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
    and periodo      <= _per_fin_dic     -- 2009-12
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

foreach
 select no_documento,
	    sum(pri_pag),				--	 prima pagada actual
		sum(sin_pag_aa),			--   siniestros pagados actual
		sum(sin_pen_aa),			--	 siniestros pend actual
		sum(sin_pen_ap),			--   siniestros pend a dic
	    sum(pri_pag_ap),			--	 prima pagada anterior
		sum(pri_sus_pag)			--   prima devengada
   into _no_documento,
	    _pri_pag,
		_sin_pag_aa,
	    _sin_pen_aa,
		_sin_pen_dic,
	    _pri_pag_ap,
		_prima_suscrita
   from tmp_concurso
  group by no_documento
  order by no_documento

	 let _no_poliza = sp_sis21(_no_documento);

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

	 if _cod_grupo = "00000" then -- Excluir estado
		continue foreach;
	 end if

	 SELECT tipo_produccion
	   INTO _tipo_prod
	   FROM emitipro
	  WHERE cod_tipoprod = _cod_tipoprod;

	-- Excluir Reaseguro Asumido y Coas. Minoritario

	 if _tipo_prod = 4 or _tipo_prod = 3 then
	   continue foreach;
	 end if

	 select count(*)
	   into _cnt
	   from emifafac
	  where no_poliza = _no_poliza;

	 if _cnt > 0 then		-- Excluir Facultativos
		 continue foreach;
	 end if

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

     let _flag = 0;

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza

           let _unificar = 0;	 --01221 Maribel Pineda a 01727 PJ Seg.Asemar	:10/06/2010 Gina

		SELECT count(*)
		  INTO _unificar
		  FROM agtagent
		 WHERE cod_agente = _cod_agente
		   AND agente_agrupado = "01727";

		   if _unificar <> 0 then
			   let _cod_agente = "01727";
		   end if

		SELECT nombre,
		       tipo_pago,
		       tipo_agente,
			   estatus_licencia,
			   cedula,
			   agente_agrupado
		  INTO _nombre,
		       _tipo_pago,
		       _tipo_agente,
			   _estatus_licencia,
			   _cedula_agt,
			   _agente_agrupado
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

			if trim(_cedula_agt) = trim(_cedula_paga) then	-- Contra pagador
			    let _flag = 1;
				exit foreach;
			end if

			if trim(_cedula_agt) = trim(_cedula_cont) then	-- Contra Contratante
			    let _flag = 1;
				exit foreach;
			end if

			IF _tipo_agente <> "A" then	-- Solo agentes
			    let _flag = 1;
				exit foreach;
			END IF

			IF _estatus_licencia <> "A" then  -- El corredor debe estar activo
			    let _flag = 1;
				exit foreach;
			END IF

			if _agente_agrupado = "01068" then -- Grupo FF Seguros
			    let _flag = 1;
				exit foreach;
			end if

			if _cod_agente = "00180" and  -- Tecnica de Seguros
			   _cod_ramo   = "016"	 and  -- Colectivo de vida
			   _cod_grupo  = "01016" then -- Grupo Suntracs
			    let _flag = 1;
				exit foreach;
			end if

			if _cod_agente  = "00035" and  -- Ducruet
			   _cod_agencia = "075"   and  -- Agencia Ducruet
			   _cod_ramo    = "020"   then -- Soda
			    let _flag = 1;
				exit foreach;

			   {
			   if _cod_ramo = "002" or 	 -- Auto
			      _cod_ramo = "020" then -- Soda
				    let _flag = 1;
					exit foreach;
			   end if
			   }

			end if

	 end foreach

	 if _flag = 1 then
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

	let _sini_incu = 0;
	let _sini_incu = _sin_pag_aa + _sin_pen_aa - _sin_pen_dic;

	select nombre,
	       porc_res_mat
	  into _nombre_ramo,
	       _porc_res_mat
	  from prdramo
	 where cod_ramo = _cod_ramo;

	-- Prima Devengada

	let _porc_res_mat   = 100 - _porc_res_mat;
	let _prima_suscrita = _prima_suscrita * _porc_res_mat / 100;


	 foreach
	  SELECT cod_agente
	    INTO _cod_agente
	    FROM emipoagt
	   WHERE no_poliza = _no_poliza

           let _unificar = 0;	 --01221 Maribel Pineda a 01727 PJ Seg.Asemar	:10/06/2010 Gina

		SELECT count(*)
		  INTO _unificar
		  FROM agtagent
		 WHERE cod_agente = _cod_agente
		   AND agente_agrupado = "01727";

		   if _unificar <> 0 then
			   let _cod_agente = "01727";
		   end if

		SELECT nombre,
		       tipo_persona,
			   cod_vendedor
		  INTO _nombre,
		       _tipo_persona,
			   _cod_vendedor
	      FROM agtagent
		 WHERE cod_agente = _cod_agente;

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
		 where cod_vendedor = _cod_vendedor ;

		--/*CATEGORIZAR*/
		--A-AUTOMOVIL                   ="002","020"
		--B-SALUD y HOSPITALIZACION     ="018"
		--C-PATRIMONIALES               ="001","003","005","006","015","011","013","010","009","017","014","021","012","007"
		--D-PERSONAS    				="019","004","016"
		--E-FIANZAS                     ="008","080"

		if  _cod_ramo in ("002","020") then
		   let _cod_tipo = 'A' ;
		end if

		if  _cod_ramo = "018" then
		   let _cod_tipo = 'B' ;
		end if

		if  _cod_ramo in ("001","003","005","006","015","011","013","010","009","017","014","021","012","007") then
		   let _cod_tipo = 'C' ;
		end if


		if  _cod_ramo in ("019","004","016") then
		   let _cod_tipo = 'D' ;
		end if


		if  _cod_ramo in ("008","080") then
		   let _cod_tipo = 'E';
		end if

		-- Descripcion del Tipo de Categoria

		if  _cod_tipo = 'A' then
		  let _n_cod_tipo = 'AUTOMOVIL'  ;
		end if
		if  _cod_tipo = 'B' then
		  let _n_cod_tipo = 'SALUD'  ;			-- 'SALUD Y HOSPITALIZACION'
		end if
		if  _cod_tipo = 'C' then
		  let _n_cod_tipo = 'PATRIMONIAL'  ;
		end if
		if _cod_tipo = 'D' then
		  let _n_cod_tipo = 'PERSONAS'  ;		-- 'COLECTIVOS DE VIDA Y ACCIDENES PERSONALES'
		end if
		if  _cod_tipo = 'E' then
		  let _n_cod_tipo = 'FIANZAS'  ;
		end if

		insert into rentabilidad(
		cod_agente,
		no_documento,
		pri_sus_pag_aa,
		pri_sus_pag_ap,
		sini_inc,
		n_agente,
    	cod_contratante,
		n_cliente,
		periodo,
		cod_vendedor,
		nombre_vendedor,
		cod_ramo,
		nombre_ramo,
		tipo_agente,
		tipo,
		nombre_tipo,
		prima_neta,
		comision,
		porcentaje,
		por_crecimiento,
		por_siniestro,
		prima_max,
		prima_devengada)
		values(
		_cod_agente,
		_no_documento,
		_pri_pag,
		_pri_pag_ap,
		_sini_incu,
		_nombre,
		_cod_contratante,
		_n_cliente,
		a_periodo,
		_cod_vendedor,
		_nombre_vendedor,
		_cod_ramo,
		_nombre_ramo,
		_nombre_tipo,
		_cod_tipo,
		_n_cod_tipo,
		0,
		0,
		0,
		0,
		0,
		0,
		_prima_suscrita);

	 end foreach
end foreach

--/***************************************/
-- SE ACUMULARAN POR RAMO - GLOBAL
--/***************************************/
foreach
	select tipo,
		   cod_agente,
		   sum(pri_sus_pag_aa),
		   sum(pri_sus_pag_ap),
		   sum(sini_inc),
		   sum(prima_devengada)
	  into _cod_tipo,
		   _cod_agente,
		   _pri_sus_pag,
		   _pri_sus_pag_ap,
		   _sini_incu,
		   _pri_devengada
	  from rentabilidad
	 where periodo    = a_periodo
	 group by cod_agente,tipo
	 order by cod_agente,tipo

	let _valor_prima = 0;
	let _porcentaje  = 0;
	let _prima_max   = 0;

	let _prima_max = (_pri_sus_pag * 15)/100;
	--************************************************
	--   Calculos de rentabilidad
	--************************************************
	if _pri_sus_pag = 0  then
		continue foreach;
	end if

	let _incremento_psp       = 0;
	let _crecimiento          = 0;
	let _siniestralidad       = 0;
	let _valor_prima          = 0;
	let _porcentaje			  = 0;

	--************************************************
	--   Calculos para incremeto de PSP 2010 vs 2009
	--************************************************
	let _incremento_psp  = _pri_sus_pag - _pri_sus_pag_ap ;

	--************************************************
	--   Calculos % de crecimiento de PSP
	--************************************************
	if _pri_sus_pag_ap <> 0 then
		let _crecimiento = ((_pri_sus_pag - _pri_sus_pag_ap) / _pri_sus_pag_ap) * 100;
	end if

	if _crecimiento = 0 then
		let _crecimiento = 100;
	end if
	--************************************************
	--    Calculos % de siniestralidad 2010
	--************************************************
	let _siniestralidad = 0;
	if _pri_devengada <> 0 then
		let _siniestralidad = (_sini_incu / _pri_devengada) * 100;
	end if
	--************************************************
	--   Condicionar rentabilidad
	--************************************************
	if _cod_tipo = 'A' then	  --   automovil
		if _pri_sus_pag >= 25000 then
			if _crecimiento >= 40 then
				if _siniestralidad <= 40 then
					let _porcentaje = 5;
				end if
				if _siniestralidad > 40 and _siniestralidad <= 45 then
					let _porcentaje = 4;
				end if
				if _siniestralidad > 45 and _siniestralidad <= 50 then
					let _porcentaje = 3;
				end if
			end if
		end if
	end if

	if _cod_tipo = 'B' then  --    salud
		if _pri_sus_pag >= 15000 then
			if _crecimiento >= 40 then
				if _siniestralidad <= 40 then
					let _porcentaje = 5;
				end if
				if _siniestralidad > 40 and _siniestralidad <= 50 then
					let _porcentaje = 4;
				end if
			end if
		end if
	end if

	if _cod_tipo = 'C' then     -- patrimoniales
		if _pri_sus_pag >= 15000 then
			if _crecimiento >= 40 then
				if _siniestralidad <= 30 then
					let _porcentaje = 5;
				end if
				if _siniestralidad > 30 and _siniestralidad <= 40 then
					let _porcentaje = 4;
				end if
				if _siniestralidad > 40 and _siniestralidad <= 50 then
					let _porcentaje = 3;
				end if
			end if
		end if
	end if

	if _cod_tipo = 'D' then	  --   Personas
		if _pri_sus_pag >= 15000 then
			if _crecimiento >= 40 then
				if _siniestralidad <= 40 then
					let _porcentaje = 5;
				end if
				if _siniestralidad > 40 and _siniestralidad <= 45 then
					let _porcentaje = 4;
				end if
				if _siniestralidad > 45 and _siniestralidad <= 50 then
					let _porcentaje = 3;
				end if
			end if
		end if
	end if

	if _cod_tipo = 'E' then	  --  Fianzas
		if _pri_sus_pag >= 50000 then
			if _crecimiento >= 30 then
				if _siniestralidad <= 10 then
					let _porcentaje = 3;
				end if
			end if
		end if
	end if

	if _porcentaje <> 0 then
		-- Para el valor de la comision se tomara en base al porcentaje
		let _valor_prima = _pri_sus_pag * ( _porcentaje / 100);

		if 	_valor_prima > _prima_max then
			let _valor_prima = _prima_max ;
		end if

    	INSERT INTO tmprenta(cod_agente,periodo,tipo,prima_neta,comision,porcentaje,por_crecimiento,por_siniestro,prima_max)
		VALUES (_cod_agente,a_periodo,_cod_tipo,_pri_sus_pag,_valor_prima,_porcentaje,_crecimiento,_siniestralidad,_prima_max) ;

	end if
end foreach

foreach
	select cod_agente,
		   periodo,
		   tipo,
		   prima_neta,
		   comision,
		   porcentaje,
		   por_crecimiento,
		   por_siniestro,
		   prima_max
	  into _cod_agente,
		   a_periodo,
		   _cod_tipo,
		   _pri_sus_pag,
		   _valor_prima,
		   _porcentaje,
		   _crecimiento,
		   _siniestralidad,
		   _prima_max
	from tmprenta
	order by 2,1,3

		update rentabilidad
		set prima_neta      = _pri_sus_pag,
			comision        = _valor_prima,
			porcentaje      = _porcentaje,
			por_crecimiento = _crecimiento,
			por_siniestro   = _siniestralidad,
			prima_max       = _prima_max
	  where periodo         = a_periodo
		and cod_agente      = _cod_agente
		and tipo            = _cod_tipo;

end foreach


drop table tmp_concurso;
drop table tmprenta;

return 0;

END PROCEDURE 
                                                                                                                                                                                                                               
		  