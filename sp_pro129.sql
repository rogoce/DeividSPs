-- Procedure que determina cuales facturas han cambiado
-- desde que se crearon

-- Creado    : 31/07/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 31/07/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro129;

create procedure sp_pro129(a_no_factura char(10))
returning char(100);

define _no_poliza			char(10);
define _no_endoso			char(5);
define _referencia			char(100);

define _cod_compania1		char(3);
define _cod_sucursal1		char(3);
define _cod_tipocalc1		char(3);
define _cod_formapag1		char(3);
define _cod_tipocan1		char(3);
define _cod_perpago1		char(3);
define _cod_endomov1		char(3);
define _no_documento1		char(20);
define _vigencia_inic1		date;
define _vigencia_final1		date;
define _prima1				dec(16,2);
define _descuento1			dec(16,2);
define _recargo1			dec(16,2);
define _prima_neta1			dec(16,2);
define _impuesto1			dec(16,2);
define _prima_bruta1		dec(16,2);
define _prima_suscrita1		dec(16,2);
define _prima_retenida1		dec(16,2);
define _tiene_impuesto1		smallint;
define _fecha_emision1		date;
define _fecha_impresion1	date;
define _fecha_primer_pago1	date;
define _no_pagos1			smallint;
define _actualizado1		smallint;
define _no_factura1			char(10);
define _fact_reversar1		char(10);
define _interna1			smallint;
define _periodo1			char(7);
define _factor_vigencia1	dec(9,6);
define _suma_asegurada1		dec(16,2);
define _posteado1			char(1);
define _activa1				smallint;
define _vigencia_inic_pol1	date;
define _vigencia_final_pol1	date;
define _no_endoso_ext1		char(5);

define _cod_compania2		char(3);
define _cod_sucursal2		char(3);
define _cod_tipocalc2		char(3);
define _cod_formapag2		char(3);
define _cod_tipocan2		char(3);
define _cod_perpago2		char(3);
define _cod_endomov2		char(3);
define _no_documento2		char(20);
define _vigencia_inic2		date;
define _vigencia_final2		date;
define _prima2				dec(16,2);
define _descuento2			dec(16,2);
define _recargo2			dec(16,2);
define _prima_neta2			dec(16,2);
define _impuesto2			dec(16,2);
define _prima_bruta2		dec(16,2);
define _prima_suscrita2		dec(16,2);
define _prima_retenida2		dec(16,2);
define _tiene_impuesto2		smallint;
define _fecha_emision2		date;
define _fecha_impresion2	date;
define _fecha_primer_pago2	date;
define _no_pagos2			smallint;
define _actualizado2		smallint;
define _no_factura2			char(10);
define _fact_reversar2		char(10);
define _interna2			smallint;
define _periodo2			char(7);
define _factor_vigencia2	dec(9,6);
define _suma_asegurada2		dec(16,2);
define _posteado2			char(1);
define _activa2				smallint;
define _vigencia_inic_pol2	date;
define _vigencia_final_pol2	date;
define _no_endoso_ext2		char(5);

define _diferente1			char(16);
define _diferente2			char(16);

select no_poliza,
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
       interna,
       periodo,
       factor_vigencia,
       suma_asegurada,
       posteado,
       activa,
       vigencia_inic_pol,
       vigencia_final_pol,
       no_endoso_ext
  into _no_poliza,
       _no_endoso,
       _cod_compania1,
       _cod_sucursal1,
       _cod_tipocalc1,
       _cod_formapag1,
       _cod_tipocan1,
       _cod_perpago1,
       _cod_endomov1,
       _no_documento1,
       _vigencia_inic1,
       _vigencia_final1,
       _prima1,
       _descuento1,
       _recargo1,
       _prima_neta1,
       _impuesto1,
       _prima_bruta1,
       _prima_suscrita1,
       _prima_retenida1,
       _tiene_impuesto1,
       _fecha_emision1,
       _fecha_impresion1,
       _fecha_primer_pago1,
       _no_pagos1,
       _actualizado1,
       _no_factura1,
       _fact_reversar1,
       _interna1,
       _periodo1,
       _factor_vigencia1,
       _suma_asegurada1,
       _posteado1,
       _activa1,
       _vigencia_inic_pol1,
       _vigencia_final_pol1,
       _no_endoso_ext1
  from endedhis
 where no_factura = a_no_factura;

	update endedmae
	   set prima		   = _prima1,
	       descuento	   = _descuento1,
	       recargo		   = _recargo1,
	       prima_neta	   = _prima_neta1,
	       impuesto	       = _impuesto1,
	       prima_bruta	   = _prima_bruta1,
	       prima_suscrita  = _prima_suscrita1,
	       prima_retenida  = _prima_retenida1,
	       tiene_impuesto  = _tiene_impuesto1,
	       actualizado 	   = _actualizado1,
	       no_factura 	   = _no_factura1,
	       fact_reversar   = _fact_reversar1,
	       periodo		   = _periodo1,
	       factor_vigencia = _factor_vigencia1,
	       suma_asegurada  = _suma_asegurada1,
	       activa		   = _activa1
	 where no_poliza       = _no_poliza
	   and no_endoso       = _no_endoso;

return "Actualizacion Exitosa ...";

end procedure

