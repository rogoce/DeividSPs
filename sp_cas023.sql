-- Arreglar Documento en la Gestion
-- 
-- Creado    : 03/06/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 03/06/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas023;

create procedure sp_cas023()

define _no_poliza		char(10);
define _no_documento	char(20);

foreach
 select no_poliza
   into _no_poliza
   from cobgesti
  where no_documento is null
--	and no_poliza    = "127106"

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	update cobgesti
	   set no_documento = _no_documento
	 where no_poliza    = _no_poliza
	   and no_documento is null;

end foreach

end procedure
