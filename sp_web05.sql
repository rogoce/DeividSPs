-- Procedure que carga los registros para el WEB

-- Creado: 26/10/2010 - Autor: Demetrio Hurtado Almanza

drop procedure sp_web05;

create procedure "informix".sp_web05()
returning integer,
          char(100);

define _cod_cliente			char(10);
define _nombre_cliente		char(100);
define _direccion			char(50);
define _telefono1			char(10);
define _telefono2			char(10);
define _direccion_cob		char(100);
define _email				char(50);
define _apartado			char(20);

define _cant_reg			integer;

define _error	   			integer;
define _error_isam 			integer;
define _error_desc 			char(50);

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_isam || " " || trim(_error_desc);
end exception

--SET DEBUG FILE TO "sp_web05.trc";
--TRACE ON ;

--begin work;

let _cant_reg = 0;

foreach	with hold
 select cod_cliente,
  	    nombre,
   	    direccion_1,
	    telefono1,
	    telefono2,
	    direccion_cob,
	    e_mail,
	    apartado
   into _cod_cliente,
	    _nombre_cliente,
	    _direccion,
	    _telefono1,
	    _telefono2,
	    _direccion_cob,
	    _email,
	    _apartado
   from cliclien

	let _cant_reg = _cant_reg + 1;

	insert into web_cliente(
	cod_cliente,
	nom_cliente,
	ciudad,
	direccion,
	telefono1,
	telefono2,
	email,
	apartado,
	dir_cobro,
	ciudad_cobro,
	tel_cobro
	)
	values(
	_cod_cliente,
	_nombre_cliente,
	'',
	_direccion,
	_telefono1,
	_telefono2,
	_email,
	_apartado,
	_direccion_cob,
	'',
	''
	);

	if _cant_reg >= 1000 then

		let _cant_reg = 0;
		commit work;
		begin work;

	end if

end foreach

end

if _cant_reg < 1000 and 
   _cant_reg <> 0   then

	commit work;

end if

return 0, "Exito";

end procedure
