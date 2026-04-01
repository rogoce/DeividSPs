-- Procedure que verifica las polizas de ducruet

drop procedure sp_par220;

create procedure "informix".sp_par220()
returning integer, 
          char(50);

define _poliza			char(100);
define _no_documento	char(20);
define _nombre			char(100);
define _no_poliza		char(10);
define _cod_cliente		char(10);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

foreach
 select poliza
   into _poliza
   from deivid_tmp:ducruet

	let _no_documento = _poliza;
	let _no_poliza    = sp_sis21(_no_documento);

	if _no_poliza is not null then

		select cod_contratante
		  into _cod_cliente
		  from emipomae
		 where no_poliza = _no_poliza;

		select nombre
		  into _nombre
		  from cliclien
		 where cod_cliente = _cod_cliente;

		update deivid_tmp:ducruet
		   set poliza_deivid = _no_documento,
		       nombre_deivid = _nombre
		 where poliza        = _poliza;

	else

		let _no_documento = sp_par221(_poliza);
		let _no_poliza    = sp_sis21(_no_documento);

		if _no_poliza is not null then

			select cod_contratante
			  into _cod_cliente
			  from emipomae
			 where no_poliza = _no_poliza;

			select nombre
			  into _nombre
			  from cliclien
			 where cod_cliente = _cod_cliente;

			update deivid_tmp:ducruet
			   set poliza_deivid = _no_documento,
			       nombre_deivid = _nombre
			 where poliza        = _poliza;

		end if

	end if

end foreach

end

return 0, "Actualizacion Exitosa";

end procedure  
