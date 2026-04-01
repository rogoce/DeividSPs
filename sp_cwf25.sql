-- Consulta de la descripcion de una requisicion

-- Creado    : 25/06/2004 - Autor: Amado Perez M.
-- Modificado: 25/06/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_cwf25;

CREATE PROCEDURE sp_cwf25(a_no_requis CHAR(10) default "%")
RETURNING smallint,
		  char(100);

define v_renglon     	    smallint;
define v_desc          	    varchar(100);

--set debug file to "sp_rwf02.trc";

SET ISOLATION TO DIRTY READ;

FOREACH
	SELECT renglon,
	       desc_cheque
	  INTO v_renglon,
		   v_desc         	
	  FROM chqchdes 		  
	 WHERE no_requis = a_no_requis
	 ORDER BY 1

	RETURN v_renglon, 
	       trim(v_desc)
	 	   WITH RESUME;

END FOREACH
END PROCEDURE;