-- Procedimiento para generacion de cheques
-- 
-- creado: 14/09/2009 - Autor: Amado Perez.

--DROP PROCEDURE sp_rwf73;
CREATE PROCEDURE "informix".sp_rwf73(a_no_tranrec CHAR(10)) 
			RETURNING CHAR(10), CHAR(10);  

DEFINE _transaccion			CHAR(10);
DEFINE _cod_asignacion		CHAR(10);

SET ISOLATION TO DIRTY READ;

 SELECT transaccion,
		cod_asignacion
   INTO _transaccion,
		_cod_asignacion
   FROM rectrmae
  WHERE no_tranrec = a_no_tranrec;

 IF _cod_asignacion IS NULL THEN
	LET _cod_asignacion = "";
 END IF

if _cod_asignacion <> ""  then
    set lock mode to wait;

    update atcdocde
	   set suspenso = 0
	 where cod_asignacion = _cod_asignacion
	   and completado = 0;

	SET ISOLATION TO DIRTY READ;
end if

 RETURN _transaccion, _cod_asignacion;
END PROCEDURE
