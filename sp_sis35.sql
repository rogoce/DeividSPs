-- Procedure para los Triggers de Endedmae

-- Creado    : 05/08/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 05/08/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure pu_endedmae;

create procedure pu_endedmae(
a_no_poliza				char(10),
a_no_endoso				char(5),
a_cod_compania			char(3),
a_cod_sucursal			char(3),
a_cod_tipocalc			char(3),
a_cod_formapag			char(3),
a_cod_tipocan			char(3),
a_cod_perpago			char(3),
a_cod_endomov			char(3),
a_no_documento			char(20),
a_vigencia_inic			date,
a_vigencia_final		date,
a_prima					dec(16,2),
a_descuento				dec(16,2),
a_recargo				dec(16,2),
a_prima_neta			dec(16,2),
a_impuesto				dec(16,2),
a_prima_bruta			dec(16,2),
a_prima_suscrita		dec(16,2),
a_prima_retenida		dec(16,2),
a_tiene_impuesto		smallint,
a_fecha_emision			date,
a_fecha_impresion		date,
a_fecha_primer_pago		date,
a_no_pagos				smallint,
a_actualizado			smallint,
a_no_factura			char(10),
a_fact_reversar			char(10),
a_date_added			date,
a_date_changed			date,
a_interna				smallint,
a_periodo				char(7),
a_user_added			char(8),
a_factor_vigencia		dec(9,6),
a_suma_asegurada		dec(16,2),
a_posteado				char(1),
a_activa				smallint,
a_vigencia_inic_pol		date,
a_vigencia_final_pol	date,
a_no_endoso_ext			char(5)
);

define _fecha 		date;
define _user  		char(8);
define _current		datetime year to fraction(5);

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
values(
a_no_poliza,		  
a_no_endoso,		  
a_cod_compania,	  
a_cod_sucursal,	  
a_cod_tipocalc,	  
a_cod_formapag,	  
a_cod_tipocan,		  
a_cod_perpago,		  
a_cod_endomov,		  
a_no_documento,	  
a_vigencia_inic,	  
a_vigencia_final,	  
a_prima,			  
a_descuento,		  
a_recargo,			  
a_prima_neta,		  
a_impuesto,		  
a_prima_bruta,		  
a_prima_suscrita,	  
a_prima_retenida,	  
a_tiene_impuesto,	  
_fecha,	  
_fecha,	  
a_fecha_primer_pago, 
a_no_pagos,		  
a_actualizado,		  
a_no_factura,		  
a_fact_reversar,	  
_fecha,		  
_fecha,	  
a_interna,			  
a_periodo,			  
_user,		  
a_factor_vigencia,	  
a_suma_asegurada,	  
a_posteado,		  
a_activa,			  
a_vigencia_inic_pol, 
a_vigencia_final_pol,
a_no_endoso_ext,
"Update",
_current
);

end procedure



