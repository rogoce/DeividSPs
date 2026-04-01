--Procedimiento para realizar la carga en Rentabilidad1 para bono de RENTABILIDAD
--Usando prima neta cobrada devengada
--Creado 18/03/2019	Armando Moreno M.

DROP PROCEDURE sp_che115_carga2019;
CREATE PROCEDURE sp_che115_carga2019(a_compania CHAR(3), a_sucursal CHAR(3))
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
DEFINE _monto_dev       DEC(16,2);
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
define _pri_dev_aa      DEC(16,2);
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
define _vigente,_pagado         smallint;
define v_filtros        varchar(255);
define a_periodo        char(7);
define _n_cliente       varchar(100);
define _nueva_renov     char(1);
define _periodo_reno    char(7);
define _vigen_ini		date;
define _vigencia_ant	date;
define _vigencia_act	date;
define _fec_aa_ini,_fecha_anulado   	date;
define _no_pol_ren_aa	integer;
define _no_pol_ren_ap	integer;

define _no_pol_nue_aa	integer;
define _no_pol_nue_ap	integer;

define _no_pol_nue_ap_per	integer;
define _no_pol_ren_aa_per	integer;
define _no_pol_ren_ap_per	integer;

define _estatus_poliza		smallint;
define _pri_sus_pag_ap  	DEC(16,2);
define _pri_pag_ap      	DEC(16,2);
define _pri_can_ap      	DEC(16,2);
define _pri_dev_ap      	DEC(16,2);
define _monto_90_aa     	DEC(16,2);
define _monto_90_ap     	DEC(16,2);
define _prima_cobrada       DEC(16,2);

define _ano					smallint;
define _ano_ant				smallint;

define _cod_agencia			char(3);
define _suc_promotoria		char(3);
define _cod_vendedor		char(3);
define _nombre_vendedor		char(50);
define _vigencia_inic		date;
define _vigencia_final		date;
define _tipo_persona		char(1);
define _nombre_tipo			char(15);
define _concurso			smallint;

define _porc_res_mat		dec(5,2);
define _agente_agrupado 	char(5);

define _cod_tipo        	char(3);
define _n_cod_tipo 	    	char(50);
define _pri_sus_pag     	dec(16,2);
define _valor_prima     	dec(16,2);
define _porcentaje      	dec(16,2);
define _prima_max       	dec(16,2);
define _pri_devengada   	dec(16,2);
define _unificar        	smallint;
define _cod_agente_tmp      char(5);

define _pri_cob_dev     	dec(16,2);
define _pri_cob_dev_max 	dec(16,2);
define _pri_sus_dev     	dec(16,2);
define _pri_sus_dev_max 	dec(16,2);
define _pri_cob         	dec(16,2);
define _pri_cob_max     	dec(16,2);
define _valor_cob_dev 		dec(16,2);
define _valor_sus_dev 		dec(16,2);
define _valor_cob     		dec(16,2);
define _pri_sus_orig    	dec(16,2);
define _porc_res_xramo  	dec(16,2);
define _prima_suscrita_ap 	dec(16,2);
define _pri_cob_dev_ap    	dec(16,2);

define _pri_susc_dev_aa		dec(16,2);
define _pri_susc_dev_ap		dec(16,2);
define _pri_susc_aa	    	dec(16,2);
define _pri_susc_ap	    	dec(16,2);
define _aplica          	smallint;
define _porc_prima_dev_max	dec(16,2);
define _pri_dev_max_aa		dec(16,2);
define _pri_dev_max_ap		dec(16,2);
define _prim_suscrita_min 	dec(16,2);
define _crecimiento_min   	dec(16,2);
define _monto3              dec(16,2);

define _prima_beneficio 	dec(16,2);
define _prima_maxima    	dec(16,2);
define _bono            	dec(16,2);
define _pri_sus_aa_tmp		dec(16,2);
define _pri_sus_ap_tmp		dec(16,2);
define _prima_ret_aa,_monto2 		dec(16,2);
define _prima_ret_ap,_monto_fac_ac   		dec(16,2);
define _bono_rent2          smallint;
define _cod_perpago         char(3);
define my_sessionid,_valor  integer;
define _porc_partic_agt     decimal(16,4);
define _mensaje             varchar(100);
define _error_desc          char(50);

