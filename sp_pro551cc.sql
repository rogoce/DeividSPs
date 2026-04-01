-- Procedimiento que genera endoso de Modificación para facturacion de salud mal facturada
-- Creado     : 06/03/2014 - Autor: Román Gordón.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro551cc;
create procedure sp_pro551cc(a_no_poliza char(10), a_usuario char(8), a_prima dec(16,2), a_suscursal char(3))
returning	integer,	--_error
            char(200),	--_error_desc
            char(5);	--_no_endoso

define _no_poliza_coaseg	varchar(30);
define _descripcion			char(200);
define _error_desc			char(50);
define _no_documento    	char(20);
define _no_factura			char(10);
define _periodo				char(7);
define _no_endoso_ext		char(5);
define _cod_cobertura		char(5);
define _no_unidad			char(5);
define _no_endoso			char(5);
define _cod_impuesto		char(3);
define _cod_tipocalc		char(3);
define _cod_endomov			char(3);
define _cod_tipocan			char(3);
define _null				char(1);
define _factor_impuesto		dec(16,2);
define _prima_sin_descp		dec(16,2);
define _total_impuestop		dec(16,2);
define _prima_retenidap		dec(16,2);
define _prima_sin_desc		dec(16,2);
define _suma_asegurada		dec(16,2);
define _prima_suscrita		dec(16,2);
define _prima_retenida 		dec(16,2);
define _suma_impuesto		dec(16,2);
define _prima_brutap		dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_netap			dec(16,2);
define _prima_neta			dec(16,2);
define _descuento			dec(16,2);
define _impuesto			dec(16,2);
define _recargo				dec(16,2);
define _prima 				dec(16,2);
define _suma				dec(16,2);
define _tiene_impuesto		smallint;
define _no_endoso_int		smallint;
define _cantidad			smallint;
define _flag				smallint;
define _orden				smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_hoy			date;

--set debug file to "sp_pro551cc.trc";
--trace on;

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc, "";
end exception

set isolation to dirty read;

select emi_periodo
  into _periodo
  from parparam
 where cod_compania = "001";

let _cod_tipocalc = "006"; -- Manual
let _cod_endomov  = "006"; -- Modificación de Unidades
let _null		  = null; -- Para campos null

select max(no_endoso)
  into _no_endoso_int
  from endedmae
 where no_poliza = a_no_poliza;

let _no_endoso      = sp_set_codigo(5, _no_endoso_int + 1);
let _no_endoso_ext  = sp_sis30(a_no_poliza, _no_endoso);
let _no_unidad = '00001';
let _fecha_hoy = current;

insert into endedmae(
		no_poliza,
		no_endoso,
		cod_compania,
		cod_sucursal,
		cod_tipocalc,
		cod_formapag,
		cod_tipocan,
		cod_perpago,
		cod_endomov,
		no_documento,
		vigencia_inic,
		vigencia_final,
		prima,
		descuento,
		recargo,
		prima_neta,
		impuesto,
		prima_bruta,
		prima_suscrita,
		prima_retenida,
		tiene_impuesto,
		fecha_emision,
		fecha_impresion,
		fecha_primer_pago,
		no_pagos,
		actualizado,
		no_factura,
		fact_reversar,
		date_added,
		date_changed,
		interna,
		periodo,
		user_added,
		factor_vigencia,
		suma_asegurada,
		posteado,
		activa,
		vigencia_inic_pol,
		vigencia_final_pol,
		no_endoso_ext,
		cod_tipoprod,
		cotizacion,
		de_cotizacion,
		gastos,
		no_poliza_coaseguro)
select	no_poliza,
		_no_endoso,
		cod_compania,
		a_suscursal,
		_cod_tipocalc,
		cod_formapag,
		_null,
		cod_perpago,
		_cod_endomov,
		no_documento,
		vigencia_inic,
		vigencia_final,
		0.00,
		0.00,
		0.00,
		0.00,
		0.00,
		0.00,
		0.00,
		0.00,
		tiene_impuesto,
		today,
		today,
		today,
		1,
		0,
		_null,
		_null,
		today,
		today,
		1,
		_periodo,
		a_usuario,
		1,
		0.00,
		0,
		1,
		vigencia_inic,
		vigencia_final,
		_no_endoso_ext,
		cod_tipoprod,
		_null,
		0,
		0.00,
		no_poliza_coaseg
	  from emipomae
	 where no_poliza = a_no_poliza;

select tiene_impuesto
  into _tiene_impuesto
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = _no_endoso;

if _tiene_impuesto = 1 then
	insert into endedimp(
			no_poliza,
			no_endoso,
			cod_impuesto,
			monto)
	select no_poliza,
		   _no_endoso,
		   cod_impuesto,
		   0.00
	  from emipolim
	 where no_poliza = a_no_poliza;
end if

select count(*)
  into _cantidad
  from endedimp
 where no_poliza = a_no_poliza
   and no_endoso = _no_endoso;

if _cantidad = 0 then	
	update endedmae
	   set tiene_impuesto = 0
     where no_poliza      = a_no_poliza
       and no_endoso      = _no_endoso;

	let _tiene_impuesto = 0;
end if

