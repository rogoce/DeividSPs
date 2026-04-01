-- Procedimiento para insertar  masivo cobreaco y cobreafa
-- 
-- Creado    : 03/08/2012 - Autor: Armando Moreno M.
-- Modificado: 03/08/2012 - Autor: Armando Moreno M.


drop PROCEDURE sp_sis172;

CREATE PROCEDURE "informix".sp_sis172()
RETURNING INTEGER, CHAR(250);

DEFINE _mensaje			CHAR(250);
DEFINE _error		    INTEGER;

DEFINE _no_remesa       CHAR(10);
DEFINE _renglon         SMALLINT;
DEFINE _no_cambio       CHAR(3);
DEFINE _cod_cober_prod  CHAR(5);
DEFINE _cod_cober_reas  CHAR(3);
DEFINE _cod_tipoprod 	CHAR(3);
DEFINE _tipo_produccion SMALLINT;
DEFINE _cod_coasegur    CHAR(3);
DEFINE _cod_compania    CHAR(3);
DEFINE _cod_ramo        CHAR(3);
DEFINE _ramo_sis        SMALLINT;
DEFINE _porcentaje      DEC(7,4);
DEFINE _contador_ret	SMALLINT;
DEFINE _abierta         SMALLINT;
DEFINE _vigencia_final  DATE;
DEFINE _cnt				SMALLINT;

SET ISOLATION TO DIRTY READ;


-- Lectura del Detalle de la Remesa

FOREACH

	 SELECT	no_remesa
	   INTO	_no_remesa
	   FROM	cobredet
	  WHERE	tipo_mov     IN ('P','N')
        and fecha between '01/08/2012' and '08/08/2012'
      group by 1
      order by 1

	  call sp_sis171(_no_remesa) returning _error,_mensaje;

END FOREACH

RETURN _error, _mensaje;

END PROCEDURE;
