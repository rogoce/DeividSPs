-- Procedimiento para aplicar o sacar de suspenso una asignación
--
-- Creado    : 03/05/2013 - Autor: Federico Coronado.
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_imp15;
CREATE PROCEDURE "informix".sp_imp15(a_cod_asignacion CHAR(10), a_suspenso smallint)
RETURNING   SMALLINT			 -- _error
						

DEFINE _error		  INTEGER;
DEFINE v_resultado   smallint;
define v_fecha       DATETIME YEAR TO FRACTION(5);
	BEGIN
		ON EXCEPTION SET _error 
		 RETURN _error;         
		END EXCEPTION
			let v_fecha = current;
			if a_suspenso = 0 then
				update atcdocde
				   set suspenso      = a_suspenso,
					   date_susp_add = v_fecha
				where  cod_asignacion = a_cod_asignacion;
			else
			update atcdocde
			   set suspenso      = a_suspenso,
				   date_susp_rem = v_fecha
			where cod_asignacion = a_cod_asignacion;
			end if
		RETURN 0;
	end 
end procedure