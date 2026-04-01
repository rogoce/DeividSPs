--************************************************************************************
-- Bonificacion de rentabilidad al perido actual -- Tabla de rentabilidad progresiva
--************************************************************************************
-- execute procedure sp_che115p("001","001")
-- Creado    : 24/03/2010 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che115p;

CREATE PROCEDURE sp_che115p(
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
--define _porc_prima_dev_max  dec(16,2);

define _prima_beneficio 	dec(16,2);
define _prima_maxima    	dec(16,2);
define _bono            	dec(16,2);

--SET DEBUG FILE TO "sp_aud21.trc";

-- Desactivado por Order de Demetrio, para que no afecte los calculos realizados. 
-- Return 0;


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

let _pri_susc_dev_aa	 = 0;
let _pri_susc_dev_ap	 = 0;

--delete from rentabilidad1;
--delete from tmprenta;
--delete from tmp_che115a;

select par_ase_lider,
       par_periodo_act  -- ult_per_renta
  into _cod_coasegur,
	   a_periodo
  from parparam
 where cod_compania = a_compania;

if a_periodo > "2011-12" then
	let a_periodo = "2011-12";
end if

let _per_ini        = "2011-01";
let _per_ini_ap     = "2010-01";
let _ano            = a_periodo[1,4];
let _ano            = _ano - 1;
let _per_fin_ap     = _ano || a_periodo[5,7];

let _per_fin_dic    = "2010-12";         
let _fecha_aa_ini   = sp_sis36(_per_ini);
let _fecha_aa       = sp_sis36(a_periodo);
let _fecha_ap_ini   = sp_sis36(_per_ini_ap);
let _fecha_ap       = sp_sis36(_per_fin_ap);

--trace off;
{create temp table tmp_che115abk(
no_documento 	  CHAR(20), 
pri_sus_pag   	  DECIMAL(16,2) DEFAULT 0,
pri_pag  		  DECIMAL(16,2) DEFAULT 0,
pri_can  		  DECIMAL(16,2) DEFAULT 0,
pri_dev  		  DECIMAL(16,2) DEFAULT 0,
sin_pag_aa 		  DECIMAL(16,2) DEFAULT 0, 
sin_pen_aa 		  DECIMAL(16,2) DEFAULT 0, 
sin_pen_ap 		  DECIMAL(16,2) DEFAULT 0, 
no_pol_ren_aa 	  INTEGER DEFAULT 0, 
no_pol_ren_ap 	  INTEGER DEFAULT 0, 
no_pol_nue_aa 	  INTEGER DEFAULT 0, 
no_pol_nue_ap 	  INTEGER DEFAULT 0, 
no_pol_nue_ap_per INTEGER DEFAULT 0, 
pri_sus_pag_ap    DECIMAL(16,2) DEFAULT 0, 
pri_pag_ap  	  DECIMAL(16,2) DEFAULT 0,
pri_can_ap  	  DECIMAL(16,2) DEFAULT 0,
pri_dev_ap  	  DECIMAL(16,2) DEFAULT 0,
no_pol_ren_aa_per INTEGER DEFAULT 0, 
no_pol_ren_ap_per INTEGER DEFAULT 0, 
tipo              INTEGER DEFAULT 0) ;
reate temp table rentabilidad1bk (
periodo   			CHAR(7) , 
cod_agente     		CHAR(5) , 
no_documento   		CHAR(20), 
pri_susc_aa  		DECIMAL(16,2) default 0,
pri_susc_ap  		DECIMAL(16,2) default 0,
pri_susc_dev_aa  	DECIMAL(16,2) default 0,
pri_susc_dev_ap  	DECIMAL(16,2) default 0,
pri_dev_max_aa  	DECIMAL(16,2) default 0,
pri_dev_max_ap  	DECIMAL(16,2) default 0,
sini_inc  			DECIMAL(16,2) default 0,
monto_90     		DECIMAL(16,2) default 0,
n_agente 			VARCHAR(50), 
cod_contratante 	CHAR(10), 
n_cliente 			VARCHAR(100), 
cod_vendedor    	CHAR(3), 
nombre_vendedor 	CHAR(50), 
cod_ramo    		CHAR(3), 
nombre_ramo 		CHAR(50), 
tipo_agente 		CHAR(15), 
tipo         		CHAR(3),
nombre_tipo 		CHAR(50), 
por_incremento 	    DECIMAL(16,2) default 0,
por_crecimiento 	DECIMAL(16,2) default 0,
por_siniestro   	DECIMAL(16,2) default 0,
aplica          	smallint default 0,
beneficio        	DECIMAL(16,2) default 0,
bono				DECIMAL(16,2) default 0
)with no log;  }


SET ISOLATION TO DIRTY READ;
-- TRACE ON;
--/***************************************/
-- SE ACUMULARAN POR RAMO - GLOBAL
--/***************************************/
foreach
	select tipo,
		   cod_agente,
		   sum(pri_susc_aa),		  
		   sum(pri_susc_ap),			  
		   sum(sini_inc),
		   sum(pri_susc_dev_aa),
		   sum(pri_susc_dev_ap)
	  into _cod_tipo,
		   _cod_agente,
		   _pri_susc_aa,
		   _pri_susc_ap,
		   _sini_incu,
		   _pri_dev_max_aa,
		   _pri_dev_max_ap
	  from rentabilidad1bk
	 where periodo    = a_periodo
	   and monto_90   = 0
	 group by cod_agente,tipo
	 order by cod_agente,tipo

		--************************************************
		--   Calculos para incremeto de PSP 2010 vs 2009
		--************************************************
		let _incremento_psp  = _pri_susc_aa - _pri_susc_ap ;				

		--************************************************
		--   Calculos % de crecimiento de PSP
		--************************************************
		if _pri_susc_ap <> 0 then
	       let _crecimiento = (_incremento_psp / _pri_susc_ap) * 100;
	  else
	       let _crecimiento = 100; 
	   end if		

	   --************************************************
	   --    Calculos % de siniestralidad 
	   --************************************************
	   let _siniestralidad = 0;
	    if _pri_susc_aa <> 0 then
		   let _siniestralidad = (_sini_incu / _pri_susc_aa) * 100;
	  else
	   	   let _siniestralidad = 100;
	   end if	

	select prim_suscrita_min,
	       crecimiento_min,
		   porc_prima_dev_max
	  into _prim_suscrita_min,
		   _crecimiento_min,
		   _porc_prima_dev_max  
	  from prdrenttipo 
     where periodo  = a_periodo
       and cod_tipo = _cod_tipo 
       and activo   = 1 ;

		if _pri_susc_aa >= _prim_suscrita_min then

			if _crecimiento >= _crecimiento_min then

				   let _porcentaje = 0; 

				select beneficio 
				  into _porcentaje
				  from prdrenttsin
				 where periodo  = a_periodo
				   and cod_tipo = _cod_tipo
				   and _siniestralidad between rango_inicial and rango_final;

					if _porcentaje is null then
					   let _porcentaje = 0; 
 				   end if

					if _porcentaje <> 0 then

					   let _prima_maxima = (_pri_dev_max_aa + _pri_dev_max_ap) * (_porc_prima_dev_max/100);
					   let _prima_beneficio = _pri_susc_aa * (_porcentaje/100);

					    if _prima_beneficio > _prima_maxima then
						    let _bono = _prima_maxima ;
					  else
						    let _bono = _prima_beneficio ;								
					    end if

					 update rentabilidad1bk
						set bono            = _bono,
						    beneficio       = _porcentaje,
						    aplica          = 1 
					  where periodo         = a_periodo
						and cod_agente      = _cod_agente
						and tipo            = _cod_tipo
						and monto_90        = 0
						and aplica          = 0;	
				   end if
		   end if
	   end if
end foreach	 


--drop table tmp_che115abk;
--drop table rentabilidad1bk;

return 0;

END PROCEDURE;
