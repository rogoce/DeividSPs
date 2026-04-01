-- Procedure para sacar informacion de cglresumen / cglresumen1 para TTCORP
-- 
-- Creado    :04/04/2014 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud51b;

create procedure "informix".sp_aud51b()
 returning integer, integer, varchar(100); 

define _error_cod  			integer;
define _error_desc          varchar(50);
define _error_isam	        integer;
define _transaccion			char(50);
define _id_reas_caract		integer;
define _count				integer;

set isolation to dirty read;

let _count = 601;

begin


foreach

	select id_reas_caract_ancon
	  into _id_reas_caract
	  from deivid_ttcorp:reas_caract_pri
	  
	  let _count = _count + 1;

	update deivid_ttcorp:reas_caract_pri
	   set id_reas_caract_ancon = _count
	 where id_reas_caract_ancon = _id_reas_caract;

  	if _count = 1494 then
		exit foreach;
	end if
end foreach


return 0, 0, "Exitoso";

end

end procedure








