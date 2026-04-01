--Procedimiento para realizar la carga en Rentabilidad1 para simular el bono de RENTABILIDAD
--Creado 22/03/2017	Armando Moreno M.

DROP PROCEDURE sp_che115_carga2017sim3fac2;
CREATE PROCEDURE sp_che115_carga2017sim3fac2(a_compania CHAR(3), a_sucursal CHAR(3))
RETURNING SMALLINT,char(20);

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
define _fec_aa_ini   	date;
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

define _prima_beneficio 	dec(16,2);
define _prima_maxima    	dec(16,2);
define _bono            	dec(16,2);
define _pri_sus_aa_tmp		dec(16,2);
define _pri_sus_ap_tmp		dec(16,2);
define _prima_ret_aa 		dec(16,2);
define _prima_ret_ap   		dec(16,2);
define _bono_rent2          smallint;

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
let _pri_pag        	 = 0;
let _sin_pen_dic    	 = 0;
let _sin_pen_aa     	 = 0;
let _sin_pag_aa     	 = 0;
let v_por_vencer    	 = 0;
let v_exigible	    	 = 0;
let v_corriente	    	 = 0;
let v_monto_30	    	 = 0;
let v_monto_60	    	 = 0;
let v_monto_90	    	 = 0;
let v_saldo         	 = 0;
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

if a_periodo > "2012-12" then
	let a_periodo = "2017-12";
end if

let a_periodo   = '2017-12';


let _fec_aa_ini     = "01/01/2017";	--para sacar cancelada o anulada en el periodo
let _per_ini        = "2017-01";
let _per_ini_ap     = "2016-01";
let _ano            = a_periodo[1,4];  --2014
let _ano            = _ano - 1;		   --2013
let _per_fin_ap     = _ano || a_periodo[5,7]; --2013-12

let _per_fin_dic    = "2016-12";         
let _fecha_aa_ini   = sp_sis36(_per_ini);    --31/01/2014	 
let _fecha_aa       = sp_sis36(a_periodo);	 --30/06/2014 
let _fecha_ap_ini   = sp_sis36(_per_ini_ap); --31/01/2013 
let _fecha_ap       = sp_sis36(_per_fin_ap); --31/12/2013

SET ISOLATION TO DIRTY READ;


let _pri_susc_aa	 = 0;
let _pri_susc_ap	 = 0;
let _pri_susc_dev_aa = 0;
let _pri_susc_dev_ap = 0;
let _pri_dev_max_aa	 = 0;
let _pri_dev_max_ap	 = 0;

foreach
	select no_documento,
		   sum(sin_pen_aa),			--   siniestros pend actual
		   sum(sin_pen_ap),			--   siniestros pend a dic
		   sum(sin_pag_aa),			--   siniestros pagados actual
		   sum(pri_sus_pag),			--   prima Suscrita Actual
		   sum(pri_sus_pag_ap)			--   prima Suscrita Anio Pasado
	  into _no_documento,
		   _sin_pen_aa,
		   _sin_pen_dic,
		   _sin_pag_aa,
		   _pri_susc_aa,
		   _pri_susc_ap
	  from fis_che115a
	 where no_documento = '0215-01958-01'
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
	   
	if _cod_ramo = '023' then
		let _cod_ramo = '002';
	end if

    if _cod_ramo in("002","020","004","016","012","014","017","010","022","013","003","006","015","005","011","021","009","007",'023') then
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
	
	select count(*)
	   into _cnt
	   from emifafac
	  where no_poliza = _no_poliza;

	if _cnt > 0 then		-- Facultativos, solo nuestra parte
		let _prima_ret_aa = 0;
		let _prima_ret_ap = 0;
	
		select sum(a.prima)
		  into _prima_ret_aa
		  from emifacon a, endedmae e, reacomae r
		 where a.no_poliza = e.no_poliza
		   and a.no_endoso = e.no_endoso
		   and a.cod_contrato = r.cod_contrato
		   and r.tipo_contrato not in(3)
		   and e.actualizado  = 1
		   and e.periodo      >= '2017-01'
		   and e.periodo  	  <= '2017-12'
		   and e.no_documento = _no_documento;
	
		if _prima_ret_aa is null then
			let _prima_ret_aa = 0.00;
		end if
		
		select sum(a.prima)
		  into _prima_ret_ap
		  from emifacon a, endedmae e, reacomae r
		 where a.no_poliza = e.no_poliza
		   and a.no_endoso = e.no_endoso
		   and a.cod_contrato = r.cod_contrato
		   and r.tipo_contrato not in(3)
		   and e.actualizado  = 1
		   and e.periodo      >= '2016-01'
		   and e.periodo  	  <= '2016-12'
		   and e.no_documento = _no_documento;
		
		if _prima_ret_ap is null then
			let _prima_ret_ap = 0;
		end if
		
		update fis_che115a
		   set pri_sus_pag    = _prima_ret_aa
		 where no_documento   = _no_documento
		   and tipo = 3;
		   
		update fis_che115a
		   set pri_sus_pag_ap = _prima_ret_ap
		 where no_documento   = _no_documento
		   and tipo = 4;
		return 0,_no_documento with resume;   
	end if	 
end foreach
return 0,'';
END PROCEDURE                                                                                                                                                                                                 
