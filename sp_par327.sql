-- Procedure que inserta la descripcion al endoso del proceso diario de cancelacion o eliminacion de unidades por perdida total.
-- Creado por: Amado Perez M. 01/03/2012

DROP PROCEDURE sp_par327;

CREATE PROCEDURE "informix".sp_par327(
		a_poliza        CHAR(10),
		a_endoso  		CHAR(5),
		a_unidad        CHAR(5), 
	    a_endomov       CHAR(3)
        ) RETURNING  smallint, char(50);


DEFINE lblb_blob REFERENCES TEXT;
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);


--SET DEBUG FILE TO "amado_blob.trc";
--trace on;

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc;
end exception


SET ISOLATION TO DIRTY READ;

let lblb_blob = null;
 
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

end

return 0, "Actualizacion Exitosa";

END PROCEDURE;
