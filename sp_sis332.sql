-- Procedimiento que Carga los Datos para la Apadea
-- Se carga la tabla de cib_control donde se guardan los totales de las otras tablas
-- Creado    : 18/02/2002 - Autor: Amado Perez M. 
-- Modificado: 18/02/2002 - Autor: Amado Perez M. 

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis332;		

CREATE PROCEDURE "informix".sp_sis332()
RETURNING INTEGER, CHAR(250);

DEFINE _mensaje			CHAR(250);
DEFINE _fecha           DATE;
DEFINE _siniestros      INTEGER;
DEFINE _reclamantes     INTEGER;
DEFINE _coberturas      INTEGER;
DEFINE _recuperos       INTEGER;
DEFINE _codasegura      SMALLINT;

DELETE FROM cib_totalcontrol;

SET ISOLATION TO DIRTY READ;

LET _codasegura = 8;
LET _fecha = CURRENT;
--LET _fecha = '09/03/2002';
LET _siniestros  = 0;
LET _reclamantes = 0;
LET _coberturas  = 0;
LET _recuperos   = 0;


SELECT COUNT(numeroreclamo)
  INTO _siniestros
  FROM cib_reclamos
 WHERE fecharegistro = _fecha;
--   AND fecharegistro >= '04/12/2002';

SELECT COUNT(numerorecl)
  INTO _reclamantes
  FROM cib_reclamantes
 WHERE date_changed = _fecha;

SELECT COUNT(numerorecl)
  INTO _coberturas
  FROM cib_coberturas
 WHERE date_changed = _fecha;

SELECT COUNT(numeroreclamo)
  INTO _recuperos
  FROM cib_recuperaciones;

INSERT INTO cib_totalcontrol
VALUES(_codasegura,
       _fecha,
	   _siniestros,
	   _reclamantes,
	   _coberturas,
	   _recuperos
	   );

LET _mensaje = 'Actualizacion Exitosa ...';
RETURN 0, _mensaje;
       


END PROCEDURE;