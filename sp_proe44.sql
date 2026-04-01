-- Procedimiento Verificar que si hay asegurados sin Conoce a tu Cliente
--
-- Creado    : 28/10/2009 - Autor: Amado Perez.
-- Modificado: 28/10/2009 - Autor: Amado Perez.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe44;
CREATE PROCEDURE "informix".sp_proe44(a_poliza CHAR(10), a_documento CHAR(20))
			RETURNING   SMALLINT;

DEFINE _error			INTEGER;
DEFINE _cnt             SMALLINT;

BEGIN

SET LOCK MODE TO WAIT;

-- SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_pro44.trc";      
-- TRACE ON;                                                                     

SELECT count(*)	  
  INTO _cnt	  
  FROM emipomae
 WHERE no_documento = trim(a_documento)
   AND no_poliza <> trim(a_poliza)
   AND nueva_renov = 'N'
   AND actualizado = 1;

RETURN _cnt;
END
END PROCEDURE;