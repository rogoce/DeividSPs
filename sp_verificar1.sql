-- Verificar clientes locales y que no pagan impuesto

-- Creado    : 04/08/2010 - Autor: Armando Moreno

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_verificar1;

create procedure sp_verificar1()
returning char(10),char(100);

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
define _aplica_imp			smallint;
define _canti			    smallint;
define _cod_origen			char(3);
define _cod_ramo			char(3);
define _cod_subramo			char(3);
define _cod_impuesto        char(3);
define _nombre              varchar(100);
define _cod_cliente		    char(10);
define _paga_impuesto       smallint;

set isolation to dirty read;

foreach

	select cod_origen,
	       paga_impuesto,
		   cod_cliente,
		   nombre
	  into _cod_origen,
	       _paga_impuesto,
		   _cod_cliente,
		   _nombre
	  from cliclien


	if _cod_origen = '001' and _paga_impuesto = 0 then	--local y no paga impuesto

		return _cod_cliente,_nombre with resume;

	end if

end foreach

end procedure

