--Creado: 05/05/2022 
--Autor: Román Gordón
--Simulación de Renovación para Pool Automático
--execute procedure sp_sis245('2022-06') 


drop procedure sp_sis245;
create procedure sp_sis245(a_periodo char(7))
returning	char(20)		as poliza,
			date			as vigencia_inic,
			date			as vigencia_final,
			char(10)		as no_poliza,
			char(10)		as no_poliza_n,
			char(5)			as no_unidad,
			smallint		as ano_auto,
			smallint		as ano_tarifa,
			char(5)			as cod_cobertura,
			varchar(50)		as nom_cobertura,
			smallint		as orden,
			dec(16,2)		as limite_1,
			dec(16,2)		as limite_2,
			dec(16,2)		as prima_anual,
			dec(16,2)		as prima,
			dec(16,2)		as descuento,
			dec(16,2)		as prima_neta,
			smallint		as ano_tarifa_o,
			dec(16,2)		as limite_1_o,
			dec(16,2)		as limite_2_o,
			dec(16,2)		as prima_anual_o,
			dec(16,2)		as prima_o,
			dec(16,2)		as descuento_o,
			dec(16,2)		as prima_neta_o,
			dec(16,2)		as diezporc,
			dec(16,2)		as saldo,
			varchar(50)		as subramo,
			varchar(50)		as nom_producto			
			;

--) returning char(10),char(20);
--) returning char(10),char(20);

define _nom_cobertura 		varchar(100);
define _error_desc 			varchar(100);
define _n_cliente 			varchar(100);
define _subramo 				varchar(50);
define _nom_producto			varchar(50);
define _zona_ventas			varchar(50);
define _nom_agt 				varchar(50);
define _corredor				varchar(50);
define _modelo				varchar(50);
define _marca					varchar(50);
define _ramo					varchar(50);
define _no_motor				varchar(30);
define _no_documento			char(20);
define _cod_contratante		char(10);
define _no_poliza_n 			char(10);
define _no_factura 			char(10);
define _no_poliza 			char(10);
define _no_pol	 			char(10);
define _user_added 			char(8);
define _cod_producto			char(5);
define _cod_cobertura		char(5);
define _cod_marca				char(5);
define _cod_modelo			char(5);
define _cod_agente 			char(5);
define _no_unidad 			char(5);
define _cod_formapag 		char(3);
define _cod_no_renov 		char(3);
define _cod_descuen	 		char(3);
define _cod_ramo		 		char(3);
define _estatus_poliza		smallint;
define _cant_reclamos		smallint;
define _ano_tarifa_o			smallint;
define _ano_tarifa			smallint;
define _no_renovar			smallint;
define _ano_auto				smallint;
define _cant_mov				smallint;
define _renovar				smallint;
define _nuevo					smallint;
define _orden					smallint;
define _tipo_forma			smallint;
define _dias					smallint;
define _error					integer;
define _existe				integer;
define _prima_anual_o		dec(16,2);
define _prima_neta_o			dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_anual			dec(16,2);
define _descuento_o			dec(16,2);
define _prima_neta			dec(16,2);
define _limite_1_o			dec(16,2);
define _limite_2_o			dec(16,2);
define _descuento				dec(16,2);
define _incurrido				dec(16,2);
define _limite_1				dec(16,2);
define _limite_2				dec(16,2);
define _diezporc				dec(16,2);
define _saldo_elect			dec(16,2);
define _saldo_porc			dec(16,2);
define _prima_o				dec(16,2);
define _pagos					dec(16,2);
define _saldo					dec(16,2);
define _prima					dec(16,2);
define _porc_depreciacion	dec(5,2);
define _desc_be				dec(5,2);
define _desc_be_o				dec(5,2);
define _desc_flota			dec(5,2);	
define _desc_esp				dec(5,2);	
define _desc_comb				dec(5,2);	
define _desc_modelo			dec(5,2);	
define _desc_sinis			dec(5,2);	
define _desc_clasif			dec(5,2);	
define _desc_edad				dec(5,2);	
define _desc_tip_veh			dec(5,2);	
define _desc_flota_o			dec(5,2);	
define _desc_esp_o			dec(5,2);	
define _desc_comb_o			dec(5,2);	
define _desc_modelo_o		dec(5,2);
define _porc_desc				dec(5,2);
define _desc_sinis_o			dec(5,2);
define _desc_clasif_o		dec(5,2); 
define _desc_edad_o			dec(5,2);
define _desc_tip_veh_o		dec(5,2);
define _tasa					dec(5,2);
define _tasa_o				dec(5,2);
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_desde			date;
define _fecha_hasta			date;
define _fecha_selec			date;
define _fecha_hoy				date;



