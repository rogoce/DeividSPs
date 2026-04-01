-- Procedure que verifica la produccion 2008 y 2009 del Bouquet

-- Creado    : 21/01/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_rea005;

create procedure sp_rea005(a_periodo1 char(7), a_periodo2 char(7)) 
returning char(20),
		  char(10),
		  char(3),
		  char(50),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(10),
		  char(5);

define _no_poliza			char(10);
define _no_endoso			char(5);
define _no_documento		char(20);
define _no_factura			char(10);
define _no_unidad			char(5);
define _cod_ramo			char(3);
define _nombre_ramo			char(50);

define _cod_contrato		char(5);
define _cod_cober_reas		char(3);
define _cod_coasegur 		char(3);
define _bouquet				smallint;
define _nombre				char(50);
define _nombre_contrato		char(50);

define _prima				dec(16,2);
define _prima_suscrita		dec(16,2);
define _factor_impuesto	 	dec(5,2);
define _porc_comis_agt   	dec(5,2);
define _tiene_comis_rea	 	smallint;
define _porc_cont_partic 	dec(5,2);
define _porc_comis_ase   	dec(5,2);
define _monto_reas		 	dec(16,2);
define _por_pagar		 	dec(16,2);
define _comision		 	dec(16,2);
define _impuesto		 	dec(16,2);
define _es_terremoto		smallint;

define _no_tranrec			char(10);
define _no_reclamo			char(10);
define _cod_cobertura		char(5);
define _monto				dec(16,2);
define _diferencia			dec(16,2);
define _porc_partic_prima	dec(9,6);

set isolation to dirty read;

foreach
 select no_poliza,
        no_endoso,
		no_factura,
		prima_suscrita
   into _no_poliza,
        _no_endoso,
		_no_factura,
		_prima_suscrita
   from endedmae
  where periodo     >= a_periodo1
    and periodo     <= a_periodo2
	and actualizado = 1

	 select sum(prima)
	   into	_prima
	   from emifacon
	  where no_poliza = _no_poliza
	    and no_endoso = _no_endoso
		and prima     <> 0.00;

	if _prima <> _prima_suscrita then

		let _diferencia = _prima_suscrita - _prima;

		if abs(_diferencia) = 0.01 then
			continue foreach;
		end if

		select no_documento,
		       cod_ramo
		  into _no_documento,
		       _cod_ramo
		  from emipomae
		 where no_poliza = _no_poliza;

		if _cod_ramo = "018" and _no_endoso = "00000" then
			continue foreach;
		end if

		select nombre
		  into _nombre_ramo
		  from prdramo
		 where cod_ramo = _cod_ramo;

		return _no_documento,
		       _no_factura,
		       _cod_ramo,
		       _nombre_ramo,
			   _prima_suscrita,
			   _prima,
			   _diferencia,
			   _no_poliza,
			   _no_endoso
			   with resume;

	end if

end foreach

return "0",
       "0",
       "0",
       "0",
	   0,
	   0,
	   0,
	   "0",
	   "0"
	   with resume;

end procedure
