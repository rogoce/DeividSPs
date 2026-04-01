-- Carga de Archivo de Texto a Formato de Archivo de Informix
-- 
-- Creado    : 22/09/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 22/09/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cfs01;

create procedure "informix".sp_cfs01(
a_compania	char(3),
a_sucursal	char(3),
a_origen 	smallint
) returning smallint, 
            char(100);

set isolation to dirty read;

if a_origen = 1 then -- Ducruet

	begin

		define _marca	    	char(3);
		define _descmarca		char(30);
		define _modelo			char(50);
		define _cantidad		integer;
		define _poliza_madre	char(20);

		delete from cfsducpo;

		insert into	cfsducpo
		select campo[1,20],
		       campo[21,25],
			   campo[26,31],
			   campo[32,131],
			   campo[132,151],
			   campo[152,171],
			   campo[172,191],
			   campo[192,216],
			   campo[217,241],
			   campo[242,266],
			   campo[267,306],
			   campo[307,307],
			   campo[308,337],
			   campo[338,345],
			   campo[346,347],
			   campo[348,355],
			   campo[356,363],
			   campo[364,371],
			   campo[372,379],
			   campo[380,479],
			   campo[480,494],
			   campo[495,509],
			   campo[510,524],
			   campo[525,527],
			   campo[528,577],
			   campo[578,677],
			   campo[678,727],
			   campo[728,735],
			   campo[736,743],
			   campo[744,751],
			   campo[752,759],
			   campo[760,767],
			   campo[768,775],
			   campo[776,783],
			   campo[784,791],
			   campo[792,799],
			   campo[800,807],
			   campo[808,815],
			   campo[816,823],
			   campo[824,831],
			   campo[832,839],
			   campo[840,847],
			   campo[848,855],
			   campo[856,863],
			   campo[864,871],
			   campo[872,879],
			   campo[880,887],
			   campo[888,897],
			   campo[898,900],
			   campo[901,930],
			   campo[931,980],
			   campo[981,984],
			   campo[985,1009],
			   campo[1010,1039],
			   campo[1040,1064],
			   campo[1065,1066],
			   campo[1067,1068],
			   campo[1069,1093],
			   campo[1094,1095],
			   campo[1096,1125],
			   campo[1126,1380],
			   campo[1381,1460],
			   campo[1461,1462],
			   campo[1463,1474],
			   campo[1475,1482],
			   campo[1483,1486],
			   campo[1487,1494],
			   campo[1495,1502],
			   campo[1503,1510],
			   campo[1511,1518],
			   campo[1519,1519],
			   campo[1520,1569],
			   campo[1570,1584],
			   campo[1585,1585],
			   campo[1586,1587]
		  from cfscampo;

	   foreach
		select marca,
		       descmarca,
			   modelo
		  into _marca,
		       _descmarca,
			   _modelo
		  from cfsducpo

			select count(*)
			  into _cantidad
			  from cfsducma
			 where marca = _marca;
			 
			if _cantidad = 0 then
			
				insert into cfsducma(
				marca,
		        descmarca,
			    modelo,
				cod_marca,
				cod_modelo
				)
				values(
				_marca,
		        _descmarca,
			    _modelo,
				null,
				null
				);

			end if
					  
		end foreach

		select count(*)
		  into _cantidad
		  from cfsducma
		 where marca  is null
		    or modelo is null;

		if _cantidad <> 0 then
			return 1, "Hay Registros de Marcas con Registros en Blanco";
		end if

	-- Actualizar los Registros de Polizas

	foreach
	 select poliza_madre
	   into _poliza_madre
	   from cfsducpo

		select count(*)
		  into _cantidad
		  from emipomae
		 where no_documento = _poliza_madre;

		if _cantidad <> 0 then
			continue foreach;
		end if


	-- Insercion de Polizas

	insert into emipomae(
	no_poliza,
	cod_compania,
	cod_sucursal,
	sucursal_origen,
	cod_grupo,
	cod_perpago,
	cod_tipocalc,
	cod_ramo,
	cod_subramo,
	cod_formapag,
	cod_tipoprod,
	cod_contratante,
	cod_pagador,
	cod_no_renov,
	serie,
	no_documento,
	no_factura,
	prima,
	descuento,
	recargo,
	prima_neta,
	impuesto,
	prima_bruta,
	prima_suscrita,
	prima_retenida,
	tiene_impuesto,
	vigencia_inic,
	vigencia_final,
	fecha_suscripcion,
	fecha_impresion,
	fecha_cancelacion,
	no_pagos,
	impreso,
	nueva_renov,
	estatus_poliza,
	direc_cobros,
	por_certificado,
	actualizado,
	dia_cobros1,
	dia_cobros2,
	fecha_primer_pago,
	no_poliza_coaseg,
	date_changed,
	renovada,
	date_added,
	periodo,
	carta_aviso_canc,
	carta_prima_gan,
	carta_vencida_sal,
	carta_recorderis,
	fecha_aviso_canc,
	fecha_prima_gan,
	fecha_vencida_sal,
	fecha_recorderis,
	cobra_poliza,
	user_added,
	ult_no_endoso,
	declarativa,
	abierta,
	fecha_renov,
	fecha_no_renov,
	no_renovar,
	perd_total,
	anos_pagador,
	saldo_por_unidad,
	factor_vigencia,
	suma_asegurada,
	incobrable,
	saldo,
	fecha_ult_pago,
	reemplaza_poliza,
	user_no_renov,
	posteado,
	no_tarjeta,
	fecha_exp,
	cod_banco,
	monto_visa,
	tipo_tarjeta,
	no_recibo,
	no_cuenta,
	tipo_cuenta,
	gestion,
	fecha_gestion,
	dia_cobro_anterior,
	incentivo,
	cod_origen,
	cotizacion,
	de_cotizacion,
	poliza_maestra
	values(
	);		

		  	
	end foreach



	end

end if

end procedure;