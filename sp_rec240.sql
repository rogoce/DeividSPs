-- Procedimiento que Carga el Incurridos netos de los Reclamos 
-- en un Periodo Dado
--
-- Creado    : 10/06/2014 - Autor: ANGEL TELLO
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec240;

CREATE PROCEDURE informix.sp_rec240(
a_compania  CHAR(3), 
a_agencia   CHAR(3), 
a_periodo1  CHAR(7), 
a_periodo2  CHAR(7), 
a_sucursal  CHAR(255) DEFAULT "*",
a_ajustador CHAR(255) DEFAULT "*",
a_agente    CHAR(255) DEFAULT "*"
) RETURNING CHAR(50),
			CHAR(50),
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

define _no_reclamo		 char(10);
define _no_tranrec		 char(10);
define _monto_asien 	 dec(16,2);
define _monto_asien_553	 dec(16,2);
define _monto_asien_221	 dec(16,2);

LET v_compania_nombre = sp_sis01(a_compania);

LET _tri = sp_rec01d(a_compania, a_agencia, a_periodo1, a_periodo2);

FOREACH
 SELECT no_reclamo,		
		sum(incurrido_bruto),
		sum(pagado_bruto),
		sum(reserva_bruto),
		sum(reserva_neto),
		sum(pagado_bruto1),
		sum(salvamento_bruto),
		sum(recupero_bruto),
		sum(deducible_bruto),
		sum(incurrido_bruto)
   INTO	_no_reclamo,			
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
  GROUP BY no_reclamo
  ORDER BY no_reclamo

		
--	SELECT nombre
--	  INTO v_ramo_nombre
--	  FROM prdramo
--	 WHERE cod_ramo = _cod_ramo;

	let v_reserva_recup = v_reserva_bruto - v_reserva_neto;

	let _monto_asien_553 = 0;
	let _monto_asien_221 = 0;

	foreach
	 select no_tranrec
	   into _no_tranrec
	   from rectrmae
	  where no_reclamo  = _no_reclamo
	    and actualizado = 1
		and periodo     = a_periodo1

		let _monto_asien = 0;

		select sum(debito + credito)
		  into _monto_asien
		  from recasien
		 where no_tranrec  = _no_tranrec
		   and cuenta[1,3] = "553";
	
		if _monto_asien is null then
			let _monto_asien = 0;
		end if
		 
		let _monto_asien_553 = _monto_asien_553 + _monto_asien;

		let _monto_asien = 0;

		select sum(debito + credito)
		  into _monto_asien
		  from recasien
		 where no_tranrec  = _no_tranrec
		   and cuenta[1,3] = "221";

		if _monto_asien is null then
			let _monto_asien = 0;
		end if

		let _monto_asien_221 = _monto_asien_221 + (_monto_asien * -1);

	end foreach

	{
	if _monto_asien_553 <> v_reserva_neto then

		RETURN _no_reclamo,
			   "553",
			   0,
			   0,
			   0,
			   0,
			   v_reserva_neto,
			   _monto_asien_553,
			   0,
			   0
			   WITH RESUME;

	end if
	}

	--{
	if _monto_asien_221 <> v_reserva_bruto then

		RETURN _no_reclamo,
			   "221",
			   0,
			   0,
			   0,
			   v_reserva_bruto,
			   _monto_asien_221,
			   0,
			   0,
			   0
			   WITH RESUME;

	end if
	--}

END FOREACH

RETURN "0",
	   "",
	   0,
	   0,
	   0,
	   0,
	   0,
	   0,
	   0,
	   0
	   WITH RESUME;


DROP TABLE tmp_sinis;

END PROCEDURE;