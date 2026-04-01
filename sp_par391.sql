-- Procedimiento que crea los días feriados por cambio de año
-- Amado Perez M. 30-09-2025

DROP PROCEDURE sp_par391;
CREATE PROCEDURE sp_par391()
    RETURNING INTEGER, VARCHAR(50);

    DEFINE martes_carnaval 	DATE;
    DEFINE viernes_santo 	DATE;
	DEFINE _agno_max    	INTEGER;
	DEFINE _fecha_new		DATE;
	DEFINE _cnt				SMALLINT;
	DEFINE _error_code      INTEGER;
	DEFINE _error_isam		SMALLINT;
	DEFINE _error_desc		VARCHAR(50);
	DEFINE _fecha			DATE;
	DEFINE _descripcion		VARCHAR(50);
	DEFINE a_agno			INTEGER;
	DEFINE _fecha_control   DATE;
	
	CREATE TEMP TABLE tmp_feriados (
		fecha DATE,
		descripcion VARCHAR(50),
		primary key (fecha))
		with no log;
		
	SET ISOLATION TO DIRTY READ;
	
	BEGIN 
	ON EXCEPTION SET _error_code,_error_isam,_error_desc
		ROLLBACK WORK;
		DROP TABLE tmp_feriados; 
		RETURN _error_code, _error_desc;
	END EXCEPTION
	
	LET _fecha_control = CURRENT;
	
	LET _fecha_control = _fecha_control + 1 UNITS DAY;	
	
	LET a_agno = YEAR(_fecha_control);
	
    SELECT MAX(YEAR(fecha))
	  INTO _agno_max
	  FROM parferiados;
	  
	IF a_agno > _agno_max THEN
		BEGIN WORK;	
		LET _cnt = a_agno - _agno_max;
	    CALL sp_par390(a_agno) RETURNING martes_carnaval, viernes_santo;
		FOREACH
			SELECT fecha,
			       descripcion
			  INTO _fecha,
			       _descripcion
			  FROM parferiados
			 WHERE year(fecha) = _agno_max
		  ORDER BY fecha
		
			IF _descripcion LIKE '%MARTES%' THEN
				LET _fecha_new = martes_carnaval;
			ELIF _descripcion LIKE '%VIERNES%' THEN
				LET _fecha_new = viernes_santo;
			ELSE
				LET _fecha_new = _fecha + _cnt UNITS YEAR;
			END IF
			
			INSERT INTO tmp_feriados VALUES (
				_fecha_new,
				_descripcion);				
		END FOREACH	
		
		INSERT INTO parferiados
		SELECT * FROM tmp_feriados;
		COMMIT WORK;
	END IF
	END 
    DROP TABLE tmp_feriados;
    RETURN 0, 'GENERACION EXITOSA';
END PROCEDURE;