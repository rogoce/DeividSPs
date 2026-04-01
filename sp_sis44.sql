-- Procedimiento Para Actualizar los Datos de la tabla de cliclien desde cotizacion
-- 
-- Creado    : 25/03/2003 - Autor: Amado Perez
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis44;

CREATE PROCEDURE "informix".sp_sis44()
RETURNING CHAR(10),
          CHAR(25),
          DEC(16,2),
          DEC(16,2);

DEFINE _no_remesa  	    CHAR(10); 
DEFINE _cuenta			CHAR(25);
DEFINE _debito, _credito DEC(16,2);

--SET DEBUG FILE TO "sp_sis371.trc";  
--TRACE ON;                                                                 

CREATE TEMP TABLE temp_det
               (no_remesa        CHAR(10),
			    seleccionado     SMALLINT DEFAULT 1,
               PRIMARY KEY (no_remesa)) WITH NO LOG;

CREATE TEMP TABLE temp_det2
               (no_remesa        CHAR(10),
               PRIMARY KEY (no_remesa)) WITH NO LOG;


SET ISOLATION TO DIRTY READ;


 FOREACH WITH HOLD
	SELECT no_remesa		
	  INTO _no_remesa
	  FROM cobasien
	 WHERE cuenta MATCHES '139-01-03'

	BEGIN

	ON EXCEPTION  
	END EXCEPTION           
	 INSERT INTO temp_det( 
	 	no_remesa
		)
	 VALUES(
	    _no_remesa
	    );
    END

	BEGIN

	ON EXCEPTION  
	END EXCEPTION           
	 INSERT INTO temp_det2( 
	 	no_remesa
		)
	 VALUES(
	    _no_remesa
	    );
    END

 END FOREACH

UPDATE temp_det
   SET seleccionado = 0
 WHERE seleccionado = 1
	AND no_remesa NOT IN (SELECT a.no_remesa
							FROM temp_det2 a, cobasien b
						   WHERE b.no_remesa = a.no_remesa
						     AND (cuenta MATCHES '419*' OR cuenta MATCHES '541*'));

FOREACH	WITH HOLD
	SELECT a.no_remesa,
		   b.cuenta,
		   b.debito,
		   b.credito
	  INTO _no_remesa,
		   _cuenta,
		   _debito,
		   _credito
	  FROM temp_det a, cobasien b
	 WHERE b.no_remesa = a.no_remesa
       AND a.seleccionado = 1


	RETURN _no_remesa,
	       _cuenta,
		   _debito,
		   _credito
	  WITH RESUME;
END FOREACH

DROP TABLE temp_det;
DROP TABLE temp_det2;


END PROCEDURE;
