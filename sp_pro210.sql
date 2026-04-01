
--Proceso Control firma Emision
--Procedure que retorna el usuario para enviar a workflow
--Armando Moreno 16/05/2011


DROP PROCEDURE sp_pro210;		
CREATE PROCEDURE sp_pro210(a_cod_perfil CHAR(3), a_flag smallint default 0, a_userbk char(8) default "*")
RETURNING integer;

--RETURNING CHAR(8),CHAR(30),char(1),smallint;

define _usuario       char(8);
define _windows_user  char(30);
define _status        char(1);
define _emis_firma_aut smallint;

create temp table tmp_user(
usuario		 char(8),
windows_user char(20),
status       char(1),
emis_firma_aut smallint
);

SET ISOLATION TO DIRTY READ;

let _status = "";
let _windows_user = "";
let _usuario = "";

BEGIN

if a_cod_perfil = '008' then --encargado de sucursal
	let a_flag = 1;
end if
if a_flag = 0 then
   foreach

		select windows_user,
			   usuario,
			   status,
			   emis_firma_aut
		  into _windows_user,
			   _usuario,
			   _status,
			   _emis_firma_aut
		  from insuser
		 where cod_perfil_wf_emis = a_cod_perfil

		INSERT INTO tmp_user(usuario,windows_user,status,emis_firma_aut) VALUES (_usuario,_windows_user,_status,_emis_firma_aut);

	--RETURN _usuario,_windows_user,_status,_emis_firma_aut with resume;

   end foreach

elif a_flag = 1 then

   foreach
	select windows_user,
	       usuario,
		   status,
		   emis_firma_aut
	  into _windows_user,
	       _usuario,
		   _status,
		   _emis_firma_aut
	  from insuser
	 where cod_perfil_wf_emis in("001","008")

	 INSERT INTO tmp_user(usuario,windows_user,status,emis_firma_aut) VALUES (_usuario,_windows_user,_status,_emis_firma_aut);

	 --RETURN _usuario,_windows_user,_status,_emis_firma_aut with resume;

   end foreach

elif a_flag = 2 then

   foreach
	select windows_user,
	       usuario,
		   status,
		   emis_firma_aut
	  into _windows_user,
	       _usuario,
		   _status,
		   _emis_firma_aut
	  from insuser
	 where usuario = a_userbk

	INSERT INTO tmp_user(usuario,windows_user,status,emis_firma_aut) VALUES (_usuario,_windows_user,_status,_emis_firma_aut);

	--RETURN _usuario,_windows_user,_status,_emis_firma_aut with resume;

   end foreach

end if

END
return 0;
END PROCEDURE;
