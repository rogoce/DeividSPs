-- Procedimiento que Graba el Asiento de la Factura

-- Creado    : 25/10/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 25/10/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob219;		

CREATE PROCEDURE "informix".sp_cob219(
a_no_poliza	CHAR(10), 
a_cuenta    CHAR(25), 
a_debito    DEC(16,2),
a_credito   DEC(16,2),
a_tipo_comp	SMALLINT
)

BEGIN
ON EXCEPTION IN(-268)

	UPDATE deivid_tmp:cobincasi
	   SET debito 	 = debito  + a_debito,
	       credito 	 = credito + a_credito
	 WHERE no_poliza = a_no_poliza
	   AND cuenta 	 = a_cuenta
	   and tipo_comp = a_tipo_comp;

END EXCEPTION

	INSERT INTO deivid_tmp:cobincasi(
	no_poliza,
	cuenta,
	debito,
	credito,
	tipo_comp
	)
	VALUES(
	a_no_poliza,
	a_cuenta,
	a_debito,
	a_credito,
	a_tipo_comp
	);

END 

END PROCEDURE;
