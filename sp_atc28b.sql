-- Procedimiento para reporte de siniestralidad por poliza
-- 
-- Creado: 28/08/2015 - Autor: Jaime Chevalier.

DROP PROCEDURE sp_atc28b;
CREATE PROCEDURE "informix".sp_atc28b(a_no_documento CHAR(20))
    RETURNING  DATE,          -- Vigencia ini
			   DATE,          --Vigencia final
			   DECIMAL(16,2), --Suma Asegurada
			   DECIMAL(16,2); --Prima

DEFINE _vigencia_ini      DATE;
DEFINE _vigencia_final    DATE;
DEFINE _suma_asegurada    DECIMAL(16,2);
DEFINE _prima             DECIMAL(16,2);

FOREACH 
	SELECT vigencia_inic,
		   vigencia_final,
		   suma_asegurada,
		   prima_bruta
	  INTO _vigencia_ini,
		   _vigencia_final,
		   _suma_asegurada,
		   _prima			   
	FROM emipomae
	WHERE no_documento = a_no_documento
	AND actualizado = 1
	
	RETURN  
			_vigencia_ini,
			_vigencia_final,
			_suma_asegurada,
			_prima
			with resume;
END FOREACH;	

END PROCEDURE

