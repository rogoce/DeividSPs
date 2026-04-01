-- Procedimiento que genera el endoso de cambio de corredor masivo a requerimiento
-- Creado: 21/03/2024 - Autor: Armando Moreno M.

--drop procedure sp_end_acr_lote;
create procedure sp_end_acr_lote(a_no_poliza char(10), a_no_unidad char(5))
returning	integer,
			char(200),
			char(5);

define _descripcion		varchar(200);
define _error_desc		varchar(50);
define _no_documento    char(20);
define _no_factura      char(10);
define _cod_impuesto	char(3);
define _periodo			char(7);
define _no_endoso_ext	char(5);
define _no_endoso		char(5);
define _cod_tipocalc	char(3);
define _cod_endomov		char(3);
define _cod_tipocan		char(3);
define _null			char(1);
define _factor_impuesto	dec(16,2);
define _prima_suscrita	dec(16,2);
define _prima_retenida	dec(16,2);
define _suma_asegurada	dec(16,2);
define _suma_impuesto	dec(16,2);
define _prima_bruta		dec(16,2);
define _prima_neta		dec(16,2);
define _descuento		dec(16,2);
define _impuesto		dec(16,2);
define _recargo			dec(16,2);
define _prima			dec(16,2);
define _tiene_impuesto	smallint;
define _no_endoso_int	smallint;
define _cnt_agt			smallint;
define _cantidad		smallint;
define _error_isam		integer;
define _error			integer;

--set debug file to "sp_pro409.trc";
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

let _error = 0;
let _cod_endomov  = "010"; -- Mod. de acreedor
let _cod_tipocalc = "007"; -- Sin Prima
let _null		  = null;  -- Para campos null

select max(no_endoso)
  into _no_endoso_int
  from endedmae
 where no_poliza = a_no_poliza;
 
if a_no_poliza = '1093635' then
	let _no_endoso_int = 2;
end if

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
gastos
)
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
		0.00
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

if _cantidad is null then
	let  _cantidad = 0;
end if

if _cantidad = 0 then	
	update endedmae
	   set tiene_impuesto = 0
     where no_poliza      = a_no_poliza
       and no_endoso      = _no_endoso;

	let _tiene_impuesto = 0;
end if

if a_fecha_efectiva is not null then
	update endedmae
	   set vigencia_inic = a_fecha_efectiva
     where no_poliza      = a_no_poliza
       and no_endoso      = _no_endoso
	   and vigencia_inic >= a_fecha_efectiva;
end if

--trace off;
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
		suma_aseg_adic)
select	a_no_poliza,
		_no_endoso,
		no_unidad,
		cod_ruta,
		cod_producto,
		cod_asegurado,
		suma_asegurada,
		0.00,
		0.00,
		0.00,
		0.00,
		0.00,
		0.00,
		reasegurada,
		vigencia_inic,
		vigencia_final,
		beneficio_max,
		desc_unidad,
		0.00,
		0.00,
		0
  from emipouni
 where no_poliza = a_no_poliza;

{select count(*)
  into _cnt_agt
  from emipoagt
 where no_poliza = a_no_poliza
   and cod_agente <> a_cod_agente_old;

if _cnt_agt is null then
	let _cnt_agt = 0;
end if


if _cnt_agt = 0 then
	insert into endmoage(
			no_poliza,
			no_endoso,
			cod_agente,
			porc_partic_agt,
			porc_comis_agt,
			porc_produc)
	select	no_poliza,
			_no_endoso,
			a_cod_agente_new,
			porc_partic_agt,
			porc_comis_agt,
			porc_produc
	   from emipoagt
	  where no_poliza = a_no_poliza
		and cod_agente = a_cod_agente_old;
else
	insert into endmoage(
			no_poliza,
			no_endoso,
			cod_agente,
			porc_partic_agt,
			porc_comis_agt,
			porc_produc)
	select	no_poliza,
			_no_endoso,
			cod_agente,
			porc_partic_agt,
			porc_comis_agt,
			porc_produc
	   from emipoagt
	  where no_poliza = a_no_poliza;

	update endmoage
	   set cod_agente = a_cod_agente_new
	 where no_poliza = a_no_poliza
	   and no_endoso = _no_endoso
	   and cod_agente = a_cod_agente_old;
end if}

insert into endmoage(
		no_poliza,
		no_endoso,
		cod_agente,
		porc_partic_agt,
		porc_comis_agt,
		porc_produc)
select *
  from (select no_poliza,
				_no_endoso,
				cod_agente,
				porc_partic_agt,
				porc_comis_agt,
				porc_produc
		   from emipoagt
		  where no_poliza = a_no_poliza
			and cod_agente not in (a_cod_agente_old,a_cod_agente_new)
		union
		 select no_poliza,
				_no_endoso,
				a_cod_agente_new,
				sum(porc_partic_agt),
				porc_comis_agt,
				sum(porc_produc)
		   from emipoagt
		  where no_poliza = a_no_poliza
			and cod_agente in (a_cod_agente_old,a_cod_agente_new)
		  group by no_poliza,porc_comis_agt
		) as tmp_emipoliza;

