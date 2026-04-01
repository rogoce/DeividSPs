-- Consulta de Marcas

-- Creado    : 09/12/2008 - Autor: Amado Perez M.
-- Modificado: 09/12/2008 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

--DROP PROCEDURE sp_rwf91;

CREATE PROCEDURE sp_rwf93(a_marca CHAR(5))
RETURNING varchar(60),
      	  char(5);

define v_cod_modelo   	char(5);
define v_nombre  		varchar(50);
define v_concat         varchar(60);

--set debug file to "sp_rwf02.trc";

SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT	cod_modelo,
		nombre
   INTO v_cod_modelo,
        v_nombre
   FROM	emimodel
  WHERE cod_marca = a_marca
    AND activo = 1
  ORDER BY 2

	let v_concat = Trim(v_nombre) || " | " || trim(v_cod_modelo);

	RETURN  trim(v_concat),
	        v_cod_modelo
			WITH RESUME;

END FOREACH


	


END PROCEDURE;