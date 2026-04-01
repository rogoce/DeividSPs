-- Descripcion de una Transaccion

-- Creado    : 09/12/2004 - Autor: Amado Perez M.
-- Modificado: 09/12/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_rwf124;

CREATE PROCEDURE sp_rwf124(a_no_reclamo CHAR(10) default "%")
RETURNING varchar(60);

define v_desccripcion	varchar(60);
define _renglon         SMALLINT;

--set debug file to "sp_rwf02.trc";

SET ISOLATION TO DIRTY READ;

FOREACH
	SELECT desc_transaccion,
	       renglon
	  INTO v_desccripcion,
	       _renglon			
	  FROM recrcde2 		  
	 WHERE no_reclamo = a_no_reclamo
  ORDER BY renglon

	RETURN v_desccripcion     	
	 	   WITH RESUME;

END FOREACH



END PROCEDURE;