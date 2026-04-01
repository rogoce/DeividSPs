-- Informaci¢n: Saber de estos reclamos cuales son perdida

--DROP PROCEDURE sp_actuari6;

create procedure "informix".sp_actuario6()

returning smallint;

DEFINE _perdida    smallint;
DEFINE _numrecla   char(18);

SET ISOLATION TO DIRTY READ;

let _perdida = 0;

foreach 

	 select numrecla
	   into _numrecla
	   from perdida

	 select  perd_total
	   into  _perdida
	   from  recrcmae
	  where numrecla = _numrecla;

	 if _perdida = 1 then

		update perdida
		   set perdida  = _perdida
		 where numrecla = _numrecla;

	 end if

end foreach;

return 0;
end procedure;
