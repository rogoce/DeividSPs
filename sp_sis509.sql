-- Procedimiento que actualiza los descuentos y recargos de las polizas de salud en emipomae, emipouni y emipocob

-- Creado    : 06/03/2013 - Autor: Amado Perez 

DROP PROCEDURE sp_sis509;

CREATE PROCEDURE "informix".sp_sis509()
returning varchar(8) as periodo;

define _periodo       varchar(8);

SET ISOLATION TO DIRTY READ;

return "*" with resume;

FOREACH
	SELECT distinct(periodo) 
	  INTO _periodo
	  from recrcmae 
	  where periodo >= '2008-01' order by 1 desc	
	  	 
	   return trim(_periodo) || ";" WITH RESUME;
END FOREACH   


END PROCEDURE
