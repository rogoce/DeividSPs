--***************************************************************************************
-- Procedimiento que genera el Reporte para convencion a Qatar 2020 para los corredores
--***************************************************************************************
--CONVENCION QATAR 2020
--1. sp_sis421       = carga la prima suscrita año anterior periodo del concurso en la tabla prisusap.
--2. sp_che86_clasif = clasificacion de los corredores por rango.
--3. sp_che86_aa     = carga la tabla fis_concurso1 con los valores del año pasado periodo del concurso. Esta tabla no se borra, para que las cifras año pasado periodo concurso no se muevan.
--4. En el procedimiento sp_che86 que es el que corre diariamente, se borra la tabla milan08 y la tabla fis_concurso. Se carga fis_concurso a partir de fis_concurso1 y sigue el proceso de carga de datos,
--   buscando año actual periodo del concurso y año pasado periodo del concurso a la fecha(es decir al mes que va corriendo año actual).


DROP PROCEDURE sp_che86_prueba2;
CREATE PROCEDURE sp_che86_prueba2(a_compania CHAR(3), a_sucursal CHAR(3))
RETURNING SMALLINT,char(30),dec(16,2),char(20);

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
--se puso a correr 03/01/2020 Armando
--se detuvo 04/10/2019 Armando
--return 0; 

--SET DEBUG FILE TO "sp_che86.trc";
--TRACE ON;

begin 

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

-- Periodo Actual


SET ISOLATION TO DIRTY READ;
let my_sessionid = DBINFO('sessionid');
--******************************************************************************
-- Prima neta devengada periodo convencion 2019-10 Al periodo se esta evaluando
--******************************************************************************
foreach
	select c.doc_remesa
	  into _no_documento
	  from cobredet c, cobreagt a
	 where c.no_remesa = a.no_remesa
           and c.renglon = a.renglon
           and c.periodo     >= '2019-10'
	   and c.periodo     <= '2020-01'
	   and c.actualizado = 1
	   and c.tipo_mov    in ("P", "N")
       and a.cod_agente = '02302'
	 group by c.doc_remesa
	 order by doc_remesa

	let _valor = sp_sis101a(_no_documento,'01/10/2019','30/09/2020', my_sessionid);
	call sp_dev06f(_no_documento,'31/01/2020','01/10/2019','31/01/2020') returning _valor,_mensaje,_pri_dev_aa;
	if _pri_dev_aa is null then
		let _pri_dev_aa = 0.00;
	end if
	return _valor,_mensaje,_pri_dev_aa,_no_documento with resume;
end foreach
end
end procedure
