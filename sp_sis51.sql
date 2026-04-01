-- Cargar Porcentajes de Gasto de Administracion, Adquisicion y Contrato XLS
-- 
-- Creado    : 08/03/2004 - Autor: Demetrio Hurtado Almanza
-- Modificado: 08/03/2004 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_sis51;

CREATE PROCEDURE "informix".sp_sis51(a_periodo char(7))
returning char(10),
          dec(16,2),
		  dec(16,2),
		  char(10),
		  char(5),
		  smallint;

define _no_factura		char(10);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _prima_suscrita	dec(16,2);
define _prima_reas		dec(16,2);
define _tipo			smallint;

foreach
 select no_factura,
        prima_suscrita,
		no_poliza,
		no_endoso
   into _no_factura,
        _prima_suscrita,
		_no_poliza,
		_no_endoso
   from endedmae
  where actualizado = 1
    and periodo     = a_periodo

	select sum(prima)
	  into _prima_reas
	  from emifacon
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;
	
	let _tipo = 1;

	if _prima_suscrita <> _prima_reas then

		return _no_factura,
		       _prima_suscrita,
			   _prima_reas,
			   _no_poliza,
			   _no_endoso,
			   _tipo
			   with resume;

	end if

	select sum(prima)
	  into _prima_reas
	  from emifacon f, reacomae c
	 where no_poliza       = _no_poliza
	   and no_endoso       = _no_endoso
	   and f.cod_contrato  = c.cod_contrato
	   and c.tipo_contrato = 3;
	
	select sum(prima)
	  into _prima_suscrita
	  from emifafac
	 where no_poliza       = _no_poliza
	   and no_endoso       = _no_endoso;

	let _tipo = 2;

	if _prima_suscrita <> _prima_reas then

		return _no_factura,
		       _prima_suscrita,
			   _prima_reas,
			   _no_poliza,
			   _no_endoso,
			   _tipo
			   with resume;

	end if

end foreach

end procedure
