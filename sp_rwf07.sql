-- Procedimiento que retorna el ajustador

-- Creado    : 22/03/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_rwf07;

create procedure sp_rwf07(a_windows_user char(20))
returning smallint,
          char(3);

define _user			char(8);
define _cod_ajustador	char(3);

set isolation to dirty read;

select usuario
  into _user
  from insuser
 where upper(windows_user) = upper(a_windows_user);

if _user is null then

	return 1,
	       "";

else

	 select cod_ajustador
	   into _cod_ajustador
	   from recajust
	  where upper(usuario) = upper(_user);

	if _cod_ajustador is null then
	    return 1,
		"";
	else
		return 0,
		       _cod_ajustador;
	end if

end if

end procedure