-- Procedimiento que busca los tramites a reasignar

-- Creado    : 06/01/2023 - Autor: Amado Pérez Mendoza 

-- SIS v.2.0 - sp_par203 - DEIVID, S.A.

DROP PROCEDURE sp_sis468;		

CREATE PROCEDURE "informix".sp_sis468()
  returning CHAR(10) as no_tramite,
            CHAR(20) as numrecla,
            CHAR(3) as cod_ajustador,
            CHAR(3) as ajust_deivid,
            CHAR(8) as usuario_deivid,
            CHAR(50) as nombre;

define _no_tramite	  CHAR(10);
define _numrecla	  CHAR(20);
define _cod_ajustador CHAR(3);
define _ajust_interno CHAR(3);
define _usuario       CHAR(8);
define _ajustador     CHAR(50);

SET ISOLATION TO DIRTY READ;

FOREACH
  SELECT tmp_tramite_r.no_tramite,   
         tmp_tramite_r.numrecla,   
         tmp_tramite_r.cod_ajustador,
         recrcmae.ajust_interno
    INTO _no_tramite,
         _numrecla,
         _cod_ajustador,
         _ajust_interno       
    FROM recrcmae,   
         tmp_tramite_r  
   WHERE ( recrcmae.numrecla = tmp_tramite_r.numrecla ) 
     and  tmp_tramite_r.procesado = 0
     and  recrcmae.no_reclamo not in (
                select no_reclamo from recterce)
                
   select usuario
     into _usuario
     from recajust
    where cod_ajustador = _ajust_interno;
    
   select descripcion
     into _ajustador
     from insuser
    where usuario = _usuario;              
   
   return  _no_tramite, 
           _numrecla,
           _cod_ajustador,
           _ajust_interno,
           _usuario,
           _ajustador with resume;
                             
END FOREACH


END PROCEDURE;
