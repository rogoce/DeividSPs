-- Procedimiento que Genera el html body y la secuencia del envio de correos masivos 	

-- Creado    : 15/11/2010 - Autor: Roman Gordon

DROP PROCEDURE sp_par313;

CREATE PROCEDURE "informix".sp_par313(
a_secuencia_correo	smallint,
a_no_remesa			char(10),
a_renglon			smallint
)returning			integer,
					integer,
					char(100);

Define _cant_comprobates	smallint;
Define _cantidad			smallint;
Define _adjunto				smallint;
Define _html_body			char(512);
Define _secuencia_char		char(5);
define _error				integer;
define _error_isam			integer;
define _error_desc			char(100);

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return _error, _error_isam, _error_desc;
end exception


SET ISOLATION TO DIRTY READ;

delete from parmailsend;

END PROCEDURE
