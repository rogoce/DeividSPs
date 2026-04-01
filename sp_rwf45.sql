-- Consulta de Partes

-- Creado    : 25/06/2004 - Autor: Amado Perez M.
-- Modificado: 25/06/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

--DROP PROCEDURE sp_rwf45;

CREATE PROCEDURE sp_rwf45()
RETURNING varchar(100),
      	  char(10);

define v_cod_cliente	char(10);
define v_nombre		    varchar(100);

--set debug file to "sp_rwf02.trc";


SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT	cod_cliente,
        nombre
   INTO v_cod_cliente,
        v_nombre
   FROM	cliclien 
  WHERE es_taller = 1
  ORDER BY 2

RETURN  v_nombre,
		v_cod_cliente
		WITH RESUME;

END FOREACH

END PROCEDURE;