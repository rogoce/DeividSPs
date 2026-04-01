-- Procedimiento para generacion una nota de demandas
-- 
-- creado: 07/08/2015 - Autor: Jaime Chevalier.

DROP PROCEDURE sp_leg06;
CREATE PROCEDURE "informix".sp_leg06(a_no_demanda CHAR(10), a_fecha DATETIME year to fraction(5), a_nota VARCHAR(250), a_usuario CHAR(8))
                  RETURNING integer, varchar(50);  

DEFINE _no_reclamo			CHAR(10);
DEFINE _error               integer;

Insert into legnotas (no_demanda, fecha_nota, desc_nota, user_added)
              values (a_no_demanda, a_fecha, a_nota, a_usuario); 

return 0, "Se inserto en LEGNOTAS";

END PROCEDURE
