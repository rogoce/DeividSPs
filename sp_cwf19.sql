-- Procedimiento para generacion de cheques
-- 
-- creado: 14/09/2009 - Autor: Amado Perez.

--DROP PROCEDURE sp_rwf73;
CREATE PROCEDURE "informix".sp_cwf19(a_tipo_firma CHAR(1)) 
RETURNING VARCHAR(20);

DEFINE _usuario VARCHAR(20); 

   SET LOCK MODE TO WAIT;


   IF a_tipo_firma = "*" THEN
	   update wf_firmas
	   set orden_salud = 0 
	   where activo = 1 
	   and marc_salud = 0 
	   and salud_default = 0
	   and de_salud      = 1
	   and tipo_firma in ('A', 'B');
   ELSE
	   update wf_firmas
	   set orden_salud = 0 
	   where activo = 1 
	   and marc_salud = 0 
	   and salud_default = 0
	   and de_salud      = 1
	   and tipo_firma = a_tipo_firma;

   END IF

   SET ISOLATION TO DIRTY READ;


   IF a_tipo_firma = "*" THEN
   	FOREACH
		select usuario 
		  into _usuario
		  from wf_firmas 
		 where activo = 1 
		   and marc_salud = 0 
		   and orden_salud = 0 
	       and salud_default = 0
		   and de_salud      = 1
		   and tipo_firma in ('A', 'B')

        return TRIM(_usuario) with resume;
	END FOREACH
   ELSE
   	FOREACH
		select usuario 
		  into _usuario
		  from wf_firmas 
		 where activo = 1 
		   and marc_salud = 0 
		   and orden_salud = 0 
	       and salud_default = 0
		   and de_salud      = 1
	       and tipo_firma = a_tipo_firma

        return TRIM(_usuario) with resume;
	END FOREACH
   END IF

END PROCEDURE