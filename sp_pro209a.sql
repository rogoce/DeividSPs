--Proceso Control firma Emision
--Procedure que retorna el usuario para enviar a workflow
--Armando Moreno 16/05/2011

--DROP PROCEDURE sp_pro209a;

CREATE PROCEDURE "informix".sp_pro209a()
RETURNING CHAR(8),CHAR(30),smallint,char(30),char(1),smallint;


define _usuario      char(8);
define _windows_user char(30);
define _limite1 	 dec(16,2);
define _cod_perfil   char(3);
define _status       char(1);
define _correo_vice  char(30);
define _usuario_bk   char(8);
define _valor        integer;
define _emis_firma_aut smallint;

SET ISOLATION TO DIRTY READ;

begin

ON EXCEPTION IN(-206)
END EXCEPTION

drop table tmp_user;
end

BEGIN

--set debug file to "sp_pro209.trc";
--trace on;


let _correo_vice = "";
let _usuario_bk  = "";


call sp_pro210('001') returning _valor; --buscar Sub Gerencia T. de Emision. o GT

	select count(*)
	  into _valor
	  from tmp_user
	 where status = "A";

	if _valor > 0 then

		foreach

			select windows_user,
			       usuario,
				   status,
				   emis_firma_aut
			  into _windows_user,
			       _usuario,
				   _status,
				   _emis_firma_aut
			  from tmp_user

			RETURN _usuario,_windows_user,0,"",_status,_emis_firma_aut with resume;

		end foreach

		drop table tmp_user;

	else
		RETURN 'ERROR','ERROR',2,"","",0;
	end if

END

begin

ON EXCEPTION IN(-206)
END EXCEPTION

drop table tmp_user;
end

END PROCEDURE;