-- return 0; --se detuvo la corrida

-- SET DEBUG FILE TO "sp_che115_carga.trc";
-- TRACE ON;

let _error          	 = 0;
let _prima_can      	 = 0;
let _pri_can        	 = 0;
let _siniestralidad 	 = 0;
let _sini_incu      	 = 0;
let _prima_sus_pag  	 = 0;
let _pri_dev        	 = 0;
let _cnt            	 = 0;
let _pri_dev_aa        	 = 0;
let _sin_pen_dic    	 = 0;
let _sin_pen_aa     	 = 0;
let _sin_pag_aa     	 = 0;
let v_por_vencer    	 = 0;
let v_exigible	    	 = 0;
let v_corriente	    	 = 0;
let v_monto_30	    	 = 0;
let v_monto_60	    	 = 0;
let v_monto_90	    	 = 0;
let _cantidad       	 = 0;
let _prima_orig     	 = 0;

let _pri_sus_pag_ap    	 = 0;
let _prima_suscrita_ap 	 = 0;
let _monto_90_aa       	 = 0;
let _pri_can		   	 = 0;
let	_pri_dev		   	 = 0;
let _monto_90_ap       	 = 0;
let _pri_devengada     	 = 0;
let _pri_cob_dev       	 = 0;
let _pri_cob_dev_max   	 = 0;
let _pri_cob_max       	 = 0;
let _pri_cob           	 = 0;
let _pri_sus_dev       	 = 0;
let _pri_sus_dev_max   	 = 0;
let _pri_sus           	 = 0;
let _pri_sus_orig  	   	 = 0;
let _porc_res_xramo	   	 = 0;
let _porc_coaseguro      = 0;
let _mensaje             = "";
let _pri_susc_dev_aa	 = 0;
let _pri_susc_dev_ap	 = 0;
let _porc_partic         = 0;
let _pri_sus_aa_tmp	 = 0;
let _pri_sus_ap_tmp	 = 0;
let _prima_ret_aa 	 = 0;
let _prima_ret_ap	 = 0;

select par_ase_lider,
       par_periodo_act  -- ult_per_renta
  into _cod_coasegur,
	   a_periodo
  from parparam
 where cod_compania = a_compania;
 
 let my_sessionid = DBINFO('sessionid');

if a_periodo > "2012-12" then
	let a_periodo = "2019-12";
end if

delete from rentabilidad1 where periodo = a_periodo;

select par_periodo_ant
  into a_periodo
  from parparam
 where cod_compania = a_compania;

let a_periodo   = '2019-12';

update parparam
   set agt_per_fidel = a_periodo;

let _fec_aa_ini     = "01/01/2019";	--para sacar cancelada o anulada en el periodo
let _per_ini        = "2019-01";
let _per_ini_ap     = "2018-01";
let _ano            = a_periodo[1,4];
let _ano            = _ano - 1;
let _per_fin_ap     = _ano || a_periodo[5,7];

let _per_fin_dic    = "2018-12";         
let _fecha_aa_ini   = sp_sis36(_per_ini);    --31/01/2019	 
let _fecha_aa       = sp_sis36(a_periodo);	 --31/12/2019 
let _fecha_ap_ini   = sp_sis36(_per_ini_ap); --31/01/2018 
let _fecha_ap       = sp_sis36(_per_fin_ap); --31/12/2018

