drop procedure sp_pro164;

create procedure sp_pro164()
returning char(20),
          date,
		  date,
		  date,
		  smallint,
		  smallint,
		  smallint,
		  dec(16,2),
		  dec(16,2),
		  char(5),
		  smallint;

define _no_poliza		char(10);
define _no_documento	char(20);
define _vigencia_inic	date;
define _vigencia_final	date;
define _cod_cliente		char(10);
define _cod_producto	char(5);
define _cambiar_tarifas	smallint;
define _fecha_nac		date;
define _edad			smallint;
define _edad_desde		smallint;
define _edad_hasta		smallint;
define _cantidad		smallint;
define _anos			smallint;
define _prima_plan		dec(16,2);
define _prima_vida		dec(16,2);
define _cant_pro		smallint;

set isolation to dirty read;

FOREACH
 SELECT no_poliza,
		no_documento,
		vigencia_inic,
		vigencia_final
   INTO _no_poliza,
		_no_documento,
		_vigencia_inic,
		_vigencia_final
   FROM emipomae
  WHERE cod_compania   = "001"
    AND cod_ramo       = "018"
    AND estatus_poliza IN (1,3)
    AND actualizado    = 1
    AND cod_tipoprod   in ("001", "005")
	and vigencia_final >= "01/01/2006"

	select count(*)
	  into _cantidad
	  from emipouni
	 where no_poliza = _no_poliza;

	if _cantidad > 1 then
		continue foreach;
	end if

	foreach
	 select cod_asegurado,
	        cod_producto,
			cambiar_tarifas
	   into _cod_cliente,
	        _cod_producto,
			_cambiar_tarifas
	   from emipouni
	  where no_poliza = _no_poliza

		select count(*)
		  into _cant_pro
		  from prdnewpro
		 where producto_nuevo = _cod_producto;

		if _cant_pro <> 0 then
--			continue foreach;
		end if

		select fecha_aniversario
		  into _fecha_nac
		  from cliclien
		 where cod_cliente = _cod_cliente;
		 
--		let _edad = sp_sis78(_fecha_nac, today);
		let _edad = sp_sis78(_fecha_nac, "31/10/2005");

		if _edad is null then
			continue foreach;
		end if

		let _anos = (_vigencia_final - _vigencia_inic) / 365;

		if _anos = 0 then
			continue foreach;
		end if

		if month(_vigencia_inic) <> 10 then
--			continue foreach;
		end if

		let _prima_plan   = 0;
		let _prima_vida   = 0;

		select prima,
	           prima_vida,
			   edad_desde,
			   edad_hasta
		  into _prima_plan,
	           _prima_vida,
			   _edad_desde,
			   _edad_hasta
		  from prdtaeda
		 where cod_producto = _cod_producto
		   and edad_desde   <= _edad
		   and edad_hasta   >= _edad;

		if _edad = _edad_desde then

			return _no_documento,
			       _vigencia_inic,
				   _vigencia_final,
				   _fecha_nac,
				   _edad,
				   _edad_desde,
				   _edad_hasta,
				   _prima_plan,
				   _prima_vida,
				   _cod_producto,
				   _cambiar_tarifas
				   with resume;

		end if

	end foreach

end foreach

end procedure