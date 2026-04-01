-- Procedimiento para eliminar los duplicados de las polizas a cancelar
-- 
-- Creado     : 16/05/2013 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par333;

create procedure "informix".sp_par333()
returning integer,
          char(20),
          integer;

define _no_documento	char(20);
define _cantidad		integer;
define _duplicados		integer;
define _id				integer;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);


--set debug file to "sp_par333.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc, _error_isam;
end exception

let _cantidad   = 0;
 
foreach	
 select poliza,
		count(*)
   into _no_documento,
		_duplicados
   from deivid_tmp:tmp_cancsodajul2013
--  where poliza = "0210-90045-47"
  group by poliza
  order by 2 desc

	if _duplicados > 1 then

		let _cantidad = 0;

		foreach
		 select id
		   into _id
		   from deivid_tmp:tmp_cancsodajul2013
          where poliza = _no_documento

			let _cantidad = _cantidad + 1;

			if _cantidad > 1 then

				delete from deivid_tmp:tmp_cancsodajul2013 where id = _id;

			end if

			return _cantidad, 
			       _no_documento, 
			       _id
			       with resume; 

		end foreach

	end if

end foreach

end 

return 0, "Actualizacion", 0; 

end procedure