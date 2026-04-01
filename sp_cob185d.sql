-- Procedimiento para traer la fecha de hoy desde el servidor
--
-- Creado    : 24/11/2005 - Autor: Lic. Armando Moreno
-- Modificado: 24/11/2005 - Autor: Lic. Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob185d;

CREATE PROCEDURE "informix".sp_cob185d(a_cod_pagador char(10))
	   RETURNING   char(10),char(20),dec(16,2);

define 	_no_doc    	   char(20);
define 	_id_cliente    char(10);
define 	_apagar		   dec(16,2);

BEGIN

foreach

	select cod_pagador,
		   no_documento,
		   a_pagar
	  into _id_cliente,   
		   _no_doc,
		   _apagar
	  from cdmcorrd
	 where cod_pagador = a_cod_pagador

	return _id_cliente,   
		   _no_doc,
		   _apagar
	with resume;

end foreach

END

END PROCEDURE
