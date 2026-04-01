--drop procedure sp_par201;

create procedure sp_par201()

define _no_documento	char(20);
define _cod_grupo		char(5);

set isolation to dirty read;

foreach
 select poliza,
        cod_grupo
   into _no_documento,
        _cod_grupo
   from accionista01

	update emipomae
	   set cod_grupo    = _cod_grupo
	 where no_documento = _no_documento;

end foreach

end procedure