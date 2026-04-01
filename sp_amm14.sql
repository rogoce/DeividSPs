--pagadores que tienen cuenta y no tienen cedula creada

--DROP procedure sp_amm14;

CREATE procedure "informix".sp_amm14(a_periodo CHAR(1))

RETURNING   CHAR(17),
            CHAR(100),
            CHAR(10);

DEFINE _no_cuenta      CHAR(17);
DEFINE _cnt		       SMALLINT;
DEFINE _monto		   DEC(16,2);
DEFINE _cedula		   CHAR(30);
DEFINE _cod_pagador    CHAR(10);
DEFINE v_documento     CHAR(20);
DEFINE _vigencia_final DATE;
DEFINE _nombre_pagador CHAR(100);

SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT h.no_cuenta
   INTO _no_cuenta
   FROM cobcutas c, cobcuhab h
  WHERE c.no_cuenta = h.no_cuenta
    AND c.periodo   = a_periodo
	AND c.procesar  = 1
  GROUP BY h.no_cuenta
  ORDER BY h.no_cuenta

  SELECT cod_pagador,
		 nombre
    INTO _cod_pagador,
	     _nombre_pagador
    FROM cobcuhab
   WHERE no_cuenta = _no_cuenta;

  LET _cedula = null;

  SELECT cedula
    INTO _cedula
    FROM cliclien
   WHERE cod_cliente = _cod_pagador;

  IF _cedula IS NULL THEN
	RETURN _no_cuenta,
		   _nombre_pagador,
		   _cod_pagador
		   WITH RESUME;
		   	
  END IF
END FOREACH
END PROCEDURE