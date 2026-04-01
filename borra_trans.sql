-- Procedimiento Para Borrar transacciones de auto sin # de incidente
-- 
-- Creado    : 17/12/2004 - Autor: Amado Perez
-- Modificado: 17/12/2004 - Autor: Amado Perez
-- mODIFICADO: 10/08/2005 - Autor: Amado Perez -- Ahora borra la transaccion, no actualizada, que no se usara
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE borra_trans;

CREATE PROCEDURE "informix".borra_trans(a_no_tranrec CHAR(10))
RETURNING INTEGER;

--DEFINE _no_tranrec     CHAR(10); 

DEFINE _error, _actualizado	    SMALLINT; 

--SET DEBUG FILE TO "sp_sis27.trc";  
--TRACE ON;                                                                 

{SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_rectr1(
			no_tranrec     CHAR(10),
			PRIMARY KEY (no_tranrec)
			) WITH NO LOG;


FOREACH
	SELECT x.no_tranrec	  
	  INTO _no_tranrec
	  FROM rectrmae x, recrcmae y, emipomae z
	 WHERE x.fecha <= "25/11/2004"
	   AND x.actualizado = 0
	   AND (x.wf_incidente is null
	    OR x.wf_incidente = "")
	   AND y.no_reclamo = x.no_reclamo
	   AND z.no_poliza = y.no_poliza
	   AND z.cod_ramo = '002'

    INSERT INTO tmp_rectr1(
	no_tranrec
	)
	VALUES
	(
	_no_tranrec
	);

END FOREACH

BEGIN

ON EXCEPTION SET _error 
    DROP TABLE tmp_rectr1;
 	RETURN _error;         
END EXCEPTION           
}
--FOREACH	WITH HOLD
--	SELECT no_tranrec	  
--	  INTO _no_tranrec
--	  FROM tmp_rectr1

	-- Eliminar Registros

SELECT actualizado
  INTO _actualizado
  FROM rectrmae
 WHERE no_tranrec =  a_no_tranrec;

IF _actualizado = 0 THEN

	BEGIN

	ON EXCEPTION SET _error 
	 	RETURN _error;         
	END EXCEPTION        
	   
		DELETE FROM rectrcob WHERE no_tranrec = a_no_tranrec ;
		DELETE FROM rectrcon WHERE no_tranrec = a_no_tranrec ;
		DELETE FROM rectrdes WHERE no_tranrec = a_no_tranrec ;
		DELETE FROM rectrde2 WHERE no_tranrec = a_no_tranrec ;
		DELETE FROM rectrref WHERE no_tranrec = a_no_tranrec ;
		DELETE FROM rectrrea WHERE no_tranrec = a_no_tranrec ;
		DELETE FROM rectrmae WHERE no_tranrec = a_no_tranrec ;
	--END FOREACH
	END

   RETURN 0;         
ELSE
   RETURN 1;
END IF
END PROCEDURE;
