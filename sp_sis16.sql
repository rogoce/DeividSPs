-- Procedimiento que Graba el Asiento de la Remesa

-- Creado    : 31/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 31/10/2000 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - sp_par203 - DEIVID, S.A.

DROP PROCEDURE sp_sis16;		

CREATE PROCEDURE "informix".sp_sis16(
a_no_remesa	CHAR(10), 
a_renglon   SMALLINT, 
a_cuenta    CHAR(25), 
a_debito    DEC(16,2),
a_credito   DEC(16,2)
)

define _cantidad	smallint;

select count(*)
  into _cantidad
  from cobasien
 WHERE no_remesa = a_no_remesa
   AND renglon   = a_renglon
   AND cuenta 	 = a_cuenta;

if _cantidad = 0 then

	INSERT INTO cobasien(
	no_remesa,
	renglon,
	cuenta,
	debito,
	credito
	)
	VALUES(
	a_no_remesa,
	a_renglon,
	a_cuenta,
	a_debito,
	a_credito
	);

else

	UPDATE cobasien
	   SET debito 	 = debito  + a_debito,
	       credito 	 = credito + a_credito
	 WHERE no_remesa = a_no_remesa
	   AND renglon   = a_renglon
	   AND cuenta 	 = a_cuenta;

end if

END PROCEDURE;
