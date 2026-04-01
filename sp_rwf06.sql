-- Procedimiento que retorna La compania, la sucursal y el Usuario de Deivid

-- Creado    : 22/03/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_rwf06;

create procedure sp_rwf06(a_windows_user char(20))
returning smallint,
          char(8),
		  char(3),
		  char(3);

define _user			char(8);
define _cod_compania	char(3);
define _cod_sucursal	char(3);

set isolation to dirty read;

let _user = null;

let a_windows_user = upper(a_windows_user);

foreach
	select usuario
	  into _user
	  from insuser
	 where upper(windows_user) = a_windows_user
	   and status = "A"
  order by fecha_inicio
  exit foreach;
end foreach

if _user is null then

	return 1,
	       "",
		   "",
		   "";

else

	foreach
	 select codigo_compania,
	        codigo_agencia
	   into _cod_compania,
	        _cod_sucursal
	   from insusco
	  where usuario = _user
	    and status = "A"
		exit foreach;
	end foreach

	return 0,
	       _user,
		   _cod_compania,
		   _cod_sucursal;

end if

end procedure