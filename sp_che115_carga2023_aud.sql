--Procedimiento para realizar la carga en Rentabilidad1 para bono de RENTABILIDAD 2023
--Usando prima neta cobrada devengada
--Creado 31/03/2023	Armando Moreno M.

DROP PROCEDURE sp_che115_carga2023_aud;
CREATE PROCEDURE sp_che115_carga2023_aud(a_compania CHAR(3), a_sucursal CHAR(3))
RETURNING SMALLINT;

DEFINE _no_poliza       CHAR(10);
DEFINE _monto           DEC(16,2);
DEFINE _fecha,_fecha_siniestro           DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2);
DEFINE _porc_comis2     DEC(5,2);
DEFINE _porc_coas_ancon DEC(5,2);
DEFINE _sobrecomision   DEC(16,2);
DEFINE _nombre          CHAR(50); 
DEFINE _no_documento    CHAR(20); 
define _numrecla        char(18);
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
DEFINE _no_unidad	char(5);
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
define _reserva_bruto       DEC(16,2);

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
define _prima_ret_ap,_monto_fac_ac  dec(16,2);
define _bono_rent2,_fronting        smallint;
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
let _fronting            = 0;
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
let _reserva_bruto	 = 0;

select par_ase_lider,
       par_periodo_act  -- ult_per_renta
  into _cod_coasegur,
	   a_periodo
  from parparam
 where cod_compania = a_compania;
 
 let my_sessionid = DBINFO('sessionid');

if a_periodo > "2012-12" then
	let a_periodo = "2023-12";
end if

--delete from rentabilidad1 where periodo = a_periodo;

select par_periodo_ant
  into a_periodo
  from parparam
 where cod_compania = a_compania;

let a_periodo   = '2023-12';

let _fec_aa_ini     = "01/01/2023";	--para sacar cancelada o anulada en el periodo
let _per_ini        = "2023-01";
let _per_ini_ap     = "2022-01";
let _ano            = a_periodo[1,4];
let _ano            = _ano - 1;
let _per_fin_ap     = _ano || a_periodo[5,7];

let _per_fin_dic    = "2022-12";         
let _fecha_aa_ini   = sp_sis36(_per_ini);    --31/01/2021	 
let _fecha_aa       = sp_sis36(a_periodo);	 --31/12/2021 
let _fecha_ap_ini   = sp_sis36(_per_ini_ap); --31/01/2020 
let _fecha_ap       = sp_sis36(_per_fin_ap); --31/12/2020

--***************************
--truncate table fis_che115a;
--***************************
SET ISOLATION TO DIRTY READ;

--**********************************
-- Siniestros Pagados Anno Actual --
--**********************************
call sp_rec01(a_compania, a_sucursal, _per_ini, a_periodo) returning _filtros;

foreach

    select doc_poliza,
           pagado_bruto,
           reserva_bruto,
           no_poliza,
		   numrecla,
		   cod_ramo		   
      into _no_documento,
           _sin_pag_aa,
		   _reserva_bruto,
		   _no_poliza,
		   _numrecla,
		   _cod_ramo
      from tmp_sinis
	 where cod_agente in('02311','01589','02901') 

	let _valor = sp_sis101a(_no_documento,'01/01/2023', _fecha_aa, my_sessionid);
	
	select cod_reclamante,fecha_siniestro,no_unidad
	  into _cod_contratante,_fecha_siniestro,_no_unidad
	  from recrcmae
	 where numrecla = _numrecla;
	 
	select vigencia_inic,vigencia_final
      into _vigencia_inic,_vigencia_final
      from emipomae
     where no_poliza = _no_poliza;	  
	 
	foreach
		select cod_agente,
		       porcentaje
		  into _cod_agente,
               _porcentaje
		  from con_corr
 		 where sessionid = my_sessionid
 		let _monto2 = 0.00;  
		let _monto2 = _sin_pag_aa * _porcentaje / 100;
		--begin work;
		insert into fis_che115ab(no_documento, sin_pag_aa, tipo,cod_agente,numrecla,cod_ramo,fecha_siniestro,cod_reclamante,no_unidad,reserva_bruto,
		                         vig_ini,vig_fin,no_poliza)
		values (_no_documento,_monto2,5,_cod_agente,_numrecla,_cod_ramo,_fecha_siniestro,_cod_contratante,_no_unidad,_reserva_bruto,_vigencia_inic,
		                         _vigencia_final,_no_poliza);
		--commit work;
	end foreach
end foreach
drop table tmp_sinis;

return 0;
--usar este query para la salida
{elect a.cod_agente,d.nombre,a.no_documento,a.cod_ramo,b.nombre,a.vig_ini,a.vig_fin,a.numrecla,a.no_unidad,a.cod_reclamante,c.nombre,a.fecha_siniestro,a.sin_pag_aa,a.reserva_bruto
from fis_che115ab a, prdramo b, cliclien c, agtagent d
where a.cod_ramo = b.cod_ramo
and a.cod_reclamante = c.cod_cliente
and a.cod_agente = d.cod_agente
order by d.nombre,a.cod_ramo}
END PROCEDURE