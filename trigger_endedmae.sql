-- Procedure para los Triggers de Endedmae

-- Creado    : 05/08/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 05/08/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure pu_endedmae;

create procedure pu_endedmae(a_no_poliza char(10), a_no_endoso char(5));

define _fecha 		date;
define _user  		char(8);
define _current		datetime year to second;


let _fecha   = today;
let _user    = user;
let _current = current;


insert into endedtri(
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
tipo,
tiempo
)
select
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
_fecha,	  
_fecha,	  
fecha_primer_pago, 
no_pagos,		  
actualizado,		  
no_factura,		  
fact_reversar,	  
_fecha,		  
_fecha,	  
interna,			  
periodo,			  
_user,		  
factor_vigencia,	  
suma_asegurada,	  
posteado,		  
activa,			  
vigencia_inic_pol, 
vigencia_final_pol,
no_endoso_ext,
"Update",
_current
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;	  

end procedure


