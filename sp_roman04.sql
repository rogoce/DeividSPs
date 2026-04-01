--***********************************************************************
-- Procedimiento que genera Variable Cierre 2023
--***********************************************************************
-- Creado    : 01/12/2023 - Autor: Armando Moreno M.

DROP PROCEDURE sp_roman01;
CREATE PROCEDURE sp_roman01(a_compania CHAR(3),a_sucursal CHAR(3),a_periodo char(7))
RETURNING char(3),char(50),char(5),char(50),char(3),char(50),char(3),char(50),char(20),date,date,DEC(16,2),DEC(16,2),char(3);

DEFINE _no_poliza       CHAR(10);
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
DEFINE _cnt_traspaso    SMALLINT;
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
DEFINE _dif		        DEC(16,2);
define _porc_partic_ancon dec(7,4);
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
define _prima_sus_pag,_monto_pen   DEC(16,2);
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
define _prima_sus_agt   DEC(16,2);
define _flag            smallint;
define _cod_coasegur	char(3);
define _cod_agente   	char(5);
define _cantidad        integer;
define v_filtros        varchar(255);
define _n_cliente       varchar(100);
define _nueva_renov     char(1);
define _periodo_reno    char(7);
define _vigen_ini		date;
define _vigencia_ant	date;
define _vigencia_act	date;
define _no_pol_ren_aa	integer;
define _no_pol_ren_ap	integer;
define _puntos          dec(3,2);
define _puntos_tiene    dec(16,2);
define _no_pol_nue_aa	integer;
define _no_pol_nue_ap	integer;
define _no_pol_nue_ap_per	integer;
define _estatus_poliza	smallint;
define _pri_sus_pag_ap  DEC(16,2);
define _pri_pag_ap      DEC(16,2);
define _prima_neta_calc      DEC(16,2);
define _pri_dev_ap      DEC(16,2);
define _monto_90_aa     DEC(16,2);
define _prima_suscrita  DEC(16,2);
define _prima_sus_ramo  DEC(16,2);
define _prima_fac       DEC(16,2);
define _ano				smallint;
define _ano_ant			smallint;
define _cod_agencia		char(3);
define _suc_promotoria	char(3);
define _cod_vendedor	char(3);
define _nombre_vendedor,_nombre_subramo	char(50);
define _vigencia_inic,_fecha_act	date;
define _vigencia_final,_fecha_tope	date;
define _tipo_persona	char(1);
define _nombre_tipo,_reemplaza_pol		char(20);
define _concurso,_unificar smallint;
define _pagada 			   smallint;
DEFINE _porc_partic_agt       DEC(5,2);
define _meses                 smallint;
define _valor,_prima_neta_agt                 decimal(16,2);
define _cod_perpago           char(3);
define _cod_agente_anterior   char(5);
define _grupo_agente    char(15);
define _monto_p     decimal(16,2);
define _prima_neta      decimal(16,2);

--SET DEBUG FILE TO "sp_pro868a.trc";
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
let v_monto_90	    = 0;
let _valor          = 0;
let _dif            = 0;
let v_saldo         = 0;
let _cantidad       = 0;
let _prima_orig     = 0;
let _porc_partic_agt = 0;
let _prima_fac       = 0;

LET _reemplaza_pol = "";

let _prima_suscrita  = 0;
let _nombre_tipo     = "";
let _prima_neta      = 0;

create temp table tmp_caribe13(
no_documento		char(20),
pri_sus				dec(16,2) 	default 0,
pri_pag				dec(16,2) 	default 0,
pri_pag_dif			dec(16,2) 	default 0,
cod_ramo            char(3),
pri_sus_ap			dec(16,2) 	default 0,
cod_agente          char(5),
prima_neta          dec(16,2) 	default 0
) with no log;

CREATE INDEX xie01_tmp_caribe ON tmp_caribe13(no_documento);
CREATE INDEX xie02_tmp_caribe ON tmp_caribe13(no_documento,cod_agente);

SET ISOLATION TO DIRTY READ;

