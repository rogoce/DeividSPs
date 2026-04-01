-- Procedimiento que Verifica emipomae vs emipoliza
-- 
-- Creado    : 09/11/2004 - Autor: Demetrio Hurtado Almanza 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis65;

CREATE PROCEDURE "informix".sp_sis65()
returning char(20);

define _no_documento	char(20);
define _cantidad		smallint;

foreach
 select no_documento
   into _no_documento
   from emipomae
  where actualizado  = 1
    and no_documento is not null
  group by no_documento
  order by no_documento

	select count(*)
	  into _cantidad
	  from emipoliza
	 where no_documento = _no_documento;

	if _cantidad = 0 then

--		call sp_sis64(_no_documento);

		return _no_documento
		       with resume;

	end if

end foreach

return "0";

end procedure
