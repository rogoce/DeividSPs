-- Procedimiento que Graba el Asiento de la Factura

-- Creado    : 25/10/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 25/10/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par144a;		

CREATE PROCEDURE "informix".sp_par144a(
a_no_poliza	CHAR(10), 
a_no_endoso CHAr(5), 
a_cuenta    CHAR(25), 
a_debito    DEC(16,2),
a_credito   DEC(16,2),
a_cod_lider	char(3),
a_tipo_comp	smallint
)

define _cod_auxiliar	char(5);

select cod_auxiliar
  into _cod_auxiliar
  from emicoase
 where cod_coasegur = a_cod_lider;

if _cod_auxiliar is null then

	let _cod_auxiliar = "RE" || trim(a_cod_lider);

	update emicoase
	   set cod_auxiliar = _cod_auxiliar 
     where cod_coasegur = a_cod_lider;

end if

BEGIN
ON EXCEPTION IN(-268)

	UPDATE dep_endasiau
	   SET debito 	    = debito  + a_debito,
	       credito 	    = credito + a_credito
	 WHERE no_poliza    = a_no_poliza
	   AND no_endoso    = a_no_endoso
	   AND cuenta 	    = a_cuenta
	   and cod_auxiliar = _cod_auxiliar
	   and tipo_comp    = a_tipo_comp;

END EXCEPTION

	INSERT INTO dep_endasiau(
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
	_cod_auxiliar,
	a_debito,
	a_credito,
	a_tipo_comp
	);

END 

END PROCEDURE;
