-- Procedimiento que Carga el Incurridos netos de los Reclamos 
-- en un Periodo Dado
--
-- Creado    : 10/06/2014 - Autor: ANGEL TELLO
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec305;

CREATE PROCEDURE informix.sp_rec305(
a_compania  CHAR(3), 
a_agencia   CHAR(3), 
a_periodo1  CHAR(7), 
a_periodo2  CHAR(7), 
a_sucursal  CHAR(255) DEFAULT "*",
a_ajustador CHAR(255) DEFAULT "*",
a_agente    CHAR(255) DEFAULT "*"
) RETURNING CHAR(50) as ramo,
			CHAR(20) as reclamo,
			DATE as fecha_siniestro,
			VARCHAR(50) as asegurado,
			CHAR(20) as poliza,
			CHAR(5) as unidad,
			CHAR(10) as transaccion,
			DECIMAL(16,2) as pagado_bruto,
			DECIMAL(16,2) as deducible_bruto,
			DECIMAL(16,2) as salvamento_bruto,
			DECIMAL(16,2) as recupero_bruto,
			DECIMAL(16,2) as reserva_neto_553,
			DECIMAL(16,2) as reserva_bruto_221,
			DECIMAL(16,2) as reserva_recup_222;
				   		

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
DEFINE _no_reclamo       CHAR(10);
DEFINE _no_tranrec       CHAR(10);
DEFINE _numrecla         CHAR(20);
DEFINE _cod_cliente      CHAR(10);
DEFINE _doc_poliza		 CHAR(20);
DEFINE _no_unidad        CHAR(5);
DEFINE _fecha_siniestro  DATE;
DEFINE _asegurado        VARCHAR(100);
DEFINE _transaccion      CHAR(10);

LET v_compania_nombre = sp_sis01(a_compania);

LET _tri = sp_rec01d(a_compania, a_agencia, a_periodo1, a_periodo2);

FOREACH
 SELECT cod_ramo,
        no_reclamo,
        no_tranrec,
        numrecla,
        cod_cliente,
        doc_poliza,		
		incurrido_bruto,
		pagado_bruto,
		reserva_bruto,
		reserva_neto,
		pagado_bruto1,
		salvamento_bruto,
		recupero_bruto,
		deducible_bruto,
		incurrido_bruto
   INTO	_cod_ramo,			
        _no_reclamo,
        _no_tranrec,
        _numrecla,
        _cod_cliente,
        _doc_poliza,	
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
  ORDER BY cod_ramo, numrecla   
	
	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;
	 
    SELECT no_unidad,
           fecha_siniestro
      INTO _no_unidad,
           _fecha_siniestro
      FROM recrcmae
     WHERE no_reclamo = _no_reclamo;
   
    SELECT nombre
      INTO _asegurado
      FROM cliclien
     WHERE cod_cliente = _cod_cliente;	  
	 
	SELECT transaccion
	  INTO _transaccion
	  FROM rectrmae
	 WHERE no_tranrec = _no_tranrec;

	let v_reserva_recup = v_reserva_bruto - v_reserva_neto;

	RETURN v_ramo_nombre,		--1
	       _numrecla,
		   _fecha_siniestro,
		   _asegurado,
		   _doc_poliza,
		   _no_unidad,
		   _transaccion,
		   v_pagado_bruto1,		--3
		   v_dec_bruto,			--4
		   v_salv_bruto,		--5
		   v_recupero_bruto,	--6
		   v_reserva_bruto,		--7
		   v_reserva_bruto,		--8
		   v_reserva_recup		--10
		   WITH RESUME;

END FOREACH
DROP TABLE tmp_sinis;
END PROCEDURE;