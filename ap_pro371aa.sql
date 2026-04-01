-- Procedimiento que carga las coberturas de los prodcutos en el Proceso de Emisiones Electronicas.
--
-- Creado: 28/08/2012 - Autor: Roman Gordon--
-- Modificado : 06/11/2013 - Autor: Roman Gordon	--Se modificó el orden los limites en el archivo para que se envie lo que se llena como limite 1 en limite 2 y viceversa.
-- sis v.2.0 - deivid, s.a.

drop procedure ap_pro371aa;
create procedure "informix".ap_pro371aa(a_periodo char(7))
returning	varchar(20)		as Poliza,				--1_no_documento,   	 
			varchar(50)		as Ramo,				--2_cod_ramo,   
			varchar(10)		as Vigencia_Inicial,	--3_vig_inic,   
			varchar(10)		as Vigencia_Final,		--4_vig_fin,
			varchar(100)	as Nom_Cliente,			--5_nom_cliente,   
			varchar(40)		as Ape_Cliente,			--6_ape_cliente,   
			varchar(40)		as Seg_Ape_Cliente,		--7_seg_ape_cli,
			varchar(30)		as Cedula,				--8_cedula,   
			varchar(30)		as Pasaporte,			--9_pasaporte,   
			varchar(30)		as Ruc,					--10_ruc,   
			varchar(10)		as Telefono_Res,		--11_tel_residenc,   
			varchar(10)		as Telefono_Ofic,		--12_tel_oficina,   
			varchar(10)		as Celular,				--13_celular,   
			varchar(50)		as Correo_Elect,		--14_email,   
			varchar(10)		as Tipo,				--15_tipo,   
			dec(16,2)		as Prima_Sin_Desc,		--16_prima_sin_desc,   
			dec(16,2)		as Descuento,			--17_monto_desc,   
			dec(16,2)		as Porc_Descuento,		--18_porc_desc,   
			dec(16,2)		as Prima,				--19_prima,   
			dec(16,2)		as Porc_Impuesto,		--20_porc_imp,   
			dec(16,2)		as Impuesto,			--21_monto_imp,   
			dec(16,2)		as Prima_Bruta,			--22_prima_bruta,
			smallint		as No_Pagos,			--23_cant_pagos,   
			dec(16,2)		as Suma_asegurada,		--24_suma_asegurada,   
			varchar(50)		as Acreedor,			--25_nom_acreedor,   
			varchar(10)		as Cod_Acreedor,		--26_cod_acreedor_agt,   
			varchar(100)	as Nom_Conductor,		--27_nom_conductor,   
			varchar(40)		as Ape_Conductor,		--28_ape_conductor,   
			varchar(1)		as Sexo_Conductor,		--29_sexo_conductor,   
			dec(16,2)		as Prima_Lesiones,		--30_prima_lesiones_corp,  
			dec(16,2)		as Limite_Lesiones1,	--31_limite_lesiones1,
			dec(16,2)		as Limite_Lesiones2,	--32_limite_lesiones2,
			dec(16,2)		as Prima_Danos,			--33_prima_danos,
			dec(16,2)		as Limite_Danos1,		--34_limite_danos1,
			dec(16,2)		as Limite_Danos2,		--35_limite_danos2,
			dec(16,2)		as Deducible_Danos,		--36_deducible_danos,
			dec(16,2)		as Prima_Gastos_Med,	--37_prima_gastos_med,
			dec(16,2)		as Limite_Gastos_Med1,	--38_limite_gastos_med1,
			dec(16,2)		as Limite_Gastos_Med2,	--39_limite_gastos_med2,
			dec(16,2)		as Prima_Compresivo,	--40_prima_comprensivo,
			dec(16,2)		as Limite_Comprensivo1,	--41_limite_comprensivo1,
			dec(16,2)		as Limite_Comprensivo2,	--42_limite_comprensivo2,
			dec(16,2)		as Deducible_Comprensivo,	--43_deducible_comprensivo,
			dec(16,2)		as Prima_Colision,		--44_prima_colision,
			dec(16,2)		as Limite_Colision1,	--45_limite_colision1,
			dec(16,2)		as Limite_Colision2,	--46_limite_colision2,
			dec(16,2)		as Deducible_Colision,	--47_deducible_colision,
			dec(16,2)		as Prima_Muerte,		--48_prima_muerte,	
			dec(16,2)		as Limite_Muerte1,		--49_limite_muerte1,   
			dec(16,2)		as Limite_Muerte2,		--50_limite_muerte2,   
			dec(16,2)		as Prima_Endoso,		--51_prima_endoso,  
			dec(16,2)		as Limite_Endoso1,		--52_limite_endoso1,   
			dec(16,2)		as Limite_Endoso2,		--53_limite_endoso2,
			char(100)		as Observaciones,		--54_obs_auto
			dec(16,2)		as Porc_Comis_Agt,		--55_porc_comis_agt
			dec(16,2)		as Prima_Robo,			--56_prima_robo,
			dec(16,2)		as Limite_Robo1,		--57_limite_robo1,
			dec(16,2)		as Limite_Robo2,		--58_limite_robo2,
			dec(16,2)		as Deducible_Robo,		--59_deducible_robo,
			dec(16,2)		as Prima_Incendio,		--60_prima_incendio,		
			dec(16,2)		as Limite_Incendio1,	--61_limite_incedio1,	  
			dec(16,2)		as Limite_Incendio2,	--62_limite_incedio2,	  
			dec(16,2)		as Deducible_Incendio,	--63_deducible_incendio,   
			varchar(10)		as Uso_Auto,			--64_nom_uso_auto,
			dec(16,2)		as Prima2,				--65_prima   
			varchar(30)		as Motor,				--66_no_motor
			varchar(10)		as Cod_Producto,		--67_cod_prod_agt
			varchar(50)		as Producto,			--68_nom_producto
			dec(16,2)		as Prima_Caida_Obj,		--69_caida_objetos_prima
			dec(16,2)		as Limite_Caida_Obj2,	--70_caida_objetos_limite2
			dec(16,2)		as Limite_Caida_Obj1,	--71_caida_objetos_limite1
			dec(16,2)		as Deducible_Caida_Obj,	--72_caida_objetos_deducible
			dec(16,2)		as Prima_Vidrios,		--73_vidrios_prima
			dec(16,2)		as Limite_Vidrios2,		--74_vidrios_limite2
			dec(16,2)		as Limite_Vidrios1,		--75_vidrios_limite1
			dec(16,2)		as Deducible_Vidrios,	--76_vidrios_deducible
			char(5)         as grupo;
	   