--set debug file to "sp_sis245.trc";
--trace on;

begin
on exception set _error
	return _error || ' - ' ||  _no_poliza,
			null,                   
			null,                   
			null,                   
			null,                  
			'00001',               
			0,                      
			0,                      
			'00000',               
			'',                     
			0,                      
			0.00,                  
			0.00,                  
			0.00,                  
			0.00,                  
			0.00,                  
			0.00,                  
			0,                      
			0.00,                  
			0.00,                  
			0.00,                  
			0.00,                  
			0.00,                  
			0.00,                  
			0.00,                  
			0.00,
			'',
			'';
end exception

let _fecha_hoy = sp_sis26();
let _fecha_desde = mdy(a_periodo[6,7],1,a_periodo[1,4]);
let _fecha_hasta = sp_sis36(a_periodo);



drop table if exists tmp_sim_auto;
create temp table tmp_sim_auto(
subramo			varchar(50),
poliza				char(20),
vigencia_inic		date,
vigencia_final	date,
no_poliza			char(10),
no_poliza_n		char(10),
no_unidad			char(5),
nom_producto	    varchar(50),
corredor		    varchar(50),
zona_ventas	    varchar(50),
no_motor			varchar(30),
cod_marca			char(5),
marca				varchar(50),
cod_modelo			char(5),
modelo				varchar(50),
nuevo				smallint,		
ano_auto			smallint,
ano_tarifa			smallint,
cod_cobertura		char(5),
nom_cobertura		varchar(50),
orden				smallint,
limite_1			dec(16,2),
limite_2			dec(16,2),
tasa				dec(5,2),
prima_anual		dec(16,2),
prima				dec(16,2),
descuento			dec(16,2),
prima_neta			dec(16,2),
desc_esp			dec(5,2),
desc_combinado	dec(5,2),
desc_sinis			dec(5,2),
desc_clasif		dec(5,2),
desc_edad			dec(5,2),
ano_tarifa_o		smallint,
limite_1_o			dec(16,2),
limite_2_o			dec(16,2),
tasa_o				dec(5,2),
prima_anual_o		dec(16,2),
prima_o			dec(16,2),
descuento_o		dec(16,2),
prima_neta_o		dec(16,2),
desc_esp_o			dec(5,2),
desc_combinado_o	dec(5,2),
desc_sinis_o		dec(5,2),
desc_clasif_o		dec(5,2),
desc_edad_o		dec(5,2),
diezporc			dec(16,2),
saldo				dec(16,2),
desc_buena_exp	dec(16,2),
desc_flota			dec(16,2),
desc_modelo		dec(16,2),
desc_tipo_veh		dec(16,2),
desc_buena_exp_o	dec(16,2),
desc_flota_o		dec(16,2),
desc_modelo_o		dec(16,2),
desc_tipo_veh_o	dec(16,2),
incurrido			dec(16,2)
) with no log;

foreach
/*
select no_poliza,
		    no_documento,
			cod_ramo,
			vigencia_inic,
			vigencia_final
	  into _no_poliza,
			_no_documento,
			_cod_ramo,
			_vigencia_inic,
			_vigencia_final
	  from emipomae
	 where no_poliza = '1638614'*/
