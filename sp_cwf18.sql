-- Procedimiento para generacion de cheques
-- 
-- creado: 14/09/2009 - Autor: Amado Perez.

--DROP PROCEDURE sp_rwf73;
CREATE PROCEDURE "informix".sp_cwf18(a_usuario VARCHAR(20), a_valor SMALLINT) 
--RETURNING VARCHAR(20);

DEFINE _usuario VARCHAR(20); 

   SET LOCK MODE TO WAIT;


   update wf_firmas 
      set orden = a_valor 
    where trim(usuario) = a_usuario;

END PROCEDURE