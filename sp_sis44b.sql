-- Procedimiento Para Actualizar los Datos de la tabla de cliclien desde cotizacion
-- 
-- Creado    : 25/03/2003 - Autor: Amado Perez
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis44b;

CREATE PROCEDURE "informix".sp_sis44b()
RETURNING CHAR(10),
          CHAR(10),
		  CHAR(30),
          DEC(16,2);

DEFINE _no_remesa, _no_recibo  	CHAR(10); 
DEFINE _doc_remesa				CHAR(30);
DEFINE _monto					DEC(16,2);

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
		   b.doc_remesa,
		   b.no_recibo,
		   b.monto
	  INTO _no_remesa,
		   _doc_remesa,
		   _no_recibo,
		   _monto
	  FROM temp_det a, cobredet b
	 WHERE b.no_remesa = a.no_remesa
       AND a.seleccionado = 1
	   AND b.tipo_mov IN ('D','S','R')


	RETURN _no_remesa,
	       _no_recibo,
	       _doc_remesa,
		   _monto
	  WITH RESUME;
END FOREACH

DROP TABLE temp_det;
DROP TABLE temp_det2;


END PROCEDURE;
