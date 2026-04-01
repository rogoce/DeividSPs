-- Procedimiento que calcula la prima devengada x periodo (polizas web)
-- Sacada del sp_bo043
-- Creado     :	10/01/2014 - Autor: Jorge Contreras

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo086;		

create procedure "informix".sp_bo086(a_periodo char(7), _cod_agente char(5))
returning integer, char(100);

define _ano_evaluar		smallint;
define _mes_evaluar		smallint;
define _mes_pnd			smallint;
define _ano_pnd			smallint;
define _periodo_pnd1	char(7);
define _periodo_pnd2	char(7);
define _pri_dev_aa		dec(16,2);
define _pri_dev_aa1  	dec(16,2);
define _no_documento	char(20);



set isolation to dirty read;

CREATE TEMP TABLE tmp_dev(
        no_documento         CHAR(20)  NOT NULL,
	   	pri_dev_aa			 dec(16,2) 	default 0
		) WITH NO LOG;

   -- Primas Devengadas (Primas Suscritas Devengadas PND)

--{
let _ano_evaluar = a_periodo[1,4];
let _mes_evaluar = a_periodo[6,7];

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

   	foreach
	 select a.no_documento,
	        sum(a.prima_suscrita)
	   into _no_documento,
	        _pri_dev_aa
	   from endedmae a, endmoage b
	  where a.periodo     >= _periodo_pnd1
	    and a.periodo     <= _periodo_pnd2
	--	and no_documento = _no_documento1
	    and a.no_poliza = b.no_poliza
  	    and a.no_endoso = b.no_endoso
		and b.cod_agente = _cod_agente
		and actualizado = 1
	  group by 1

       IF _pri_dev_aa IS NULL THEN
		LET _pri_dev_aa = 0;
	   END IF
	  
	  let _pri_dev_aa = _pri_dev_aa / 12;

	  insert into tmp_dev( no_documento, pri_dev_aa)
	  values (_no_documento, _pri_dev_aa);

       

	end foreach

end for

{select sum(pri_dev_aa)
into _pri_dev_aa1
from tmp_dev; 

 DROP TABLE tmp_dev;}

 return 0, "Actualizacion Exitosa";

end procedure
