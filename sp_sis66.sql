drop procedure sp_sis66;

create procedure "".sp_sis66(a_no_poliza char(10), a_no_endoso char(5))
returning integer,
          char(50);

define _error		integer;
define _descripcion	char(50);
define _null		char(1);
define _cantidad	integer;

let _null = null;
	
begin 
on exception set _error
	return _error, _descripcion;
end exception

-- Descuentos

let _descripcion = "endeddes"; 

select count(*)
  into _cantidad
  from endeddes
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _cantidad = 0 then

	INSERT INTO endeddes(
	no_poliza,
	no_endoso,
	cod_descuen,
	porc_descuento
	)
	SELECT 
	a_no_poliza,
	a_no_endoso,
	cod_descuen,
	porc_descuento
	FROM emipolde
	WHERE no_poliza = a_no_poliza;

end if

-- Recargos

let _descripcion = "endedrec"; 

select count(*)
  into _cantidad
  from endedrec
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _cantidad = 0 then

	INSERT INTO endedrec(
	no_poliza,
	no_endoso,
	cod_recargo,
	porc_recargo
	)
	SELECT 
	a_no_poliza,
	a_no_endoso,
	cod_recargo,
	porc_recargo
	FROM emiporec
	WHERE no_poliza = a_no_poliza;

end if

-- Impuestos

let _descripcion = "endedimp"; 

select count(*)
  into _cantidad
  from endedimp
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _cantidad = 0 then

	INSERT INTO endedimp(
	no_poliza,
	no_endoso,
	cod_impuesto,
	monto
	)
	SELECT 
	a_no_poliza,
	a_no_endoso,
	cod_impuesto,
	monto
	FROM emipolim
	WHERE no_poliza = a_no_poliza;

end if

-- Unidades

let _descripcion = "endeduni"; 

select count(*)
  into _cantidad
  from endeduni
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _cantidad = 0 then

	INSERT INTO endeduni(
	no_poliza,
	no_endoso,
	no_unidad,
	cod_ruta,
	cod_producto,
	cod_cliente,
	suma_asegurada,
	prima,
	descuento,
	recargo,
	prima_neta,
	impuesto,
	prima_bruta,
	reasegurada,
	vigencia_inic,
	vigencia_final,
	beneficio_max,
	desc_unidad,
	prima_suscrita,
	prima_retenida,
	suma_aseg_adic,
	tipo_incendio
	)
	SELECT
	a_no_poliza,
	a_no_endoso,
	no_unidad,
	cod_ruta,
	cod_producto,
	cod_asegurado,
	suma_asegurada,
	prima,
	descuento,
	recargo,
	prima_neta,
	impuesto,
	prima_bruta,
	reasegurada,
	vigencia_inic,
	vigencia_final,
	beneficio_max,
	desc_unidad,
	prima_suscrita,
	prima_retenida,
	suma_aseg_adic,
	tipo_incendio
	FROM emipouni
	WHERE no_poliza = a_no_poliza;

end if

-- Descuentos

let _descripcion = "endunide"; 

select count(*)
  into _cantidad
  from endunide
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _cantidad = 0 then

	INSERT INTO endunide(
	no_poliza,
	no_endoso,
	no_unidad,
	cod_descuen,
	porc_descuento
	)
	SELECT 
	a_no_poliza,
	a_no_endoso,
	no_unidad,
	cod_descuen,
	porc_descuento
	FROM emiunide
	WHERE no_poliza = a_no_poliza;

end if

-- Recargos

let _descripcion = "endunire"; 

select count(*)
  into _cantidad
  from endunire
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _cantidad = 0 then

	INSERT INTO endunire(
	no_poliza,
	no_endoso,
	no_unidad,
	cod_recargo,
	porc_recargo
	)
	SELECT 
	a_no_poliza,
	a_no_endoso,
	no_unidad,
	cod_recargo,
	porc_recargo
	FROM emiunire
	WHERE no_poliza = a_no_poliza;

end if

-- Descripcion

let _descripcion = "endedde2"; 

select count(*)
  into _cantidad
  from endedde2
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _cantidad = 0 then

	INSERT INTO endedde2(
	no_poliza,
	no_endoso,
	no_unidad,
	descripcion
	)
	SELECT 
	no_poliza,
	a_no_endoso,
	no_unidad,
	descripcion
	FROM emipode2
	WHERE no_poliza = a_no_poliza;

end if

-- Acreedores

let _descripcion = "endedacr"; 

select count(*)
  into _cantidad
  from endedacr
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _cantidad = 0 then

	INSERT INTO endedacr(
	no_poliza,
	no_endoso,
	no_unidad,
	cod_acreedor,
	limite
	)
	SELECT 
	no_poliza,
	a_no_endoso,
	no_unidad,
	cod_acreedor,
	limite
	FROM emipoacr
	WHERE no_poliza = a_no_poliza;

