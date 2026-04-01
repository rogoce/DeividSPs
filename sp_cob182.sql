-- Obtener Numero de Poliza para Ducruet

-- Creado    : 10/09/2005 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_cob182;

create procedure "informix".sp_cob182(a_poliza_duc char(20))
returning char(10);

define _no_poliza 		char(10);
define _no_documento	char(20);

let _no_poliza = sp_sis21(a_poliza_duc);

if _no_poliza is null then
	select no_poliza_ancon
	  into _no_documento
	  from cobpaex2
	 where no_poliza_ducruet = a_poliza_duc;
 
	let _no_poliza = sp_sis21(_no_documento);	 
end if	 	

return _no_poliza;
end procedure;