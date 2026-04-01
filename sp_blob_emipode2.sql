-- Procedimiento que Genera el txt 
-- Creado : 14/09/2016 - Autor: Henry Giron 
DROP PROCEDURE sp_blob_emipode2;

CREATE PROCEDURE sp_blob_emipode2(ls_poliza CHAR(10), ls_unidad CHAR(5))
RETURNING REFERENCES TEXT

DEFINE lblb_descripcion REFERENCES TEXT;

SELECT descripcion  
  INTO lblb_descripcion 
  FROM emipode2  
 WHERE no_poliza = ls_poliza
   AND no_unidad = ls_unidad;

RETURN  lblb_descripcion;

END PROCEDURE;