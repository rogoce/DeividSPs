--*******************************************************************************************
-- Procedimiento que Actualiza las primas cobradas nuevas para mini convencion tropical 2011
--*******************************************************************************************

-- Creado    : 27/02/2008 - Autor: Armando Moreno M.
-- Modificado: 27/02/2008 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.
DROP PROCEDURE sp_che206b;

CREATE PROCEDURE sp_che206b(a_compania CHAR(3))
RETURNING SMALLINT;

DEFINE _cod_agente      CHAR(5);  
DEFINE _no_poliza       CHAR(10);
define _cod_subramo     char(3); 
define _cod_origen      char(3); 
DEFINE _no_remesa       CHAR(10); 
DEFINE _renglon         SMALLINT; 
DEFINE _monto           DEC(16,2);
DEFINE _no_recibo       CHAR(10); 
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
DEFINE _monto_vida      DEC(16,2);
DEFINE _monto_danos     DEC(16,2);
DEFINE _monto_fianza    DEC(16,2);
DEFINE _cod_tiporamo    CHAR(3);  
DEFINE _tipo_ramo       SMALLINT; 
DEFINE _cod_ramo        CHAR(3);  
DEFINE _no_licencia     CHAR(10); 
DEFINE _tipo_mov        CHAR(1);  
DEFINE _incobrable		SMALLINT;
DEFINE _tipo_pago     	SMALLINT;
DEFINE _tipo_agente     CHAR(1);
DEFINE _cod_producto	char(5);
DEFINE _cod_formapag    char(3);
DEFINE _tipo_forma      SMALLINT;
DEFINE _no_licencia2    CHAR(10); 
DEFINE _nombre2         CHAR(50); 
define _forma_pag		smallint;
define _fecha_hoy       date;
DEFINE v_prima_orig     DEC(16,2);
DEFINE v_saldo          DEC(16,2);
DEFINE v_prima_n        DEC(16,2);
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente      DEC(16,2);
DEFINE v_monto_30       DEC(16,2);
DEFINE v_monto_60       DEC(16,2);
define _prima_45        DEC(16,2);
define _prima_90		DEC(16,2);
define _prima_r  		DEC(16,2);
define _prima_rr  		DEC(16,2);
define _formula_a  		DEC(16,2);
define _cnt             integer;
define v_monto_30bk		DEC(16,2);
define v_corr			DEC(16,2);
DEFINE _formula_b       DEC(16,2);
define _comision1       DEC(16,2);
define _comision2       DEC(16,2);
define _prima_bruta     DEC(16,2);
define _cod_grupo       char(5);
define _cedula_agt      char(30);				   
define _cedula_paga		char(30);				   
define _cedula_cont		char(30);				   
define _cod_pagador     char(10);				   
define _cod_contratante char(10);				   
define _estatus_licencia char(1);				   
define v_nombre_clte     char(100);				   
define _cod_contr        char(10);
define _error           smallint;				   
define _monto_m			DEC(16,2);				   
define _monto_p			DEC(16,2);				   
define _suc_origen      char(3);				   
define _beneficios      smallint;				   
define _contado         smallint;				   
define _dias            integer;
define _fecha_decla     date;
define _mess            integer;
define _anno            integer;
define _f_ult           date;
define _f_decla_ult     date;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _concurso        smallint;
define _agente_agrupado char(5);
define _prima_cobrada   dec(16,2);
define _prima_cobrada2   dec(16,2);
define _retro            smallint;
define a_periodo_ini    char(7);
define _cod_agente1     char(5);
define _declarativa     smallint;
define _valor           smallint;
define _nueva_renov     char(1);
define _cantidad_pol    integer;
define _n_agente        char(50);
define _n_ramo          char(50);
define _categoria       smallint;
define _cod_agente2     char(5);
define _sw              smallint;

--SET DEBUG FILE TO "sp_che207a.trc";
--TRACE ON;

let _error   = 0;
let _porc_coas_ancon = 0;
let _forma_pag      = 0;
let _porc_comis     = 0;
let _porc_comis2    = 0;
let _prima_45       = 0;
let _prima_90       = 0;
let _cnt            = 0;
let _monto_m        = 0;
let _monto_p        = 0;
let _prima_bruta    = 0;
let _prima_cobrada  = 0;
let _prima_cobrada2 = 0;
let _retro          = 0;
let _declarativa    = 0;
let _valor          = 0;
let v_prima_n       = 0;
let _sw             = 0;


SET ISOLATION TO DIRTY READ;

FOREACH

	select cod_agente,pri_co_2010_con
	  into _cod_agente,_monto_p
	  from tropical
  order by cod_agente


   UPDATE tropical2
      SET pri_co_2010_con = pri_co_2010_con + _monto_p
    WHERE cod_agente   = _cod_agente
      AND no_documento is null;


end foreach

return 0;

END PROCEDURE;