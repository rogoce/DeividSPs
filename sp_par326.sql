-- Procedimiento para crear en bitchqpagco todos los movimientos de chqpagco
--
-- Creado    : 09/11/2011 - Autor: Amado Perez Mendoza 
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par326;

CREATE PROCEDURE "informix".sp_par326(a_semana integer, a_tipo_mov CHAR(1))
 
define _username	char(32);
DEFINE _CANT        INTEGER;
define _fecha       DATE;

let _username = sp_sis84();
LET _fecha = current;

-- SET DEBUG FILE TO "sp_pro44.trc";      
-- TRACE ON;   

SELECT COUNT(*) 
  INTO _CANT                                                                
  FROM chqpagco
 WHERE semana = a_semana;

IF _CANT > 0 THEN

	INSERT INTO bitchqpagco(
	   semana,
	   fecha_desde,
	   fecha_hasta,
	   generado,
	   user_added,
	   date_added,
	   user_changed,
	   date_changed,
	   tipo_mov
		)
		SELECT semana,
			   fecha_desde,
			   fecha_hasta,
			   generado,
			   user_added,
			   date_added,
			   _username,
			   _fecha,
			   a_tipo_mov
		  FROM chqpagco
	 WHERE semana = a_semana; 	             

END IF

END PROCEDURE
