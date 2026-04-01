-- Procedimiento que genera las cancelaciones por Decisión de la Compañia (proceso de nueva ley de seguros parte II)
-- Creado     : 06/03/2014 - Autor: Román Gordón.
-- SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_par367('00000','DEIVID',0.00,'001','037',today)

drop procedure sp_par367;
create procedure sp_par367(
a_no_poliza			char(10),
a_usuario			char(8),
a_saldo				dec(16,2),
a_suscursal			char(3),
a_tipocan			char(3),
a_fecha_efectiva	date)
returning	integer,	--_error
            char(200),	--_error_desc
            char(5);	--_no_endoso

define _descripcion		char(200);
define _error_desc		char(50);
define _no_documento    char(20);
define _no_factura      char(10);
define _periodo			char(7);
define _no_endoso_ext	char(5);
define _no_endoso		char(5);
define _cod_impuesto	char(3);
define _cod_tipocalc	char(3);
define _cod_endomov		char(3);
define _cod_tipocan		char(3);
define _null			char(1);
define _factor_impuesto	dec(16,2);
define _suma_asegurada	dec(16,2);
define _prima_suscrita	dec(16,2);
define _prima_retenida 	dec(16,2);
define _suma_impuesto	dec(16,2);
define _prima_bruta		dec(16,2);
define _prima_neta		dec(16,2);
define _descuento		dec(16,2);
define _impuesto		dec(16,2);
define _recargo			dec(16,2);
define _prima 			dec(16,2);
define _tiene_impuesto	smallint;
define _no_endoso_int	smallint;
define _cantidad		smallint;
define _error_isam		integer;
define _error			integer;
define _facultativo     smallint;

--set debug file to 'sp_par342.trc';
--trace on;

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc, '';
end exception

set isolation to dirty read;

select emi_periodo
  into _periodo
  from parparam
 where cod_compania = '001';

let _cod_tipocalc = '007'; -- SIN PRIMA
let _cod_endomov  = '019'; -- Disminución de Vigencia
let _null		  = null; -- Para campos null

select max(no_endoso)
  into _no_endoso_int
  from endedmae
 where no_poliza = a_no_poliza;

let _no_endoso      = sp_set_codigo(5, _no_endoso_int + 1);
let _no_endoso_ext  = sp_sis30(a_no_poliza, _no_endoso);

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
	select no_poliza,
		_no_endoso,
		cod_compania,
		a_suscursal,
		_cod_tipocalc,
		cod_formapag,
		a_tipocan,
		cod_perpago,
		_cod_endomov,
		no_documento,
		'31/05/2018',
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
		a_fecha_efectiva,
		a_fecha_efectiva,
		a_fecha_efectiva,
		1,
		0,
		_null,
		_null,
		a_fecha_efectiva,
		a_fecha_efectiva,
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

let _prima_bruta = a_saldo * -1;

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

call sp_pro493(a_no_poliza, _no_endoso, -1) returning _error, _descripcion;

if _error <> 0 then
	return _error, _descripcion, _no_endoso;
end if

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

--*****Insersion a tabla nota_cesion para polizas facultativas para el envio de la nota de cesion por correo Armando 14/11/2017.
let _facultativo = 0;
select facultativo
  into _facultativo
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = _no_endoso;
   
if _facultativo = 1 then
	insert into nota_cesion(no_poliza,no_endoso,enviado)
	values(a_no_poliza,_no_endoso,0);
end if

update emipomae
   set no_renovar = 1,
	   cod_no_renov = '040'
 where no_poliza = a_no_poliza;
 
--*****************************************************************
{
select no_documento 
  into _no_documento 
  from emipomae 
 where no_poliza = a_no_poliza;
 
select no_factura 
  into _no_factura 
  from endedmae 
 where no_poliza = a_no_poliza
   and no_endoso = _no_endoso; 

update coboutleg 
   set gen_endcan = 1,  
	   no_factura = _no_factura
 where no_documento = _no_documento; 
}

return 0, 'Actualizacion Exitosa', _no_endoso;
end procedure;