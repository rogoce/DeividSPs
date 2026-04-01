-- Procedimiento para insertar registros en COBENVAU para proceso diario de envio de correos desde programa de remesas
-- Creado: 10/03/2010 - Autor: Armando Moreno
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob283;

CREATE PROCEDURE "informix".sp_cob283(a_reclamo CHAR(10))
RETURNING VARCHAR(30);

DEFINE	_ajust_interno	CHAR(3);
DEFINE	_usuario	    CHAR(8);
DEFINE	v_e_mail    	VARCHAR(30);

SET ISOLATION TO DIRTY READ;

BEGIN

select ajust_interno
  into _ajust_interno
  from recrcmae
 where no_reclamo = a_reclamo;

select usuario
  into _usuario
  from recajust
 where cod_ajustador = _ajust_interno;

select e_mail
  into v_e_mail
  from insuser
 where usuario = _usuario;

RETURN v_e_mail;

END

END PROCEDURE
