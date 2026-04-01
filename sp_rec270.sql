-- Procedure que actualiza la requisiciones cuando hay excepcion

-- AmadoPerez 10/01/2017


--drop procedure sp_rec270;

create procedure sp_rec270(a_requis char(10), a_usuario char(8), a_nota_excep varchar(255), a_usuario_excep char(8),a_fecha_excep datetime year to fraction(5))
RETURNING integer, varchar(100);

define _error_cod		integer;
define _error_isam		integer;
define _error_desc		varchar(100);

set isolation to dirty read;
--SET LOCK MODE TO WAIT;

begin
on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, _error_desc;
end exception
update chqchmae 
	set pre_autorizado = 1, 
	  user_pre_aut = a_usuario, 
	  date_pre_aut = current, 
	  nota_excepcion = a_nota_excep, 
	  user_excepcion = a_usuario_excep, 
	  date_excepcion = a_fecha_excep 
 where no_requis = a_requis;

				  
RETURN 0, "Actualizacion Exitosa";

end
end procedure