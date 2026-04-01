-- Verificacion de Facturas para Primas por Cobrar

DROP PROCEDURE sp_par28;

CREATE PROCEDURE "informix".sp_par28() 
returning char(10),
		  dec(16,2),
		  dec(16,2),
		  char(100),
		  char(7),
		  date,
		  char(20),
		  char(3),
		  date,
		  dec(16,2);	

define _no_factura		char(10);
define _monto_letra		dec(16,2);
define _prima_bruta		dec(16,2);
define _periodo			char(7);
define _vigencia_inic	date;
define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_documento	char(20);
define _cod_tipoprod	char(3);
define _fecha_emision	date;
define _totalfact		dec(16,2);
define _primafact		dec(16,2);
define _itbmfact		dec(16,2);
define _activa			smallint;
define _correcto		smallint;

--set debug file to "sp_par26.trc";
--trace on;

FOREACH
 SELECT no_factura,
        prima_bruta,
		periodo,
		vigencia_inic,
		no_poliza,
		no_endoso,
		no_documento,
		fecha_emision
   INTO _no_factura,
        _prima_bruta,
		_periodo,
		_vigencia_inic,
		_no_poliza,
		_no_endoso,
		_no_documento,
		_fecha_emision
   FROM endedmae
  where actualizado = 1
    and activa      = 1
    and periodo     >= "1996-07"
	and periodo     <= "2000-10"
