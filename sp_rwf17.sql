-- Consulta de Cobertura de un Reclamo

-- Creado    : 25/06/2004 - Autor: Amado Perez M.
-- Modificado: 25/06/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_rwf17;

CREATE PROCEDURE sp_rwf17(a_no_reclamo CHAR(10) default "%")
RETURNING char(5),
      	  varchar(50),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
          dec(16,2);

define v_cod_cobertura		char(5);
define v_desc_cobertura		varchar(50);
define v_estimado       	dec(16,2);
define v_deducible			dec(16,2);
define v_reserva_inicial	dec(16,2);
define v_reserva_actual		dec(16,2);
define v_pagos				dec(16,2);
define v_salvamento			dec(16,2);
define v_recupero			dec(16,2);
define v_deducible_pagado	dec(16,2);
define v_deducible_devuel	dec(16,2);

--set debug file to "sp_rwf02.trc";

SET ISOLATION TO DIRTY READ;

FOREACH
	SELECT cod_cobertura,
	       estimado,
		   deducible,
		   reserva_inicial,
		   reserva_actual,
		   pagos,
		   salvamento,
		   recupero,
		   deducible_pagado,
		   deducible_devuel
	  INTO v_cod_cobertura,
		   v_estimado,       	
		   v_deducible,			
		   v_reserva_inicial,	
	       v_reserva_actual,		
	       v_pagos,				
		   v_salvamento,			
		   v_recupero,			
		   v_deducible_pagado,
		   v_deducible_devuel
	  FROM recrccob 		  
	 WHERE no_reclamo = a_no_reclamo


	SELECT nombre
	  INTO v_desc_cobertura
	  FROM prdcober
	 WHERE cod_cobertura = v_cod_cobertura;

	RETURN v_cod_cobertura, 
	       v_desc_cobertura,
		   v_deducible,			
		   v_reserva_inicial,	
		   v_reserva_actual,	
		   v_pagos,				
		   v_salvamento,			
		   v_recupero,				
		   v_deducible_pagado,	
		   v_deducible_devuel	 
	 	   WITH RESUME;

END FOREACH


	


END PROCEDURE;