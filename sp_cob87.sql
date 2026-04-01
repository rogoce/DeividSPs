-- Cambia la ruta del Cobrador al Cambiar el Cobrador
-- 
-- Creado    : 19/07/2002 - Autor: Demetrio Hurtado Almanza
-- Modificado: 19/07/2002 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob87;

CREATE PROCEDURE "informix".sp_cob87(
a_compania CHAR(3), 
a_cobrador_old CHAR(3), 
a_cobrador_new CHAR(3), 
a_pais CHAR(3),
a_prov CHAR(2), 
a_ciud CHAR(2), 
a_dist CHAR(2), 
a_correg CHAR(5))
BEGIN WORK;

update cobruter
   set cod_cobrador   = a_cobrador_new
 where cod_cobrador   = a_cobrador_old
   and code_pais      = a_pais
   and code_provincia = a_prov
   and code_ciudad    = a_ciud
   and code_distrito  = a_dist
   and code_correg   = a_correg;

COMMIT WORK;
END PROCEDURE
