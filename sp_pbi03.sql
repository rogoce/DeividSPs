-- PBI 
-- Devuelve Información para la tabla dimUsuarios
-- Creado    : 27/07/2021 - Autor: Armando Moreno M.

DROP PROCEDURE sp_pbi03;
CREATE PROCEDURE sp_pbi03()
RETURNING  varchar(50) as Descripcion,
		   varchar(20) as windowsUser;

           
DEFINE _windows_user        varchar(20);
DEFINE _descripcion			varchar(50);

SET ISOLATION TO DIRTY READ;
 -- set debug file to "sp_pbi03.trc";	
 -- trace on;

FOREACH
	select windows_user,
	       descripcion
	  into _windows_user,
		   _descripcion
	  from insuser
	 where windows_user is not null 
     order by windows_user
	 
	RETURN _descripcion,_windows_user WITH RESUME;

END FOREACH
END PROCEDURE	  