-- Procedimiento que verifica si las remesas de Wester Union estan en deivid
-- Creado     :	03/12/2015 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_wun05;		

create procedure "informix".sp_wun05()
returning char(250), smallint;

define _no_remesa_wu  char(10);
define _cnt           smallint;
define _no_procesadas varchar(250);

set isolation to dirty read;
let _no_procesadas = null;
	foreach
		select distinct(no_remesa)
		  into _no_remesa_wu
		  from deivid_cob:wun_historico
		 where cob_cobro_fecha > '20151201'
		  
		select count(*)
		  into _cnt
		  from deivid:cobremae
		 where no_remesa = _no_remesa_wu;
		 
		if _cnt is null then
			let _cnt = 0;
		end if
		if _cnt = 0 then
			if _no_procesadas is null then
				let _no_procesadas = trim(_no_remesa_wu);
			else 
				let _no_procesadas = trim(_no_procesadas) || ', ' || trim(_no_remesa_wu);
			end if
		end if
	end foreach
	if _no_procesadas is null then
		return "Actualizacion Exitosa", 0 with resume;
	else
		return "Error #Remesas no Creadas  "||_no_procesadas, 1 with resume;
	end if
end procedure
  