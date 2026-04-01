-- Procedimiento para Insertar notas de Reclamos Autos
-- 
-- creado: 15/06/2019 - Autor: Federico Coronado

DROP PROCEDURE sp_yos12;
CREATE PROCEDURE "informix".sp_yos12(a_no_reclamo CHAR(10), a_nota VARCHAR(250), a_usuario CHAR(8))
                  RETURNING integer, varchar(50);  

DEFINE _error   			SMALLINT;
DEFINE _hoy                 DATETIME HOUR TO FRACTION(5);
DEFINE _descripcion    		VARCHAR(50);

begin work;
	 -- Insertando RECNOTAS
	 LET _hoy = CURRENT;
	 LET _hoy = _hoy + 1 units second;

	 CALL sp_rwf104(a_no_reclamo,_hoy,a_nota,a_usuario) returning _error, _descripcion;
	 IF _error <> 0 THEN
		rollback work;
		RETURN  _error, _descripcion;
	 END IF
commit work;
	RETURN  0, "Nota Registrada Exitosamente";
end PROCEDURE