--***************************
truncate table fis_che115a;
--***************************
SET ISOLATION TO DIRTY READ;
--***************************
--***PRIMA SUSCRITA DEVENGADA
-- Año Actual
--call sp_dev01('01/01/2018', _fecha_aa) returning _error, _error_desc;
--**********************************
-- Prima Neta Cobrada Año Actual
--**********************************
foreach
	select doc_remesa
	  into _no_documento
	  from cobredet
	 where periodo     >= _per_ini
	   and periodo     <= a_periodo
	   and actualizado = 1
	   and tipo_mov    in ("P", "N")
	 group by doc_remesa
	 
	let _valor = sp_sis101a(_no_documento,'01/01/2019',_fecha_aa, my_sessionid);
	call sp_dev06f_renta(_no_documento,_fecha_aa,'01/01/2019',_fecha_aa) returning _valor,_mensaje,_pri_devengada;
	if _pri_devengada is null then
		let _pri_devengada = 0.00;
	end if
	foreach
		select cod_agente,
		       porcentaje
		  into _cod_agente,
               _porc_partic_agt
		  from con_corr
		 where sessionid = my_sessionid
		let _monto2 = 0.00;
		let _monto2 = _pri_devengada * _porc_partic_agt /100;
		begin work;
		insert into fis_che115a(no_documento, pri_pag, tipo,cod_agente) --pri_pag = corresponde a prima neta cobrada devengada
		values (_no_documento, _monto2, 8,_cod_agente);
		commit work;
	end foreach
end foreach
--****************************************************************
-- Prima SUSCRITA  AA -- Excluye prima de contratos en Facultativo
--****************************************************************
foreach	with hold
	select sum(a.prima),
	       no_documento
	  into _prima_suscrita,
	       _no_documento
	  from emifacon a, endedmae e, reacomae r
	 where a.no_poliza = e.no_poliza
	   and a.no_endoso = e.no_endoso
	   and a.cod_contrato = r.cod_contrato
	   and r.tipo_contrato not in(3)
	   and e.actualizado  = 1
	   and e.periodo      >= _per_ini
	   and e.periodo  	  <= a_periodo
	 group by e.no_documento

	if _prima_suscrita is null then
		let _prima_suscrita = 0;
	end if
	let _valor = sp_sis101a(_no_documento,'01/01/2019',_fecha_aa,my_sessionid);
	foreach
		select cod_agente,
		       porcentaje
		  into _cod_agente,
               _porc_partic_agt
		  from con_corr
		 where sessionid = my_sessionid
		let _monto2 = 0.00;
		let _monto2 = _prima_suscrita * _porc_partic_agt /100;
		begin work;
		insert into fis_che115a(no_documento,pri_sus_pag,tipo,cod_agente)
		values (_no_documento,_monto2,3,_cod_agente);
		commit work;
	end foreach	
end foreach
--***********************
-- Prima  SUSCRITA  AP --
--***********************
foreach	with hold
	select sum(a.prima),
		   no_documento
	  into _prima_suscrita,
		   _no_documento
	  from emifacon a, endedmae e, reacomae r
	 where a.no_poliza = e.no_poliza
	   and a.no_endoso = e.no_endoso
	   and a.cod_contrato = r.cod_contrato
	   and r.tipo_contrato not in(3)
	   and e.actualizado  = 1
	   and e.periodo      >= _per_ini_ap
	   and e.periodo  	  <= _per_fin_ap
	 group by e.no_documento

	if _prima_suscrita is null then
		let _prima_suscrita = 0;
	end if
	let _valor = sp_sis101a(_no_documento,'01/01/2018',_fecha_ap,my_sessionid);
	foreach
		select cod_agente,
		       porcentaje
		  into _cod_agente,
               _porc_partic_agt
		  from con_corr
		 where sessionid = my_sessionid
		let _monto2 = 0.00;
		let _monto2 = _prima_suscrita * _porc_partic_agt /100;
		begin work;
		insert into fis_che115a(no_documento, pri_sus_pag_ap, tipo,cod_agente)
		values (_no_documento, _monto2, 4,_cod_agente);
		commit work;
	end foreach	
end foreach
--**********************************
-- Siniestros Pagados Anno Actual --
--**********************************
call sp_rec01(a_compania, a_sucursal, _per_ini, a_periodo) returning _filtros;

foreach	with hold

    select doc_poliza,
           pagado_bruto   
      into _no_documento,
           _sin_pag_aa
      from tmp_sinis
	let _valor = sp_sis101a(_no_documento,'01/01/2019', _fecha_aa, my_sessionid);
	foreach
		select cod_agente,
		       porcentaje
		  into _cod_agente,
               _porcentaje
		  from con_corr
 		 where sessionid = my_sessionid
 		let _monto2 = 0.00;  
		let _monto2 = _sin_pag_aa * _porcentaje / 100;
		begin work;
		insert into fis_che115a(no_documento, sin_pag_aa, tipo,cod_agente)
		values (_no_documento, _monto2, 5,_cod_agente);
		commit work;
	end foreach
