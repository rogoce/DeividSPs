DROP PROCEDURE amado_blob;

CREATE PROCEDURE "informix".amado_blob(
		a_poliza        CHAR(10),
		a_endoso  		CHAR(5),
		a_unidad        CHAR(5), 
	    a_endomov       CHAR(3)
        ) RETURNING  smallint;


DEFINE lblb_blob REFERENCES TEXT;
--DEFINE 
-- Tabla Temporal tmp_prod


SET DEBUG FILE TO "amado_blob.trc";
trace on;

SET ISOLATION TO DIRTY READ;

let lblb_blob = null;
--let lblb_blob = ASCII('MEDIANTE EL PRESENTE ENDOSO SE HACE CONSTAR Y QUEDA ENTENDIDO QUE SE CANCELA LA POLIZA ARRIBA DESCRITA POR PERDIDA TOTAL');
--let lblb_blob = FILETOBLOB('C:\Users\APEREZ\Desktop\cancela.txt', 'client');  
 
DELETE FROM endedde2 WHERE no_poliza = a_poliza AND no_endoso = a_endoso AND no_unidad = a_unidad;

SELECT descripcion
  INTO lblb_blob
  FROM enddescrip
 WHERE cod_endomov = a_endomov;

Insert Into endedde2 
(no_poliza,
 no_endoso, 
 no_unidad,
 descripcion)
Values(
a_poliza,
a_endoso,
a_unidad,
lblb_blob
);

END PROCEDURE;
