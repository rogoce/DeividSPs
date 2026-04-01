-- Procedimiento para generacion una nota del reclamo
-- 
-- creado: 18/02/2011 - Autor: Amado Perez.

DROP PROCEDURE sp_leg_notas;
CREATE PROCEDURE "informix".sp_leg_notas()
    RETURNING integer, varchar(50);  

DEFINE _no_reclamo			CHAR(10);
DEFINE _error               integer;



Insert into legnotas (no_demanda, fecha_nota, desc_nota, user_added)
              values (a_no_reclamo, a_fecha, a_nota, a_usuario); 

return 0, "Se inserto en LEGNOTAS";

END PROCEDURE