define _nom_primer_cli			varchar(100);
define _nom_conductor			varchar(100);
define _nom_cliente				varchar(100);
define _error_desc				varchar(100);
define _desc_limite1			varchar(50);
define _desc_limite2			varchar(50);
define _nom_acreedor			varchar(50);
define _nom_producto			varchar(50);
define _nom_ramo				varchar(50);
define _email					varchar(50);																	  
define _nom_segundo_cli			varchar(40);
define _casada_ape_cli			varchar(40);
define _ape_conductor			varchar(40);													   
define _ape_cliente				varchar(40);													   
define _seg_ape_cli				varchar(40);
define _pasaporte				varchar(30);
define _no_motor				varchar(30);
define _cedula					varchar(30);
define _ruc						varchar(30);													   
define _no_documento			varchar(20);
define _cod_acreedor_agt		varchar(10);
define _no_poliza_ant			varchar(10);
define _cod_prod_agt			varchar(10);
define _nom_uso_auto			varchar(10);
define _tel_residenc			varchar(10);
define _tel_oficina				varchar(10);
define _cod_cliente				varchar(10);
define _no_poliza				varchar(10);
define _vig_inic				varchar(10);
define _vig_fin					varchar(10);
define _celular					varchar(10);
define _tipo					varchar(10);
define _cod_cobertura			varchar(5);															   
define _cod_producto			varchar(5);															   
define _cod_acreedor			varchar(5);															   
define _no_unidad				varchar(5);
define _cod_impuesto			varchar(3);															   
define _cod_subramo				varchar(3);												   
define _cod_ramo				varchar(3);
define _sexo_conductor			varchar(1);												   
define _tipo_persona			varchar(1);												   
define _uso_auto				varchar(1);												   
define _caida_objetos_deducible	dec(16,2);
define _deducible_comprensivo	dec(16,2);
define _caida_objetos_limite1	dec(16,2);
define _caida_objetos_limite2	dec(16,2);
define _caida_objetos_prima		dec(16,2);
define _limite_comprensivo1		dec(16,2);
define _limite_comprensivo2		dec(16,2);																							  
define _prima_lesiones_corp		dec(16,2);																							  
define _deducible_incendio		dec(16,2);																							  
define _limite_gastos_med2		dec(16,2);																							  
define _limite_gastos_med1		dec(16,2);
define _deducible_colision		dec(16,2);													 
define _vidrios_deducible		dec(16,2);
define _prima_comprensivo		dec(16,2);													 
define _limite_colision1		dec(16,2);												  
define _limite_lesiones1		dec(16,2);												 
define _limite_lesiones2		dec(16,2);
define _prima_gastos_med		dec(16,2);
define _limite_colision2		dec(16,2);
define _vidrios_limite1			dec(16,2);
define _vidrios_limite2			dec(16,2);
define _limite_incedio1			dec(16,2);					   
define _limite_incedio2			dec(16,2);					   
define _deducible_danos			dec(16,2);					   
define _deducible_cober			dec(16,2);
define _monto_impuesto			dec(16,2);												   
define _limite_endoso1			dec(16,2);												   
define _limite_endoso2			dec(16,2);												   
define _porc_comis_agt			dec(16,2);												   
define _deducible_robo			dec(16,2);
define _prima_incendio			dec(16,2);
define _prima_sin_desc 			dec(16,2);
define _suma_asegurada			dec(16,2);
define _prima_colision			dec(16,2);
define _limite_muerte1			dec(16,2);
define _limite_muerte2			dec(16,2);
define _vidrios_prima			dec(16,2);
define _limite1_cober			dec(16,2);
define _limite2_cober			dec(16,2);
define _limite_danos1			dec(16,2);
define _limite_danos2			dec(16,2);
define _limite_robo1			dec(16,2);
define _limite_robo2			dec(16,2);
define _prima_endoso			dec(16,2);
define _prima_muerte			dec(16,2);
define _prima_bruta				dec(16,2);
define _prima_danos				dec(16,2);
define _prima_cober				dec(16,2);
define _prima_robo				dec(16,2);
define _prima_neta				dec(16,2);
define _monto_desc				dec(16,2);
define _porc_desc				dec(16,2);
define _monto_imp				dec(16,2);
define _porc_imp				dec(16,2);
define _prima		   			dec(16,2);
define _fact_impuesto			dec(5,2);
define _es_pasaporte			smallint;
define _cnt_existe				smallint;
define _tipo_cober				smallint;
define _error_isam				smallint;
define _cant_pagos				smallint;
define _flag_agt				smallint;
define _enviado					smallint;
define _flota					smallint;
define _error					smallint;
define _vigencia_inic			date;
define _vigencia_fin			date;
define _cod_grupo               char(5);

