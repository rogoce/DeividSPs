-- Procedimiento que Determina la Distribucion de Reaseguro
-- para el Cambio de Reaseguro Individual

-- Creado    : 27/08/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 28/08/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis29;

create procedure sp_sis29(
a_no_poliza	char(10),
a_no_endoso	char(5),
a_no_unidad	char(5)
) returning smallint;

define _no_cambio			smallint;
define _suma				dec(16,2);
define _prima				dec(16,2);
define _cod_cober_reas		char(3);
define _orden				smallint;
define _cod_contrato		char(5);
define _porc_partic_suma	dec(9,6);
define _porc_partic_prima	dec(9,6);
define _cod_ruta			char(5);
define _cod_coasegur		char(3);
define _porc_partic_reas	dec(9,6);
define _porc_comis_fac		dec(7,4);
define _porc_impuesto		dec(5,2);

define _error				smallint;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION           

let _cod_ruta = NULL;

--set debug file to "sp_sis29.trc";
--trace on;

set isolation to dirty read;

-- Eliminacion de la Distribucion Existente

delete from emifafac
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso
   and no_unidad = a_no_unidad;

delete from emifacon
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso
   and no_unidad = a_no_unidad;

delete from endcamre
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso
   and no_unidad = a_no_unidad;

delete from endcamrf
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso
   and no_unidad = a_no_unidad;

-- Seleccion de la Distribucion Actual

select max(no_cambio)
  into _no_cambio
  from emireama
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad;

-- Contratos

foreach
 select cod_cober_reas,
        orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima
   into _cod_cober_reas,
        _orden,
		_cod_contrato,
		_porc_partic_suma,
		_porc_partic_prima
   from emireaco
  where no_poliza = a_no_poliza
    and no_unidad = a_no_unidad
	and no_cambio = _no_cambio

	select sum(c.suma_asegurada),
	       sum(c.prima)
	  into _suma,
	       _prima
	  from emifacon	c, endedmae e
	 where c.no_poliza      = a_no_poliza
	   and c.no_unidad      = a_no_unidad
	   and c.cod_cober_reas = _cod_cober_reas
	   and c.cod_contrato	= _cod_contrato
	   and c.no_poliza		= e.no_poliza
	   and c.no_endoso		= e.no_endoso
	   and e.actualizado    = 1
	   and c.orden          = _orden;

	if _suma is null then
		let _suma = 0;
	end if

	if _prima is null then
		let _prima = 0;
	end if

	insert into endcamre(
	no_poliza,
	no_endoso,
	no_unidad,
	cod_cober_reas,
	orden,
	cod_contrato,
	suma,
	prima,
	suma_total,
	prima_total,
	porc_partic_suma,
	porc_partic_prima
	)
	values(
	a_no_poliza,
	a_no_endoso,
	a_no_unidad,
	_cod_cober_reas,
	_orden,
	_cod_contrato,
	_suma,
	_prima,
	0,
	0,
	_porc_partic_suma,
	_porc_partic_prima
	);

	insert into emifacon(
	no_poliza,
	no_endoso,
	no_unidad,
	cod_cober_reas,
	orden,
	cod_contrato,
	cod_ruta,
	porc_partic_suma,
	porc_partic_prima,
	suma_asegurada,
	prima
	)
	values(
	a_no_poliza,
	a_no_endoso,
	a_no_unidad,
	_cod_cober_reas,
	_orden,
	_cod_contrato,
	_cod_ruta,
	_porc_partic_suma,
	_porc_partic_prima,
	0,
	0
	);

end foreach

foreach
 select sum(suma),
        sum(prima),
		cod_cober_reas
   into _suma,
        _prima,
		_cod_cober_reas
   from endcamre
  where no_poliza      = a_no_poliza
    and no_endoso      = a_no_endoso
    and no_unidad      = a_no_unidad
  group by cod_cober_reas

	update endcamre
	   set suma_total     = _suma,
	       prima_total    = _prima
	 where no_poliza      = a_no_poliza
       and no_endoso      = a_no_endoso
       and no_unidad      = a_no_unidad
       and cod_cober_reas = _cod_cober_reas;

