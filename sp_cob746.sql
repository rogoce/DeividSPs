-- Procedimiento que Borra Remesa
-- Creado    : 31/12/2008 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob746;

CREATE PROCEDURE "informix".sp_cob746(a_numero		CHAR(10)) 
RETURNING SMALLINT, CHAR(100);	 

--SET DEBUG FILE TO "sp_cob212.trc"; 
--TRACE ON;                                                                
DEFINE _error_code      	INTEGER;

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Borrar.';
END EXCEPTION

delete cobsuspe where doc_suspenso in (
Select cobredet.doc_remesa  FROM cobredet
WHERE cobredet.no_remesa in (a_numero) and cobredet.tipo_mov = 'E')	;

delete cobreagt WHERE cobreagt.no_remesa in (a_numero) ;

delete cobredet WHERE cobredet.no_remesa in (a_numero) ;

delete cobremae WHERE cobremae.no_remesa in (a_numero) ;


RETURN 0, 'Se borro la remesa ' || a_numero ; 

END 					 

END PROCEDURE;	   