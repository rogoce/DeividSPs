-- Validacion del no_requis antes de imprimir, para evitar duplicidad.
--
-- Creado    : 07/09/2007 - Autor: Lic. Armando Moreno 
--
-- SIS v.2.0 d_- DEIVID, S.A.

--DROP PROCEDURE sp_che78;

CREATE PROCEDURE "informix".sp_che78(
a_no_requis 	CHAR(10) 
) RETURNING INTEGER;


DEFINE _valor    INTEGER;

--SET DEBUG FILE TO "sp_che78.trc";
--TRACE ON;

 SELECT count(*)
   INTO _valor
   FROM bitache
  WHERE no_requis = a_no_requis;

 RETURN _valor;

END PROCEDURE;
