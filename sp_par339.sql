-- Procedimiento que Graba el Asiento de la Factura a Nivel de Auxiliar

-- Creado    : 13/18/2013 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_par339;		

CREATE PROCEDURE "informix".sp_par339(
a_no_poliza		char(10), 
a_no_endoso 	char(5), 
a_cuenta    	char(25), 
a_debito    	dec(16,2),
a_credito   	dec(16,2),
a_cod_auxiliar	char(5),
a_tipo_comp		smallint
)

BEGIN
ON EXCEPTION IN(-268)

	UPDATE endasiau
	   SET debito 	    = debito  + a_debito,
	       credito 	    = credito + a_credito
	 WHERE no_poliza    = a_no_poliza
	   AND no_endoso    = a_no_endoso
	   AND cuenta 	    = a_cuenta
	   and cod_auxiliar = a_cod_auxiliar
	   and tipo_comp    = a_tipo_comp;

END EXCEPTION

	INSERT INTO endasiau(
	no_poliza,
	no_endoso,
	cuenta,
	cod_auxiliar,
	debito,
	credito,
	tipo_comp
	)
	VALUES(
	a_no_poliza,
	a_no_endoso,
	a_cuenta,
	a_cod_auxiliar,
	a_debito,
	a_credito,
	a_tipo_comp
	);

END 

END PROCEDURE;
