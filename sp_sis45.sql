-- Carga Inicial de Emipoliza

drop procedure sp_sis45;

create procedure sp_sis45()

define _cantidad		smallint;
define _no_documento	char(20);

set isolation to dirty read;

delete from emipoliza;

foreach
 select no_documento
   into	_no_documento
   from emipomae
  where actualizado = 1
  group by no_documento

	select count(*)
	  into _cantidad
	  from emipoliza
	 where no_documento = _no_documento;

	if _cantidad = 0 then

		insert into emipoliza(
		no_documento
		)
		values(
		_no_documento
		);

	end if

end foreach

end procedure