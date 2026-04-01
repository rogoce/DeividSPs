--****************************************************************************************************
-- Procedimiento para determinar bono sobre prima nueva cobrada 2021 PROYECTO CCP  INCENTIVO 1
--****************************************************************************************************

-- Creado    : 08/05/2021 - Autor: Armando Moreno M.

DROP PROCEDURE sp_bonoccp01bk;
CREATE PROCEDURE sp_bonoccp01bk()
RETURNING CHAR(5),CHAR(5);

DEFINE _cod_agente,_cod_agente_anterior CHAR(5);
DEFINE _cod_agente_tmp  CHAR(5);
DEFINE _no_poliza       CHAR(10);
define _cod_vendedor    char(3); 
DEFINE _monto           DEC(16,2);
DEFINE _prima_suscrita  DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2);
DEFINE _porc_comis2     DEC(5,2);
DEFINE _cod_tipoprod    CHAR(3);  
DEFINE _tipo_prod       SMALLINT; 
DEFINE _cod_tiporamo    CHAR(3);  
DEFINE _cod_ramo        CHAR(3);  
DEFINE _no_licencia     CHAR(10); 
define _forma_pag		smallint;
define _prima_sus_ant	DEC(16,2);
define _cod_grupo       char(5);
define _prima_neta		DEC(16,2);
define _renglon         smallint;
define _no_recibo       char(10);
define _cnt             smallint;
define _prima_r         DEC(16,2);
define _monto_b         DEC(16,2);
define _prima_n         DEC(16,2);
define _cod_subramo     char(3);
define _concurso        smallint;
define _declarativa     smallint;
define _agente_agrupado char(5);
define _no_documento    char(20);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _prima_fac       DEC(16,2);
define v_exigible       DEC(16,2);
define v_corriente		DEC(16,2);
define v_monto_30		DEC(16,2);
define v_monto_60		DEC(16,2);
define _es_mensual      smallint ;
define _desde			char(7);
define _hasta           char(7);
define _fecha_ini		date;
define _fecha_fin		date;
define _fecha_anulado   date;
define _pagado          smallint;
define _pri_sus_fal     dec(16,2);
define _no_requis		char(10);
define _monto_fac_ac    dec(16,2);
define _monto_fac       dec(16,2);
define _porc_partic_prima dec(16,2);
define _porc_proporcion   dec(16,2);
define _periodo           char(4);
define _porc_coaseguro    decimal(7,4);
define _cod_coasegur      char(3);
define _estatus_poliza    smallint;
define _prima             decimal(16,2);
define _prima_retenida,_meta_minima    decimal(16,2);
define _cnt_rg,_tipo_contrato		  smallint;
define _valor             smallint;
define _ano_actual,_unificar        integer;
define _periodo_actual    char(7);
define _prima_cob_ap      decimal(16,2);

let _error           = 0;
let _prima_neta      = 0;
let _cnt             = 0;
let _prima_r         = 0;
let _monto_b         = 0;
let _prima_n         = 0;
let _declarativa     = 0;
let _prima_fac	     = 0;
let	v_exigible  	 = 0;
let	v_corriente		 = 0;
let	v_monto_30		 = 0;
let	v_monto_60		 = 0;
let _pri_sus_fal	 = 0;
let _monto_fac_ac    = 0;
let _monto_fac		 = 0;
let _porc_proporcion = 0;
let _porc_partic_prima = 0;
let _prima_suscrita    = 0;
let _cnt_rg            = 0;
let _prima_retenida    = 0;
let _prima_sus_ant     = 0;
let _prima_cob_ap      = 0;

let _desde = null;
let _hasta = null;

--Meta Minima
let _meta_minima = 2000;

SET ISOLATION TO DIRTY READ;
--SET DEBUG FILE TO "sp_bonoccp01.trc";
--TRACE ON;
--******************************************************

--delete from bono_ccpl
--where periodo = _periodo;

--***************************AGREGAR CORREDORES NUEVOS
foreach
	select cod_agente
	  into _cod_agente
	  from prisusapccp
	 group by cod_agente 
	   
	let _cod_agente_anterior = _cod_agente;
	call sp_che168(_cod_agente_anterior) returning _error,_cod_agente;  --Buscar si el corredor nuevo esta agrupado y ya existia en la tabla.

    if _cod_agente_anterior <> _cod_agente then
	  --  delete from prisusapccp where cod_agente = _cod_agente_anterior;
		return _cod_agente_anterior,_cod_agente with resume;
	end if
end foreach
return '','';
END PROCEDURE;