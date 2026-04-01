-- Procedimiento que Carga el Incurridos netos de los Reclamos 
-- en un Periodo Dado
--
-- Creado    : 10/06/2014 - Autor: ANGEL TELLO
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE ap_rec01b2;

CREATE PROCEDURE informix.ap_rec01b2(
a_compania  CHAR(3), 
a_agencia   CHAR(3), 
a_periodo1  CHAR(7), 
a_periodo2  CHAR(7), 
a_sucursal  CHAR(255) DEFAULT "*",
a_ajustador CHAR(255) DEFAULT "*",
a_agente    CHAR(255) DEFAULT "*"
) RETURNING CHAR(50),
			CHAR(50),
			CHAR(18),
			char(10),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2),
			DECIMAL(16,2);
			
	   		

DEFINE v_ramo_nombre     CHAR(50);
DEFINE v_compania_nombre CHAR(50);
DEFINE _tipo             CHAR(1);
DEFINE v_saber           CHAR(3);
DEFINE v_doc_reclamo     CHAR(18);
DEFINE v_pagado_total    DECIMAL(16,2);
DEFINE v_pagado_bruto    DECIMAL(16,2);
DEFINE v_pagado_neto     DECIMAL(16,2);
DEFINE v_reserva_bruto   DECIMAL(16,2);
DEFINE v_reserva_neto    DECIMAL(16,2);
DEFINE v_reserva_recup   DECIMAL(16,2);
DEFINE v_incurrido_bruto DECIMAL(16,2);
DEFINE v_pagado_bruto1   DECIMAL(16,2);
DEFINE v_salv_bruto		 DECIMAL(16,2);
DEFINE v_recupero_bruto	 DECIMAL(16,2);
DEFINE v_dec_bruto		 DECIMAL(16,2);
DEFINE v_incurrido_bru   DECIMAL(16,2);
DEFINE _tri				 CHAR(255);
DEFINE _cod_ramo		 CHAR(3);
define _numrecla         CHAR(18);
define _no_tranrec       CHAR(10);


LET v_compania_nombre = sp_sis01(a_compania);

LET _tri = sp_rec01d(a_compania, a_agencia, a_periodo1, a_periodo2);

FOREACH
 SELECT cod_ramo,	
        numrecla, 
		no_tranrec,
		sum(incurrido_bruto),
		sum(pagado_bruto),
		sum(reserva_bruto),
		sum(reserva_neto),
		sum(pagado_bruto1),
		sum(salvamento_bruto),
		sum(recupero_bruto),
		sum(deducible_bruto),
		sum(incurrido_bruto)
   INTO	_cod_ramo,	
        _numrecla,   
		_no_tranrec,
		v_incurrido_bruto,
		v_pagado_bruto,
		v_reserva_bruto,
		v_reserva_neto,
		v_pagado_bruto1,
		v_salv_bruto,
		v_recupero_bruto,
		v_dec_bruto,
		v_incurrido_bru
   FROM tmp_sinis 
  GROUP BY cod_ramo, numrecla, no_tranrec
  ORDER BY cod_ramo, numrecla, no_tranrec
	
	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	let v_reserva_recup = v_reserva_bruto - v_reserva_neto;

	RETURN v_ramo_nombre,		--1
		   v_compania_nombre,	--2
		   _numrecla,
		   _no_tranrec,
		   v_pagado_bruto1,		--3
		   v_dec_bruto,			--4
		   v_salv_bruto,		--5
		   v_recupero_bruto,	--6
		   v_reserva_neto,		--7
		   v_reserva_bruto,		--8
		   v_reserva_recup,		--9
		   v_incurrido_bru		--10
		   WITH RESUME;

END FOREACH
DROP TABLE tmp_sinis;
END PROCEDURE;