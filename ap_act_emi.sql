-- Renovacion automatica, dw de tabla emideren(detalle de excepciones de la poliza)

-- Creado    : 15/04/2009 - Autor: Armando Moreno.

DROP PROCEDURE ap_act_emi;

CREATE PROCEDURE "informix".ap_act_emi()
returning smallint;		   

define _no_documento	    char(20);
define _no_poliza		    char(10);
define _cod_pagador		    char(10);


SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro850.trc";
--trace on;

   foreach 
		SELECT no_documento
		  INTO _no_documento
		  FROM emicartasal5
		 WHERE periodo = '2023-04'
		 
		let _no_poliza = sp_sis21(_no_documento); 

		SELECT cod_pagador
		  INTO _cod_pagador
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;
		 
		UPDATE emicartasal5
           SET cod_contratante = _cod_pagador
         WHERE no_documento = _no_documento; 
		 
		  return 0 with resume;
   end foreach
 END PROCEDURE