end foreach

-- Facultativos

foreach
 select cod_cober_reas,
        orden,
		cod_contrato,
		cod_coasegur,
		porc_partic_reas,
		porc_comis_fac,
		porc_impuesto
   into _cod_cober_reas,
        _orden,
		_cod_contrato,
		_cod_coasegur,
		_porc_partic_reas,
		_porc_comis_fac,
		_porc_impuesto
   from emireafa
  where no_poliza = a_no_poliza
    and no_unidad = a_no_unidad
	and no_cambio = _no_cambio

	select sum(c.suma_asegurada),
	       sum(c.prima)
	  into _suma,
	       _prima
	  from emifafac	c, endedmae e
	 where c.no_poliza      = a_no_poliza
	   and c.no_unidad      = a_no_unidad
	   and c.cod_cober_reas = _cod_cober_reas
	   and c.cod_contrato	= _cod_contrato
	   and c.cod_coasegur	= _cod_coasegur
	   and c.no_poliza		= e.no_poliza
	   and c.no_endoso		= e.no_endoso
	   and e.actualizado    = 1;

	if _suma is null then
		let _suma = 0;
	end if

	if _prima is null then
		let _prima = 0;
	end if

	insert into endcamrf(
	no_poliza,
	no_endoso,
	no_unidad,
	cod_cober_reas,
	orden,
	cod_contrato,
	cod_coasegur,
	suma,
	prima,
	suma_total,
	prima_total,
	porc_partic_reas,
	porc_comis_fac,
	porc_impuesto
	)
	values(
	a_no_poliza,
	a_no_endoso,
	a_no_unidad,
	_cod_cober_reas,
	_orden,
	_cod_contrato,
	_cod_coasegur,
	_suma,
	_prima,
	0,
	0,
	_porc_partic_reas,
	_porc_comis_fac,
	_porc_impuesto
	);

	insert into emifafac(
	no_poliza,
	no_endoso,
	no_unidad,
	cod_cober_reas,
	orden,
	cod_contrato,
	cod_coasegur,
	porc_partic_reas,
	porc_comis_fac,
	porc_impuesto,
	suma_asegurada,
	prima,
	impreso,
	fecha_impresion,
	no_cesion
	)
	select
	a_no_poliza,
	a_no_endoso,
	a_no_unidad,
	cod_cober_reas,
	orden,
	cod_contrato,
	cod_coasegur,
	porc_partic_reas,
	porc_comis_fac,
	porc_impuesto,
	0,
	0,
	0,
	TODAY,
	""
	 from emireafa
	where no_poliza      = a_no_poliza
      and no_unidad      = a_no_unidad
	  and no_cambio      = _no_cambio
	  and cod_cober_reas = _cod_cober_reas
	  and orden		     = _orden
	  and cod_contrato   = _cod_contrato
	  and cod_coasegur   = _cod_coasegur;

end foreach

foreach
 select sum(suma),
        sum(prima),
		cod_cober_reas,
		orden,
		cod_contrato,
		cod_coasegur
   into _suma,
        _prima,
		_cod_cober_reas,
		_orden,
		_cod_contrato,
		_cod_coasegur
   from endcamrf
  where no_poliza      = a_no_poliza
    and no_endoso      = a_no_endoso
    and no_unidad      = a_no_unidad
  group by cod_cober_reas, orden, cod_contrato, cod_coasegur

	update endcamrf
	   set suma_total     = _suma,
	       prima_total    = _prima
	 where no_poliza      = a_no_poliza
       and no_endoso      = a_no_endoso
       and no_unidad      = a_no_unidad
       and cod_cober_reas = _cod_cober_reas
       and orden		  = _orden
       and cod_contrato   = _cod_contrato
       and cod_coasegur	  = _cod_coasegur;

end foreach

end

return 0;

end procedure;

