-- Procedure que determina cuales facturas han cambiado
-- desde que se crearon

-- Creado    : 31/07/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 31/07/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro128_sac;

create procedure sp_pro128_sac()
returning integer,
		  varchar(100);

define _no_poliza				char(10);
define _no_endoso				char(5);
define _referencia			varchar(100);

define _cod_compania1			char(3);
define _cod_sucursal1			char(3);
define _cod_tipocalc1			char(3);
define _cod_formapag1			char(3);
define _cod_tipocan1			char(3);
define _cod_perpago1			char(3);
define _cod_endomov1			char(3);
define _no_documento1			char(20);
define _vigencia_inic1		date;
define _vigencia_final1		date;
define _prima1					dec(16,2);
define _descuento1			dec(16,2);
define _recargo1				dec(16,2);
define _prima_neta1			dec(16,2);
define _impuesto1				dec(16,2);
define _prima_bruta1			dec(16,2);
define _prima_suscrita1		dec(16,2);
define _prima_retenida1		dec(16,2);
define _tiene_impuesto1		smallint;
define _fecha_emision1		date;
define _fecha_impresion1		date;
define _fecha_primer_pago1	date;
define _no_pagos1				smallint;
define _actualizado1			smallint;
define _no_factura1			char(10);
define _fact_reversar1		char(10);
define _interna1				smallint;
define _periodo1				char(7);
define _factor_vigencia1		dec(9,6);
define _suma_asegurada1		dec(16,2);
define _posteado1				char(1);
define _activa1				smallint;
define _vigencia_inic_pol1	date;
define _vigencia_final_pol1	date;
define _no_endoso_ext1		char(5);

define _cod_compania2			char(3);
define _cod_sucursal2			char(3);
define _cod_tipocalc2			char(3);
define _cod_formapag2			char(3);
define _cod_tipocan2			char(3);
define _cod_perpago2			char(3);
define _cod_endomov2			char(3);
define _no_documento2			char(20);
define _vigencia_inic2		date;
define _vigencia_final2		date;
define _prima2					dec(16,2);
define _descuento2			dec(16,2);
define _recargo2				dec(16,2);
define _prima_neta2			dec(16,2);
define _impuesto2				dec(16,2);
define _prima_bruta2			dec(16,2);
define _prima_suscrita2		dec(16,2);
define _prima_retenida2		dec(16,2);
define _tiene_impuesto2		smallint;
define _fecha_emision2		date;
define _fecha_impresion2		date;
define _fecha_primer_pago2	date;
define _no_pagos2				smallint;
define _actualizado2			smallint;
define _no_factura2			char(10);
define _fact_reversar2		char(10);
define _interna2				smallint;
define _periodo2				char(7);
define _factor_vigencia2		dec(9,6);
define _suma_asegurada2		dec(16,2);
define _posteado2				char(1);
define _activa2				smallint;
define _vigencia_inic_pol2	date;
define _vigencia_final_pol2	date;
define _no_endoso_ext2		char(5);

define _diferente1			char(16);
define _diferente2			char(16);

define _error_fact			smallint;

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

	if _cod_compania2 is null then

		let _referencia = "Factura No Existe";
		let _diferente1 = _no_factura1;
		let _diferente2 = "";
		
		return 1,
			   _referencia || " " || _no_factura1
			   with resume;

		let _error_fact = 1;

	end if

	if _prima_suscrita1 <> _prima_suscrita2 then

		let _referencia = "Prima Suscrita";
		let _diferente1 = _prima_suscrita1;
		let _diferente2 = _prima_suscrita2;

		let _referencia = _referencia || " " || _no_factura1 || " " || _diferente1 || " " || _diferente2; 

		return 1, _referencia with resume;

	end if
	   
	if _prima_neta1 <> _prima_neta2 then

		let _referencia = "Prima Neta";
		let _diferente1 = _prima_neta1;
		let _diferente2 = _prima_neta2;

		let _referencia = _referencia || " " || _no_factura1 || " " || _diferente1 || " " || _diferente2; 

		return 1, _referencia with resume;

	end if

	if _prima_bruta1 <> _prima_bruta2 then

		let _referencia = "Prima Bruta";
		let _diferente1 = _prima_bruta1;
		let _diferente2 = _prima_bruta2;

		let _referencia = _referencia || " " || _no_factura1 || " " || _diferente1 || " " || _diferente2; 

		return 1, _referencia with resume;

	end if

	{
	let _referencia = null;
	let _error_fact = 0;
	}

end foreach

return 0, "Verificacion Completada";

