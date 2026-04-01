-- Procedimiento para traer la fecha de hoy desde el servidor
--
-- Creado    : 06/07/2001 - Autor: Lic. Amado Perez Mendoza 
-- Modificado: 06/07/2001 - Autor: Lic. Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_sis26a;

CREATE PROCEDURE "informix".sp_sis26a()
   RETURNING   DATE;
   RETURN CURRENT - 20 units day;
END PROCEDURE
