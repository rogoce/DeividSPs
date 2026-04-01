DROP PROCEDURE sp_extrae_blob;

CREATE PROCEDURE "informix".sp_extrae_blob(ls_poliza CHAR(10), ls_endoso CHAR(5), ls_unidad CHAR(5))
--RETURNING CHAR(50)
RETURNING REFERENCES TEXT

DEFINE lblb_descripcion REFERENCES TEXT;
DEFINE ls_data     		CHAR(50);

--BEGIN WORK;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_blob.trc";  
--TRACE ON;                                                                 

SELECT descripcion[1,45]  INTO ls_data
  FROM endedde2
 WHERE no_poliza = ls_poliza
   AND no_endoso = ls_endoso
   AND no_unidad = ls_unidad;

--LET ls_data = lblb_descripcion;
-- CALL sp_set_codigo(5, li_poliza) RETURNING ls_poliza;
-- CALL sp_set_codigo(5, li_endoso) RETURNING ls_endoso;
RETURN lblb_descripcion;

END PROCEDURE; 