-- Procedimiento que calcula la prima devengada x periodo
-- Sacado del sp_bo043
-- Creado     :	10/01/2014 - Autor: Jorge Contreras

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo084b;		

create procedure "informix".sp_bo084b(a_periodo2 char(7))
--returning integer;

define _ano_evaluar				 smallint;
define _mes_evaluar				 smallint;
define _mes_pnd					 smallint;
define _ano_pnd					 smallint;
define _periodo_pnd1			 char(7);
define _periodo_pnd2			 char(7);
define _pri_dev_aa				 dec(16,2);
define _pri_dev_aa1  			 dec(16,2);
define _no_documento			 char(20);
define _no_poliza   			 char(20);
define _cod_ramo    			 char(20);
define _cod_sub_ramo    		 char(20);
define _periodo   				 char(20);
define _no_documento_e			 char(20);
define _cod_agente   		     char(5);
define _cod_grupo    			 char(20);
define _prima_pagada_agt         dec(16,2);
define _porc_agte       	     dec(16,2);
define _count    		         smallint;
define _prima_susc_agt           dec(16,2);
define _cod_tipoveh    			 char(20);
define _no_unidad				 char(5);
define _error					 integer;

--on exception set _error
 --   ROLLBACK WORK;
	--return _error;
--end exception

set isolation to dirty read;
--tabla prima devengada 
CREATE TEMP TABLE tmp_dev1(
		no_documento         CHAR(20)  NOT NULL,
	   	pri_dev_aa			 DECIMAL(16,2) 	default 0,
		no_poliza            char(5),
		cod_ramo             char(3),
		cod_subramo			 char(3),
		cod_agente           char(5),
		cod_grupo            char(5),
		--cod_tipoveh          char(3), 
		periodo1			 char(7),
		periodo2			 char(7)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_dev1 ON tmp_dev1(no_documento);
CREATE INDEX xie02_tmp_dev1 ON tmp_dev1(cod_ramo);
CREATE INDEX xie03_tmp_dev1 ON tmp_dev1(cod_subramo);
CREATE INDEX xie04_tmp_dev1 ON tmp_dev1(cod_agente);

  -- Primas Devengadas (Primas Suscritas Devengadas PND)

--{
let _ano_evaluar = a_periodo2[1,4];
let _mes_evaluar = a_periodo2[6,7];

--BEGIN WORK;

for _mes_pnd = _mes_evaluar to 1 step -1

	if _mes_pnd = 12 then

		let _periodo_pnd1 = _ano_evaluar || "-01";

	else
		
		if _mes_pnd < 10 then
			let _periodo_pnd1 = _ano_evaluar - 1 || "-0" || _mes_pnd + 1;
		else
			let _periodo_pnd1 = _ano_evaluar - 1 || "-" || _mes_pnd + 1;
		end if
	end if

	if _mes_pnd < 10 then
		let _periodo_pnd2 = _ano_evaluar || "-0" || _mes_pnd;
	else
		let _periodo_pnd2 = _ano_evaluar || "-" || _mes_pnd;
	end if

foreach with hold
	 select no_documento,
	        sum(prima_suscrita)
	   into _no_documento,
	        _pri_dev_aa
	   from endedmae
	  where periodo     >= _periodo_pnd1
	    and periodo     <= _periodo_pnd2
		and actualizado = 1
	  group by no_documento
	    		

			   
		 IF _pri_dev_aa IS NULL THEN
			LET _pri_dev_aa = 0;
	     END IF
	   
         let _pri_dev_aa = _pri_dev_aa / 12;

	    FOREACH
			SELECT no_poliza,
				   cod_subramo,
				   cod_grupo,
				   cod_ramo
			  INTO _no_poliza,
				   _cod_sub_ramo,
				   _cod_grupo,
				   _cod_ramo
			  FROM emipomae
			 WHERE no_documento = _no_documento
			EXIT FOREACH;
		END FOREACH
	
		let _no_poliza = sp_sis21(_no_documento);
		LET _prima_susc_agt = 0;
		
	 foreach with hold

			SELECT cod_agente,
				   porc_partic_agt
			  INTO _cod_agente,
			       _porc_agte
			  FROM emipoagt
			 WHERE no_poliza = _no_poliza

			LET _prima_susc_agt = _pri_dev_aa / 100 * _porc_agte; 
	   
				--INSERT DE tmp_dev1
		    insert into tmp_dev1(no_documento, pri_dev_aa, no_poliza, cod_ramo, cod_subramo, cod_agente, cod_grupo, periodo1, periodo2)
			values (_no_documento, _prima_susc_agt, _no_poliza, _cod_ramo, _cod_sub_ramo, _cod_agente, _cod_grupo, _periodo_pnd1, _periodo_pnd2);
		
		end foreach

	end foreach
end for
--COMMIT WORK;
--return 0;

end procedure
