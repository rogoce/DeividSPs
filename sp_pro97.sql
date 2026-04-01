-- Verificacion de las polizas a renovar

-- Creado    : 10/04/2002 - Autor: Marquelda Valdelamar

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro97;

create procedure sp_pro97(a_compania CHAR) 
returning CHAR(20),  -- no_documento
          integer;
		 
DEFINE _no_documento	  CHAR(20);
DEFINE _valor             INTEGER;

SET ISOLATION TO DIRTY READ;

--Selecciona los registros de polizas
FOREACH   
SELECT count(*),
       no_documento
  into _valor,
       _no_documento
  from emipomae
 where renovada    = 0
   and actualizado = 1
   and vigencia_final >= "01/01/2002"
--  and  estatus_poliza = 1
 GROUP BY no_documento
 ORDER BY no_documento
  
IF _valor >= 2 and _no_documento IS NOT NULL then

  RETURN _no_documento,
         _valor
    	 WITH RESUME;
END IF
END FOREACH

END PROCEDURE

