DROP PROCEDURE sp_user;

CREATE PROCEDURE "informix".sp_user()

DEFINE _usuario CHAR(8);

{
BEGIN
ON EXCEPTION IN(-692)
END EXCEPTION
	DELETE FROM insuser
	WHERE usuario NOT MATCHES 'informix';
END
}

FOREACH
 SELECT	cod_usuario
   INTO	_usuario
   FROM	usuario

	LET _usuario = DOWNSHIFT(_usuario);

	BEGIN
	ON EXCEPTION IN(-268)
	END EXCEPTION

		INSERT INTO insuser(
		usuario,
		fecha_inicio,
		hora_inicio,
		hora_final,
		no_login_permitido,
		codigo_perfil,
		password,
		fecha_final
		)
		VALUES(
		_usuario,
		TODAY,
		'08:00',
		'08:00',
		1,
		'001',
		_usuario,
		TODAY
		);

	END
{
FOREACH
 SELECT usuario
   INTO _usuario	
   FROM insuser
--  WHERE	usuario NOT MATCHES 'informix'

	BEGIN
	ON EXCEPTION IN(-268)
	END EXCEPTION

		INSERT INTO insusco(
		usuario,
		codigo_compania,
		codigo_agencia,
		password,
		status,
		fecha_status
		)
		VALUES(
		_usuario,
		'001',
		'001',
		_usuario,
		'A',
		TODAY
		);

	END
}

END FOREACH

END PROCEDURE
