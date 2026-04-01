-- Verificacion de Facturas para Primas por Cobrar

DROP PROCEDURE sp_par31;

CREATE PROCEDURE "informix".sp_par31() 
returning char(2),
		  char(5),
		  char(10),
		  dec(16,2),
		  dec(16,2),
		  char(100);	

define _numfact		char(5);
define _sucursal	char(2);
define _primafact	dec(16,2);
define _itbmfact	dec(16,2);
define _totalfact	dec(16,2);

define _no_factura	char(10);
define _prima_neta	dec(16,2);
define _impuesto	dec(16,2);
define _prima_bruta	dec(16,2);

--set debug file to "sp_par31.trc";
--trace on;

FOREACH
 SELECT numfact,
        sucursal,
		primafact,
		itbmfact,
		totalfact
   INTO _numfact,
        _sucursal,
		_primafact,
		_itbmfact,
		_totalfact
   FROM facturas
  order by sucursal, numfact

	let _no_factura = trim(_sucursal) || "-" || trim(_numfact);

	begin
	on exception in (-284)
		return _sucursal,
		       _numfact,
		       "",
			   _primafact,
		       0,
		       "05 - Factura Duplicada en endedmae"
		       with resume;
	end exception
		select prima_neta,
		       impuesto,
		       prima_bruta
		  into _prima_neta,
		       _impuesto,
		       _prima_bruta
		  from endedmae
		 where no_factura = _no_factura;
	end 
		 
	 if _prima_neta is null then
		return _sucursal,
		       _numfact,
		       "",
			   _primafact,
		       0,
		       "06 - No existe la factura en endedmae"
		       with resume;
	elif _primafact <> _prima_neta then		 	  	
		if abs(_primafact - _prima_neta) <= 0.05 then		
			return _sucursal,
			       _numfact,
			       _no_factura,
				   _primafact,
			       _prima_neta,
			       "02 - 1 Primas Netas Diferentes (Menos de 0.05)"
			       with resume;
		else
			return _sucursal,
			       _numfact,
			       _no_factura,
				   _primafact,
			       _prima_neta,
			       "02 - 2 Primas Netas Diferentes (Mas de 0.05)"
			       with resume;
		end if
	elif _totalfact <> _prima_bruta then		 	  	
		return _sucursal,
		       _numfact,
		       _no_factura,
			   _totalfact,
		       _prima_bruta,
		       "03 - Primas Brutas Diferentes"
		       with resume;
	elif _itbmfact <> _impuesto then		 	  	
		return _sucursal,
		       _numfact,
		       _no_factura,
			   _itbmfact,
		       _impuesto,
		       "04 - Imuestos Diferentes"
		       with resume;
	end if
	       	
end foreach

END PROCEDURE 