--	and cod_endomov not in ("021")
--	and no_documento = "0997-0358-01"
--	and no_factura  = "01-45380"
--  and cod_endomov not in ("021")
--	and cod_endomov in ("011")
--	and periodo >= "1999-01"
--	and year(vigencia_inic) = 2000
--	and fecha_emision >= "18/11/2000"
  order by periodo desc
	
	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "004" then
		continue foreach;
	end if

	select sum(monto_letra), 
	       correcto
	  into _monto_letra,
		   _correcto
	  from primacob
	 where documento = _no_factura
	 group by correcto;

	if _correcto = 0 then
		continue foreach;
	end if

	if _monto_letra is null then
		let _monto_letra = 0;
	end if		

	if abs(_monto_letra - _prima_bruta) > 0.05 then

		let _totalfact = null;

	   foreach
		select totalfact,
			   primafact,
			   itbmfact	
		  into _totalfact,
		       _primafact,
			   _itbmfact	
		  from facturas
		 where numfact  = trim(_no_factura[4,10])
		   and sucursal = trim(_no_factura[1,2])
			exit foreach;
		end foreach

		if _totalfact is not null then
			if _totalfact = _prima_bruta then
				{		
				return _no_factura,
					   _prima_bruta,
					   _monto_letra,
					   "99 - Facturas y Endosos Igual Primacob Diferente",
					   _periodo,
					   _vigencia_inic,
					   _no_documento,
					   _cod_tipoprod,
					   _fecha_emision,
					   _totalfact
					   with resume;
				--}
			elif _totalfact = _monto_letra then

				if _totalfact   = 0 and
				   _monto_letra = 0 then

					return _no_factura,
						   _prima_bruta,
						   _monto_letra,
						   "2 - 1 Facturas y Primacob Cero Endosos con Valor",
						   _periodo,
						   _vigencia_inic,
						   _no_documento,
						   _cod_tipoprod,
						   _fecha_emision,
						   _totalfact
						   with resume;
				else

					{
					update endedmae
					   set prima_neta  = _primafact,
					       impuesto    = _itbmfact,
						   prima_bruta = _totalfact
					 where no_poliza   = _no_poliza
					   and no_endoso   = _no_endoso;
					--}

					return _no_factura,
						   _prima_bruta,
						   _monto_letra,
						   "2 - 0 Facturas y Primacob Igual Endosos Diferente",
						   _periodo,
						   _vigencia_inic,
						   _no_documento,
						   _cod_tipoprod,
						   _fecha_emision,
						   _totalfact
						   with resume;
				end if
			else
				if abs(_totalfact - _monto_letra) <= 0.02 then
					{
					update endedmae
					   set prima_neta  = _primafact,
					       impuesto    = _itbmfact,
						   prima_bruta = _totalfact
					 where no_poliza   = _no_poliza
					   and no_endoso   = _no_endoso;
					--}
					return _no_factura,
						   _prima_bruta,
						   _monto_letra,
						   "3 - 0 Todos Diferentes (Primacob y Facturas Menos de 0.02)",
						   _periodo,
						   _vigencia_inic,
						   _no_documento,
						   _cod_tipoprod,
						   _fecha_emision,
						   _totalfact
						   with resume;
				elif abs(_totalfact - _prima_bruta) <= 1.00 then
					return _no_factura,
						   _prima_bruta,
						   _monto_letra,
						   "3 - 1 Endosos - Primacob y Facturas Diferentes",
						   _periodo,
						   _vigencia_inic,
						   _no_documento,
						   _cod_tipoprod,
						   _fecha_emision,
						   _totalfact
						   with resume;
				else
					return _no_factura,
						   _prima_bruta,
						   _monto_letra,
						   "3 - 2 Endosos - Primacob y Facturas Diferentes",
						   _periodo,
						   _vigencia_inic,
						   _no_documento,
						   _cod_tipoprod,
						   _fecha_emision,
						   _totalfact
						   with resume;
				end if
			end if
		else
			if _monto_letra = 0 then
				return _no_factura,
					   _prima_bruta,
					   _monto_letra,
					   "4 - 0 Facturas no Existe, Primacob Cero",
					   _periodo,
					   _vigencia_inic,
					   _no_documento,
					   _cod_tipoprod,
					   _fecha_emision,
					   0.00
					   with resume;
			elif _prima_bruta = 0 then
				return _no_factura,
					   _prima_bruta,
					   _monto_letra,
					   "4 - 1 Facturas no Existe, Primacob con Valor, Endoso 0",
					   _periodo,
					   _vigencia_inic,
					   _no_documento,
					   _cod_tipoprod,
					   _fecha_emision,
					   0.00
					   with resume;
			else
				return _no_factura,
					   _prima_bruta,
					   _monto_letra,
					   "4 - 2 Facturas no Existe, Primacob con Valor, Endoso <> 0",
					   _periodo,
					   _vigencia_inic,
					   _no_documento,
					   _cod_tipoprod,
					   _fecha_emision,
					   0.00
					   with resume;
			end if
		end if
	end if

end foreach

foreach
 select documento,
        sum(monto_letra)
   into	_no_factura,
        _monto_letra
   from primacob
  where referencia[1,2] = "FA"
    and correcto = 1
  group by documento
 having sum(monto_letra) <> 0 	

	let _no_documento = null;

	foreach
	select no_documento,
	       activa,
		   prima_bruta,
		   periodo,
		   vigencia_inic,
		   fecha_emision
	  into _no_documento,
	       _activa,
		   _prima_bruta,
		   _periodo,
		   _vigencia_inic,
		   _fecha_emision
	  from endedmae
	 where no_factura = _no_factura
		exit foreach;
	end foreach

	if _no_documento is null then
		return _no_factura,
			   0.00,
			   _monto_letra,
			   "5 - 1 Facturas no Existe, Primacob con Valor",
			   "",
			   "",
			   "",
			   "",
			   "",
			   0.00
			   with resume;
	else
		if _activa = 0 then
			return _no_factura,
				   _prima_bruta,
				   _monto_letra,
				   "5 - 2 Facturas no Activa, Primacob con Valor",
				   _periodo,
				   _vigencia_inic,
				   _no_documento,
				   "",
				   _fecha_emision,
				   0.00
				   with resume;
		end if
	end if
end foreach

END PROCEDURE 

