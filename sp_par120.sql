-- Procedimiento que verifica los montos de produccion contra los registros contables
-- 
-- Creado    : 25/11/2004 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par120;		

Create Procedure "informix".sp_par120()
returning char(10),
		  char(10),
		  char(5),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          smallint,
          char(3),
          char(50),
          char(50),
          char(7);

define _no_poliza		char(10);
define _no_endoso		char(10);
define _no_factura		char(10);
define _cod_endomov		char(3);
define _nombre_endomov	char(50);
define _cod_tipoprod	char(3);
define _nombre_tipoprod	char(50);

define _prima_suscrita	dec(16,2);
define _impuesto		dec(16,2);
define _prima_bruta 	dec(16,2);

define _monto			dec(16,2);
define _monto2			dec(16,2);
define _cantidad		smallint;

DEFINE _cod_contrato	CHAR(5);
DEFINE _tipo_contrato   SMALLINT;
define _periodo			char(7);
define _ano				smallint;

set isolation to dirty read;

select par_anofiscal
  into _ano
  from cglparam;

if _ano <= 2007 then
	let _ano = 2008;
end if

foreach
 select no_poliza,
        no_endoso,
		no_factura,
		prima_suscrita,
		impuesto,
		prima_bruta,
		cod_endomov,
		periodo
   into _no_poliza,
        _no_endoso,
		_no_factura,
		_prima_suscrita,
		_impuesto,
		_prima_bruta,
		_cod_endomov,
		_periodo
   from endedmae
  where periodo[1,4] >= _ano
    and actualizado   = 1
	and sac_asientos  = 2
--	and periodo       = "2007-07"

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nombre_tipoprod
	  from emitipro
	 where cod_tipoprod = _cod_tipoprod;

	select nombre
	  into _nombre_endomov
	  from endtimov
	 where cod_endomov = _cod_endomov;

	-- Registros No Cuadran

--{
	let _monto2 = 0.00;

	select sum(debito + credito)
	  into _monto
	  from endasien
	 where no_poliza   = _no_poliza
	   and no_endoso   = _no_endoso;
	
	if _monto is null then
		let _monto = 0.00;
	end if
	
	if _monto2 <> _monto then

		return _no_factura,
			   _no_poliza,
			   _no_endoso,
			   _monto2,
			   _monto,
			   (_monto2 - _monto),
			   0,
			   _cod_endomov,
			   _nombre_endomov,	
			   _nombre_tipoprod,
			   _periodo	
			   with resume;

	end if
--}

	-- Prima Suscrita

	select sum(debito + credito)
	  into _monto
	  from endasien
	 where no_poliza   = _no_poliza
	   and no_endoso   = _no_endoso
	   and cuenta[1,3] = "411";
	
	if _monto is null then
		let _monto = 0.00;
	end if
	
	let _monto = _monto * -1;

	if _prima_suscrita <> _monto then

{
		 update endedmae
			set prima_suscrita = _monto
		  where no_poliza      = _no_poliza
		    and no_endoso      = _no_endoso;

		 update endedhis
			set prima_suscrita = _monto
		  where no_poliza      = _no_poliza
		    and no_endoso      = _no_endoso;
}

		return _no_factura,
			   _no_poliza,
			   _no_endoso,
			   _prima_suscrita,
			   _monto,
			   (_prima_suscrita - _monto),
			   1,
			   _cod_endomov,
			   _nombre_endomov,	
			   _nombre_tipoprod,
			   _periodo	
			   with resume;

	end if

	select count(*)
	  into _cantidad
	  from endasien
	 where no_poliza   = _no_poliza
	   and no_endoso   = _no_endoso;
	
	if _cantidad = 0 then

		if _prima_suscrita <> 0.00 then

			return _no_factura,
				   _no_poliza,
				   _no_endoso,
				   _prima_suscrita,
				   0.00,
				   0.00,
				   3,
				   _cod_endomov,
				   _nombre_endomov,	
				   _nombre_tipoprod,
				   _periodo	
				   with resume;

		end if

	end if

	select count(*)
	  into _cantidad
	  from endasien
	 where no_poliza   = _no_poliza
	   and no_endoso   = _no_endoso
	   and sac_notrx   is null;
	
	if _cantidad <> 0 then

		if _prima_suscrita <> 0.00 then

			return _no_factura,
				   _no_poliza,
				   _no_endoso,
				   _prima_suscrita,
				   0.00,
				   0.00,
				   4,
				   _cod_endomov,
				   _nombre_endomov,	
				   _nombre_tipoprod,
				   _periodo	
				   with resume;

		end if

	end if

{
	-- Impuestos

	let _monto2 = _impuesto;

	select sum(debito + credito)
	  into _monto
	  from endasien
	 where no_poliza   = _no_poliza
	   and no_endoso   = _no_endoso
	   and cuenta[1,3] = "265"
	   and tipo_comp   = 1;
	
	if _monto is null then
		let _monto = 0.00;
	end if
	
	let _monto = _monto * -1;

	if _monto2 <> _monto then

		return _no_factura,
			   _no_poliza,
			   _no_endoso,
			   _monto2,
			   _monto,
			   (_monto2 - _monto),
			   2,
			   _cod_endomov,
			   _nombre_endomov,	
			   _nombre_tipoprod,
			   _periodo	
			   with resume;

	end if

	-- Prima Bruta

	let _monto2 = _prima_bruta;

	select sum(debito + credito)
	  into _monto
	  from endasien
	 where no_poliza   = _no_poliza
	   and no_endoso   = _no_endoso
	   and cuenta[1,3] in ("131","144")
	   and tipo_comp   = 1;
	
	if _monto is null then
		let _monto = 0.00;
	end if
	
	if _monto2 <> _monto then

		return _no_factura,
			   _no_poliza,
			   _no_endoso,
			   _monto2,
			   _monto,
			   (_monto2 - _monto),
			   3,
			   _cod_endomov,
			   _nombre_endomov,	
			   _nombre_tipoprod,
			   _periodo	
			   with resume;

	end if
}

	-- Reserva Estadistica

{
	Foreach
	 Select cod_contrato,
	        sum(prima)
--			cod_cober_reas,
--			no_unidad,
--			orden
	   Into _cod_contrato,
	        _monto2
--			_cod_cober_reas,
--			_no_unidad,
--			_orden
	   From emifacon
	  Where no_poliza = _no_poliza
	    And no_endoso = _no_endoso
	  group by 1

		Select tipo_contrato
--		       porc_impuesto
		  Into _tipo_contrato
--		       _factor_impuesto
		  From reacomae
		 Where cod_contrato = _cod_contrato;

		If _tipo_contrato = 1 Then

			let _monto2 = _monto2 * 0.01;

			select sum(debito + credito)
			  into _monto
			  from endasien
			 where no_poliza   = _no_poliza
			   and no_endoso   = _no_endoso
			   and cuenta[1,3] in ("213")
			   and tipo_comp   = 6;
			
			if _monto is null then
				let _monto = 0.00;
			end if

			let _monto = _monto * -1;

		
			if _monto2 <> _monto then

				return _no_factura,
					   _no_poliza,
					   _no_endoso,
					   _monto2,
					   _monto,
					   (_monto2 - _monto),
					   4,
					   _cod_endomov,
					   _nombre_endomov,	
					   _nombre_tipoprod,
					   _periodo	
					   with resume;

			end if

		end if

	end foreach
}

end foreach

return "",
	   0,
	   0,
	   0,
	   0,
	   0,
	   0,
	   "",
	   "",	
	   "",
	   ""
	   with resume;

end procedure
