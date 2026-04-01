-- Procedimiento que calcula la prima devengada x periodo
-- Sacado del sp_bo043
-- Creado     :	10/01/2014 - Autor: Jorge Contreras

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo084a;		

create procedure "informix".sp_bo084a(a_periodo1 char(7), a_periodo2 char(7))
			RETURNING integer, 
					  char(100);

define _ano_evaluar		 smallint;
define _mes_evaluar		 smallint;
define _mes_pnd			 smallint;
define _ano_pnd			 smallint;
define _periodo_pnd1	 char(7);
define _periodo_pnd2	 char(7);
define _pri_dev_aa		 dec(16,2);
define _pri_dev_aa1  	 dec(16,2);
define _no_documento	 char(20);
define _no_poliza        char(10);
define _cod_ramo         char(10);
define _cod_agente		 char(20);
define _count			 int;
DEFINE _porc_partic      DEC(16,2);
DEFINE _prima_dev_agt    DECIMAL(16,2);
DEFINE _prima_dev_fin    DECIMAL(16,2);


set isolation to dirty read;
BEGIN WORK;
CREATE TEMP TABLE tmp_dev(
		cod_agente      CHAR(20)        NOT NULL,
        no_documento    CHAR(20)        NOT NULL,
	   	pri_dev_aa		DECIMAL(16,2) 	DEFAULT 0,
		cod_ramo_a		CHAR(3)			NOT NULL,
		seleccionado    SMALLINT        DEFAULT 1 NOT NULL
		) WITH NO LOG;

   -- Primas Devengadas (Primas Suscritas Devengadas PND)

--SET DEBUG FILE TO "sp_bo084a.trc";
--TRACE ON;

   foreach
   
	select no_poliza,
		   no_documento,
		   cod_ramo
	  into _no_poliza,
	       _no_documento,
	       _cod_ramo
	  from emipomae
	 where periodo   >= a_periodo1
	   and periodo   <= a_periodo2
	   and actualizado = 1
		
    select count(*)
	  into _count
	  from emipoagt
     where no_poliza = _no_poliza;

	 if _no_documento = '0213-00228-11' then --pendiente de averiguar por que no tiene agente ni datos del auto ni coberuras.
	   continue foreach;
		
	 end if

	 if _count < 1 then
	
	    foreach
		    select cod_agente,
			       porc_partic_agt
		      into _cod_agente,
			       _porc_partic
	          from emipoagt
             where no_poliza = _no_poliza

            select sum(prima_suscrita)
			  into _pri_dev_aa
			  from endedmae
			 where no_documento = _no_documento
		       and periodo   >= a_periodo1
	           and periodo   <= a_periodo2
			   and actualizado = 1;
				 
			IF _pri_dev_aa IS NULL THEN
				LET _pri_dev_aa = 0;
			END IF
	     
		 --Participacion por agente
		 -- LET _prima_dev_agt = _pri_dev_aa / 100 * _porc_partic; 
			
			--Devengada por angente
			let _prima_dev_fin = _prima_dev_agt / 12;

			
			insert into tmp_dev(cod_agente, no_documento, pri_dev_aa, cod_ramo_a)
		    values (_cod_agente, _no_documento, _pri_dev_aa, _cod_ramo);

		end foreach	
	else
	    foreach 
		   select cod_agente
		      into _cod_agente
	          from emipoagt
             where no_poliza = _no_poliza

            select sum(prima_suscrita)
			  into _pri_dev_aa
			  from endedmae
			 where no_documento = _no_documento
			   and periodo   >= a_periodo1
	           and periodo   <= a_periodo2
			   and actualizado = 1;
			   
			IF _pri_dev_aa IS NULL THEN
				LET _pri_dev_aa = 0;
			END IF
	  
			let _pri_dev_aa = _pri_dev_aa / 12;

			insert into tmp_dev( cod_agente, no_documento, pri_dev_aa, cod_ramo_a)
		    values (_cod_agente, _no_documento, _pri_dev_aa, _cod_ramo);
	    end foreach
    end if
	
end foreach

COMMIT WORK;
	return 0, "Actualizacion Exitosa";

end procedure
