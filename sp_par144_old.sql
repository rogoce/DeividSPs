-- Procedimiento que Graba el Asiento de la Factura

-- Creado    : 25/10/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 25/10/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par144;		

CREATE PROCEDURE "informix".sp_par144(
a_no_poliza	CHAR(10), 
a_no_endoso CHAr(5), 
a_cuenta    CHAR(25), 
a_debito    DEC(16,2),
a_credito   DEC(16,2),
a_cod_lider	char(3)
)

define _porc_total		dec(16,4);
define _porc_coas		dec(16,4);
define _porc_calc		dec(16,4);
define _debito      	dec(16,2);
define _credito     	dec(16,2);
define _cod_auxiliar	char(5);
define _cod_coasegur	char(3);
define _monto	     	dec(16,2);

select sum(porc_partic_coas)
  into _porc_total
  from endcoama
 where no_poliza    =  a_no_poliza
   and no_endoso    =  a_no_endoso
   and cod_coasegur <> a_cod_lider;

foreach
 select porc_partic_coas,
	    cod_coasegur
   into _porc_coas,
        _cod_coasegur
   from endcoama
  where no_poliza    =  a_no_poliza
    and no_endoso    =  a_no_endoso
	and cod_coasegur <> a_cod_lider

	select cod_auxiliar
	  into _cod_auxiliar
	  from emicoase
	 where cod_coasegur = _cod_coasegur;

	let _porc_calc = _porc_coas / _porc_total;
	let _debito    = a_debito   * _porc_calc;
	let _credito   = a_credito  * _porc_calc;
		 
	BEGIN
	ON EXCEPTION IN(-268)

		UPDATE endasiau
		   SET debito 	    = debito  + _debito,
		       credito 	    = credito + _credito
		 WHERE no_poliza    = a_no_poliza
		   AND no_endoso    = a_no_endoso
		   AND cuenta 	    = a_cuenta
		   and cod_auxiliar = _cod_auxiliar;

	END EXCEPTION

		INSERT INTO endasiau(
		no_poliza,
		no_endoso,
		cuenta,
		cod_auxiliar,
		debito,
		credito
		)
		VALUES(
		a_no_poliza,
		a_no_endoso,
		a_cuenta,
		_cod_auxiliar,
		_debito,
		_credito
		);

	END 

end foreach

select sum(debito),
       sum(credito)
  into _debito,
       _credito
  from endasiau
 WHERE no_poliza = a_no_poliza
   AND no_endoso = a_no_endoso
   AND cuenta 	 = a_cuenta;

let _monto = a_debito - _debito;

if _monto <> 0.00 then

	UPDATE endasiau
	   SET debito 	    = debito + _monto
	 WHERE no_poliza    = a_no_poliza
	   AND no_endoso    = a_no_endoso
	   AND cuenta 	    = a_cuenta
	   and cod_auxiliar = _cod_auxiliar;

end if

let _monto = a_credito - _credito;

if _monto <> 0.00 then

	UPDATE endasiau
	   SET credito 	    = credito + _monto
	 WHERE no_poliza    = a_no_poliza
	   AND no_endoso    = a_no_endoso
	   AND cuenta 	    = a_cuenta
	   and cod_auxiliar = _cod_auxiliar;

end if

END PROCEDURE;
