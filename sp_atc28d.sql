-- Procedimiento para reporte de siniestralidad por poliza
-- 
-- Creado: 28/08/2015 - Autor: Jaime Chevalier.

DROP PROCEDURE sp_atc28d;
CREATE PROCEDURE "informix".sp_atc28d(a_no_documento CHAR(20))
    RETURNING  CHAR(5),
	           CHAR(100),
			   DECIMAL(16,2);

DEFINE _nombre            CHAR(100);
DEFINE _no_unidad         CHAR(5);
DEFINE _prima_bruta       DECIMAL(16,2);
DEFINE _no_poliza         CHAR(10);


CALL sp_sis21(a_no_documento) RETURNING _no_poliza;

 SELECT cliclien.nombre
   INTO _nombre
   FROM emipomae,
        cliclien
  WHERE cliclien.cod_cliente = emipomae.cod_contratante
    and emipomae.no_documento = a_no_documento
   GROUP BY cliclien.nombre;

FOREACH 
	  SELECT no_unidad, 
	         prima_bruta 
	   INTO _no_unidad,
	        _prima_bruta
	    FROM emipouni 
	   WHERE no_poliza = _no_poliza  

	
		RETURN  _no_unidad,
		        _nombre,
			    _prima_bruta with resume;
			
END FOREACH	
		   
END PROCEDURE

