-- Procedimiento que Graba el Asiento de la Remesa de los auxiliares

-- Creado    : 10/03/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - sp_par203 - DEIVID, S.A.

--DROP PROCEDURE sp_sis86;		

CREATE PROCEDURE "informix".sp_sis86(
a_no_remesa	CHAR(10), 
a_renglon   SMALLINT, 
a_cuenta    CHAR(25),
a_cod_aux	char(5), 
a_debito    DEC(16,2),
a_credito   DEC(16,2)
)

define _cantidad	smallint;

select count(*)
  into _cantidad
  from cobasiau
 WHERE no_remesa 	= a_no_remesa
   AND renglon   	= a_renglon
   AND cuenta 	 	= a_cuenta
   and cod_auxiliar = a_cod_aux;

if _cantidad = 0 then

	INSERT INTO cobasiau(
	no_remesa,
	renglon,
	cuenta,
	cod_auxiliar,
	debito,
	credito
	)
	VALUES(
	a_no_remesa,
	a_renglon,
	a_cuenta,
	a_cod_aux,
	a_debito,
	a_credito
	);

else

	UPDATE cobasiau
	   SET debito 	 	= debito  + a_debito,
	       credito 	 	= credito + a_credito
	 WHERE no_remesa 	= a_no_remesa
	   AND renglon   	= a_renglon
	   AND cuenta 	 	= a_cuenta
	   and cod_auxiliar = a_cod_aux;

end if

END PROCEDURE;
