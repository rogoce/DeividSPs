-- Comparacion entre Informe de Cierres y Registros Contables
-- 
-- Creado    : 12/10/2004 - Autor: Marquelda Valdelamar
-- Modificado: 12/10/2004 - Autor: Marquelda Valdelamar.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par115;

CREATE PROCEDURE "informix".sp_par115(a_periodo CHAR(7))
returning char(10),
          char(5),
		  dec(16,2),
		  dec(16,2);

define _prima_suscrita	dec(16,2);
define _impuesto	    dec(16,2);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _cod_tipoprod	char(3);
define _impuesto_5		dec(16,2);
define _impuesto_1		dec(16,2);
define _monto			dec(16,2);

define _cod_impuesto	char(3);

foreach
 select	prima_suscrita,
		impuesto,
		no_poliza,
		no_endoso,
		cod_tipoprod
   into	_prima_suscrita,
        _impuesto,
		_no_poliza,
		_no_endoso,
		_cod_tipoprod
   from endedmae
  where periodo     = a_periodo
	and actualizado = 1

	-- Si es Reaseguro Aumido

	if _cod_tipoprod = "004" then
		continue foreach;
	end if

	-- Calculo de Impuesto para Prima Suscrita	

	let _impuesto_5 = 0.00;
	let _impuesto_1 = 0.00;

	if _impuesto <> 0.00 then

		foreach	
		 select cod_impuesto
		   into _cod_impuesto
		   from endedimp
		  where no_poliza = _no_poliza
		    and no_endoso = _no_endoso
		    
		    if _cod_impuesto = "001" then
		    	let _impuesto_5 = _prima_suscrita * 0.05;
		    else
		    	let _impuesto_1 = _prima_suscrita * 0.01;
		    end if	

		end foreach

	end if

	select sum(debito + credito)
	  into _monto
	  from endasien
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso
	   and cuenta    = "26504";

	if _monto is null then
		let _monto = 0.00;
	end if

	let _impuesto_1 = _impuesto_1 * -1;
	 
	if _monto <> _impuesto_1 then
		
		return _no_poliza,
		       _no_endoso,
			   _monto,
			   _impuesto_1
			   with resume;
			   
	end if

end foreach

end procedure