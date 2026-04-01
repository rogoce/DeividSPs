-- Procedimiento que extrae los datos del Rutero (Cobruter1)
--
-- Creado    : 20/09/2000 - Autor: Amado Perez Mendoza
-- Modificado: 20/11/2001 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob130bk;
CREATE PROCEDURE "informix".sp_cob130bk(a_cobrador CHAR(3), a_dia INT) 
       RETURNING	    INT,
       					int;

DEFINE _pago_fijo  SMALLINT;
DEFINE _cod_pagador      CHAR(10);
DEFINE _fecha_dt         DATETIME YEAR TO FRACTION(5);
define _fecha_hoy  date;
define _dia_ant,_cantidad integer;

set isolation to dirty read;

LET _cantidad = 0;

let _fecha_dt  = sp_sis40();
let _fecha_hoy = date(_fecha_dt);
let _fecha_hoy = _fecha_hoy - 1;
let _dia_ant   = day(_fecha_hoy);

FOREACH
	SELECT cod_pagador
	  INTO _cod_pagador
	  FROM cobruter1
	 WHERE cod_cobrador  = a_cobrador
	   AND (dia_cobros1  = _dia_ant
	    OR  dia_cobros2  = _dia_ant)
	foreach
		SELECT pago_fijo
		  INTO _pago_fijo
		  FROM cascliente
		 WHERE cod_cliente = _cod_pagador
		exit foreach;
	end foreach

   if _pago_fijo = 1 then
		continue foreach;
   else
		let _cantidad = _cantidad + 1;
   end if
   let _cantidad = 0;
END FOREACH
RETURN _cantidad,
	   _dia_ant;
END PROCEDURE