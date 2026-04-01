-- Consulta de Marcas

-- Creado    : 09/12/2008 - Autor: Amado Perez M.
-- Modificado: 09/12/2008 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

--DROP PROCEDURE sp_rwf91;

CREATE PROCEDURE sp_rwf92()
RETURNING varchar(60),
      	  char(5);

define v_cod_marca   	char(5);
define v_nombre  		varchar(50);
define v_concat         varchar(60);

--set debug file to "sp_rwf02.trc";

SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT	cod_marca,
		nombre
   INTO v_cod_marca,
        v_nombre
   FROM	emimarca
  WHERE activo = 1
  ORDER BY 2

	let v_concat = Trim(v_nombre) || " | " || trim(v_cod_marca);

	RETURN  v_concat,
	        v_cod_marca
			WITH RESUME;

END FOREACH


	


END PROCEDURE;