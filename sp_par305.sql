-- Procedimiento que genera las eliminaciones de unidades por Cancelacion de Saldo
-- Creado     : 01/10/2010 - Autor: Henry Giron 
-- SIS v.2.0 - DEIVID, S.A.

Drop procedure sp_par305;
create procedure sp_par305(
a_no_poliza		char(10),
a_no_unidad		char(5),
a_usuario		char(8),
a_saldo			dec(16,2),
a_fecha_cancela date
) returning integer,
            char(250),
            char(5);

define _cod_endomov		char(3);
define _cod_tipocan		char(3);
define _cod_tipocalc	char(3);

define _null			char(1);
define _periodo			char(7);
define _no_endoso_int	smallint;
define _no_endoso		char(5);
define _no_endoso_ext	char(5);
define _tiene_impuesto	smallint;
define _cantidad		smallint;
define _vigencia_inic	date;
define _vigencia_final	date;
define _cant_dias		smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(250);
define _descripcion		char(250);

define _prima_suscrita	dec(16,2);
define _prima_retenida 	dec(16,2);
define _prima 			dec(16,2);
define _descuento		dec(16,2);
define _recargo			dec(16,2);
define _prima_neta		dec(16,2);
define _impuesto		dec(16,2);
define _prima_bruta		dec(16,2);
define _suma_asegurada	dec(16,2);
define _suma_impuesto	dec(16,2);
define _factor_impuesto	dec(16,2);
define _cod_impuesto	char(3);
define a_cod_ramo       char(3);
define _no_documento    CHAR(20);
define _cod_tiporamo    CHAR(3);
define _firma_end_canc  char(20);
define _vigen_ini		date;
define _vigen_fin		date;
define _fecha_hoy		date;
define _factor_vig		dec(16,5);
define _dias1			integer;
define _dias2			integer;
define _vig_fin_max     date;

--set debug file to "sp_par280.trc";
--trace on;

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc, "";
end exception

set isolation to dirty read;
let _firma_end_canc = "";
--let _fecha_hoy      = today;   -- '03/08/2011';
let _fecha_hoy      = sp_sis26();
let _null	    	= null ;   -- Para campos null

select emi_periodo
  into _periodo
  from parparam
 where cod_compania = "001";
let _factor_vig = -1;

foreach
 select cod_ramo,no_documento,vigencia_inic,vigencia_final
   into a_cod_ramo,_no_documento,_vigen_ini, _vigen_fin
   from emipomae
  where no_poliza   = a_no_poliza
	and actualizado = 1
  order by vigencia_final desc
	exit foreach;
end foreach

select cod_tiporamo 
  into _cod_tiporamo
  from prdramo 
 where cod_ramo = a_cod_ramo;

if _cod_tiporamo = "001" then   -- 'PERSONAS'  
	let _cod_endomov  = "002";  -- Cancelacion de Poliza
	let _cod_tipocan  = "001";  -- Falta de Pago
	let _cod_tipocalc = "004";  -- SALDO o FLAT
elif _cod_tiporamo = "002" then	-- 'DANIOS o PATRIMONIALES'
	let _cod_endomov  = "002";  -- Cancelacion de Poliza
	let _cod_tipocan  = "001";  -- Falta de Pago
	let _cod_tipocalc = "001";  -- PRORRATA
else						    
	return 1, "Poliza "||_no_documento||" fuera de la condiciones.",a_no_poliza;
end if
let _vig_fin_max = a_fecha_cancela;
{if a_fecha_cancela >= _vigen_fin then
	let _vig_fin_max = _vigen_fin;
end if}
let _dias1      = _vigen_fin - _vigen_ini;
if _dias1 > 365 then
	let _dias1 = 365;
end if
let _dias2      = _vig_fin_max - _vigen_fin;
if _dias2 = 0 then
   let _dias2 = -1;
