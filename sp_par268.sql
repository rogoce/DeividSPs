drop procedure sp_par268;

create procedure "informix".sp_par268()
returning char(20),
          char(5),
          dec(16,2);

define _no_documento 	char(20);
define _no_unidad	 	char(5);
define _no_poliza    	char(10);
define _cod_producto 	char(5);
define _prima_vida   	dec(16,2);
define _prima_vida_orig dec(16,2);
define _prima_vida_tr   dec(16,2);
define _prima_compara   dec(16,2);
define _cod_perpago     char(3);
define _error			integer;
define _cantidad		integer;
define _ano				integer;
define _desc			char(50);
define _meses           smallint;

set isolation to dirty read;

FOREACH
	SELECT a.no_poliza, 
	       a.no_unidad, 
	       b.no_documento,
	  	   a.cod_producto, 
	  	   a.prima_vida, 
	  	   a.prima_vida_orig, 
	  	   c.prima_vida,
		   b.cod_perpago
	  INTO _no_poliza, 	
		   _no_unidad,	 	
		   _no_documento,    	
		   _cod_producto, 	
		   _prima_vida,   	
		   _prima_vida_orig,
		   _prima_vida_tr,  
		   _cod_perpago    
	  FROM prdtaeda c, emipouni a, emipomae b
	 WHERE a.cod_producto = c.cod_producto
	   AND b.no_poliza = a.no_poliza
	   AND c.prima_vida <> 0.00
	   AND b.estatus_poliza IN (1, 3)
	   AND b.actualizado = 1
	 GROUP BY a.no_poliza, a.no_unidad, b.no_documento, a.cod_producto, a.prima_vida, a.prima_vida_orig, c.prima_vida, b.cod_perpago 
	 ORDER BY b.no_documento

-- Hasta Aqui las evaluaciones.

	select meses
	  into _meses
	  from cobperpa
	 where cod_perpago = _cod_perpago;

	if _meses = 0 then
		let _meses = 1;
	end if

    let _prima_compara = _prima_vida_tr * _meses;

    If _prima_vida_tr <> _prima_vida_orig Then
		return _no_documento,
		       _no_unidad,
		       _prima_vida_orig
			   with resume;
	End If

    If _prima_compara <> _prima_vida Then
		return _no_documento,
		       _no_unidad,
		       _prima_vida
			   with resume;
	End If


end foreach

return "0",
       "00000",
        0.00;

end procedure