end foreach
drop table tmp_sinis;
--***********************************************
-- Siniestros Pendientes Diciembre Anno Pasado --
--***********************************************
foreach	with hold
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
	let _valor = sp_sis101a(_no_documento,'01/01/2018','31/12/2018',my_sessionid);
	foreach
		select cod_agente,
		       porcentaje
		  into _cod_agente,
               _porcentaje
		  from con_corr
 		 where sessionid = my_sessionid
 		let _monto2 = 0.00;  
		let _monto2 = _sin_pen_dic * _porcentaje / 100;
		begin work;
		insert into fis_che115a(no_documento, sin_pen_ap, tipo,cod_agente)
		values (_no_documento, _monto2, 6, _cod_agente);
		commit work;
	end foreach	
end foreach
--*************************************
-- Siniestros Pendientes Anno Actual --
--*************************************
foreach	with hold
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
	let _valor = sp_sis101a(_no_documento,'01/01/2019',_fecha_aa, my_sessionid);
	foreach
		select cod_agente,
		       porcentaje
		  into _cod_agente,
               _porcentaje
		  from con_corr
 		 where sessionid = my_sessionid
 		let _monto2 = 0.00;  
		let _monto2 = _sin_pen_aa * _porcentaje / 100;
		begin work;
		insert into fis_che115a(no_documento, sin_pen_aa, tipo,cod_agente)
		values (_no_documento, _monto2, 7,_cod_agente);
		commit work;
	end foreach
end foreach
--******************************************************************************************
let _pri_susc_aa	 = 0;
let _pri_susc_ap	 = 0;
let _pri_susc_dev_aa = 0;
let _pri_susc_dev_ap = 0;
let _pri_dev_max_aa	 = 0;
let _pri_dev_max_ap	 = 0;
let _pri_devengada   = 0;
let _pri_dev_aa      = 0;

