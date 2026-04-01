-- Procedimiento para verificar los programas sp_cob05 y sp

drop procedure sp_par122;

create procedure "informix".sp_par122()

define _no_documento	char(20);
define _no_poliza		char(10);
define _cod_tipoprod	char(3);

set isolation to dirty read;

foreach
 select no_documento
   into _no_documento
   from cobinc04

	let _no_poliza  = sp_sis21(_no_documento);

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;
	   
	update cobinc04
	   set cod_tipoprod = _cod_tipoprod
	 where no_documento = _no_documento;

end foreach

end procedure