end if

-- Autos

let _descripcion = "endmoaut"; 

select count(*)
  into _cantidad
  from endmoaut
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _cantidad = 0 then

	INSERT INTO endmoaut(
	no_poliza,
	no_endoso,
	no_unidad,
	no_motor,
	cod_tipoveh,
	uso_auto,
	no_chasis,
	ano_tarifa
	)
	SELECT
	a_no_poliza,
	a_no_endoso,
	no_unidad,
	no_motor,
	cod_tipoveh,
	uso_auto,
	_null,
	ano_tarifa
	FROM emiauto
	WHERE no_poliza = a_no_poliza;

end if

-- Transporte

let _descripcion = "endmotra"; 

select count(*)
  into _cantidad
  from endmotra
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _cantidad = 0 then

	INSERT INTO endmotra(
	no_poliza,
	no_endoso,
	no_unidad,
	cod_nave,
	consignado,
	tipo_embarque,
	clausulas,
	contenedor,
	sello,
	fecha_viaje,
	viaje_desde,
	viaje_hasta,
	sobre
	)
	SELECT
	a_no_poliza,
	a_no_endoso,
	no_unidad,
	cod_nave,
	consignado,
	tipo_embarque,
	clausulas,
	contenedor,
	sello,
	fecha_viaje,
	viaje_desde,
	viaje_hasta,
	sobre
	FROM emitrans
	WHERE no_poliza = a_no_poliza;

end if

let _descripcion = "endmotrd"; 

select count(*)
  into _cantidad
  from endmotrd
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _cantidad = 0 then

	INSERT INTO endmotrd(
	no_poliza,
	no_endoso,
	no_unidad,
	especiales
	)
	SELECT
	a_no_poliza,
	a_no_endoso,
	no_unidad,
	especiales
	FROM emitrand
	WHERE no_poliza = a_no_poliza;

end if

-- Cumulos de Incendio

let _descripcion = "endcuend"; 

select count(*)
  into _cantidad
  from endcuend
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _cantidad = 0 then

	INSERT INTO endcuend(
	no_poliza,
	no_endoso,
	no_unidad,
	cod_ubica,
	suma_incendio,
	suma_terremoto,
	prima_incendio,
	prima_terremoto
	)
	SELECT
	a_no_poliza,
	a_no_endoso,
	no_unidad,
	cod_ubica,
	suma_incendio,
	suma_terremoto,
	prima_incendio,
	prima_terremoto
	FROM emicupol
	WHERE no_poliza = a_no_poliza;

end if

-- Coberturas

let _descripcion = "endedcob"; 

select count(*)
  into _cantidad
  from endedcob
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _cantidad = 0 then

	INSERT INTO endedcob(
	no_poliza,
	no_endoso,
	no_unidad,
	cod_cobertura,
	orden,
	tarifa,
	deducible,
	limite_1,
	limite_2,
	prima_anual,
	prima,
	descuento,
	recargo,
	prima_neta,
	date_added,
	date_changed,
	desc_limite1,
	desc_limite2,
	factor_vigencia,
	opcion
	)
	SELECT
	no_poliza,
	a_no_endoso,
	no_unidad,
	cod_cobertura,
	orden,
	tarifa,
	deducible,
	limite_1,
	limite_2,
	prima_anual,
	prima,
	descuento,
	recargo,
	prima_neta,
	date_added,
	date_changed,
	desc_limite1,
	desc_limite2,
	factor_vigencia,
	0
	FROM emipocob
	WHERE no_poliza = a_no_poliza;

end if

-- Descuentos

let _descripcion = "endcobde"; 

select count(*)
  into _cantidad
  from endcobde
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _cantidad = 0 then

	INSERT INTO endcobde(
	no_poliza,
	no_endoso,
	no_unidad,
	cod_cobertura,
	cod_descuen,
	porc_descuento
	)
	SELECT 
	no_poliza,
	a_no_endoso,
	no_unidad,
	cod_cobertura,
	cod_descuen,
	porc_descuento
	FROM emicobde
	WHERE no_poliza = a_no_poliza;

end if

-- Recargos

let _descripcion = "endcobre"; 

select count(*)
  into _cantidad
  from endcobre
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _cantidad = 0 then

	INSERT INTO endcobre(
	no_poliza,
	no_endoso,
	no_unidad,
	cod_cobertura,
	cod_recargo,
	porc_recargo
	)
	SELECT 
	no_poliza,
	a_no_endoso,
	no_unidad,
	cod_cobertura,
	cod_recargo,
	porc_recargo
	FROM emicobre
	WHERE no_poliza = a_no_poliza;

end if

end

return 0, "Actualizacion Exitosa";

end procedure