if a_cod_agente_new = '02569' and a_cod_agente_new = a_cod_agente_old then
	update endmoage
	   set porc_comis_agt = 25.5   ---AMORENO 23/08/2019
	 where no_poliza = a_no_poliza
	   and no_endoso = _no_endoso
	   and cod_agente = a_cod_agente_new;
end if

if a_cod_agente_new in ('02649','00849') and  a_cod_agente_old  = '00473' then
	update endmoage
	   set porc_partic_agt = 40
	 where no_poliza = a_no_poliza
	   and no_endoso = _no_endoso
	   and cod_agente = a_cod_agente_new;
	
	insert into endmoage(
		no_poliza,
		no_endoso,
		cod_agente,
		porc_partic_agt,
		porc_comis_agt,
		porc_produc)
	select no_poliza,
				_no_endoso,
				a_cod_agente_old,
				60,
				porc_comis_agt,
				sum(porc_produc)
		   from emipoagt
		  where no_poliza = a_no_poliza
			and cod_agente in (a_cod_agente_old)
		  group by no_poliza,porc_comis_agt;
elif a_cod_agente_new in ('00547','00177') and  a_cod_agente_old  = '01486' then
	update endmoage
	   set porc_partic_agt = 40
	 where no_poliza = a_no_poliza
	   and no_endoso = _no_endoso
	   and cod_agente = a_cod_agente_new;
	
	insert into endmoage(
		no_poliza,
		no_endoso,
		cod_agente,
		porc_partic_agt,
		porc_comis_agt,
		porc_produc)
	select no_poliza,
		   _no_endoso,
		   '00177',
		   60,
		   porc_comis_agt,
		   sum(porc_produc)
	  from emipoagt
	 where no_poliza = a_no_poliza
	   and cod_agente in (a_cod_agente_old)
	 group by no_poliza,porc_comis_agt;
	 
elif a_cod_agente_new in ('02420') and  a_cod_agente_old  = '00083' then  --SD#7837 ISMAEL VALLARINO 14/09/2023 HGIRON
	update endmoage
	   set porc_partic_agt = 50
	 where no_poliza = a_no_poliza
	   and no_endoso = _no_endoso
	   and cod_agente = a_cod_agente_new;
	
	insert into endmoage(
		no_poliza,
		no_endoso,
		cod_agente,
		porc_partic_agt,
		porc_comis_agt,
		porc_produc)
	select no_poliza,
		   _no_endoso,
		   a_cod_agente_old,
		   50,
		   porc_comis_agt,
		   sum(porc_produc)
	  from emipoagt
	 where no_poliza = a_no_poliza
	   and cod_agente in (a_cod_agente_old)
	 group by no_poliza,porc_comis_agt;	 
elif a_cod_agente_new in ('02667') and  a_cod_agente_old  = '01834' then  --SD#7837 ISMAEL VALLARINO 14/09/2023 HGIRON
	update endmoage
	   set porc_partic_agt = 50
	 where no_poliza = a_no_poliza
	   and no_endoso = _no_endoso
	   and cod_agente = a_cod_agente_new;
	
	insert into endmoage(
		no_poliza,
		no_endoso,
		cod_agente,
		porc_partic_agt,
		porc_comis_agt,
		porc_produc)
	select no_poliza,
		   _no_endoso,
		   '03053',
		   50,
		   porc_comis_agt,
		   sum(porc_produc)
	  from emipoagt
	 where no_poliza = a_no_poliza
	   and cod_agente in (a_cod_agente_old)
	 group by no_poliza,porc_comis_agt;	 
	 
elif a_cod_agente_new in ('02420') and  a_cod_agente_old  = '00448' then  --SD#7854 ISMAEL VALLARINO 14/09/2023 HGIRON
	update endmoage
	   set porc_partic_agt = 50
	 where no_poliza = a_no_poliza
	   and no_endoso = _no_endoso
	   and cod_agente = a_cod_agente_new;
	
	insert into endmoage(
		no_poliza,
		no_endoso,
		cod_agente,
		porc_partic_agt,
		porc_comis_agt,
		porc_produc)
	select no_poliza,
		   _no_endoso,
		   a_cod_agente_old,
		   50,
		   porc_comis_agt,
		   sum(porc_produc)
	  from emipoagt
	 where no_poliza = a_no_poliza
	   and cod_agente in (a_cod_agente_old)
	 group by no_poliza,porc_comis_agt;	 	 
	
end if


call sp_pro43(a_no_poliza, _no_endoso) returning _error, _descripcion;

if _error <> 0 then
	return _error, _descripcion, _no_endoso;
end if

return 0, "Actualizacion Exitosa", _no_endoso;

end
end procedure;