
DROP PROCEDURE sp_cob109;
CREATE PROCEDURE "informix".sp_cob109()
RETURNING INT;

DEFINE _no_poliza,_cod_pagador 	char(10);
DEFINE _cant        int;
let _cant = 0;
set isolation to dirty read;
FOREACH
 -- Lectura de Cobruter2	
		SELECT no_poliza
		  INTO _no_poliza
		  FROM cobruter2

		If _no_poliza is null Then
			continue foreach;
		Else
			SELECT cod_pagador
			  INTO _cod_pagador
			  FROM emipomae
			 WHERE no_poliza = _no_poliza;

			update cobruter2
			   set cod_pagador = _cod_pagador
			 where no_poliza   = _no_poliza;

			let _cant = _cant + 1;

		End If

END FOREACH
return _cant;
END PROCEDURE