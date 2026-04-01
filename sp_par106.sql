drop procedure sp_par106;

create procedure "informix".sp_par106(a_no_documento char(20))
returning dec(16,2);

define _prima_bruta		dec(16,2);
define _prima_neta		dec(16,2);
define _impuesto		dec(16,2);
define _impuesto_calc	dec(16,2);
define _prima_calc		dec(16,2);
define _no_poliza		char(10);
define _tiene_impuesto	smallint;
define _porc_impuesto	dec(16,2);
define _no_documento	char(20); 
define _no_recibo		char(10); 

define _no_remesa		char(10);
define _renglon 		smallint;


{
foreach
 select monto, 
        prima_neta,
		impuesto,
		doc_remesa,
		no_poliza,
		no_recibo,
		no_remesa,
		renglon
   into	_prima_bruta,
		_prima_neta,
		_impuesto,
		_no_documento,
		_no_poliza,
		_no_recibo,
		_no_remesa,
		_renglon
   from cobredet
  where actualizado = 1
    and tipo_mov    in ("P", "N")
    and doc_remesa  = a_no_documento
}

	let _no_poliza = sp_sis21(a_no_documento);

	select tiene_impuesto
	  into _tiene_impuesto
	  from emipomae
	 where no_poliza = _no_poliza;

	if _tiene_impuesto = 1 then

		select sum(i.factor_impuesto)
		  into _porc_impuesto
		  from emipolim p, prdimpue i
		 where p.cod_impuesto = i.cod_impuesto
		   and p.no_poliza    = _no_poliza;
	else
		
		let _porc_impuesto = 0.00;

	end if	

	if _porc_impuesto is null then
		let _porc_impuesto = 0.00;
	end if
	
	let _porc_impuesto = 1 + (_porc_impuesto/100) ;

{
	let _no_recibo    = "";
	let _no_documento = a_no_documento;

	let _prima_calc    = _prima_bruta / _porc_impuesto;
	let _impuesto_calc = _prima_bruta - _prima_calc;	    
}
{
	if _prima_neta <> _prima_calc then

		return _no_documento,
		       _no_recibo,
		       _prima_bruta,
		       _prima_neta,
		       _prima_calc,
			   _porc_impuesto
		       with resume;	
}
		return _porc_impuesto;	

--	end if

--end foreach
   
end procedure