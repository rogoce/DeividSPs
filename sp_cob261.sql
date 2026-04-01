-- Filtro de Motivos de Rechazo de Tarjeta de Credito
-- Creado por :     Roman Gordon	27/01/2011
-- SIS v.2.0 - DEIVID, S.A.


DROP PROCEDURE sp_cob261;

CREATE PROCEDURE "informix".sp_cob261()
RETURNING	CHAR(50);	-- motivo de rechzazo
			
DEFINE _motivo_rechazo	CHAR(50);


SET ISOLATION TO DIRTY READ;

--set debug file to "sp_co51c.trc";
--trace on;

let _motivo_rechazo = '';

foreach
	Select distinct motivo_rechazo
  	  into _motivo_rechazo
  	  from emipoliza
 	 where motivo_rechazo is not null 
 	   and motivo_rechazo <> ''
	
	if _motivo_rechazo = ''  or _motivo_rechazo is null then
		continue foreach;
	end if

	return _motivo_rechazo with resume;
end foreach
end Procedure;	