foreach
	select no_documento,
	       cod_agente,
		   sum(sin_pen_aa),			--   siniestros pend actual
		   sum(sin_pen_ap),			--   siniestros pend a dic
		   sum(sin_pag_aa),			--   siniestros pagados actual
		   sum(pri_sus_pag),		--   prima Suscrita Actual
		   sum(pri_sus_pag_ap),		--   prima Suscrita Año Pasado
		   sum(pri_can_ap),			--   prima neta cobrada
		   sum(pri_dev),            --   prima neta cobrada devengada
		   sum(pri_pag)			    --   prima neta cobrada devengada
	  into _no_documento,
		   _cod_agente,
		   _sin_pen_aa,
		   _sin_pen_dic,
		   _sin_pag_aa,
		   _pri_susc_aa,
		   _pri_susc_ap,
		   _monto_90_aa,
		   _pri_devengada,
		   _pri_dev_aa
	  from fis_che115a
	 group by no_documento,cod_agente
	 order by no_documento,cod_agente

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

	if _cod_grupo in('00000','1000') then --Grupo del estado se excluye
		continue foreach;
	end if
	if _cod_ramo = '001' and _cod_subramo = '006' then	--Zona Libre Francefield y cocosolito se excluyen.
		continue foreach;
	end if
	   
	if _cod_ramo = '023' then
		let _cod_ramo = '002';
	elif _cod_ramo = '001' then
		let _pri_dev_aa    = _pri_dev_aa    * (70 / 100);	--Quitar los riesgos catastroficos a prima neta cobrada devengada
	end if
    if _cod_ramo in("002","020","023","016","004","001","012","014","017","010","022","013","003","006","015","005","011","021","009","007") then
	else
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

	-- Siniestros Incurridos
	let _sini_incu = 0;
	let _sini_incu = _sin_pag_aa + _sin_pen_aa - _sin_pen_dic;
	
	select nombre,
	       porc_res_mat
	  into _nombre_ramo,
	       _porc_res_mat
	  from prdramo
	 where cod_ramo = _cod_ramo;

   	let a_periodo = '2019-12';
	
	-- dinamico
	select cod_tipo 
	  into _cod_tipo
	  from prdrentram 
	 where periodo  = a_periodo
	   and cod_ramo = _cod_ramo;

	--********  Unificacion de Agente *********************************
	let _cod_agente_tmp = _cod_agente;
	call sp_che168(_cod_agente_tmp) returning _error,_cod_agente;
	--*****************************************************************
	SELECT nombre,
		   tipo_pago,
		   tipo_persona,
		   cod_vendedor,
		   bono_rent2,
		   agente_agrupado,
		   tipo_agente,
		   estatus_licencia,
		   cedula
	  INTO _nombre,
		   _tipo_pago,
		   _tipo_persona,
		   _cod_vendedor,
		   _bono_rent2,
		   _agente_agrupado,
		   _tipo_agente,
		   _estatus_licencia,
		   _cedula_agt
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	if trim(_cedula_agt) = trim(_cedula_paga) then	-- Contra pagador
		continue foreach;
	end if
	if trim(_cedula_agt) = trim(_cedula_cont) then	-- Contra Contratante
		continue foreach;
	end if
	IF _tipo_agente <> "A" then	-- Solo agentes
		continue foreach;
	END IF
	if _agente_agrupado = "00270" then -- MARSH Semusa no Aplica a rentabilidad correo Analisa 01/06/2017
		continue foreach;
	end if
	if _cod_agente in('02569','02656') then	--se excluyen estos corredores por instr. Analisa, correo del 09/07/2019
		continue foreach;
	end if
	if _cod_agente = "00180" and  -- Tecnica de Seguros
	   _cod_ramo   = "016"	 and  -- Colectivo de vida
	   _cod_grupo  = "01016" then -- Grupo Suntracs
		continue foreach;
	end if
	if _cod_agente  = "00035" and  -- Ducruet
	   _cod_agencia = "075"   and  -- Agencia Ducruet
	   _cod_ramo    = "020"   then -- Soda
		continue foreach;
	end if
	if _cod_agente = '02111' then	--Se excluyen pólizas corredor Javier Avila.
		continue foreach;
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

	select nombre
	  into _nombre_vendedor
	  from agtvende
	 where cod_vendedor = _cod_vendedor ;

	--dinamico
	select trim(name_tipo),
		   porc_prima_dev_max 
	  into _n_cod_tipo,
		   _porc_prima_dev_max
	  from prdrenttipo
	 where periodo  = a_periodo
	   and cod_tipo = _cod_tipo 
	   and activo   = 1;

	--************************************************
	--   Calculos para incremeto de PSP 2019 vs 2018
	--************************************************
		let _pri_sus_aa_tmp = 0;
		let _pri_sus_ap_tmp = 0;		
		let _pri_sus_aa_tmp = _pri_susc_aa;
		let _pri_sus_ap_tmp = _pri_susc_ap;
		let _incremento_psp = _pri_sus_aa_tmp - _pri_susc_ap;
		
		--**********************************************************
		let _pri_susc_dev_aa = 0;
		let _pri_susc_dev_ap = 0;
		let _prima_cobrada   = 0;
		let _pri_susc_dev_ap = _pri_dev_aa;     --prima neta cobrada devengada

		if _pri_sus_aa_tmp is null then
			let _pri_sus_aa_tmp = 0;
		end if

		if _pri_sus_ap_tmp is null then
			let _pri_sus_ap_tmp = 0;
		end if

		--************************************************
		--   Calculos % de crecimiento de PSP
		--************************************************

		if _pri_sus_ap_tmp <> 0 then
			let _crecimiento = (_incremento_psp / _pri_sus_ap_tmp) * 100;
			if _pri_susc_aa = 0 and _pri_sus_ap_tmp <= 0 then
				let _crecimiento = 0;
				let _incremento_psp = 0;
			end if
		else
			let _crecimiento = 100; 
		end if
		
		--************************************************
		--    Calculos % de siniestralidad 
		--************************************************
		let _siniestralidad = 0;
		if _pri_dev_aa <> 0 then
			let _siniestralidad = (_sini_incu / _pri_dev_aa) * 100;
		end if

		let _aplica = 0;
		insert into rentabilidad1(
		periodo,   			
		cod_agente,     		
		no_documento,   		
		pri_susc_aa,  	   --PRIMA SUSCRITA AA	
		pri_susc_ap,  		
		pri_susc_dev_aa,  	
		pri_susc_dev_ap,   --PRIMA NETA COBRADA DEVENGADA
		pri_dev_max_aa,
		pri_dev_max_ap,
		sini_inc,  			
		monto_90,     		--Aqui se almacena la prima neta cobrada	
		n_agente, 			
		cod_contratante, 	
		n_cliente, 			
		cod_vendedor,    	
		nombre_vendedor, 	
		cod_ramo,    		
		nombre_ramo, 		
		tipo_agente, 		
		tipo,         		
		nombre_tipo,
		por_incremento, 		
		por_crecimiento, 	
		por_siniestro,
		aplica,
		beneficio,
		bono,
		sin_pag_aa,
		sin_pen_aa,
		sin_pen_dic   	
		)
		values(
		a_periodo,
		_cod_agente, 
		_no_documento,
		_pri_sus_aa_tmp,  		
		_pri_sus_ap_tmp,  		
		_pri_susc_dev_aa,  	
		_pri_susc_dev_ap,  --PRIMA NETA COBRADA DEVENGADA
		_pri_dev_max_aa,
		_pri_dev_max_ap,
		_sini_incu, 
		_prima_cobrada,
		_nombre,
		_cod_contratante, 
		_n_cliente, 
		_cod_vendedor,
		_nombre_vendedor,
		_cod_ramo,
		_nombre_ramo,
		_nombre_tipo,
		_cod_tipo,
		_n_cod_tipo,
		_incremento_psp,
		_crecimiento,
		_siniestralidad,
		_aplica,
		0,
		0,
		_sin_pag_aa,
		_sin_pen_aa,
		_sin_pen_dic
		);
