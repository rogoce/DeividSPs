-- Descripcion de una Transaccion

-- Creado    : 09/12/2004 - Autor: Amado Perez M.
-- Modificado: 09/12/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

--DROP PROCEDURE sp_rwf36;

CREATE PROCEDURE sp_rwf36(a_no_tranrec CHAR(10) default "%")
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
	  FROM rectrde2 		  
	 WHERE no_tranrec = a_no_tranrec
  ORDER BY renglon

	RETURN v_desccripcion     	
	 	   WITH RESUME;

END FOREACH



END PROCEDURE;