--set debug file to "sp_pro371a.trc";
--trace on;

set isolation to dirty read;

let _cod_acreedor_agt			= '';
let _nom_segundo_cli			= '';
let	_sexo_conductor				= '';
let _nom_primer_cli				= '';
let _ape_conductor				= '';
let	_nom_conductor				= '';
let _no_poliza_ant				= '';
let _nom_acreedor				= '';
let _cod_acreedor				= '';
let _pasaporte					= '';
let _cedula						= '';
let _ruc						= '';
let _caida_objetos_deducible	= 0.00;
let _deducible_comprensivo		= 0.00;
let _caida_objetos_limite1		= 0.00;
let _caida_objetos_limite2		= 0.00;
let _caida_objetos_prima		= 0.00;
let _limite_comprensivo1		= 0.00;		
let _limite_comprensivo2		= 0.00;	
let _prima_lesiones_corp		= 0.00;	
let _deducible_incendio			= 0.00;
let _limite_gastos_med2			= 0.00;
let _limite_gastos_med1			= 0.00;
let _deducible_colision			= 0.00;
let _prima_comprensivo			= 0.00;
let _vidrios_deducible			= 0.00;
let _limite_colision1			= 0.00;
let _limite_lesiones1			= 0.00;
let _limite_lesiones2			= 0.00;
let _prima_gastos_med			= 0.00;
let _limite_colision2			= 0.00;
let _vidrios_limite1			= 0.00;
let _vidrios_limite2			= 0.00;
let _limite_incedio1			= 0.00;	
let _limite_incedio2			= 0.00;	
let _deducible_danos			= 0.00;	
let _deducible_cober			= 0.00;	
let _monto_impuesto				= 0.00;
let _limite_endoso1				= 0.00;
let _limite_endoso2				= 0.00;
let _porc_comis_agt				= 0.00;
let _deducible_robo				= 0.00;
let _prima_incendio				= 0.00;
let _prima_sin_desc				= 0.00;	
let _suma_asegurada				= 0.00;
let _prima_colision				= 0.00;
let _limite_muerte1				= 0.00;
let _limite_muerte2				= 0.00;
let _vidrios_prima				= 0.00;
let _limite1_cober				= 0.00;
let _limite2_cober				= 0.00;
let _limite_danos1				= 0.00;
let _limite_danos2				= 0.00;
let _fact_impuesto				= 0.00;
let _limite_robo1				= 0.00;
let _limite_robo2				= 0.00;
let _prima_endoso				= 0.00;
let _prima_muerte				= 0.00;
let _prima_bruta				= 0.00;	
let _prima_danos				= 0.00;	
let _prima_cober				= 0.00;	
let _prima_robo					= 0.00;
let _prima_neta					= 0.00;
let _monto_desc					= 0.00;
let _porc_desc					= 0.00;
let _monto_imp					= 0.00;
let _porc_imp					= 0.00;
let _prima						= 0.00;
let _flag_agt					= 0;
let _flota						= 0;

