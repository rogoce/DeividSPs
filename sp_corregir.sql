-- Procedure que determina cuales facturas han cambiado
-- desde que se crearon

-- Creado    : 31/07/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 31/07/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_corregir;

create procedure sp_corregir(a_compania  CHAR(3),a_agencia   CHAR(3))
returning char(20),
          date,
		  date,
		  date,
		  char(10);

define _no_poliza			char(10);
define _no_endoso			char(5);
define _referencia			char(100);
define _no_documento        char(20);
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
define _vigencia_inic	date;
define _vigencia_final	date;
define _no_endoso_ext1		char(5);
define _fecha_aviso_canc    date;
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
define _ano					smallint;
define _cnt integer;

set isolation to dirty read;

foreach

	select no_documento,
	       fecha_aviso_canc,
		   vigencia_inic,
		   vigencia_final,
		   no_poliza
	  into _no_documento,
	       _fecha_aviso_canc,
		   _vigencia_inic,
		   _vigencia_final,
		   _no_poliza
	  from emipomae
	 where actualizado = 1
	   and carta_aviso_canc = 1
	   and fecha_aviso_canc between "01/08/2009" and "28/02/2010"


		select count(*)
		  into _cnt
		  from emipoagt
		 where no_poliza = _no_poliza
		   and cod_agente = "00180";

		if _cnt = 0 then
		else
		   return _no_documento,
		          _fecha_aviso_canc,
			   	  _vigencia_inic,
			      _vigencia_final,
				  _no_poliza
			   with resume;
			
		end if

end foreach


{let _ano = year(today) - 2;

foreach
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
 where periodo[1,4] >= _ano
 order by periodo DESC, fecha_impresion DESC

	select cod_compania,
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
	  into _cod_compania2,
	       _cod_sucursal2,
	       _cod_tipocalc2,
	       _cod_formapag2,
	       _cod_tipocan2,
	       _cod_perpago2,
	       _cod_endomov2,
	       _no_documento2,
	       _vigencia_inic2,
	       _vigencia_final2,
	       _prima2,
	       _descuento2,
	       _recargo2,
	       _prima_neta2,
	       _impuesto2,
	       _prima_bruta2,
	       _prima_suscrita2,
	       _prima_retenida2,
	       _tiene_impuesto2,
	       _fecha_emision2,
	       _fecha_impresion2,
	       _fecha_primer_pago2,
	       _no_pagos2,
	       _actualizado2,
	       _no_factura2,
	       _fact_reversar2,
	       _interna2,
	       _periodo2,
	       _factor_vigencia2,
	       _suma_asegurada2,
	       _posteado2,
	       _activa2,
	       _vigencia_inic_pol2,
	       _vigencia_final_pol2,
	       _no_endoso_ext2
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;


	if _periodo1 <> _periodo2 then

		let _referencia = "Periodo";
		let _diferente1 = _periodo1;
		let _diferente2 = _periodo2;

	   {	update endedhis
		   set periodo   = _periodo2
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;}

{		return _no_poliza,
		       _no_endoso,
			   _no_factura1,
			   _no_documento1,
			   _diferente1,
			   _diferente2,
			   _referencia,
			   _periodo1,
			   1
			   with resume;

	end if

end foreach	} 

end procedure

