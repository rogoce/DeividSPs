
-- Creado    : 27/09/2010 - Autor: Armando Moreno.

--DROP PROCEDURE sp_rec175;

CREATE PROCEDURE "informix".sp_rec175(a_cod_asignacion char(10))
returning integer,char(100);

define _fecha_time       datetime year to fraction(5);
define _error_code		 smallint;
define _cod_entrada      char(10);
define _cantidad         integer;
define _suspenso		 smallint;
define _monto_tot        decimal(16,2);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rec125.trc";
--trace on;

let _fecha_time = CURRENT;
let _cantidad   = 0;

BEGIN

ON EXCEPTION SET _error_code
 	RETURN _error_code, 'Error al Actualizar la Asignacion'; 
END EXCEPTION

SELECT count(*)
  INTO _cantidad
  FROM rectrmae
 WHERE cod_asignacion = a_cod_asignacion;

if _cantidad = 0 then

	RETURN 1, 'Esta Asignacion no tiene transacciones creadas, no se puede Salvar...'; 

end if

RETURN 0, 'Actualizacion Exitosa ...'; 

END
END PROCEDURE