--*****************************
-- Polizas Nuevas
--*****************************
foreach
	select no_documento
	  into _no_documento
	  from emipomae
	 where cod_compania  = a_compania
	   and actualizado   = 1
	   and nueva_renov   = "N"
	   and periodo >= a_periodo
	   and periodo <= a_periodo
	 group by no_documento
	 order by no_documento

	let _no_poliza = sp_sis21(_no_documento);
	
	select nueva_renov,
	       no_documento,
		   estatus_poliza,
		   cod_pagador, 
		   cod_contratante,
		   cod_tipoprod,
		   prima_suscrita,
		   cod_grupo,
		   cod_ramo,
		   cod_perpago,
		   cod_subramo,
		   reemplaza_poliza,
		   vigencia_inic,
		   vigencia_final,
		   cod_formapag,
		   prima_neta
	  into _nueva_renov,
	       _no_documento,
		   _estatus_poliza,
		   _cod_pagador,
		   _cod_contratante,
		   _cod_tipoprod,
		   _prima_suscrita,
		   _cod_grupo,
		   _cod_ramo,
		   _cod_perpago,
		   _cod_subramo,
		   _reemplaza_pol,
		   _vigen_ini,
		   _vigencia_final,
		   _cod_formapag,
		   _prima_neta
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	let _reemplaza_pol = TRIM(_reemplaza_pol);
	let _monto_pen = 0;
	let _pagada    = 0;
	let _monto_p   = 0;
	
	select count(*)
	  into _cnt
	  from emiletra
	 where no_poliza = _no_poliza;
	if _cnt is null then
		let _cnt = 0;
    end if
	if _cnt = 0 then
		continue foreach;
	end if
	
	select monto_pen,
	       monto_pag
	  into _monto_pen,
	       _monto_p
	  from emiletra
	 where no_poliza = _no_poliza
	   and no_letra  = 1
	   and monto_pag <> 0;

	if _monto_p is null then
		let _monto_p = 0.00;
	end if
	if _monto_pen is null then
		let _pagada = 0;
	elif _monto_pen <= 10 then --Holgura de $10
		let _pagada = 1;
	end if
	
	if _pagada > 0 then	--Debe tener pagada la primera letra.
	else
		continue foreach;
    end if

	IF _reemplaza_pol <> "" or _reemplaza_pol is not null then
		continue foreach;
	end if

	SELECT tipo_produccion
	   INTO _tipo_prod
	   FROM emitipro
	  WHERE cod_tipoprod = _cod_tipoprod;

	let _porc_partic_ancon = 100;
	
    if _tipo_prod in(3, 4) THEN   -- Excluir Coaseguro Minoritario y Reaseguro Asumido
	   CONTINUE FOREACH;
	elif _tipo_prod = 2 then      -- Coaseguro Mayoritario, solo nuestra participacion.
	
		let _prima_neta_calc = 0.00;
		
		select porc_partic_coas
		  into _porc_partic_ancon
		  from emicoama
		 where no_poliza = _no_poliza
		   and cod_coasegur = '036';	--Aseg. Ancón.
		
		if _porc_partic_ancon is null then
			let _porc_partic_ancon = 100;
		end if
		let _prima_neta_calc = _prima_neta * (_porc_partic_ancon /100);
		let _prima_neta = _prima_neta_calc;
	end if
	
	if _nueva_renov = "N" then
		foreach
			SELECT cod_agente,
				   porc_partic_agt
			  INTO _cod_agente,
				   _porc_partic_agt
			  FROM emipoagt
			 WHERE no_poliza = _no_poliza
			
			let _prima_sus_agt = 0; 
			let _prima_sus_agt = _prima_suscrita * _porc_partic_agt /100;
			let _prima_neta_agt = 0; 
			let _prima_neta_agt = _prima_neta * _porc_partic_agt /100;			
			
			--********  Unificacion de Agente *******
			--call sp_che168(_cod_agente_anterior) returning _error,_cod_agente;
			
			insert into tmp_caribe13(no_documento, pri_sus, cod_ramo, cod_agente,prima_neta)
			values (_no_documento, _prima_sus_agt, _cod_ramo, _cod_agente,_prima_neta_agt);
		end foreach		
	end if
	
end foreach
--************************************
foreach
	select no_documento,
	       cod_agente,
		   sum(pri_sus),
		   sum(prima_neta)
	  into _no_documento,
	       _cod_agente,
		   _prima_suscrita,
		   _prima_neta
	  from tmp_caribe13
	 group by no_documento,cod_agente
	 order by no_documento,cod_agente

	let _no_poliza = sp_sis21(_no_documento);

	select sucursal_origen,cod_ramo, cod_subramo, vigencia_inic, vigencia_final,cod_tipoprod
	  into _cod_agencia, _cod_ramo, _cod_subramo, _vigencia_inic,_vigencia_final,_cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	 select nombre
	   into _nombre_ramo
	   from prdramo
	  where cod_ramo = _cod_ramo;
	  
	 select nombre
	   into _nombre_subramo
	   from prdsubra
	  where cod_ramo    = _cod_ramo
	    and cod_subramo = _cod_subramo;

	select nombre,
		   tipo_agente,
		   estatus_licencia,
		   cedula
	  into _nombre,
		   _tipo_agente,
		   _estatus_licencia,
		   _cedula_agt
	  from agtagent
	 where cod_agente = _cod_agente;
	 
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
	 
	Return _cod_vendedor,_nombre_vendedor,_cod_agente,_nombre,_cod_ramo,_nombre_ramo,_cod_subramo,_nombre_subramo,_no_documento,_vigencia_inic,_vigencia_final,_prima_neta,_prima_suscrita,_cod_tipoprod with resume;

end foreach
drop table tmp_caribe13;
END PROCEDURE;