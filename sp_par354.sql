-- Procedimiento para crear en agtbitacora todos los registros de agentes nuevos y modificados
--
-- Creado    : 02/03/2015 - Autor: Amado Perez Mendoza 
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par354;

CREATE PROCEDURE "informix".sp_par354(a_estafeta CHAR(4), a_tipo_mov CHAR(1))
 
define _username	char(32);

let _username = sp_sis84();

-- SET DEBUG FILE TO "sp_pro44.trc";      
-- TRACE ON;                                                                     

INSERT INTO cobestafbit(
    cod_estafeta,
	agrupacion,
	nombre,
	ubicacion,
	telefono1,
	telefono2,
	cantidad,
	user_changed,
	date_changed
	)
	SELECT 	cod_estafeta,
			agrupacion,
			nombre,
			ubicacion,
			telefono1,
			telefono2,
			cantidad,
			_username,
			current
	  FROM cobestafeta
	 WHERE cod_estafeta = a_estafeta; 	             


END PROCEDURE
