-- Anualizacion de polizas del ramo colectivo de vida y vida individual
--
-- Creado    : 08/06/2009 - Autor: Armando Moreno M.

-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_pro334;

CREATE PROCEDURE "informix".sp_pro334(a_renglon integer, a_old_usr char(8), a_new_usr char(8))
RETURNING integer;


define _no_poliza      CHAR(10); 
define _user_added     char(8);

--SET DEBUG FILE TO "sp_pro334.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

FOREACH

	SELECT no_poliza
	  INTO _no_poliza
	  FROM emideren
	 WHERE renglon = a_renglon

	SELECT user_added
	  INTO _user_added
	  FROM emirepo
	 WHERE no_poliza = _no_poliza;

	if trim(_user_added) = trim(a_old_usr) then

		update emirepo
		   set user_added = a_new_usr
		 where no_poliza  = _no_poliza;

	end if

END FOREACH

return 0;

END PROCEDURE;
