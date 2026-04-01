--***************************************************************--
-- Procedimiento que categoriza al corredor para la mini convencion Cancun 2015
-- Prima cobraada total
--***************************************************************--

-- Creado    : 24/03/2011 - Autor: Armando Moreno M.
-- Modificado: 08/01/2015 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che206zzz;

CREATE PROCEDURE sp_che206zzz()
RETURNING SMALLINT;

DEFINE _cod_agente      CHAR(5); 
define _cod_unificar    char(5);
define _cod_agente_s    char(5); 
DEFINE _no_poliza       CHAR(10);
define _cod_origen      char(3); 
DEFINE _monto           DEC(16,2);
DEFINE _fecha           DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2);
DEFINE _porc_comis2     DEC(5,2);
DEFINE _porc_coas_ancon DEC(5,2);
DEFINE _nombre          CHAR(50); 
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
define _fecha_desde     date;
define _fecha_hasta     date;
define v_corr			DEC(16,2);
define _cod_grupo       char(5);
define _cedula_agt      char(30);
define _cedula_paga		char(30);
define _cedula_cont		char(30);
define _cod_pagador     char(10);
define _cod_contratante char(10);
define _estatus_licencia char(1);
DEFINE _periodo_ant     CHAR(7);
define _mes_ant			smallint;
define _ano_ant			smallint;
define _error           smallint;
define _prima_neta		DEC(16,2);
define _vigencia_inic   date;
define _vigencia_final  date;
define _fecha_cancelacion date;
define _renglon         smallint;
define _nueva_renov     char(1);
define _flag            smallint;
define _saldo           dec(16,2);
define _per_cero        char(7);
define _no_remesa       char(10);
define _no_recibo       char(10);
define _cnt             smallint;
define _prima_r         DEC(16,2);
define _monto_b         DEC(16,2);
define _prima_n         DEC(16,2);
define _cod_subramo     char(3);
define _concurso        smallint;
define _n_agente        char(50);
define _prima_cob_nva   DEC(16,2);
define _prima_cob2014   DEC(16,2);
define _prima_cob2014_un  dec(16,2);
define _prima_cobnva_un  dec(16,2);
define _pri_rango        dec(16,2);


--SET DEBUG FILE TO "sp_che206.trc";
--TRACE ON;

let _error           = 0;
let _porc_coas_ancon = 0;
let _prima_neta      = 0;
let _cnt             = 0;
let _prima_cobnva_un = 0;
let _prima_cob2014   = 0;
let _prima_cob2014_un = 0;
let _prima_cob_nva    = 0;
let _pri_rango        = 0;

SET ISOLATION TO DIRTY READ;

foreach
	select cod_agente, prima_cobrada2010, pri_co_nva_ap
	  into _cod_agente, _prima_cob2014,_prima_cob_nva
	  from tropicals

      let _cod_unificar = null;
	  
	  select cod_unificar
	    into _cod_unificar
	    from unificar
	   where cod_unificar = _cod_agente
	    group by cod_unificar;
      	 
	  if _cod_unificar is null then
			continue foreach;
	  else
		select sum(prima_cobrada2010),sum(pri_co_nva_ap) 
		  into _prima_cob2014_un,_prima_cobnva_un
		  from tropicals
		 where cod_agente in(select cod_agente from unificar where cod_unificar = _cod_unificar);
		 
		if  _prima_cob2014_un is null then
			let _prima_cob2014_un = 0;
		end if	
	    update tropical2s
		   set prima_cobrada2010 = _prima_cob2014_un + _prima_cob2014,
		       pri_co_nva_ap     = _prima_cobnva_un     + _prima_cob_nva
		 where cod_agente        = _cod_unificar
		   and no_documento is null;
		
        foreach		
			select cod_agente
			  into _cod_agente_s
			  from unificar
			 where cod_unificar = _cod_unificar
			 
			delete from tropical2s
			 where cod_agente = _cod_agente_s
			   and no_documento is null;
        end foreach
		
		select sum(prima_cobrada2010)
		  into _prima_neta
		  from tropical2s
		 where cod_agente = _cod_unificar;

	UPDATE tropical2s
	   SET pri_cob_ap_men = _prima_neta / 12,
		   pri_rango      = (_prima_neta / 12) * 4
	 WHERE cod_agente     = _cod_unificar
	   and no_documento is null;
	   
    let _pri_rango = (_prima_neta / 12) * 4;		 

		if _pri_rango > 100000 then
			UPDATE tropical2s
			   SET categoria  = 1
			 where cod_agente = _cod_unificar;
		elif _pri_rango > 50000 then
			UPDATE tropical2s
			   SET categoria  = 2
		     where cod_agente = _cod_unificar;
		elif _pri_rango < 49999 then
			UPDATE tropical2s
			   SET categoria  = 3
			 where cod_agente = _cod_unificar;
		end	if		   
	 end if
	  
end foreach

return 0;

END PROCEDURE;