/*
	execute procedure sp_pro324()
	into	_nom_agt,
			_no_poliza,		
			_user_added,		
			_cod_no_renov,    
			_no_documento,
			_renovar,
			_no_renovar,		
			_fecha_selec,		
			_vigencia_inic,
			_vigencia_final,
			_saldo,
			_cant_reclamos,
			_no_factura,
			_incurrido,
			_pagos,
			_porc_depreciacion,
			_cod_agente,
			_n_cliente,
			_prima_bruta,
			_diezporc,
			_cod_contratante,
			_dias,
			_no_poliza_n,
			_cant_mov,
			_subramo
*/

	select aut.no_poliza,
			aut.no_documento,
			aut.vigencia_inic,
			aut.vigencia_final,
			aut.saldo,
			aut.incurrido,
			emi.prima_bruta,
			emi.cod_subramo,
			emi.cod_formapag
	  into _no_poliza,
			_no_documento,
			_vigencia_inic,
			_vigencia_final,
			_saldo,
			_incurrido,
			_prima_bruta,
			_subramo,
			_cod_formapag
	  from emirepo aut
	  inner join emipomae emi on emi.no_poliza = aut.no_poliza
	 where aut.vigencia_final between _fecha_desde and _fecha_hasta
	   and emi.cod_ramo = '002'
	   and emi.cod_subramo = '001'
	   and aut.estatus in (1,4)
	
	select saldo_elect,
		    saldo_porc
	  into _saldo_elect,
		    _saldo_porc
	  from emirepar;

	select tipo_forma
	  into _tipo_forma
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	if _tipo_forma = 2 or _tipo_forma = 3 or _tipo_forma = 4 then	--2=visa,3=desc salario,4=ach
		let _saldo_porc = _saldo_elect;
	end if

	if _saldo_porc is null then
		let _saldo_porc = 10;
	end if

	let _diezporc = 0;
	let _diezporc = _prima_bruta * (_saldo_porc/100);
	
	select emi.cod_ramo,
		   emi.cod_no_renov,
			emi.estatus_poliza,
			ram.nombre
	  into _cod_ramo,
		   _cod_no_renov,
		   _estatus_poliza,
		   _ramo
	  from emipomae emi
	 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
	 where no_poliza = _no_poliza;

	if _cod_no_renov in ('039') or _estatus_poliza in (2,4) then
		continue foreach;
	end if

	if _cod_ramo = '002' and _subramo = '001' and _vigencia_final between _fecha_desde and _fecha_hasta then
		
		let _no_poliza_n = 'S' || trim(_no_poliza);
		call sp_pro320d('DEIVID', _no_poliza, _no_poliza_n) returning _error,_error_desc;
		
		foreach
			select uni.no_unidad,
					veh.ano_auto,
					aut.ano_tarifa,
					cob.cod_cobertura,
					cob.nombre,
					mae.orden,
					mae.limite_1,
					mae.limite_2,
					mae.prima_anual,
					mae.prima,
					mae.descuento,
					mae.prima_neta,
					uni.cod_producto,
					prd.nombre,
					veh.no_motor,
					veh.nuevo,
					mar.cod_marca,
					mar.nombre,
					mdl.cod_modelo,
					mdl.nombre,
					case
					  when mae.limite_1 = 0 then 0
					  else (mae.prima/mae.limite_1) * 100
					end,
					agt.nombre,
					zon.nombre
			  into _no_unidad,
					_ano_auto,
					_ano_tarifa,
					_cod_cobertura,
					_nom_cobertura,
					_orden, 
					_limite_1, 
					_limite_2, 
					_prima_anual, 
					_prima, 
					_descuento, 
					_prima_neta,
					_cod_producto,
					_nom_producto,
					_no_motor,
					_nuevo,
					_cod_marca,
					_marca,
					_cod_modelo,
					_modelo,
					_tasa,
					_corredor,
					_zona_ventas
			  from emipomae emi
			 inner join emipouni uni on uni.no_poliza = emi.no_poliza
			 inner join emiauto aut on aut.no_poliza = uni.no_poliza and aut.no_unidad = uni.no_unidad
			 inner join emivehic veh on veh.no_motor = aut.no_motor
			 inner join emimarca mar on mar.cod_marca = veh.cod_marca
			 inner join emimodel mdl on mdl.cod_marca = veh.cod_marca and mdl.cod_modelo = veh.cod_modelo
			 inner join emipocob mae on mae.no_poliza = uni.no_poliza and mae.no_unidad = uni.no_unidad and mae.prima_neta <> 0
			 inner join prdprod prd on prd.cod_producto = uni.cod_producto
			 inner join prdcober cob on cob.cod_cobertura = mae.cod_cobertura --and (cob.nombre like 'COLI%' or cob.nombre like 'COMPR%')
			 inner join emipoliza pol on pol.no_documento = emi.no_documento
			 inner join agtagent agt on agt.cod_agente = pol.cod_agente
			 inner join agtvende zon on zon.cod_vendedor = agt.cod_vendedor
			 where emi.no_poliza = _no_poliza_n

			let _desc_be = 0.00;
			let _desc_be_o = 0.00;
			let _desc_flota = 0.00;
			let _desc_flota_o = 0.00;
			let _desc_esp = 0.00;
			let _desc_comb = 0.00;
			let _desc_modelo = 0.00;
			let _desc_sinis = 0.00;
			let _desc_clasif = 0.00;
			let _desc_edad = 0.00;
			let _desc_tip_veh = 0.00;
			let _desc_flota_o = 0.00;
			let _desc_esp_o = 0.00;
			let _desc_comb_o = 0.00;
			let _desc_modelo_o = 0.00;
			let _desc_sinis_o = 0.00;
			let _desc_clasif_o = 0.00;
			let _desc_edad_o = 0.00;
			let _desc_tip_veh_o = 0.00;

			foreach
				select no_poliza,
						cod_descuen,
					    porc_descuento
				  into _no_pol,
						_cod_descuen,
					    _porc_desc
				  from emicobde
				 where no_poliza in (_no_poliza_n,_no_poliza)
				   and no_unidad = _no_unidad
				   and cod_cobertura = _cod_cobertura


				if _no_pol = _no_poliza_n then
					if _cod_descuen = '001' then
						let _desc_be = _porc_desc;
					elif _cod_descuen = '002' then
						let _desc_flota = _porc_desc;
					elif _cod_descuen = '003' then
						let _desc_esp = _porc_desc;
					elif _cod_descuen = '004' then
						let _desc_comb = _porc_desc;
					elif _cod_descuen = '005' then
						let _desc_modelo = _porc_desc;
					elif _cod_descuen = '006' then
						let _desc_sinis = _porc_desc;
					elif _cod_descuen = '007' then
						let _desc_clasif = _porc_desc;
					elif _cod_descuen = '008' then
						let _desc_edad = _porc_desc;
					elif _cod_descuen = '009' then
						let _desc_tip_veh = _porc_desc;
					end if
				else
					if _cod_descuen = '001' then
						let _desc_be_o = _porc_desc;
					elif _cod_descuen = '002' then
						let _desc_flota_o = _porc_desc;
					elif _cod_descuen = '003' then
						let _desc_esp_o = _porc_desc;
					elif _cod_descuen = '004' then
						let _desc_comb_o = _porc_desc;
					elif _cod_descuen = '005' then
						let _desc_modelo_o = _porc_desc;
					elif _cod_descuen = '006' then
						let _desc_sinis_o = _porc_desc;
					elif _cod_descuen = '007' then
						let _desc_clasif_o = _porc_desc;
					elif _cod_descuen = '008' then
						let _desc_edad_o = _porc_desc;
					elif _cod_descuen = '009' then
						let _desc_tip_veh_o = _porc_desc;
					end if
				end if
				let _porc_desc = 0;
			end foreach

			select aut.ano_tarifa,
					mae.limite_1,
					mae.limite_2,
					mae.prima_anual,
					mae.prima,
					mae.descuento,
					mae.prima_neta,
					case
					  when mae.limite_1 = 0 then 0
					  else (mae.prima/mae.limite_1) * 100
					end
			  into _ano_tarifa_o,
					_limite_1_o, 
					_limite_2_o, 
					_prima_anual_o, 
					_prima_o, 
					_descuento_o, 
					_prima_neta_o,
					_tasa_o
			  from emipomae emi
			 inner join emipouni uni on uni.no_poliza = emi.no_poliza
			 inner join emiauto aut on aut.no_poliza = uni.no_poliza and aut.no_unidad = uni.no_unidad
			 inner join emivehic veh on veh.no_motor = aut.no_motor
			 inner join emipocob mae on mae.no_poliza = uni.no_poliza and mae.no_unidad = uni.no_unidad
			 inner join prdcober cob on cob.cod_cobertura = mae.cod_cobertura --and (cob.nombre like 'COLI%' or cob.nombre like 'COMPR%')
			 where emi.no_poliza = _no_poliza
			   and uni.no_unidad = _no_unidad
			   and mae.cod_cobertura = _cod_cobertura;

			insert into tmp_sim_auto(
				subramo			,	
				poliza				,   
				vigencia_inic		,   
				vigencia_final	,   
				no_poliza			,   
				no_poliza_n		,   
				no_unidad			,   
				nom_producto	    ,   
				no_motor			,   
				cod_marca			,   
				marca				,   
				cod_modelo			,   
				modelo				,   
				nuevo				,   
				ano_auto			,   
				ano_tarifa			,   
				cod_cobertura		,   
				nom_cobertura		,   
				orden				,   
				limite_1			,   
				limite_2			,   
				tasa				,   
				prima_anual		,   
				prima				,   
				descuento			,   
				prima_neta			,   
				desc_buena_exp	,   
				desc_flota			,   
				desc_esp			,   
				desc_combinado	,   
				desc_modelo		,   
				desc_sinis			,   
				desc_clasif		,   
				desc_edad			,   
				desc_tipo_veh		,   
				ano_tarifa_o		,   
				limite_1_o			,   
				limite_2_o			,   
				tasa_o				,   
				prima_anual_o		,   
				prima_o			,   
				descuento_o		,   
				prima_neta_o		,   
				desc_buena_exp_o	,   
				desc_flota_o		,   
				desc_esp_o			,   
				desc_combinado_o	,   
				desc_modelo_o		,   
				desc_sinis_o		,   
				desc_clasif_o		,   
				desc_edad_o		,   
				desc_tipo_veh_o	,   
				diezporc			,   
				saldo,                 
				corredor,				
				zona_ventas,			
				incurrido				
			)
			values (
				_subramo,
				_no_documento,
				_vigencia_inic,
				_vigencia_final,
				_no_poliza			 ,
				_no_poliza_n		 ,
				_no_unidad			 ,
			    _nom_producto	     ,
			    _no_motor			 ,
			    _cod_marca			 ,
			    _marca				 ,
			    _cod_modelo			 ,
			    _modelo				 ,
			    _nuevo				 ,
			    _ano_auto			 ,
			    _ano_tarifa			 ,
			    _cod_cobertura		 ,
			    _nom_cobertura		 ,
			    _orden				 ,
			    _limite_1			 ,
			    _limite_2			 ,
			    _tasa				 ,
			    _prima_anual		 ,
			    _prima				 ,
			    _descuento			 ,
			    _prima_neta			 ,
			    _desc_be,
			    _desc_flota			 ,
			    _desc_esp			 ,
			    _desc_comb,
			    _desc_modelo,
			    _desc_sinis			 ,
			    _desc_clasif		 ,
			    _desc_edad			 ,
			    _desc_tip_veh		 ,
			    _ano_tarifa_o		 ,
			    _limite_1_o,
			    _limite_2_o,
			    _tasa_o,
			    _prima_anual_o,
			    _prima_o,
			    _descuento_o,
			    _prima_neta_o,
			    _desc_be_o,
			    _desc_flota_o,
			    _desc_esp_o,
			    _desc_comb_o,
			    _desc_modelo_o,
			    _desc_sinis_o,
			    _desc_clasif_o,
			    _desc_edad_o,
			    _desc_tip_veh_o,
			    _diezporc,
			    _saldo,
				_corredor,
				_zona_ventas,
				_incurrido);
		end foreach
		
		update emipomae
			set renovada  = 0
		 where no_poliza = _no_poliza;

		call sp_sis61b(_no_poliza_n) returning _error, _error_desc;
		
--		exit foreach;
	else
		continue foreach;
	end if
end foreach
end
end procedure;