
-- Procedimiento para insertar el endoso de descuento apoyo COVID-19
-- Amado Perez M - 27/04/2020

drop procedure sp_pro417;

create procedure sp_pro417(
	a_periodo			char(7),
	a_no_poliza			char(10),
	a_prima_bruta_end	dec(16,2)) 
returning	smallint,
		    char(5),
			char(100);

define _error_desc			char(30);
define _no_documento		char(20);
define _cod_pagador         char(10);
define _no_endoso_ext		char(5);
define _no_endoso       	char(5);
define v_unidad          	char(5);
define _cod_endomov     	char(3);
define _cod_ramo            char(3);
define	v_mes_string		char(2);
define _null            	char(1);
define v_cobertura       	char(5);
define v_periodo			char(7);
define v_factor 			dec(9,6);
define	v_prima_suscrita	dec(16,2);
define 	v_prima_retenida	dec(16,2);
define  v_suma_asegurada   	dec(16,2);
define 	v_porc_recargo		dec(16,2);
define	v_total_descto		dec(16,2);
define v_prima_bruta		dec(16,2);
define	v_prima_neta		dec(16,2);
define	v_impuesto			dec(16,2);
define _prima_neta			dec(16,2);
define	v_prima_br			dec(16,2);
define  v_gastos			dec(16,2);
define	v_prima				dec(16,2);
define	v_existe_end		smallint;
define	_existe_rev			smallint;
define	v_mes_actual		smallint;
define _error_isam 	    	smallint;
define _error     	    	smallint;
define _no_endoso_ent		integer;
define _dias                integer;
define v_fecha_actual		date;
define  _fecha_hoy          date;
define _vigencia_i          date;
define _fecha_sus           date;
define _fecha_gestion   	datetime year to second;
define 	a_user				char(8);


set isolation to dirty read;

begin

on exception set _error,_error_isam,_error_desc
 	return _error, '',_error_desc;
end exception

let a_user = 'DEIVID';

--periodo
let v_fecha_actual = sp_sis26();
let v_mes_string = month(v_fecha_actual);
let v_mes_actual =  length(v_mes_string);

if v_mes_actual = 1 then
	let v_mes_string = "0" || month(v_fecha_actual);
else	
	let v_mes_string = month(v_fecha_actual);
end if

let v_periodo = year(v_fecha_actual) || "-" || v_mes_string;


--verifica si ya se le hizo el descuento a la poliza
let v_existe_end = 0;
let _fecha_hoy   = current;

let a_prima_bruta_end = a_prima_bruta_end * -1;

select no_documento,cod_pagador
  into _no_documento,_cod_pagador
  from emipomae
 where no_poliza = a_no_poliza;

select count(*)
  into v_existe_end
  from endedmae
 where no_poliza = a_no_poliza
   and cod_endomov = '033'
   and periodo = a_periodo
   and actualizado = 1;

{select count(*)
  into _existe_rev
  from endedmae
 where no_poliza	= a_no_poliza
   and cod_endomov	= '025'
   and actualizado  = 1;
}
if v_existe_end > 0 then
	let _error_desc = 'Esta póliza ya tiene el endoso de descuento aplicado, Por Favor Verifique...';
	return 1,'',_error_desc;
end if
   
--regresa el nuevo numero de endoso
let _no_endoso = sp_sis90(a_no_poliza);
let _no_endoso_ent = _no_endoso + 1;
let _no_endoso = sp_set_codigo(5, _no_endoso_ent);

let _cod_endomov   = "033";
let _no_endoso_ext = _no_endoso;

let _null      = null;

-- eliminar registros
delete from endeddes where no_poliza = a_no_poliza and no_endoso = _no_endoso;
delete from endedrec where no_poliza = a_no_poliza and no_endoso = _no_endoso;
delete from endedimp where no_poliza = a_no_poliza and no_endoso = _no_endoso;
delete from endunide where no_poliza = a_no_poliza and no_endoso = _no_endoso;
delete from endunire where no_poliza = a_no_poliza and no_endoso = _no_endoso;
delete from endedde2 where no_poliza = a_no_poliza and no_endoso = _no_endoso;
delete from endedacr where no_poliza = a_no_poliza and no_endoso = _no_endoso;
delete from endmoaut where no_poliza = a_no_poliza and no_endoso = _no_endoso;
delete from endmotrd where no_poliza = a_no_poliza and no_endoso = _no_endoso;
delete from endmotra where no_poliza = a_no_poliza and no_endoso = _no_endoso;
delete from endcuend where no_poliza = a_no_poliza and no_endoso = _no_endoso;
delete from endcobre where no_poliza = a_no_poliza and no_endoso = _no_endoso;
delete from endcobde where no_poliza = a_no_poliza and no_endoso = _no_endoso;
delete from endedcob where no_poliza = a_no_poliza and no_endoso = _no_endoso;
delete from endcoama where no_poliza = a_no_poliza and no_endoso = _no_endoso;