{
	if _prima1 <> _prima2 then

		let _referencia = "Prima";
		let _diferente1 = _prima1;
		let _diferente2 = _prima2;

		return 1,
			   _referencia || " " || _no_factura1 || " " || _no_factura2
			   with resume;

		let _error_fact = 1;

	end if

	if _descuento1 <> _descuento2 then

		let _referencia = "Descuento";
		let _diferente1 = _descuento1;
		let _diferente2 = _descuento2;

		return 1,
			   _referencia || " " || _no_factura1 || " " || _no_factura2
			   with resume;

	end if

	if _recargo1 <> _recargo2 then

		let _referencia = "Recargo";
		let _diferente1 = _recargo1;
		let _diferente2 = _recargo2;

		return 1,
			   _referencia || " " || _no_factura1 || " " || _no_factura2
			   with resume;

	end if


	if _impuesto1 <> _impuesto2 then

		let _referencia = "Impuesto";
		let _diferente1 = _impuesto1;
		let _diferente2 = _impuesto2;

		return 1,
			   _referencia || " " || _no_factura1 || " " || _no_factura2
			   with resume;

	end if



	if _prima_retenida1 <> _prima_retenida2 then

		let _referencia = "Prima Retenida";
		let _diferente1 = _prima_retenida1;
		let _diferente2 = _prima_retenida2;

		return 1,
			   _referencia || " " || _no_factura1 || " " || _no_factura2
			   with resume;

	end if

	if _tiene_impuesto1 <> _tiene_impuesto2 then

		let _referencia = "Tiene Impuesto";
		let _diferente1 = _tiene_impuesto1;
		let _diferente2 = _tiene_impuesto2;

		return 1,
			   _referencia || " " || _no_factura1 || " " || _no_factura2
			   with resume;

	end if

	if _actualizado1 <> _actualizado2 then

		let _referencia = "Actualizado";
		let _diferente1 = _actualizado1;
		let _diferente2 = _actualizado2;

		return 1,
			   _referencia
			   with resume;

	end if

	if _no_factura1 <> _no_factura2 then

		let _referencia = "Numero de Factura";
		let _diferente1 = _no_factura1;
		let _diferente2 = _no_factura2;

		return 1,
			   _referencia || " " || _no_factura1 || " " || _no_factura2
			   with resume;

	end if

	if _fact_reversar1 <> _fact_reversar2 then

		let _referencia = "Factura a Reversar";
		let _diferente1 = _fact_reversar1;
		let _diferente2 = _fact_reversar2;

		return 1,
			   _referencia || " " || _no_factura1 || " " || _no_factura2
			   with resume;

	end if

	if _periodo1 <> _periodo2 then

		let _referencia = "Periodo";
		let _diferente1 = _periodo1;
		let _diferente2 = _periodo2;

		return 1,
			   _referencia || " " || _no_factura1 || " " || _no_factura2
			   with resume;

	end if


	if _suma_asegurada1 <> _suma_asegurada2 then

		let _referencia = "Suma Asegurada";
		let _diferente1 = _suma_asegurada1;
		let _diferente2 = _suma_asegurada2;

		return 1,
			   trim(_referencia) || " " || _no_factura1 || " " || _no_factura2
			   with resume;

	end if

	if _activa1 <> _activa2 then

		let _referencia = "Activa";
		let _diferente1 = _activa1;
		let _diferente2 = _activa2;

		return 1, _referencia || " " || _no_factura1 || " " || _no_factura2
			   with resume;

	end if

	if _referencia is not null then
--		call sp_pro129(_no_factura1);
	end if

	if _cod_compania1 <> _cod_compania2 then

		let _referencia = "Compania";
		let _diferente1 = _cod_compania1;
		let _diferente2 = _cod_compania2;
		
		return _no_poliza,
		       _no_endoso,
			   _no_factura1,
			   _no_documento1,
			   _diferente1,
			   _diferente2,
			   _referencia,
			   _periodo1,
			   2
			   with resume;

	end if

	if _cod_sucursal1 <> _cod_sucursal2 then

		let _referencia = "Sucursal";
		let _diferente1 = _cod_sucursal1;
		let _diferente2 = _cod_sucursal2;

		return _no_poliza,
		       _no_endoso,
			   _no_factura1,
			   _no_documento1,
			   _diferente1,
			   _diferente2,
			   _referencia,
			   _periodo1,
			   2
			   with resume;

	end if

	if _cod_tipocalc1 <> _cod_tipocalc2 then

		let _referencia = "Tipo de Calculo";
		let _diferente1 = _cod_tipocalc1;
		let _diferente2 = _cod_tipocalc2;

		return _no_poliza,
		       _no_endoso,
			   _no_factura1,
			   _no_documento1,
			   _diferente1,
			   _diferente2,
			   _referencia,
			   _periodo1,
			   2
			   with resume;

	end if
}

{	if _cod_formapag1 <> _cod_formapag2 then

		let _referencia = "Forma de Pago Diferente";

		return _no_poliza,
		       _no_endoso,
			   _no_factura1,
			   _no_documento1,
			   0,
			   0,
			   _referencia
			   with resume;

	end if
}
{	if _cod_perpago1 <> _cod_perpago2 then


		let _referencia = "Periodo de Pago Diferente";

		return _no_poliza,
		       _no_endoso,
			   _no_factura1,
			   _no_documento1,
			   0,
			   0,
			   _referencia,
			   _periodo1
			   with resume;

	end if
}

