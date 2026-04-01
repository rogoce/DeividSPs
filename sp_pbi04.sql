-- PBI 
-- Devuelve Información para la tabla dimZonasVentas
-- Creado    : 27/07/2021 - Autor: Armando Moreno M.

DROP PROCEDURE sp_pbi04;
CREATE PROCEDURE sp_pbi04()
RETURNING  varchar(20) as windowsUser,
		   varchar(50) as Descripcion,
		   char(3)     as CodVendedor;

           
DEFINE _windows_user        varchar(20);
DEFINE _descripcion			varchar(50);
define _usuario             char(8);
define _cod_vendedor        char(3);

SET ISOLATION TO DIRTY READ;
 -- set debug file to "sp_pbi04.trc";	
 -- trace on;

FOREACH
	select cod_vendedor,
	       nombre,
		   usuario
	  into _cod_vendedor,
           _descripcion,
		   _usuario
      from agtvende

	select windows_user
	  into _windows_user
	  from insuser
	 where usuario = _usuario;
     
    RETURN _windows_user,_descripcion,_cod_vendedor WITH RESUME;

END FOREACH
END PROCEDURE	  