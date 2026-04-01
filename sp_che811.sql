--********************************************************
-- Procedimiento que Carga las Bonificaciones de cobranza
--********************************************************

-- Creado    : 27/02/2008 - Autor: Armando Moreno M.
-- Modificado: 27/02/2008 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che811;

CREATE PROCEDURE sp_che811
(
a_compania          CHAR(3),
a_sucursal          CHAR(3),
a_periodo		    CHAR(7),
a_usuario           CHAR(8)
)
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
DEFINE v_por_vencer     DEC(16,2);
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
define v_monto_30bk,_comision		DEC(16,2);
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

--SET DEBUG FILE TO "sp_che81.trc";
--TRACE ON;

let _error   = 0;
let _porc_coas_ancon = 0;
let _forma_pag    = 0;
let _porc_comis   = 0;
let _porc_comis2  = 0;
let _prima_45     = 0;
let _prima_90     = 0;
let _cnt          = 0;
let _monto_m      = 0;
let _monto_p      = 0;
let _prima_bruta  = 0;

{update chqboni
   set bandera   = 1,
       comision  = prima * 0.03,
       porc_045  = 3,
       porc_4690 = 0,
       comis0045 = prima * 0.03,
       seleccionado = 0
 where periodo  = '2009-03'
   and comision = 0
   and porc_4690 = 3 }

foreach

	SELECT cod_agente
	  INTO _cod_agente
	  FROM chqboni
     WHERE periodo = a_periodo
	   and seleccionado = 0
       and tipo_requis  = 'A'
	 GROUP BY cod_agente
	 ORDER BY cod_agente

{	SELECT SUM(comision)
	  INTO _comision
	  FROM chqboni
	 WHERE cod_agente = _cod_agente
	   AND periodo    = a_periodo
	   and seleccionado = 0
       and tipo_requis  = 'A';


   --	if _comision is null or _comision = 0 then
   --		continue foreach;
   --	end if }

	SELECT count(*)
	  INTO _contado
	  FROM chqchmae
	 WHERE cod_agente = _cod_agente
	   and no_cheque = 274;

	if _contado = 0 then

	 	call sp_che82a(a_compania,a_sucursal,_cod_agente,a_usuario,'001','001',a_periodo) returning _error;

	end if

	if _error <> 0 then
		return _error;
	end if

end foreach	

{update parparam
   set ult_per_boni = a_periodo
 where cod_compania = a_compania;}


DROP TABLE tmp_boni; 

return 0;
END PROCEDURE;