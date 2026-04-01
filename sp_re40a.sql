-- Detalle de Coberturas y Detalle de Pago para el Informe de Estatus del Reclamo
-- Creado    : 17/01/2001 - Autor: Marquelda Valdelamar
-- Modificado: 22/01/2001 - Autor: Marquelda Valdelamar
-- Modificado: 27/11/2001 - Autor: Armando Moreno M. para sacar el deducuble pagado
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_re40a;

CREATE PROCEDURE "informix".sp_re40a(
a_compania     CHAR(3),
a_sucursal     CHAR(3),   
a_numrecla     CHAR(18)
)
RETURNING CHAR(50),      -- nombre_concepto
		  DEC(16,2),     -- monto_concepto
		  DEC(16,2)		 -- ded pagado
		  	  		         
DEFINE _cod_concepto		CHAR(3);
DEFINE _nombre_concepto     CHAR(50);
DEFINE _monto_concepto      DECIMAL(16,2);
DEFINE _tipo_concepto       INT;
DEFINE _ded_pagado          DECIMAL(16,2);
DEFINE _descuenta_ded       DECIMAL(16,2);
DEFINE _monto_ded           DECIMAL(16,2);
DEFINE _devol_ded           DECIMAL(16,2);
DEFINE _no_reclamo			CHAR(10);

LET _ded_pagado    = 0;
LET _descuenta_ded = 0;
LET _monto_ded 	   = 0;
LET _devol_ded     = 0;

--Monto de deducible
SELECT SUM(r.monto)
  INTO _monto_ded
  FROM rectrmae r, rectitra t
 WHERE r.numrecla         = a_numrecla
   AND r.cod_tipotran     = t.cod_tipotran
   AND t.tipo_transaccion = 7	--ded
   AND r.actualizado      = 1;

IF _monto_ded IS NULL THEN
	LET _monto_ded = 0;
END IF

select no_reclamo
  into _no_reclamo
  from recrcmae
 where numrecla    = a_numrecla
   and actualizado = 1;

--Detalle de Pago
FOREACH
	SELECT c.cod_concepto,
    	   SUM(c.monto)
	  INTO _cod_concepto,
           _monto_concepto
      FROM rectrcon c, rectrmae t
     WHERE c.no_tranrec   = t.no_tranrec
	   AND t.no_reclamo   = _no_reclamo
	   AND t.actualizado  = 1
	 GROUP BY cod_concepto

	  IF _monto_concepto IS NULL THEN
	  	LET _monto_concepto = 0;
	  END IF

	SELECT nombre,
	       tipo_concepto
	  INTO _nombre_concepto,
	       _tipo_concepto
	  FROM recconce
	 WHERE cod_concepto = _cod_concepto;

   	IF _tipo_concepto = 2 THEN	--desc. ded.
		LET _descuenta_ded = _monto_concepto;
	END IF

   	IF _tipo_concepto = 3 THEN	--devol. de ded.
		LET _devol_ded = _monto_concepto;
	END IF

	LET _ded_pagado = _monto_ded + _descuenta_ded + _devol_ded;
	LET _ded_pagado = _ded_pagado * -1;
	RETURN _nombre_concepto,
   		   _monto_concepto,
		   _ded_pagado
   		   WITH RESUME;

END FOREACH;

END PROCEDURE;