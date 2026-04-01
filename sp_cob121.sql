-- Busca proxima libreta disponible

-- Creado    : 31/07/2003 - Autor: Marquelda Valdelamar 

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob121;

CREATE PROCEDURE "informix".sp_cob121(a_sucursal CHAR(3)) RETURNING CHAR(5);

DEFINE _cod_libreta  CHAR(5); 

SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT	cod_libreta
   INTO	_cod_libreta
   FROM	coblibre
  WHERE usada     = 0
	AND origen_libreta = 1			   	   
	AND tipo_libreta   = 1
	AND asignado_para  = a_sucursal
  ORDER BY cod_libreta ASC
	EXIT FOREACH;
END FOREACH

RETURN _cod_libreta;

END PROCEDURE;