foreach
	select trim(no_documento),   
		   cod_ramo,   
		   trim(vigencia_inic),   
		   trim(vigencia_fin),   
		   trim(nom_cliente),   
		   trim(ape_cliente),   
		   trim(seg_ape_cliente),
		   trim(cedula),   
		   trim(pasaporte),   
		   trim(ruc),   
		   trim(tel_residencial),   
		   trim(tel_oficina),   
		   trim(celular),   
		   trim(email),   
		   trim(tipo),   
		   prima_sin_desc,   
		   monto_desc,   
		   porc_desc,   
		   prima,   
		   porc_imp,   
		   monto_imp,   
		   tot_prima,   
		   cant_pagos,   
		   suma_aseg,   
		   trim(nom_acreedor),   
		   trim(cod_acreedor_agt),   
		   trim(nom_conductor),   
		   trim(ape_conductor),   
		   trim(sexo_conductor),   
		   prima_lesiones_corp,   
		   lesiones_limite1,   
		   lesiones_limite2,   
		   prima_danos,   
		   danos_limite1,   
		   danos_limite2,   
		   deducible_danos,   
		   prima_gastos_med,   
		   gastos_med_limite1,   
		   gastos_med_limite2,   
		   prima_comprensivo,   
		   comprensivo_limite1,   
		   comprensivo_limite2,   
		   deducible_comprensivo,   
		   prima_colision,   
		   colision_limite1,   
		   colision_limite2,   
		   deducible_colision,   
		   prima_muerte,   
		   muerte_limite1,   
		   muerte_limite2,   
		   prima_endoso,   
		   endoso_limite1,   
		   endoso_limite2,   
		   prima_robo,   
		   robo_limite1,   
		   robo_limite2,   
		   deducible_robo,   
		   prima_incendio,   
		   incendio_limite1,   
		   incendio_limite2,   
		   deducible_incendio,   
		   trim(uso_auto),   										   
		   trim(no_motor),
		   trim(cod_producto_agt),
		   trim(nom_producto),
		   no_poliza_ant,
		   vidrios_prima,
		   vidrios_limite1,
		   vidrios_limite2,
		   vidrios_deducible,
		   caida_objetos_prima,
		   caida_objetos_limite1,
		   caida_objetos_limite2,
		   caida_objetos_deducible
	  into _no_documento,									   
		   _cod_ramo,   									   
		   _vig_inic,   									   
		   _vig_fin,										   
		   _nom_cliente,   									   
		   _ape_cliente,   									   
		   _seg_ape_cli,									   
		   _cedula,   										   
		   _pasaporte,   									   
		   _ruc,   											   
		   _tel_residenc,   								   
		   _tel_oficina,   									   
		   _celular,   										   
		   _email,   										   
		   _tipo,   										   
		   _prima_sin_desc,   								   
		   _monto_desc,   									   
		   _porc_desc,   									   
		   _prima,   										   
		   _porc_imp,   									   
		   _monto_imp,   									   
		   _prima_bruta,									   
		   _cant_pagos,   									   
		   _suma_asegurada,   								   
		   _nom_acreedor,   								   
		   _cod_acreedor_agt,   							   
		   _nom_conductor,   								   
		   _ape_conductor,   								   
		   _sexo_conductor,   								   
		   _prima_lesiones_corp,  							   
		   _limite_lesiones1,								   
		   _limite_lesiones2,								   
		   _prima_danos,									   
		   _limite_danos1,									   
		   _limite_danos2,									   
		   _deducible_danos,								   
		   _prima_gastos_med,								   
		   _limite_gastos_med1,								   
		   _limite_gastos_med2,								   
		   _prima_comprensivo,								   
		   _limite_comprensivo1,							   
		   _limite_comprensivo2,							   
		   _deducible_comprensivo,							   
		   _prima_colision,									   
		   _limite_colision1,								   
		   _limite_colision2,								   
		   _deducible_colision,								   
		   _prima_muerte,									   
		   _limite_muerte1,   								   
		   _limite_muerte2,   								   
		   _prima_endoso,  									   
		   _limite_endoso1,   								   
		   _limite_endoso2,   								   
		   _prima_robo,										   
		   _limite_robo1,									   
		   _limite_robo2,									   
		   _deducible_robo,									   
		   _prima_incendio,									   
		   _limite_incedio1,	  							   
		   _limite_incedio2,	  							   
		   _deducible_incendio,   							   
		   _nom_uso_auto,   								   
		   _no_motor,										   
		   _cod_prod_agt,									   
		   _nom_producto,									   
		   _no_poliza_ant,
		   _vidrios_prima,
		   _vidrios_limite1,
		   _vidrios_limite2,
		   _vidrios_deducible,
		   _caida_objetos_prima,
		   _caida_objetos_limite1,
		   _caida_objetos_limite2,
		   _caida_objetos_deducible
	  from emirenduc
	 where periodo >= '2021-01'
	   and cod_grupo is null
	--  and prima_lesiones_corp <> 0
	

	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	if _cedula is not null and _cedula <> '' then
		call sp_sis400a(_cedula) returning _cedula;
	end if
	
	select porc_comis_agt
	  into _porc_comis_agt
	  from emipoagt
	 where no_poliza = _no_poliza_ant
	   and cod_agente = '00035';
{	
	let _no_poliza = sp_sis21(_no_documento);
	
	select count(*)
	  into _flota
	  from emipouni
	 where no_poliza = _no_poliza;

	if _flota > 1 then
		continue foreach;
	end if
}

	select cod_grupo 
	  into _cod_grupo
	  from emipomae
	 where no_poliza = _no_poliza_ant;

	update emirenduc
	   set cod_grupo = _cod_grupo
	 where no_documento = _no_documento
	   and vigencia_inic = _vig_inic;

	return _no_documento,   	 				--1_no_documento,   	 
		   trim(_nom_ramo),   					--2_cod_ramo,   
		   _vig_inic,   						--3_vig_inic,   
		   _vig_fin,							--4_vig_fin,
		   _nom_cliente,   						--5_nom_cliente,   
		   _ape_cliente,   						--6_ape_cliente,   
		   _seg_ape_cli,   						--7_seg_ape_cli,
		   _cedula,   							--8_cedula,   
		   _pasaporte,   						--9_pasaporte,   
		   _ruc,   								--10_ruc,   
		   _tel_residenc,   					--11_tel_residenc,   
		   _tel_oficina,   						--12_tel_oficina,   
		   _celular,   							--13_celular,   
		   _email,   							--14_email,   
		   _tipo,   							--15_tipo,   
		   _prima_sin_desc,   					--16_prima_sin_desc,   
		   _monto_desc,   						--17_monto_desc,   
		   _porc_desc,   						--18_porc_desc,   
		   _prima,   							--19_prima,   
		   _porc_imp,   						--20_porc_imp,   
		   _monto_imp,   						--21_monto_imp,   
		   _prima_bruta,						--22_prima_bruta,
		   _cant_pagos,   						--23_cant_pagos,   
		   _suma_asegurada,   					--24_suma_asegurada,   
		   _nom_acreedor,   					--25_nom_acreedor,   
		   _cod_acreedor_agt,   				--26_cod_acreedor_agt,   
		   _nom_conductor,   					--27_nom_conductor,   
		   _ape_conductor,   					--28_ape_conductor,   
		   _sexo_conductor,   					--29_sexo_conductor,   
		   _prima_lesiones_corp,  				--30_prima_lesiones_corp,  
		   _limite_lesiones1,					--31_limite_lesiones1,
		   _limite_lesiones2,					--32_limite_lesiones2,
		   _prima_danos,						--33_prima_danos,	invertido
		   _limite_danos2,						--35_limite_danos2,
		   _limite_danos1,						--34_limite_danos1,
		   _deducible_danos,					--36_deducible_danos,
		   _prima_gastos_med,					--37_prima_gastos_med,
		   _limite_gastos_med1,					--38_limite_gastos_med1,
		   _limite_gastos_med2,					--39_limite_gastos_med2,
		   _prima_comprensivo,					--40_prima_comprensivo,
		   _limite_comprensivo2,				--42_limite_comprensivo2,
		   _limite_comprensivo1,				--41_limite_comprensivo1,
		   _deducible_comprensivo,				--43_deducible_comprensivo,
		   _prima_colision,						--44_prima_colision,	invertido
		   _limite_colision2,					--46_limite_colision2,
		   _limite_colision1,					--45_limite_colision1,
		   _deducible_colision,					--47_deducible_colision,
		   _prima_muerte,						--48_prima_muerte,	
		   _limite_muerte1,   					--49_limite_muerte1,   
		   _limite_muerte2,   					--50_limite_muerte2,   
		   _prima_endoso,  						--51_prima_endoso,  
		   _limite_endoso1,   					--52_limite_endoso1,   
		   _limite_endoso2,   					--53_limite_endoso2,
		   '',									--54_obs_auto
		   _porc_comis_agt,						--55_porc_comis_agt
		   _prima_robo,							--56_prima_robo,
		   _limite_robo2,						--58_limite_robo2,
		   _limite_robo1,						--57_limite_robo1,
		   _deducible_robo,						--59_deducible_robo,
		   _prima_incendio,						--60_prima_incendio,	
		   _limite_incedio2,	  				--62_limite_incedio2,		
		   _limite_incedio1,	  				--61_limite_incedio1,	
		   _deducible_incendio,   				--63_deducible_incendio,  
		   _nom_uso_auto,   					--64_nom_uso_auto,
		   _prima,  							--65_prima      
		   _no_motor,							--66_no_motor
		   _cod_prod_agt,						--67_cod_prod_agt
		   _nom_producto,						--68_nom_producto
		   _caida_objetos_prima,
		   _caida_objetos_limite2,
		   _caida_objetos_limite1,
		   _caida_objetos_deducible,
		   _vidrios_prima,
		   _vidrios_limite2,
		   _vidrios_limite1,
		   _vidrios_deducible,
		   _cod_grupo
		   with resume;   						
end foreach										
end procedure   								