end foreach
--/***************************************/
-- SE ACUMULARAN POR RAMO - GLOBAL
--/***************************************/
let _bono          = 0;
let _pri_devengada = 0;
foreach
	select tipo,
		   cod_agente,
		   sum(pri_susc_aa),		  
		   sum(por_crecimiento),			  
		   sum(por_siniestro),
		   sum(pri_dev_max_aa),
		   sum(pri_dev_max_ap),
		   sum(monto_90),
		   sum(pri_susc_dev_aa),
		   sum(pri_susc_dev_ap)
	  into _cod_tipo,
		   _cod_agente,
		   _pri_susc_aa,
		   _crecimiento,
		   _siniestralidad,
		   _pri_dev_max_aa,
		   _pri_dev_max_ap,
		   _prima_cobrada,
		   _pri_devengada,
		   _pri_susc_dev_ap
	  from rentabilidad1
	 where periodo    = a_periodo
	 group by cod_agente,tipo
	 order by cod_agente,tipo

	select prim_suscrita_min,
	       crecimiento_min
	  into _prim_suscrita_min,
		   _crecimiento_min  
	  from prdrenttipo 
     where periodo  = a_periodo
       and cod_tipo = _cod_tipo 
       and activo   = 1;

		if _pri_susc_aa >= _prim_suscrita_min then

		    if _crecimiento >= _crecimiento_min then

				let _porcentaje = 0; 

				select beneficio 
				  into _porcentaje
				  from prdrenttsin
				 where periodo  = a_periodo
				   and cod_tipo = _cod_tipo
				   and _siniestralidad between rango_inicial and rango_final;

				    if _porcentaje <> 0 then
						let _prima_beneficio = _pri_susc_dev_ap * (_porcentaje/100);

						let _bono = _prima_beneficio;

						 update rentabilidad1
							set bono       = _bono,
							    beneficio  = _porcentaje,
							    aplica     = 1 
						  where periodo    = a_periodo
							and cod_agente = _cod_agente
							and tipo       = _cod_tipo
							and aplica     = 0;	
				    end if
		    end if
	    end if
end foreach
return 0;
END PROCEDURE