-- tablas no tienen instrucciones insert
delete from endmoage where no_poliza = a_no_poliza and no_endoso = _no_endoso;
delete from endmoase where no_poliza = a_no_poliza and no_endoso = _no_endoso;
delete from endcamco where no_poliza = a_no_poliza and no_endoso = _no_endoso;
delete from endedde1 where no_poliza = a_no_poliza and no_endoso = _no_endoso;

delete from endeduni where no_poliza = a_no_poliza and no_endoso = _no_endoso;
delete from endedmae where no_poliza = a_no_poliza and no_endoso = _no_endoso;
delete from endedhis where no_poliza = a_no_poliza and no_endoso = _no_endoso;

--endoso de pronto pago
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
		gastos)
select	a_no_poliza,
		_no_endoso,
		cod_compania,
		cod_sucursal,
		"006",
		cod_formapag,
		_null,
		cod_perpago,
		_cod_endomov,
		no_documento,
		vigencia_inic,
		vigencia_final,
		0,
		0,
		0,
		0,
		0,
		a_prima_bruta_end,
		0,
		0,
		tiene_impuesto,
		fecha_suscripcion,
		fecha_impresion,
		fecha_primer_pago,
		no_pagos,
		0,
		_null,
		_null,
		v_fecha_actual,
		v_fecha_actual,
		0,
		v_periodo,
		a_user,
		factor_vigencia,
		0,
		posteado,
		1,
		vigencia_inic,
		vigencia_final,
		_no_endoso_ext,
		cod_tipoprod,
		gastos
  from emipomae
 where no_poliza = a_no_poliza;

insert into endeddes(
		no_poliza,
		no_endoso,
		cod_descuen,
		porc_descuento)
select a_no_poliza,
	   _no_endoso,
	   cod_descuen,
	   porc_descuento
  from emipolde
 where no_poliza = a_no_poliza;

-- Recargos
insert into endedrec(
		no_poliza,
		no_endoso,
		cod_recargo,
		porc_recargo)
select a_no_poliza,
	   _no_endoso,
	   cod_recargo,
	   porc_recargo
  from emiporec
 where no_poliza = a_no_poliza;

-- Impuestos
insert into endedimp(
	no_poliza,
	no_endoso,
	cod_impuesto,
	monto)
select a_no_poliza,
	   _no_endoso,
	   cod_impuesto,
	   monto
from emipolim
where no_poliza = a_no_poliza;

--actualización de endoso
let _error = 0;
call sp_pro493(a_no_poliza, _no_endoso, 1.00) returning _error, _error_desc;

if _error = 1 then
	return 1, _no_endoso,_error_desc;
end if

select sum(prima_suscrita),
	   sum(prima_retenida),
	   sum(prima),
	   sum(descuento),
	   sum(recargo),
	   sum(prima_neta),
	   sum(impuesto),
	   sum(prima_bruta),
	   sum(suma_asegurada),
	   sum(gastos)
  into v_prima_suscrita,
	   v_prima_retenida,
	   v_prima,
	   v_total_descto,
	   v_porc_recargo,
	   v_prima_neta,
	   v_impuesto,
	   v_prima_br,
	   v_suma_asegurada,
	   v_gastos
  from endeduni
 where no_poliza = a_no_poliza
   and no_endoso = _no_endoso ;
   
update endedmae
   set prima = v_prima,
       descuento = v_total_descto,
       recargo = v_porc_recargo,
       prima_neta = v_prima_neta,
       impuesto = v_impuesto,
       prima_bruta = v_prima_br,
       prima_suscrita = v_prima_suscrita,   
       prima_retenida = v_prima_retenida  
 where no_poliza = a_no_poliza
   and no_endoso = _no_endoso;

let _error = 0;
call sp_pro43(a_no_poliza, _no_endoso) returning _error, _error_desc;

if _error = 1 then
	return 1,_no_endoso, _error_desc;
end if

let _fecha_gestion  = current year to second;
let _fecha_gestion  = _fecha_gestion + 1 units second;

--creacion de la gestion
insert into cobgesti(
		no_poliza,
		fecha_gestion,
		desc_gestion,
		user_added,
		no_documento,
		fecha_aviso,
		tipo_aviso,
		cod_pagador)
values(	a_no_poliza,
		_fecha_gestion,
		'APOYO ANCON PLUS AUTOMOVIL APLICADO. PERIODO: ' || a_periodo,
		a_user,
		_no_documento,
		_null,
		0,
		_cod_pagador
		);
		
--Creacion del registro en parmailsend
--call sp_cob300(a_no_poliza) returning _error, _error_desc;

return 0,_no_endoso, "Actualizacion Exitosa...";
end
end procedure;

