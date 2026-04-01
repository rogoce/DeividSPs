-- Creado Por: Modificado: 25/05/2007 Por: Rub‚n Dar¡o Arn ez , Incluir firmas en los reporte
-- SIS v.2.0 - DEIVID, S.A.

-- DROP PROCEDURE "informix".sp_co20z;

CREATE PROCEDURE "informix".sp_co20z(a_usuario1 CHAR(10), a_usuario2 CHAR(10), a_cantidad integer)

RETURNING CHAR(10),		 -- Usuario 1 
		  CHAR(10);		 -- Usuario 2
			  		         

DEFINE _usuario1  		  CHAR(10);
DEFINE _usuario2  		  CHAR(10);
define i                  integer;

SET ISOLATION TO DIRTY READ;

for i = 1 to a_cantidad
	RETURN a_usuario1,a_usuario2 with resume;
end for

END PROCEDURE;