-- Verificacion de Renovacion de Diferidas

DROP PROCEDURE sp_par25;

CREATE PROCEDURE "informix".sp_par25() 
returning char(5), 
		  char(2), 
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(10),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(10),
		  char(5);

define _numfact        	char(5);  
define _sucursal       	char(2);  
define _no_factura     	char(10); 
define _primasus       	dec(16,2);
define _prima_suscrita 	dec(16,2);
define _primafact      	dec(16,2);
define _itbmfact       	dec(16,2);
define _totalfact      	dec(16,2);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _retenporce		dec(7,4);
define _porc_reas		dec(7,4);
define _no_unidad       char(5);
define _cod_cober_reas  char(3);
define _tipofact        char(10);
define _coasegporc		dec(16,2);

define _prima_neta	 	dec(16,2);
define _impuesto	 	dec(16,2);
define _prima_bruta	 	dec(16,2);

define _contador        integer;

--set debug file to "sp_par25.trc";

foreach
 select numfact,
        sucursal,
		primcedida,
		primafact,
		itbmfact,
		totalfact,
		retenporce,
		tipofact,
		coasegporc
   into _numfact,
        _sucursal,
		_primasus,
		_primafact,
		_itbmfact,
		_totalfact,
		_retenporce,
		_tipofact,
		_coasegporc
   from facturas
--  where tipofact   = "RENV. DIF."
--  and retenporce = 100
--	and numfact    = "01759"
  order by sucursal, numfact

	if _coasegporc = 0 then
		let _coasegporc = 100;
	end if
	  	
	LET _no_factura = trim(_sucursal) || "-" || trim(_numfact);

	select count(*)
	  into _contador
	  from endedmae
	 where no_factura = _no_factura;

	if _contador is null or
	   _contador = 0     or
	   _contador > 1     then
		continue foreach;
	end if

	select no_poliza,
	       no_endoso,
		   prima_neta,
		   impuesto,
		   prima_bruta
	  into _no_poliza,
	       _no_endoso,
		   _prima_neta,
		   _impuesto,
		   _prima_bruta
	  from endedmae
	 where no_factura = _no_factura;

	if _primafact <> _prima_neta then

			{
			update endedmae
			   set prima_neta     = _primafact,
			       impuesto       = _itbmfact,
				   prima_bruta    = _totalfact,
				   tiene_impuesto = 1
			 where no_poliza      = _no_poliza
			   and no_endoso      = _no_endoso;
			--}
	
			return _numfact, 
				   _sucursal, 
				   _primafact,
				   _itbmfact,
				   _totalfact,
				   _no_factura,
				   _prima_neta,
				   _impuesto,
				   _prima_bruta,
				   _no_poliza,
				   _no_endoso
				   with resume;

		end if

end foreach

END PROCEDURE;

{
update endedmae
   set prima_neta  = _primafact,
       impuesto    = _itbmfact,
	   prima_bruta = _totalfact
 where no_factura  = _no_factura;  
--}
{
   foreach
	SELECT no_unidad,
	       cod_cober_reas,
		   SUM(e.prima),
		   SUM(e.porc_partic_prima)	
	  INTO _no_unidad,
	       _cod_cober_reas,
	       _prima_suscrita,
		   _porc_reas	
	  FROM emifacon	e
	 WHERE e.no_poliza     = _no_poliza
	   AND e.no_endoso     = _no_endoso
	 group by 1, 2

--	if abs(_primasus - _prima_suscrita) > 0.01 then
		if _porc_reas <> 100 then

			--CALL sp_par12(_no_poliza, _no_endoso);

			return _numfact, 
				   _sucursal, 
				   _no_factura,
				   _primafact,
				   _primasus,
				   _no_poliza,
				   _no_endoso,
				   _retenporce,
				   _porc_reas,
				   _prima_suscrita, 
				   _prima_neta
				   with resume;

		end if

	end foreach
}