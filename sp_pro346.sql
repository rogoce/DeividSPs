-- Proyecto de Evaluacion de personas

-- Creado    : 17/01/2011 - Autor: Armando Moreno.

--DROP PROCEDURE sp_pro346;

CREATE PROCEDURE "informix".sp_pro346()
returning char(10),		 
		  char(8),	     
		  varchar(100),
		  smallint;	 

define _no_evaluacion	char(10);
define _usuario_eval	char(8);
define _nombre			varchar(100);
define _tipo_ramo		smallint;

SET ISOLATION TO DIRTY READ;

foreach

  SELECT no_evaluacion,
         usuario_eval,
         nombre,
         tipo_ramo
	INTO _no_evaluacion,
		 _usuario_eval,
		 _nombre,
		 _tipo_ramo
    FROM emievalu  
   WHERE escaneado       = 1
     AND completado      = 0
     AND suspenso        = 0
     AND usuario_eval    is not null

   return _no_evaluacion,
          _usuario_eval,
		  _nombre,
		  _tipo_ramo
		  with resume;
end foreach

END PROCEDURE
