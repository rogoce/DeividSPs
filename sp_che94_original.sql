--***********************************************************************************
-- Procedimiento que genera la Bonificacion de Rentabilidad por corredores
--***********************************************************************************
-- execute procedure sp_che94("001","001","2010-12","HGIRON")
-- Creado    : 28/01/2009 - Autor: Henry Giron
-- Modificado: 28/01/2009 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che94;

CREATE PROCEDURE sp_che94(
a_compania          CHAR(3),
a_sucursal          CHAR(3),
v_periodo_aa        CHAR(7),  -- 2007-12
a_usuario           CHAR(8)
) RETURNING SMALLINT,
          char(50),
		  char(3);

DEFINE _no_poliza       CHAR(10);
define _no_poliza_ap    CHAR(10);
DEFINE _monto           DEC(16,2);
DEFINE _fecha           DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(16,2); 
DEFINE _porc_comis      DEC(16,2);
DEFINE _porc_comis2     DEC(16,2);
DEFINE _porc_coas_ancon DEC(16,2);
DEFINE _sobrecomision   DEC(16,2);
DEFINE _nombre          CHAR(50); 
DEFINE _no_documento    CHAR(20); 
DEFINE _no_requis       CHAR(10); 
DEFINE _cod_tipoprod    CHAR(3);  
DEFINE _tipo_prod       SMALLINT; 
DEFINE _cod_tiporamo    CHAR(3);  
DEFINE _tipo_ramo       SMALLINT; 
DEFINE _cod_ramo        CHAR(3);  
DEFINE _cod_ramo1        CHAR(3);  
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
define _cod_agente1   	char(5);
define _cantidad        integer;
define _fecha_aa_ini     date;
define _fecha_aa        date;
define _fecha_ap_ini    date;
define _fecha_ap        date;
define _vigente         smallint;
define v_filtros        varchar(255);
define a_periodo        char(7);
define v_periodo_ap     char(7);
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
define _pri_sus_pag_ap_p  DEC(16,2);

define _pri_sus_pag     dec(16,2);
define _pri_sus_pag_p     dec(16,2);

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

define _incremento_psp  dec(16,2);
define _crecimiento     dec(16,2);
define _siniestralidad  dec(16,2);
define _beneficio		dec(16,2);
define _cre_prima_aplica     smallint;
define _min_prima_pag_aplica smallint;
define _sini_aplica          smallint;
define _cnt_ant			integer;
define _cnt_act			integer;  
define _prima_neta		dec(16,2);
define _prima_neta_p		dec(16,2);
define _valor_prima     dec(16,2);
define _porcentaje      dec(16,2);
define _cod_origen      char(3);
define _cod_contr       char(10);
define v_nombre_clte    char(100);
define _valor           dec(16,2);
define _error_isam		integer;
define _error_desc		char(50);
define _tipo			char(1);
define _cod_tipo        char(1);
define _cod_tipo1       char(1);
define _beneficios      smallint;
				  
define _nombre_tipo_g	char(50);
define _tipo_g			char(1);
define _prima_neta_g    decimal(16,2);
define _comision_g		decimal(16,2);
define _porcentaje_g	decimal(16,2);
define _por_cre_g		decimal(16,2);
define _por_sin_g		decimal(16,2);
define _prima_ap_g		decimal(16,2);
define _sini_g          decimal(16,2);
define _sini_i          decimal(16,2);

define _descrip			varchar(100);
define _psp_c           varchar(20);
define _cre_c           varchar(20);
define _sin_c           varchar(20);
define s_psp_c          varchar(20);
define s_cre_c          varchar(20);
define s_sin_c          varchar(20);

define _cnt_ind			smallint;
define a_anio_rev       smallint;
DEFINE _unificar        smallint;

define _porc_res_mat	dec(5,2);
define _prima_suscrita  DEC(16,2);
define _pri_cob_dev     dec(16,2);


--SET DEBUG FILE TO "sp_che94.trc";
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
       par_periodo_act,
	   ult_per_renta
  into _cod_coasegur,  -- 036
	   a_periodo,	   -- 2008-12
	   v_periodo_ap	   -- 2007-12
  from parparam
 where cod_compania = a_compania;

--let v_periodo_ap 	= '2008-12';   --borrar esta linea

if a_periodo > "2010-12" then
	let a_periodo = "2010-12";
end if


let a_anio_rev = v_periodo_ap[1,4] + 1 ;
let a_periodo =  a_anio_rev||'-'||'12' ;

let _per_ini        = a_periodo[1,4]||'-'||'01';
let _per_fin_dic    = a_periodo;

let _ano            = a_periodo[1,4];
let _ano            = _ano - 1;

let _per_ini_ap 	= v_periodo_ap[1,4]||'-'||'01';
let _per_fin_ap 	= v_periodo_ap;

let _fecha_aa_ini   = sp_sis36(_per_ini);
let _fecha_aa       = sp_sis36(a_periodo);
let _fecha_ap_ini   = sp_sis36(_per_ini_ap);
let _fecha_ap       = sp_sis36(_per_fin_ap);


SET ISOLATION TO DIRTY READ;
begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc, _error_isam;
end exception

foreach
	SELECT cod_agente
	  INTO _cod_agente
	  FROM chqrenta3
     WHERE periodo = a_periodo
	 GROUP BY cod_agente
	 ORDER BY cod_agente

 	call sp_che98(a_compania,a_sucursal,_cod_agente,a_usuario,'001','001',a_periodo) returning _error;

	if _error <> 0 then
		return _error,'Actualizacion Exitosa...Error.',a_periodo;
	end if

end foreach	

update parparam
   set ult_per_renta = a_periodo
 where cod_compania  = a_compania;
 
end  

return 0, 'Actualizacion Exitosa...',a_periodo;

END PROCEDURE;	  