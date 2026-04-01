--DROP PROCEDURE sp_rwf32;

CREATE PROCEDURE "informix".sp_rwf32(a_reclamo CHAR(10), a_indice smallint, a_nombre VARCHAR(100),a_foto blob())
RETURNING smallint,
          CHAR(50);
--RETURNING REFERENCES TEXT

DEFINE lblb_descripcion REFERENCES TEXT;
DEFINE ls_data     		CHAR(50);
DEFINE _error           SMALLINT;

--BEGIN WORK;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rwf32.trc";  
--TRACE ON;                                                                

BEGIN

ON EXCEPTION SET _error
  RETURN _error, "Error al Insertar";
END EXCEPTION

DELETE FROM recfotos WHERE no_reclamo = a_reclamo; 
 
INSERT INTO recfotos(
	   no_reclamo,
	   indice,
	   nombre
	   )
	   VALUES(
	   a_reclamo,
	   a_indice,
  	   a_nombre
	   );

--LET lblb_descripcion = TEXT(a_foto);

UPDATE recfotos 
   SET foto = "C:\control.txt"
 WHERE no_reclamo = a_reclamo;

END 

--RETURN lblb_descripcion;
RETURN 0,"Insercion exitosa";

END PROCEDURE; 