drop procedure sp_par114;

create procedure "informix".sp_par114()
returning smallint;

define _prima_suscrita_endoso	dec(16,2);
define _prima_suscrita_unidad	dec(16,2);
define _prima_emifacon			dec(16,2);

define _prima					dec(16,2);
define _descuento				dec(16,2);
define _recargo					dec(16,2);
define _prima_neta				dec(16,2);
define _impuesto				dec(16,2);
define _prima_bruta				dec(16,2);
define _prima_retenida			dec(16,2);

define _prima_u					dec(16,2);
define _descuento_u				dec(16,2);
define _recargo_u				dec(16,2);
define _prima_neta_u			dec(16,2);
define _impuesto_u				dec(16,2);
define _prima_bruta_u			dec(16,2);
define _prima_retenida_u		dec(16,2);

define _no_poliza				char(10);
define _no_endoso				char(5);
define _no_factura				char(10);
define _no_unidad				char(5);
define _cod_tipoprod			char(3);
define _porc_partic_coas		dec(16,4);
define _monto					dec(16,2);
define _porc_impuesto			dec(16,2);
define _porc_descuento			dec(16,2);
define _centavo					dec(16,2);

define _cantidad				integer;
define _cant_desc				integer;
define _error					integer;

define _prima_uni_1				dec(16,2);
define _prima_uni_2				dec(16,2);
define _cod_ramo				char(3);
define _periodo					char(7);
define _cod_endomov				char(3);
define _cod_tipocalc			char(3);

set isolation to dirty read;

delete from endhisfa;

let _error    = 0;

foreach
 select prima_suscrita,
        no_poliza,
		no_endoso,
		no_factura,
		prima,
		descuento,
		recargo,
		prima_neta,
		impuesto,
		prima_bruta,
		prima_retenida,
		periodo,
		cod_endomov,
		cod_tipocalc
   into _prima_suscrita_endoso,
        _no_poliza,
		_no_endoso,
		_no_factura,
		_prima,
		_descuento,
		_recargo,
		_prima_neta,
		_impuesto,
		_prima_bruta,
		_prima_retenida,
		_periodo,
		_cod_endomov,
		_cod_tipocalc
   from endedhis
  where periodo = "2006-01"

	if _no_factura is null then
		let _no_factura = trim(_no_endoso) || "-" || _no_endoso;
	end if

	insert into endhisfa
	values (_no_factura);

	select cod_tipoprod,
	       cod_ramo
	  into _cod_tipoprod,
	       _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select sum(prima_suscrita),
	       sum(prima_retenida),
		   sum(prima),
		   sum(descuento),
		   sum(recargo),
		   sum(prima_neta),
		   sum(impuesto),
		   sum(prima_bruta)
	  into _prima_suscrita_unidad,
	       _prima_retenida_u,
		   _prima_u,
		   _descuento_u,
		   _recargo_u,
		   _prima_neta_u,
		   _impuesto_u,
		   _prima_bruta_u
	  from endeduni
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	if _prima_suscrita_unidad is null then
		let _prima_suscrita_unidad = 0.00;
	end if
	
	if _prima_retenida_u is null then
		let _prima_retenida_u = 0.00;
	end if

	if _prima_u is null then
		let _prima_u = 0.00;
	end if

	if _descuento_u is null then
		let _descuento_u = 0.00;
	end if

	if _recargo_u is null then
		let _recargo_u = 0.00;
	end if

	if _prima_neta_u is null then
		let _prima_neta_u = 0.00;
	end if

	if _impuesto_u is null then
		let _impuesto_u = 0.00;
	end if

	if _prima_bruta_u is null then
		let _prima_bruta_u = 0.00;
	end if

{
	select count(*)
	  into _cantidad
	  from endeduni
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;
}

	if abs(_prima_suscrita_endoso - _prima_suscrita_unidad) > 0.05 then

		let _error = 1;
		continue foreach;

	end if

	if abs(_prima_retenida - _prima_retenida_u) > 0.05 then

		let _error = 1;
		continue foreach;

	end if

	if abs(_prima - _prima_u) > 0.05 then

		let _error = 1;
		continue foreach;

	end if

	if abs(_descuento - _descuento_u) > 0.05 then

		let _error = 1;
		continue foreach;

	end if

	if abs(_recargo - _recargo_u) > 0.05 then

		let _error = 1;
		continue foreach;

	end if

	if abs(_prima_neta - _prima_neta_u) > 0.05 then

		let _error = 1;
		continue foreach;

	end if

	if abs(_impuesto - _impuesto_u) > 0.05 then

		let _error = 1;
		continue foreach;

	end if

	if abs(_prima_bruta - _prima_bruta_u) > 0.05 then

		let _error = 1;
		continue foreach;

	end if

	if abs(_prima - _descuento + _recargo - _prima_neta) > 0.05 then

		let _error = 1;
		continue foreach;

	end if

{
	select sum(prima),
		   sum(descuento),
		   sum(recargo),
		   sum(prima_neta),
		   count(*)
	  into _prima_u,
		   _descuento_u,
		   _recargo_u,
		   _prima_neta_u,
		   _cantidad
	  from endedcob
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	if _prima_u is null then
		let _prima_u = 0.00;
	end if

	if _descuento_u is null then
		let _descuento_u = 0.00;
	end if

	if _recargo_u is null then
		let _recargo_u = 0.00;
	end if

	if _prima_neta_u is null then
		let _prima_neta_u = 0.00;
	end if

	if abs(_prima - _prima_u) > 0.05 then

		let _error = 1;
		return _error;

	end if

	if abs(_descuento - _descuento_u) > 0.05 then

		let _error = 1;
		return _error;

	end if

	if abs(_recargo - _recargo_u) > 0.05 then

		let _error = 1;
		return _error;

	end if

	if abs(_prima_neta - _prima_neta_u) > 0.05 then

		let _error = 1;
		return _error;

	end if

	if _prima_neta_u           = 0     and 
	   _prima_suscrita_endoso <> 0.00  and
	   _cod_endomov           <> "018" then 

		let _error = 1;
		return _error;

	end if
}

	if _cod_endomov            = "018" and
--	   _cantidad              <> 1     and
	   _prima_suscrita_endoso <> 0.00  then 

		let _error = 1;
		continue foreach;

	end if

	delete from endhisfa
	 where no_factura = _no_factura;

end foreach

return _error;

end procedure

