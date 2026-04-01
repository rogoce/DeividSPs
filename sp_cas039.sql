-- Verificar Polizas en el Call Center que no Dicen Cobra Ancon
-- 
-- Creado    : 23/06/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 23/06/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas039;

create procedure sp_cas039()
returning char(20),
          char(10);

define _no_documento	char(20);
define _no_poliza		char(10);
define _cobra_poliza	char(1);

foreach
 select no_documento
   into _no_documento
   from caspoliza
  
	let _no_poliza = sp_sis21(_no_documento);

	select cobra_poliza
	  into _cobra_poliza
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cobra_poliza <> "E" then
		
		return _no_documento,
		       _no_poliza
		       with resume;

	end if

end foreach

end procedure
