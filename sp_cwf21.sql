-- Procedimiento para generacion de cheques
-- 
-- creado: 14/09/2009 - Autor: Amado Perez.

--DROP PROCEDURE sp_rwf73;
CREATE PROCEDURE "informix".sp_cwf21(a_usuario VARCHAR(20)) 
RETURNING VARCHAR(20);

DEFINE _usuario VARCHAR(20); 

   SET ISOLATION TO DIRTY READ;


   select windows_user
     into _usuario
   from insuser
   where usuario = a_usuario;

   if _usuario is null then
	let _usuario = "";
   end if


   RETURN _usuario;

END PROCEDURE