let _prima_bruta = a_prima;
--trace on;
if _tiene_impuesto = 1 then
	let _suma_impuesto = 0.00;

	foreach	
		select cod_impuesto
		  into _cod_impuesto
		  from emipolim
		 where no_poliza = a_no_poliza

		select factor_impuesto
		  into _factor_impuesto
		  from prdimpue
		 where cod_impuesto = _cod_impuesto;
			    
		let _suma_impuesto = _suma_impuesto  + (_factor_impuesto / 100);
	end foreach

	let _prima_neta = _prima_bruta / (1 + _suma_impuesto);
else
	let _prima_neta = _prima_bruta;
end if

let _impuesto = _prima_bruta - _prima_neta;

update endedmae
   set prima_neta  = _prima_neta,
	   impuesto    = _impuesto,
	   prima_bruta = _prima_bruta
 where no_poliza   = a_no_poliza
   and no_endoso   = _no_endoso;

{call sp_pro493(a_no_poliza, _no_endoso, 1) returning _error, _descripcion;

if _error <> 0 then
	return _error, _descripcion, _no_endoso;
end if}
insert into endeduni(
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
	   gastos, 
	   tipo_incendio)	
select a_no_poliza,
	   _no_endoso,
	   no_unidad,
	   cod_ruta,
	   cod_producto,
	   cod_asegurado,
	   suma_asegurada,
	   _prima_neta,
	   0.00,
	   0.00,
	   _prima_neta,
	   _impuesto,
	   _prima_bruta,
	   reasegurada,
	   vigencia_inic,
	   vigencia_final,
	   beneficio_max,
	   desc_unidad,
	   prima_suscrita,
	   prima_retenida,
	   0,
	   gastos,
	   tipo_incendio
  from emipouni
 where no_poliza = a_no_poliza
   and activo    = 1;

let _flag = 1;

foreach	
	SELECT cod_cobertura,
		   orden
	  into _cod_cobertura,
		   _orden
	  from emipocob  
	 where no_poliza = a_no_poliza 
	   and no_unidad = _no_unidad
	 order by orden

	Insert Into endedcob(no_poliza, 
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
				factor_vigencia, 
				opcion, 
				subir_bo)
	  Values(	a_no_poliza, 
				_no_endoso,
				_no_unidad, 
				_cod_cobertura, 
				_orden, 
				'0', 
				'0', 
				'0.00',
				'0.00', 
				_prima_neta, 
				_prima_neta,
				0.00, 
				0.00,
				_prima_neta,
				_fecha_hoy,
				_fecha_hoy,
				1.00,
				0,
				1);
	
	if _flag = 1 then
		let _flag = 0;
		let _prima_neta = 0.00;
	end if
end foreach

select *
  from emiunire
 where no_poliza = a_no_poliza
into temp prueba1;

delete from emiunire
where no_poliza = a_no_poliza;

select *
  from emiderec
 where no_poliza = a_no_poliza
into temp prueba2;

delete from emiderec
where no_poliza = a_no_poliza;

call sp_pro46a(a_no_poliza, _no_endoso, _no_unidad, '0','1.000') returning _error, _error_desc, _prima_sin_desc, _descuento, _recargo, _prima_netap, _total_impuestop, _prima_brutap;   					   
call sp_proe35(a_no_poliza, _no_endoso, _no_unidad, '001') returning _error;
call sp_pro462a(a_no_poliza, _no_endoso, _no_unidad) returning _error, _error_desc, _prima_sin_descp, _descuento, _recargo, _prima_netap, _total_impuestop, _prima_brutap,_suma,_prima_suscrita,_prima_retenidap;
call sp_pro4611a(a_no_poliza, _no_endoso) returning _error, _error_desc, _prima_sin_descp, _descuento, _recargo, _prima_netap, _total_impuestop, _prima_brutap,_suma,_prima_suscrita,_prima_retenidap;

insert into emiunire
select * from prueba1;
drop table prueba1;

insert into emiderec
select * from prueba2;
drop table prueba2;

Insert into endedde2(
		no_poliza,
		no_unidad,
		no_endoso,
		descripcion
		)
values (a_no_poliza,
	   _no_unidad,
	   _no_endoso,
	   null);

Insert into endedde1(
		no_poliza,
		no_endoso,
		descripcion)
values (a_no_poliza,
		_no_endoso,
	   null);

select sum(prima_suscrita), 
	   sum(prima_retenida), 
	   sum(prima), 
	   sum(descuento),
       sum(recargo), 
       sum(prima_neta), 
       sum(impuesto), 
       sum(prima_bruta), 
       sum(suma_asegurada)
  into _prima_suscrita, 
  	   _prima_retenida, 
  	   _prima, 
  	   _descuento, 
       _recargo, 
       _prima_neta, 
       _impuesto, 
       _prima_bruta, 
       _suma_asegurada
  from endeduni					 
 where no_poliza  = a_no_poliza
   and no_endoso  = _no_endoso;

update endedmae
   set prima_suscrita = _prima_suscrita,
	   prima_retenida = _prima_retenida,
       prima          = _prima,
       descuento      = _descuento,
	   recargo        = _recargo,
	   suma_asegurada = _suma_asegurada
 where no_poliza      = a_no_poliza
   and no_endoso      = _no_endoso;
end

call sp_pro43(a_no_poliza, _no_endoso) returning _error, _descripcion;

if _error <> 0 then
	return _error, _descripcion, _no_endoso;
end if

return 0, "Actualizacion Exitosa", _no_endoso;
end procedure;