end if
let _factor_vig = round(_dias2 / _dias1,3);
if 	_factor_vig > 0 then
	let _factor_vig = _factor_vig * -1 ;
end if

select max(no_endoso)
  into _no_endoso_int
  from endedmae
 where no_poliza = a_no_poliza;

let _no_endoso      = sp_set_codigo(5, _no_endoso_int + 1);
let _no_endoso_ext  = sp_sis30(a_no_poliza, _no_endoso);


let _cant_dias = _vigencia_final - _vigencia_inic;
if _cod_tiporamo = "001" then   -- 'PERSONAS'  
	let _factor_vig = -1;
end if


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
select 
no_poliza,
_no_endoso,
cod_compania,
cod_sucursal,
_cod_tipocalc,
cod_formapag,
_cod_tipocan, 
cod_perpago,
_cod_endomov,
no_documento,
_vig_fin_max, -- a_fecha_cancela, -- vigencia_inic,
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
_fecha_hoy,
_fecha_hoy,
_fecha_hoy,
1,
0,
_null,
_null,
_fecha_hoy,
_fecha_hoy,
0,   --1,
_periodo,
a_usuario,
_factor_vig,
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
	monto
	)
	select 
	no_poliza,
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

	Let _suma_impuesto = 0.00;

	Foreach	
	 Select cod_impuesto
	   Into _cod_impuesto
	   From emipolim
	  Where no_poliza = a_no_poliza

		Select factor_impuesto
		  Into _factor_impuesto
		  From prdimpue
		 Where cod_impuesto = _cod_impuesto;
			    
		Let _suma_impuesto = _suma_impuesto  + (_factor_impuesto / 100);

	End Foreach

	let _prima_neta = _prima_bruta / (1 + _suma_impuesto);

else

	let _prima_neta = _prima_bruta;

end if

let _impuesto = _prima_bruta - _prima_neta;

select firma_end_canc
  into _firma_end_canc
  from parparam
 where cod_compania = "001";

if _firma_end_canc is null then
	let _firma_end_canc = "JMILLER";
end if


update endedmae
   set prima_neta     = _prima_neta,
	   impuesto       = _impuesto,
	   prima_bruta    = _prima_bruta,
	   wf_firma_aprob = _firma_end_canc 
 where no_poliza      = a_no_poliza
   and no_endoso      = _no_endoso;

select vigencia_inic,
       vigencia_final
  into _vigencia_inic,
       _vigencia_final
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = _no_endoso;

--trace on;
call sp_pro463(a_no_poliza, _no_endoso, a_no_unidad, _cant_dias, _factor_vig) returning _error, 
                                                                              _descripcion, 
                                                                              _prima, 
                                                                              _descuento, 
                                                                              _recargo, 
                                                                              _prima_neta, 
                                                                              _impuesto, 
                                                                              _prima_bruta; 
--trace off;

if _error <> 0 then
	return _error, _descripcion, _no_endoso;
end if

update endeduni
   set prima_suscrita = 0,
       prima_retenida = 0
 where no_poliza      = a_no_poliza
   and no_endoso      = _no_endoso;

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

--{
update endedmae
   set prima          = _prima,
       descuento      = _descuento,
	   recargo        = _recargo,
	   prima_suscrita = _prima_suscrita,
	   prima_retenida = _prima_retenida,
	   suma_asegurada = _suma_asegurada
 where no_poliza      = a_no_poliza
   and no_endoso      = _no_endoso;
--}

end
let _error = 0;
--Caso de Renovacion automatica
let _cantidad = 0;
select count(*) into _cantidad from emireaut where no_poliza = a_no_poliza;
if _cantidad > 0 then 
	call sp_sis61d(a_no_poliza) returning _error;
end if
call sp_pro43(a_no_poliza, _no_endoso) returning _error, _descripcion;
if _error <> 0 then
	return _error, _descripcion, _no_endoso;
end if
return 0, "Actualizacion Exitosa", _no_endoso;
end procedure