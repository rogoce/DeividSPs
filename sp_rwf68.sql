-- Consulta de Conductores

-- Creado    : 09/12/2008 - Autor: Amado Perez M.
-- Modificado: 09/12/2008 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_rwf68;

CREATE PROCEDURE sp_rwf68(a_conductor VARCHAR(100) default "%")
RETURNING varchar(140),
      	  char(10);

define v_cod_cliente	char(10);
define v_nombre  		varchar(100);
define v_cedula         char(30);
define v_concat         varchar(140);

--set debug file to "sp_rwf02.trc";


SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT	cod_cliente,
		nombre,
		cedula
   INTO v_cod_cliente,
        v_nombre,
		v_cedula
   FROM	cliclien
  WHERE nombre LIKE a_conductor 
  ORDER BY 2

    IF v_cedula IS NULL THEN
		LET v_cedula = "";
	END IF

	let v_concat = Trim(v_nombre) || " | " || trim(v_cedula);

	RETURN  v_concat,
	        v_cod_cliente
			WITH RESUME;

END FOREACH


	


END PROCEDURE;