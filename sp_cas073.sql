-- buscar a los pagadores que tienen mas de 7 dias de que se emitio aviso(call center) y los cobradores
-- aun no los han entregado.
-- 
-- Creado    : 05/04/2004 - Autor: Armando Moreno
-- Modificado: 05/04/2004 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cas073;

CREATE PROCEDURE "informix".sp_cas073(a_fecha_hoy date)
RETURNING   char(20),date,char(10),char(50),char(100);

DEFINE _nombre_pagador   CHAR(100);
DEFINE _nombre_cobrador  CHAR(50);
DEFINE v_exigible        DEC(16,2);
DEFINE _cod_pagador      CHAR(10);
DEFINE _cod_cobrador     CHAR(3);
define _no_documento	 char(20);
define _fecha_aviso		 date;

set isolation to dirty read;

LET v_exigible   = 0;
LET _cod_pagador = null;
let _nombre_cobrador = "";
let _nombre_pagador = "";

FOREACH
	-- Lectura de Cobavica
	select no_documento,
		   fecha_aviso,
		   cod_pagador,
		   cod_cobrador,
		   exigible
	  into _no_documento,
		   _fecha_aviso,
		   _cod_pagador,
		   _cod_cobrador,
		   v_exigible
	  from cobavica
	 where entregado = 0
	   and (a_fecha_hoy - fecha_aviso) >= 8 -- 7 dias de que se emitio el aviso y aun no se han entregado
	order by 3

	select nombre
	  into _nombre_cobrador
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;

	select nombre
	  into _nombre_pagador
	  from cliclien
	 where cod_cliente = _cod_pagador;

	RETURN _no_documento,
		   _fecha_aviso,
		   _cod_pagador,
		   _nombre_cobrador,
		   _nombre_pagador
		   WITH RESUME;

END FOREACH;
END PROCEDURE