{	if _no_documento1 <> _no_documento2 then

		let _referencia = "Numero de Poliza Diferente";

		return _no_poliza,
		       _no_endoso,
			   _no_factura1,
			   _no_documento1,
			   0,
			   0,
			   _referencia,
			   _periodo1
			   with resume;

	end if
}
{	if _fecha_primer_pago1 <> _fecha_primer_pago2 then

		let _referencia = "Fecha Primer Pago Diferente";

		return _no_poliza,
		       _no_endoso,
			   _no_factura1,
			   _no_documento1,
			   0,
			   0,
			   _referencia,
			   _periodo1
			   with resume;

	end if

	if _no_pagos1 <> _no_pagos2 then

		let _referencia = "Numero de Pagos Diferente";

		return _no_poliza,
		       _no_endoso,
			   _no_factura1,
			   _no_documento1,
			   0,
			   0,
			   _referencia,
			   _periodo1
			   with resume;

	end if
}

{
	if _cod_tipocan1 <> _cod_tipocan2 then

		let _referencia = "Tipo de Cancelacion";
		let _diferente1 = _cod_tipocan1;
		let _diferente2 = _cod_tipocan2;

		return _no_poliza,
		       _no_endoso,
			   _no_factura1,
			   _no_documento1,
			   _diferente1,
			   _diferente2,
			   _referencia,
			   _periodo1,
			   2
			   with resume;

	end if

	if _cod_endomov1 <> _cod_endomov2 then

		let _referencia = "Tipo de Movimiento";
		let _diferente1 = _cod_endomov1;
		let _diferente2 = _cod_endomov2;

		return _no_poliza,
		       _no_endoso,
			   _no_factura1,
			   _no_documento1,
			   _diferente1,
			   _diferente2,
			   _referencia,
			   _periodo1,
			   2
			   with resume;

	end if

	if _vigencia_inic1 <> _vigencia_inic2 then

		let _referencia = "Vigencia Inicial";
		let _diferente1 = _vigencia_inic1;
		let _diferente2 = _vigencia_inic2;

		return _no_poliza,
		       _no_endoso,
			   _no_factura1,
			   _no_documento1,
			   _diferente1,
			   _diferente2,
			   _referencia,
			   _periodo1,
			   2
			   with resume;

	end if

	if _vigencia_final1 <> _vigencia_final2 then

		let _referencia = "Vigencia Final";
		let _diferente1 = _vigencia_final1;
		let _diferente2 = _vigencia_final2;

		return _no_poliza,
		       _no_endoso,
			   _no_factura1,
			   _no_documento1,
			   _diferente1,
			   _diferente2,
			   _referencia,
			   _periodo1,
			   2
			   with resume;

	end if

	if _vigencia_inic_pol1 <> _vigencia_inic_pol2 then

		let _referencia = "Viencia Inicial Poliza";
		let _diferente1 = _vigencia_inic_pol1;
		let _diferente2 = _vigencia_inic_pol2;

		return _no_poliza,
		       _no_endoso,
			   _no_factura1,
			   _no_documento1,
			   _diferente1,
			   _diferente2,
			   _referencia,
			   _periodo1,
			   2
			   with resume;

	end if

	if _vigencia_final_pol1 <> _vigencia_final_pol2 then

		let _referencia = "Vigencia Final Poliza";
		let _diferente1 = _vigencia_final_pol1;
		let _diferente2 = _vigencia_final_pol2;

		return _no_poliza,
		       _no_endoso,
			   _no_factura1,
			   _no_documento1,
			   _diferente1,
			   _diferente2,
			   _referencia,
			   _periodo1,
			   2
			   with resume;

	end if

	if _no_endoso_ext1 <> _no_endoso_ext2 then

		let _referencia = "Numero de Endoso Externo";
		let _diferente1 = _no_endoso_ext1;
		let _diferente2 = _no_endoso_ext2;

		return _no_poliza,
		       _no_endoso,
			   _no_factura1,
			   _no_documento1,
			   _diferente1,
			   _diferente2,
			   _referencia,
			   _periodo1,
			   2
			   with resume;

	end if

	if _posteado1 <> _posteado2 then

		let _referencia = "Posteado";
		let _diferente1 = _posteado1;
		let _diferente2 = _posteado2;

		return _no_poliza,
		       _no_endoso,
			   _no_factura1,
			   _no_documento1,
			   _diferente1,
			   _diferente2,
			   _referencia,
			   _periodo1,
			   2
			   with resume;

	end if

	if _factor_vigencia1 <> _factor_vigencia2 then

		let _referencia = "Factor de Vigencia";
		let _diferente1 = _factor_vigencia1;
		let _diferente2 = _factor_vigencia2;

		return _no_poliza,
		       _no_endoso,
			   _no_factura1,
			   _no_documento1,
			   _diferente1,
			   _diferente2,
			   _referencia,
			   _periodo1,
			   2
			   with resume;

	end if

	if _interna1 <> _interna2 then

		let _referencia = "Interna";
		let _diferente1 = _interna1;
		let _diferente2 = _interna2;

		return _no_poliza,
		       _no_endoso,
			   _no_factura1,
			   _no_documento1,
			   _diferente1,
			   _diferente2,
			   _referencia,
			   _periodo1,
			   2
			   with resume;

	end if
}

end procedure

