drop procedure sp_par267;

create procedure "informix".sp_par267()
returning char(10),
          char(5),
		  char(20),
		  char(5),
		  char(1),
		  smallint,
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _no_poliza		char(10);

define _no_unidad	    char(5);
define _no_documento    char(20);
define _cod_producto    char(5);
define _cod_perpago     char(3);
define _estatus_poliza  char(1);
define _prima_vida_calc	dec(16,2);
define _prima_vida_orig	dec(16,2);
define _prima_vida_p	dec(16,2);
define _prima_vida		dec(16,2);
define _no_pagos	    smallint;
define _meses			smallint;

set isolation to dirty read;

let _no_documento = '';

FOREACH
	SELECT Emipouni.no_poliza, 
	       Emipouni.no_unidad, 
	       Emipomae.no_documento,
	       Emipouni.cod_producto, 
	       Emipomae.estatus_poliza, 
	       Emipomae.no_pagos,
		   Emipomae.cod_perpago,
	       Emipouni.prima_vida, 
	       Emipouni.prima_vida_orig, 
	       Prdtaeda.prima_vida
	  INTO _no_poliza,
	       _no_unidad,
		   _no_documento,
		   _cod_producto,
		   _estatus_poliza,
		   _no_pagos,
		   _cod_perpago,
		   _prima_vida,
		   _prima_vida_orig,
		   _prima_vida_p
	  FROM prdtaeda Prdtaeda, emipouni Emipouni, emipomae Emipomae
	 WHERE Emipouni.cod_producto = Prdtaeda.cod_producto
	   AND Emipomae.no_poliza = Emipouni.no_poliza
	   AND Prdtaeda.prima_vida <> 0.00
	   AND Emipomae.actualizado = 1
	   AND Emipomae.estatus_poliza <> "2"
	   and emipouni.activo = 1
	 GROUP BY Emipouni.no_poliza, Emipouni.no_unidad,
	  Emipomae.no_documento, Emipouni.cod_producto, Emipomae.estatus_poliza,
	  Emipomae.no_pagos, Emipomae.cod_perpago, Emipouni.prima_vida, Emipouni.prima_vida_orig,
	  Prdtaeda.prima_vida
	 ORDER BY Emipomae.no_documento

	select meses
	  into _meses
	  from cobperpa
	 where cod_perpago = _cod_perpago;

	if _meses = 0 then
		let _meses = 1;
	end if

    let _prima_vida_calc = _prima_vida_p * _meses;

    If (_prima_vida_calc - _prima_vida) <> 0 Then

		return _no_poliza,
		       _no_unidad,
			   _no_documento,
			   _cod_producto,
			   _estatus_poliza,
			   _no_pagos,
			   _prima_vida,
			   _prima_vida_orig,
			   _prima_vida_p,
			   _prima_vida_calc
			   with resume;
	 End If
END FOREACH

END PROCEDURE