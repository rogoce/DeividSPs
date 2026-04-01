-- Cargar Porcentajes de Gasto de Administracion, Adquisicion y Contrato XLS
-- 
-- Creado    : 08/03/2004 - Autor: Demetrio Hurtado Almanza
-- Modificado: 08/03/2004 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 d_- DEIVID, S.A.

--DROP PROCEDURE sp_sis52;

CREATE PROCEDURE "informix".sp_sis52()
returning char(10),
		  char(10),
		  char(5),
		  char(5),
		  char(3);

define _no_factura		char(10);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _cod_contrato 	char(5);
define _cod_cober_reas  char(3);
define _cantidad		integer;
define _tipo_contrato	integer;

define _prima_sus		dec(16,2);
define _prima_rea		dec(16,2);
define _prima_cont		dec(16,2);

foreach
 select no_factura,
		no_poliza,
		no_endoso,
		prima_suscrita
   into _no_factura,
		_no_poliza,
		_no_endoso,
		_prima_sus
   from endedmae
  where actualizado = 1
    and periodo = "2004-01"

	let _prima_rea = 0.00;

   foreach
	select cod_contrato,
	       cod_cober_reas,
		   prima
	  into _cod_contrato,
	       _cod_cober_reas,
		   _prima_cont
	  from emifacon
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso

	    SELECT tipo_contrato
	      INTO _tipo_contrato
	      FROM reacomae
	     WHERE cod_contrato = _cod_contrato;

	    IF _tipo_contrato = 1 THEN	  --Retencion

	       LET _prima_rea = _prima_rea + _prima_cont;

	    ELIF _tipo_contrato = 3 THEN --facult.

	       LET _prima_rea = _prima_rea + _prima_cont;

	    ELSE 

	       LET _prima_rea = _prima_rea + _prima_cont;

	    END IF

{
		select count(*)
		  into _cantidad
		  from reacocob
		 where cod_contrato = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;

		if _cantidad = 0 then

			return _no_factura,
			       _no_poliza,
				   _no_endoso,
				   _cod_contrato,
				   _cod_cober_reas
				   with resume;
	
		end if
}

	end foreach

	if _prima_sus <> _prima_rea then

		return _no_factura,
		       _no_poliza,
			   _no_endoso,
			   _cod_contrato,
			   _cod_cober_reas
			   with resume;

	end if


end foreach

end procedure
