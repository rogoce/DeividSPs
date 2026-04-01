-- Procedimiento que valida que no se puedan afectar de forma manual 
-- cuentas que tienen registros auxiliares en Deivid.

-- Creado    : 11/03/2013 - Autor: Demetrio Hurtado Almanza 

-- drop procedure sp_sac226;

create procedure "informix".sp_sac226(
a_cuenta	char(25)
) returning integer, 
            char(50);

define _cuenta			char(25);
define _activa			smallint;
define _nivel			smallint;
define _nombre			char(50);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

for _nivel = 1 to 5

	if _nivel = 1 then
		let _cuenta = a_cuenta[1,3];
	elif _nivel = 2 then
		let _cuenta = a_cuenta[1,5];
	elif _nivel = 3 then
		let _cuenta = a_cuenta[1,7];
	elif _nivel = 4 then
		let _cuenta = a_cuenta[1,9];
	elif _nivel = 5 then
		let _cuenta = a_cuenta[1,11];
	end if

	select activa
	  into _activa
	  from sac:cglautaux
	 where cuenta = _cuenta;

	if _activa is not null then
		
		if _activa = 1 then

			select cta_nombre
			  into _nombre
			  from cglcuentas
			 where cta_cuenta = _cuenta;

			return 1, _nombre;
		
		else
			
			return 0, "Actualizacion Exitosa";

		end if

	end if

end for 

end   

return 0, "Actualizacion Exitosa";

end procedure