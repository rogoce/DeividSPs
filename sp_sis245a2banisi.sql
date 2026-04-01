--Creado: 05/05/2022 
--Autor: Román Gordón
--Simulación de Renovación para Pool Automático
--execute procedure sp_sis245a2('2022-06') 

drop procedure sp_sis245a2banisi;
create procedure sp_sis245a2banisi(a_periodo char(7))
returning	integer			as err,
			integer			as error_isam,
			varchar(100)	as descripcion;

define _nom_cobertura 			varchar(100);       
define _nom_contratante			varchar(100);       
define _error_desc 				varchar(100);       
define _n_cliente 				varchar(100);       
define _limites 				varchar(100);       
define _limites_o 				varchar(100);       
define _subramo 				varchar(50);        
define _nom_producto			varchar(50);        
define _zona_ventas				varchar(50);        
define _desc_desc				varchar(50);        
define _corredor				varchar(50);        
define _nom_agt 				varchar(50);        
define _modelo					varchar(50);        
define _marca					varchar(50);        
define _ramo					varchar(50);        
define _tipo_auto				varchar(30);        
define _no_motor				varchar(30);        
define _no_documento			char(20);           
define _cod_contratante			char(10);           
define _no_poliza_n 			char(10);           
define _no_factura 				char(10);           
define _no_poliza 				char(10);           
define _no_pol	 				char(10);           
define _user_added 				char(8);            
define _cod_producto			char(5);            
define _cod_cobertura			char(5);            
define _cod_marca				char(5);            
define _cod_modelo				char(5);            
define _cod_agente 				char(5);            
define _grupo_mdl 				char(5);            
define _no_unidad 				char(5);            
define _cod_formapag 			char(3);            
define _cod_no_renov 			char(3);            
define _cod_subramo	 			char(3);            
define _cod_descuen	 			char(3);            
define _cod_ramo		 		char(3);            
define _tipo_persona	 		char(1);
define _opcion_ren		 		char(1);
define _estatus_poliza			smallint;           
define _cant_reclamos			smallint;           
define _ano_tarifa_o			smallint;           
define _no_sinis_ult			smallint;           
define _ano_tarifa				smallint;
define _tipo_forma				smallint;
define _no_renovar				smallint;
define _ano_auto				smallint;
define _cant_mov				smallint;
define _renovar					smallint;
define _nuevo					smallint;
define _orden					smallint;
define _dias					smallint;
define _edad_contratante		integer;
define _error_isam				integer;
define _cant_recl				integer;
define _error					integer;
define _existe					integer;
define _siniestralidad			dec(16,2);
define _prima_anual_o			dec(16,2);
define _prima_neta_o			dec(16,2);
define _no_sinis_pro			dec(16,2);
define _prima_bruta				dec(16,2);
define _prima_anual				dec(16,2);
define _descuento_o				dec(16,2);
define _prima_neta				dec(16,2);
define _limite_1_o				dec(16,2);
define _limite_2_o				dec(16,2);
define _saldo_elect				dec(16,2);
define _saldo_porc				dec(16,2);
define _saldo_rec				dec(16,2);
define _inc_total				dec(16,2);
define _descuento				dec(16,2);
define _incurrido				dec(16,2);
define _limite_1				dec(16,2);
define _limite_2				dec(16,2);
define _diezporc				dec(16,2);
define _prima_o					dec(16,2);
define _pagos					dec(16,2);
define _saldo					dec(16,2);
define _prima					dec(16,2);
define _porc_depreciacion		dec(5,2);
define _desc_be					dec(5,2);
define _desc_be_o				dec(5,2);
define _desc_flota				dec(5,2);	
define _desc_esp				dec(5,2);	
define _desc_comb				dec(5,2);	
define _desc_modelo				dec(5,2);	
define _desc_sinis				dec(5,2);	
define _desc_clasif				dec(5,2);	
define _desc_edad				dec(5,2);	
define _desc_tip_veh			dec(5,2);	
define _desc_flota_o			dec(5,2);	
define _desc_esp_o				dec(5,2);	
define _desc_comb_o				dec(5,2);	
define _desc_modelo_o			dec(5,2);
define _porc_desc				dec(5,2);
define _desc_sinis_o			dec(5,2);
define _desc_clasif_o			dec(5,2); 
define _desc_edad_o				dec(5,2);
define _desc_tip_veh_o			dec(5,2);
define _tasa					dec(5,2);
define _tasa_o					dec(5,2);
define _incremento				dec(5,2);
define _vigencia_final			date;
define _fecha_aniversario		date;
define _vigencia_inic			date;
define _fecha_desde				date;
define _fecha_hasta				date;
define _fecha_selec				date;
define _fecha_hoy				date;


define _suma_prima_neta			dec(16,2);
define _total_prima_neta		dec(16,2);

define 	_lesiones_prima_neta    DEC(16,2);
define 	_lesiones_prima_neta_o  DEC(16,2);
define 	_danos_prima_neta		DEC(16,2);
define 	_danos_prima_neta_o		DEC(16,2);
define 	_asist_prima_neta		DEC(16,2);
define 	_asist_prima_neta_o		DEC(16,2);
define 	_comp_prima_neta		DEC(16,2);
define 	_comp_prima_neta_o		DEC(16,2);
define 	_col_prima_neta		    DEC(16,2);
define 	_col_prima_neta_o		DEC(16,2);
define 	_robo_prima_neta		DEC(16,2);
define 	_robo_prima_neta_o		DEC(16,2);
define  _forma_pago             VARCHAR(50);        
define  _cnt_prod_exc			SMALLINT;       

let _suma_prima_neta = 0.00;
let _total_prima_neta = 0.00;

let _lesiones_prima_neta = 0.00;
let _lesiones_prima_neta_o = 0.00;
let _danos_prima_neta = 0.00;
let _danos_prima_neta_o = 0.00;
let _asist_prima_neta = 0.00;
let _asist_prima_neta_o = 0.00;
let _comp_prima_neta = 0.00;
let _comp_prima_neta_o = 0.00;
let _col_prima_neta = 0.00;
let _col_prima_neta_o = 0.00;
let _robo_prima_neta = 0.00;
let _robo_prima_neta_o = 0.00;

--set debug file to "sp_sis245a2.trc";
--trace on;
let _error = 0;
 let _error_isam = 0;
 let _nom_cobertura = '';
 let _no_poliza = '';
 let _no_documento = '';
 let _incremento = 0;
 
begin
on exception set _error,_error_isam,_error_desc
	if _nom_cobertura is null then
		let _nom_cobertura = '';
	end if
	
	if _no_poliza is null then
		let _no_poliza = '';
	end if
	
	if _no_documento is null then
		let _no_documento = '';
	end if
	
	return	_error,
			_error_isam,
			_no_documento||' ' ||_no_poliza || ' - ' || _nom_cobertura;
end exception

let _fecha_hoy = sp_sis26();
let _fecha_desde = mdy(a_periodo[6,7],1,a_periodo[1,4]);
let _fecha_hasta = sp_sis36(a_periodo);



drop table if exists tmp_sim_auto;
create temp table tmp_sim_auto(
subramo						varchar(50),
poliza						char(20),
forma_pago                  varchar(50),
vigencia_inic				date,
vigencia_final				date,
contratante					varchar(100),
edad_contratante			integer,
no_poliza					char(10),
no_poliza_n					char(10),
no_unidad					char(5),
nom_producto	    		varchar(50),
corredor		    		varchar(50),
zona_ventas	    			varchar(50),
no_motor					varchar(30),
cod_marca					char(5),
marca						varchar(50),
cod_modelo					char(5),
modelo						varchar(50),
opcion_deduc				char(1),
grupo_mdl					char(5),
tipo_auto					varchar(30),
nuevo						smallint,	
cant_recl_ult_vig			smallint,
siniestralidad				dec(16,2),	
ano_auto					smallint,
ano_tarifa					smallint,
ano_tarifa_o				smallint,
diezporc					dec(16,2),
saldo						dec(16,2),
incurrido					dec(16,2),
lesiones_limites			varchar(100),
lesiones_tasa				dec(5,2),
lesiones_prima_anual		dec(16,2) DEFAULT 0,
lesiones_prima				dec(16,2) DEFAULT 0,
lesiones_descuento			dec(16,2) DEFAULT 0,
lesiones_prima_neta			dec(16,2) DEFAULT 0,
lesiones_limites_o			varchar(100),
lesiones_tasa_o				dec(5,2),
lesiones_prima_anual_o		dec(16,2) DEFAULT 0,
lesiones_prima_o			dec(16,2) DEFAULT 0,
lesiones_descuento_o		dec(16,2) DEFAULT 0,
lesiones_prima_neta_o		dec(16,2) DEFAULT 0,
danos_limites				varchar(100),
danos_tasa					dec(5,2),
danos_prima_anual			dec(16,2) DEFAULT 0,
danos_prima					dec(16,2) DEFAULT 0,
danos_descuento				dec(16,2) DEFAULT 0,
danos_prima_neta			dec(16,2) DEFAULT 0,
danos_limites_o				varchar(100),
danos_tasa_o				dec(5,2),
danos_prima_anual_o			dec(16,2) DEFAULT 0,
danos_prima_o				dec(16,2) DEFAULT 0,
danos_descuento_o			dec(16,2) DEFAULT 0,
danos_prima_neta_o			dec(16,2) DEFAULT 0,
asist_limites				varchar(100),
asist_tasa					dec(5,2),
asist_prima_anual			dec(16,2) DEFAULT 0,
asist_prima					dec(16,2) DEFAULT 0,
asist_descuento				dec(16,2) DEFAULT 0,
asist_prima_neta			dec(16,2) DEFAULT 0,
asist_limites_o				varchar(100),
asist_tasa_o				dec(5,2),
asist_prima_anual_o			dec(16,2) DEFAULT 0,
asist_prima_o				dec(16,2) DEFAULT 0,
asist_descuento_o			dec(16,2) DEFAULT 0,
asist_prima_neta_o			dec(16,2) DEFAULT 0,	
comp_limites				varchar(100),
comp_tasa					dec(5,2),
comp_prima_anual			dec(16,2) DEFAULT 0,
comp_prima					dec(16,2) DEFAULT 0,
comp_descuento				dec(16,2) DEFAULT 0,
comp_prima_neta				dec(16,2) DEFAULT 0,
comp_desc_esp				dec(5,2),
comp_desc_combinado			dec(5,2),
comp_desc_sinis				dec(5,2),
comp_desc_clasif			dec(5,2),
comp_desc_edad				dec(5,2),
comp_limites_o				varchar(100),
comp_tasa_o					dec(5,2),
comp_prima_anual_o			dec(16,2) DEFAULT 0,
comp_prima_o				dec(16,2) DEFAULT 0,
comp_descuento_o			dec(16,2) DEFAULT 0,
comp_prima_neta_o			dec(16,2) DEFAULT 0,
comp_desc_esp_o				dec(5,2),
comp_desc_combinado_o		dec(5,2),
comp_desc_sinis_o			dec(5,2),
comp_desc_clasif_o			dec(5,2),
comp_desc_edad_o			dec(5,2),
col_limites					varchar(100),
col_tasa					dec(5,2),
col_prima_anual				dec(16,2) DEFAULT 0,
col_prima					dec(16,2) DEFAULT 0,
col_descuento				dec(16,2) DEFAULT 0,
col_prima_neta				dec(16,2) DEFAULT 0,
col_desc_esp				dec(5,2),
col_desc_combinado			dec(5,2),
col_desc_sinis				dec(5,2),
col_desc_clasif				dec(5,2),
col_desc_edad				dec(5,2),
col_limites_o				varchar(100),
col_tasa_o					dec(5,2),
col_prima_anual_o			dec(16,2) DEFAULT 0,
col_prima_o					dec(16,2) DEFAULT 0,
col_descuento_o				dec(16,2) DEFAULT 0,
col_prima_neta_o			dec(16,2) DEFAULT 0,
col_desc_esp_o				dec(5,2),
col_desc_combinado_o		dec(5,2),
col_desc_sinis_o			dec(5,2),
col_desc_clasif_o			dec(5,2),
col_desc_edad_o				dec(5,2),
endoso						varchar(100),
end_prima					dec(16,2) DEFAULT 0,
end_prima_o					dec(16,2) DEFAULT 0,
robo_limites				varchar(100),
robo_tasa					dec(5,2),
robo_prima_anual			dec(16,2) DEFAULT 0,
robo_prima					dec(16,2) DEFAULT 0,
robo_descuento				dec(16,2) DEFAULT 0,
robo_prima_neta				dec(16,2) DEFAULT 0,
robo_limites_o				varchar(100),
robo_tasa_o					dec(5,2),
robo_prima_anual_o			dec(16,2) DEFAULT 0,
robo_prima_o				dec(16,2) DEFAULT 0,
robo_descuento_o			dec(16,2) DEFAULT 0,
robo_prima_neta_o			dec(16,2) DEFAULT 0,
suma_prima_neta 			dec(16,2) DEFAULT 0,
total_prima_neta			dec(16,2) DEFAULT 0,
reclamos_totales            dec(16,2) DEFAULT 0,
incremento				    dec(5,2),
incremento_neto             dec(16,2) DEFAULT 0,
primary key(no_poliza,no_unidad)) with no log;

foreach
/*							
0	0	Sin Siniestros	6.30%
1	50	Más de un siniestro con Stdad <=50%	8.00%
2	55	Max 2 sin con Srdad entre 50% y 55%	10.00%
2	55	Max 2 sin con Srdad mayor a 55%	15.00%
2	55	Mas de 2 sin con Srdad entre 50% y 55%	20.00%
2	55	Mas de 2 sin con Srdad mayor a 55%	25.00%
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
			_subramo*/

--set debug file to "sp_sis245.trc";
--trace on;

	select emi.no_poliza,
				aut.no_documento,
				aut.vigencia_inic,
				aut.vigencia_final,
				emi.saldo,
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
		  inner join emipomae emi on emi.no_documento = aut.no_documento--emi.no_poliza = aut.no_poliza
		 where aut.vigencia_final between _fecha_desde and _fecha_hasta  --'01/10/2023' and '31/10/2023'
		   and emi.cod_ramo = '002'
		   and emi.cod_subramo = '001'
		   and aut.estatus in (1,4)
 		   and emi.no_renovar = 0 and emi.renovada = 0
      union
      select emi.no_poliza,
				aut.no_documento,
				aut.vigencia_inic,
				aut.vigencia_final,
				emi.saldo,
				aut.incurrido,
				emi.prima_bruta,
				emi.cod_subramo,
				emi.cod_formapag
			  from emirepol aut
		  inner join emipomae emi on emi.no_documento = aut.no_documento--emi.no_poliza = aut.no_poliza
		 where aut.vigencia_final between _fecha_desde and _fecha_hasta
		   and emi.cod_ramo = '002'
		   and emi.cod_subramo = '001'
		   and aut.estatus in (1,4)
 		   and emi.no_renovar = 0 and emi.renovada = 0
                   and aut.no_poliza not in (
                   	select emi.no_poliza
			  from emirepo aut
		  inner join emipomae emi on emi.no_documento = aut.no_documento--emi.no_poliza = aut.no_poliza
		 where aut.vigencia_final between _fecha_desde and _fecha_hasta
		   and emi.cod_ramo = '002'
		   and emi.cod_subramo = '001'
		 --  and aut.estatus in (1,4)
 		   and emi.no_renovar = 0 and emi.renovada = 0)
		   
{	select emi.no_poliza,
				aut.no_documento,
				aut.vigencia_inic,
				aut.vigencia_final,
				emi.saldo,
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
		  inner join emipomae emi on emi.no_documento = aut.no_documento--emi.no_poliza = aut.no_poliza
		 where aut.vigencia_final between _fecha_desde and _fecha_hasta  --'01/10/2023' and '31/10/2023'
		   and emi.cod_ramo = '002'
		   and emi.cod_subramo = '001'
		   and aut.estatus in (1,4)
 		   and emi.no_renovar = 0 and emi.renovada = 0
}	
	let _cnt_prod_exc = 0;
{	
	select count(*)
	  into _cnt_prod_exc
	  from emipouni
	 where no_poliza = _no_poliza
	   and cod_producto in ('04563','07755','03812','03811','02283','08268','08307','08305','08306','03810','07754','07213','02282','08267');
	 
	if _cnt_prod_exc is null then
		let _cnt_prod_exc = 0;
    end if	
	
    if _cnt_prod_exc > 0 then		 
		continue foreach;
	end if
}

{02282 PETROAUTOS / SCOTIA BANK (SEDANES)
02283 PETROAUTOS / SCOTIA BANK (CAMIONETA Y PICK UP)
03810 AUTO COMPLETA – BANISI
03811 PETROAUTOS / BANISI (SEDANES)
03812 PETROAUTOS / BANISI (CAMIONETA Y PICK UP)
07215 AUTO COMPLETA - BANISI / UNITY
07755 AUTO COMPLETA - BANISI / UNITY
07754 AUTO COMPLETA - CORP. DE CREDITO
08278 AUTO COMPLETA - GENERAL REPRESENTATIVE
}	
	select count(*)
	  into _cnt_prod_exc
	  from emipouni
	 where no_poliza = _no_poliza
	   and cod_producto in ('07755','03812','03811','02283','03810','07754','02282','07215','08278');
	 
	if _cnt_prod_exc is null then
		let _cnt_prod_exc = 0;
    end if	
	
    if _cnt_prod_exc = 0 then		 
		continue foreach;
	end if
	
	select saldo_elect,
		    saldo_porc
	  into _saldo_elect,
		    _saldo_porc
	  from emirepar;

	select tipo_forma,
	       nombre
	  into _tipo_forma,
	       _forma_pago
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
		   emi.cod_subramo,
		   emi.cod_no_renov,
		   emi.estatus_poliza,
		   ram.nombre,
		   cli.nombre,
		   cli.fecha_aniversario,
		   cli.tipo_persona
	  into _cod_ramo,
		   _cod_subramo,
		   _cod_no_renov,
		   _estatus_poliza,
		   _ramo,
		   _nom_contratante,
		   _fecha_aniversario,
		   _tipo_persona
	  from emipomae emi
	 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
	 inner join cliclien cli on cli.cod_cliente = emi.cod_contratante
	 where no_poliza = _no_poliza;
	 
	if _cod_no_renov is null then
		let _cod_no_renov = '';
	end if

	if _cod_no_renov in ('039') or _estatus_poliza in (2,4) then
		continue foreach;
	end if

	if _cod_ramo = '002' and _vigencia_final between _fecha_desde and _fecha_hasta then
		
		let _no_poliza_n = 'S' || trim(_no_poliza);
		--call sp_pro320d('DEIVID', _no_poliza, _no_poliza_n) returning _error,_error_desc;	
		call sp_pro320gSim('DEIVID', _no_poliza, _no_poliza_n) returning _error, _error_desc;

		if _error = 0 then
		
			call sp_pro82m2(_no_documento) returning _cant_recl,_inc_total,_saldo_rec,_cant_mov, _no_sinis_ult, _no_sinis_pro, _siniestralidad, _desc_desc;
			
			if _tipo_persona = 'N' and _fecha_aniversario is not null then
				let _edad_contratante = sp_sis78(_fecha_aniversario, _vigencia_final); 
			else
				let _edad_contratante =  0;
			end if
			let _incremento = 0;
			-------------------------------------------------
			if _no_sinis_ult is null then
				let _no_sinis_ult = 0;
			end if			
			if _cant_recl is null then
				let _cant_recl = 0;
			end if
			if _siniestralidad is null then
				let _siniestralidad = 0;
			end if
			if _cant_recl = 0 and _incremento = 0 then
				if _siniestralidad = 0 then
					--let _incremento = 6.30;
					let _incremento = 0;
				else
				   let _incremento = 0;
				end if
			else
			   let _incremento = 0;
			end if
			
			if _cant_recl >= 3 and _incremento = 0 then
				if _siniestralidad >= 50 and _siniestralidad <= 55 then
					let _incremento = 20;
				else
					if _siniestralidad > 55 then
						--let _incremento = 25;
						let _incremento = 0;
					else
					   let _incremento = 0;
					end if
				end if
			end if	

			if _cant_recl >= 1 and _cant_recl <= 2 and _incremento = 0 then
				if _siniestralidad >= 50 and _siniestralidad <= 55 then
					--let _incremento = 10;
					let _incremento = 0;
				else
					if _siniestralidad > 55 then
						--let _incremento = 15;
						let _incremento = 0;
					else
					   let _incremento = 0;
					end if
				end if
			end if			

			if _cant_recl >= 1 and _incremento = 0 then
				if  _siniestralidad <= 50 then
					--let _incremento = 8;
					let _incremento = 0;
				else
				   let _incremento = 0;
				end if
			end if	
            --------------------------------------------------
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
						mdl.grupo,
						tip.nombre,
						aut.opcion,
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
						_grupo_mdl,
						_tipo_auto,
						_opcion_ren,
						_tasa,
						_corredor,
						_zona_ventas
				  from emipomae emi
				 inner join emipouni uni on uni.no_poliza = emi.no_poliza
				 inner join emiauto aut on aut.no_poliza = uni.no_poliza and aut.no_unidad = uni.no_unidad
				 inner join emivehic veh on veh.no_motor = aut.no_motor
				 inner join emimarca mar on mar.cod_marca = veh.cod_marca
				 inner join emimodel mdl on mdl.cod_marca = veh.cod_marca and mdl.cod_modelo = veh.cod_modelo
				 inner join emitiaut tip on tip.cod_tipoauto = mdl.cod_tipoauto
				 inner join emipocob mae on mae.no_poliza = uni.no_poliza and mae.no_unidad = uni.no_unidad and mae.prima_neta <> 0
				 inner join prdprod prd on prd.cod_producto = uni.cod_producto
				 inner join prdcober cob on cob.cod_cobertura = mae.cod_cobertura --and (cob.nombre like 'COLI%' or cob.nombre like 'COMPR%')
				 inner join emipoliza pol on pol.no_documento = emi.no_documento
				 inner join agtagent agt on agt.cod_agente = pol.cod_agente
				 inner join agtvende zon on zon.cod_vendedor = agt.cod_vendedor
				 where emi.no_poliza = _no_poliza_n
				 order by mae.no_poliza,mae.no_unidad,mae.orden

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
				
				let _suma_prima_neta = 0.00;
				let _total_prima_neta = 0.00;

				let _lesiones_prima_neta = 0.00;
				let _lesiones_prima_neta_o = 0.00;
				let _danos_prima_neta = 0.00;
				let _danos_prima_neta_o = 0.00;
				let _asist_prima_neta = 0.00;
				let _asist_prima_neta_o = 0.00;
				let _comp_prima_neta = 0.00;
				let _comp_prima_neta_o = 0.00;
				let _col_prima_neta = 0.00;
				let _col_prima_neta_o = 0.00;
				let _robo_prima_neta = 0.00;
				let _robo_prima_neta_o = 0.00;						

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
				   
				if _prima_neta is null then let  _prima_neta = 0; end if
				if _prima_neta_o is null then let  _prima_neta_o = 0; end if   

				if _cod_cobertura = '00102' then --	LESIONES CORPORALES
				
					 if _prima_neta is null then let  _prima_neta = 0; end if
					 if _prima_neta_o is null then let  _prima_neta_o = 0; end if
					 
					let _lesiones_prima_neta = _prima_neta;
					let _lesiones_prima_neta_o =  _prima_neta_o;

				
					let _limites =  cast(_limite_1 as varchar(7)) || ' - ' || cast(_limite_2 as varchar(7)); 
					let _limites_o =  cast(_limite_1_o as varchar(7)) || ' - ' || cast(_limite_2_o as varchar(7)); 
					
					BEGIN
					ON EXCEPTION IN(-239,-268)
						update tmp_sim_auto
						   set	lesiones_limites		=_limites,
								lesiones_tasa           =_tasa,
								lesiones_prima_anual    =_prima_anual,
								lesiones_prima          =_prima,
								lesiones_descuento      =_descuento,
								lesiones_prima_neta     =_prima_neta,
								lesiones_limites_o      =_limites_o,
								lesiones_tasa_o         =_tasa_o,
								lesiones_prima_anual_o  =_prima_anual_o,
								lesiones_prima_o        =_prima_o,
								lesiones_descuento_o    =_descuento_o,
								lesiones_prima_neta_o   =_prima_neta_o
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad;
					END EXCEPTION	
					

					insert into tmp_sim_auto(
					subramo,
					poliza,
					forma_pago,
					vigencia_inic,
					vigencia_final,
					contratante,
					edad_contratante,
					no_poliza,
					no_poliza_n,
					no_unidad,
					nom_producto,
					corredor,
					zona_ventas,
					no_motor,
					cod_marca,
					marca,
					cod_modelo,
					modelo,
					grupo_mdl,	
					tipo_auto,	
					opcion_deduc,
					nuevo,
					cant_recl_ult_vig,
					siniestralidad,
					ano_auto,
					ano_tarifa,
					ano_tarifa_o,				
					diezporc,
					saldo,
					incurrido,
					lesiones_limites,
					lesiones_tasa,
					lesiones_prima_anual,
					lesiones_prima,
					lesiones_descuento,
					lesiones_prima_neta,
					lesiones_limites_o,
					lesiones_tasa_o,
					lesiones_prima_anual_o,
					lesiones_prima_o,
					lesiones_descuento_o,
					lesiones_prima_neta_o,
					incremento,
					reclamos_totales
					)
					values (
						_subramo,
						_no_documento,
						_forma_pago,
						_vigencia_inic,
						_vigencia_final,
						_nom_contratante,
						_edad_contratante,
						_no_poliza,
						_no_poliza_n,
						_no_unidad,
						_nom_producto,
						_corredor,
						_zona_ventas,
						_no_motor,
						_cod_marca,
						_marca,
						_cod_modelo,
						_modelo,
						_grupo_mdl,
						_tipo_auto,
						_opcion_ren,
						_nuevo,
						_no_sinis_ult,
						_siniestralidad,
						_ano_auto,
						_ano_tarifa,
						_ano_tarifa_o,
						_diezporc,
						_saldo,
						_incurrido,
						_limites,
						_tasa,
						_prima_anual,
						_prima,
						_descuento,
						_prima_neta,
						_limites_o,
						_tasa_o,
						_prima_anual_o,
						_prima_o,
						_descuento_o,
						_prima_neta_o,
						_incremento,
                        _cant_recl						
						);
					END
				elif _cod_cobertura = '00113' then --DAÑOS A LA PROPIEDAD AJENA
					let _limites = cast(_limite_1 as varchar(7)); 
					let _limites_o = cast(_limite_1_o as varchar(7)); 
					
					 if _prima_neta is null then let  _prima_neta = 0; end if
					 if _prima_neta_o is null then let  _prima_neta_o = 0; end if
					 
					let _danos_prima_neta = _prima_neta;
					let _danos_prima_neta_o = _prima_neta_o;		
					
					BEGIN
					ON EXCEPTION IN(-239,-268)
						update tmp_sim_auto
						   set	danos_limites		 =_limites,
								danos_tasa           =_tasa,
								danos_prima_anual    =_prima_anual,
								danos_prima          =_prima,
								danos_descuento      =_descuento,
								danos_prima_neta     =_prima_neta,
								danos_limites_o      =_limites_o,
								danos_tasa_o         =_tasa_o,
								danos_prima_anual_o  =_prima_anual_o,
								danos_prima_o        =_prima_o,
								danos_descuento_o    =_descuento_o,
								danos_prima_neta_o   =_prima_neta_o
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad;
					END EXCEPTION	

					insert into tmp_sim_auto(
					subramo,
					poliza,
					forma_pago,
					vigencia_inic,
					vigencia_final,
					no_poliza,
					no_poliza_n,
					no_unidad,
					nom_producto,
					corredor,
					zona_ventas,
					no_motor,
					cod_marca,
					marca,
					cod_modelo,
					modelo,
					nuevo,
					ano_auto,
					ano_tarifa,
					ano_tarifa_o,				
					diezporc,
					saldo,
					incurrido,
					danos_limites,
					danos_tasa,
					danos_prima_anual,
					danos_prima,
					danos_descuento,
					danos_prima_neta,
					danos_limites_o,
					danos_tasa_o,
					danos_prima_anual_o,
					danos_prima_o,
					danos_descuento_o,
					danos_prima_neta_o,
					incremento	
					)
					values (
						_subramo,
						_no_documento,
						_forma_pago,
						_vigencia_inic,
						_vigencia_final,
						_no_poliza,
						_no_poliza_n,
						_no_unidad,
						_nom_producto,
						_corredor,
						_zona_ventas,
						_no_motor,
						_cod_marca,
						_marca,
						_cod_modelo,
						_modelo,
						_nuevo,
						_ano_auto,
						_ano_tarifa,
						_ano_tarifa_o,
						_diezporc,
						_saldo,
						_incurrido,
						_limites,
						_tasa,
						_prima_anual,
						_prima,
						_descuento,
						_prima_neta,
						_limites_o,
						_tasa_o,
						_prima_anual_o,
						_prima_o,
						_descuento_o,
						_prima_neta_o,
						_incremento	
						);
					END
				elif _cod_cobertura = '00117' then --ASISTENCIA MEDICA
					let _limites =  cast(_limite_1 as varchar(7)) || ' - ' || cast(_limite_2 as varchar(7)); 
					let _limites_o =  cast(_limite_1_o as varchar(7)) || ' - ' || cast(_limite_2_o as varchar(7)); 
					
					 if _prima_neta is null then let  _prima_neta = 0; end if
					 if _prima_neta_o is null then let  _prima_neta_o = 0; end if
					 
					let _asist_prima_neta = _prima_neta;
					let _asist_prima_neta_o = _prima_neta_o;					
					
					BEGIN
					ON EXCEPTION IN(-239,-268)
						update tmp_sim_auto
						   set	asist_limites		=_limites,
								asist_tasa           =_tasa,
								asist_prima_anual    =_prima_anual,
								asist_prima          =_prima,
								asist_descuento      =_descuento,
								asist_prima_neta     =_prima_neta,
								asist_limites_o      =_limites_o,
								asist_tasa_o         =_tasa_o,
								asist_prima_anual_o  =_prima_anual_o,
								asist_prima_o        =_prima_o,
								asist_descuento_o    =_descuento_o,
								asist_prima_neta_o   =_prima_neta_o
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad;
					END EXCEPTION			

					insert into tmp_sim_auto(
					subramo,
					poliza,
					forma_pago,
					vigencia_inic,
					vigencia_final,
					no_poliza,
					no_poliza_n,
					no_unidad,
					nom_producto,
					corredor,
					zona_ventas,
					no_motor,
					cod_marca,
					marca,
					cod_modelo,
					modelo,
					nuevo,
					ano_auto,
					ano_tarifa,
					ano_tarifa_o,				
					diezporc,
					saldo,
					incurrido,
					asist_limites,
					asist_tasa,
					asist_prima_anual,
					asist_prima,
					asist_descuento,
					asist_prima_neta,
					asist_limites_o,
					asist_tasa_o,
					asist_prima_anual_o,
					asist_prima_o,
					asist_descuento_o,
					asist_prima_neta_o,
					incremento	
					)
					values (
						_subramo,
						_no_documento,
						_forma_pago,
						_vigencia_inic,
						_vigencia_final,
						_no_poliza,
						_no_poliza_n,
						_no_unidad,
						_nom_producto,
						_corredor,
						_zona_ventas,
						_no_motor,
						_cod_marca,
						_marca,
						_cod_modelo,
						_modelo,
						_nuevo,
						_ano_auto,
						_ano_tarifa,
						_ano_tarifa_o,
						_diezporc,
						_saldo,
						_incurrido,
						_limites,
						_tasa,
						_prima_anual,
						_prima,
						_descuento,
						_prima_neta,
						_limites_o,
						_tasa_o,
						_prima_anual_o,
						_prima_o,
						_descuento_o,
						_prima_neta_o,
						_incremento	
						);
					END
				elif _cod_cobertura = '00118' then -- COMPRENSIVO
					let _limites =  cast(_limite_1 as varchar(7)); 
					let _limites_o =  cast(_limite_1_o as varchar(7)); 
					
					 if _prima_neta is null then let  _prima_neta = 0; end if
					 if _prima_neta_o is null then let  _prima_neta_o = 0; end if
					 
					let _comp_prima_neta = _prima_neta;
					let _comp_prima_neta_o = _prima_neta_o;					

					BEGIN
					ON EXCEPTION IN(-239,-268)
						update tmp_sim_auto
						   set	comp_limites			= _limites,
								comp_tasa           	= _tasa,
								comp_prima_anual    	= _prima_anual,
								comp_prima          	= _prima,
								comp_descuento      	= _descuento,
								comp_prima_neta     	= _prima_neta,
								comp_desc_esp			= _desc_esp,
								comp_desc_combinado		= _desc_comb,
								comp_desc_sinis			= _desc_sinis,
								comp_desc_clasif		= _desc_clasif,
								comp_desc_edad			= _desc_edad,
								comp_limites_o      	= _limites_o,
								comp_tasa_o         	= _tasa_o,
								comp_prima_anual_o  	= _prima_anual_o,
								comp_prima_o        	= _prima_o,
								comp_descuento_o    	= _descuento_o,
								comp_prima_neta_o   	= _prima_neta_o,
								comp_desc_esp_o			= _desc_esp_o,
								comp_desc_combinado_o	= _desc_comb_o,
								comp_desc_sinis_o       = _desc_sinis_o,
								comp_desc_clasif_o      = _desc_clasif_o,
								comp_desc_edad_o        = _desc_edad_o
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad;
					END EXCEPTION

					insert into tmp_sim_auto(
					subramo,
					poliza,
					forma_pago,
					vigencia_inic,
					vigencia_final,
					no_poliza,
					no_poliza_n,
					no_unidad,
					nom_producto,
					corredor,
					zona_ventas,
					no_motor,
					cod_marca,
					marca,
					cod_modelo,
					modelo,
					nuevo,
					ano_auto,
					ano_tarifa,
					ano_tarifa_o,				
					diezporc,
					saldo,
					incurrido,
					comp_limites,
					comp_tasa,
					comp_prima_anual,
					comp_prima,
					comp_descuento,
					comp_prima_neta,
					comp_desc_esp,		
					comp_desc_combinado,
					comp_desc_sinis,
					comp_desc_clasif,
					comp_desc_edad,
					comp_limites_o,
					comp_tasa_o,
					comp_prima_anual_o,
					comp_prima_o,
					comp_descuento_o,
					comp_prima_neta_o,
					comp_desc_esp_o,
					comp_desc_combinado_o,
					comp_desc_sinis_o,
					comp_desc_clasif_o,
					comp_desc_edad_o,
					incremento	
					)
					values (
						_subramo,
						_no_documento,
						_forma_pago,
						_vigencia_inic,
						_vigencia_final,
						_no_poliza,
						_no_poliza_n,
						_no_unidad,
						_nom_producto,
						_corredor,
						_zona_ventas,
						_no_motor,
						_cod_marca,
						_marca,
						_cod_modelo,
						_modelo,
						_nuevo,
						_ano_auto,
						_ano_tarifa,
						_ano_tarifa_o,
						_diezporc,
						_saldo,
						_incurrido,
						_limites,
						_tasa,
						_prima_anual,
						_prima,
						_descuento,
						_prima_neta,
						_desc_esp,
						_desc_comb,
						_desc_sinis,
						_desc_clasif,
						_desc_edad,					
						_limites_o,
						_tasa_o,
						_prima_anual_o,
						_prima_o,
						_descuento_o,
						_prima_neta_o,
						_desc_esp_o,
						_desc_comb_o,
						_desc_sinis_o,
						_desc_clasif_o,
						_desc_edad_o,
						_incremento	
						);
					END
				elif _cod_cobertura = '00119' then -- COLISION O VUELCO
					let _limites =  cast(_limite_1 as varchar(7)); 
					let _limites_o =  cast(_limite_1_o as varchar(7)); 
					
					 if _prima_neta is null then let  _prima_neta = 0; end if
					 if _prima_neta_o is null then let  _prima_neta_o = 0; end if
					 
					let _col_prima_neta = _prima_neta;
					let _col_prima_neta_o = _prima_neta_o;					

					BEGIN
					ON EXCEPTION IN(-239,-268)
						update tmp_sim_auto
						   set	col_limites				= _limites,
								col_tasa           		= _tasa,
								col_prima_anual    		= _prima_anual,
								col_prima          		= _prima,
								col_descuento      		= _descuento,
								col_prima_neta     		= _prima_neta,
								col_desc_esp			= _desc_esp,
								col_desc_combinado		= _desc_comb,
								col_desc_sinis			= _desc_sinis,
								col_desc_clasif			= _desc_clasif,
								col_desc_edad			= _desc_edad,
								col_limites_o      		= _limites_o,
								col_tasa_o         		= _tasa_o,
								col_prima_anual_o  		= _prima_anual_o,
								col_prima_o        		= _prima_o,
								col_descuento_o    		= _descuento_o,
								col_prima_neta_o   		= _prima_neta_o,
								col_desc_esp_o			= _desc_esp_o,
								col_desc_combinado_o	= _desc_comb_o,
								col_desc_sinis_o       = _desc_sinis_o,
								col_desc_clasif_o      = _desc_clasif_o,
								col_desc_edad_o        = _desc_edad_o
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad;
					END EXCEPTION

					insert into tmp_sim_auto(
					subramo,
					poliza,
					forma_pago,
					vigencia_inic,
					vigencia_final,
					no_poliza,
					no_poliza_n,
					no_unidad,
					nom_producto,
					corredor,
					zona_ventas,
					no_motor,
					cod_marca,
					marca,
					cod_modelo,
					modelo,
					nuevo,
					ano_auto,
					ano_tarifa,
					ano_tarifa_o,				
					diezporc,
					saldo,
					incurrido,
					col_limites,
					col_tasa,
					col_prima_anual,
					col_prima,
					col_descuento,
					col_prima_neta,
					col_desc_esp,		
					col_desc_combinado,
					col_desc_sinis,
					col_desc_clasif,
					col_desc_edad,
					col_limites_o,
					col_tasa_o,
					col_prima_anual_o,
					col_prima_o,
					col_descuento_o,
					col_prima_neta_o,
					col_desc_esp_o,
					col_desc_combinado_o,
					col_desc_sinis_o,    
					col_desc_clasif_o,  
					col_desc_edad_o,
					incremento	
					)
					values (
						_subramo,
						_no_documento,
						_forma_pago,
						_vigencia_inic,
						_vigencia_final,
						_no_poliza,
						_no_poliza_n,
						_no_unidad,
						_nom_producto,
						_corredor,
						_zona_ventas,
						_no_motor,
						_cod_marca,
						_marca,
						_cod_modelo,
						_modelo,
						_nuevo,
						_ano_auto,
						_ano_tarifa,
						_ano_tarifa_o,
						_diezporc,
						_saldo,
						_incurrido,
						_limites,
						_tasa,
						_prima_anual,
						_prima,
						_descuento,
						_prima_neta,
						_desc_esp,
						_desc_comb,
						_desc_sinis,
						_desc_clasif,
						_desc_edad,
						_limites_o,
						_tasa_o,
						_prima_anual_o,
						_prima_o,
						_descuento_o,
						_prima_neta_o,
						_desc_esp_o,
						_desc_comb_o,
						_desc_sinis_o,
						_desc_clasif_o,
						_desc_edad_o,
						_incremento	
						);
					END
				elif _cod_cobertura in ('00104','01535','01481') then -- ENDOSOS				

					
					BEGIN
					ON EXCEPTION IN(-239,-268)
						update tmp_sim_auto
						   set	endoso = _nom_cobertura,
								end_prima = _prima,
								end_prima_o = _prima_o
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad;
					END EXCEPTION			

					insert into tmp_sim_auto(
					subramo,
					poliza,
					forma_pago,
					vigencia_inic,
					vigencia_final,
					no_poliza,
					no_poliza_n,
					no_unidad,
					nom_producto,
					corredor,
					zona_ventas,
					no_motor,
					cod_marca,
					marca,
					cod_modelo,
					modelo,
					nuevo,
					ano_auto,
					ano_tarifa,
					ano_tarifa_o,				
					diezporc,
					saldo,
					incurrido,
					endoso,
					end_prima,
					end_prima_o,
					incremento	
					)
					values (
						_subramo,
						_no_documento,
						_forma_pago,
						_vigencia_inic,
						_vigencia_final,
						_no_poliza,
						_no_poliza_n,
						_no_unidad,
						_nom_producto,
						_corredor,
						_zona_ventas,
						_no_motor,
						_cod_marca,
						_marca,
						_cod_modelo,
						_modelo,
						_nuevo,
						_ano_auto,
						_ano_tarifa,
						_ano_tarifa_o,
						_diezporc,
						_saldo,
						_incurrido,
						_nom_cobertura,
						_prima,
						_prima_o,
						_incremento	
						);
					END
				elif _cod_cobertura = '00901' then -- ROBO TOTAL DEL AUTO
				
					 if _prima_neta is null then let  _prima_neta = 0; end if
					 if _prima_neta_o is null then let  _prima_neta_o = 0; end if
					 
					let _robo_prima_neta = _prima_neta;
					let _robo_prima_neta_o = _prima_neta_o;					
					
					let _limites =  cast(_limite_1 as varchar(7)) || ' - ' || cast(_limite_2 as varchar(7)); 
					let _limites_o =  cast(_limite_1_o as varchar(7)) || ' - ' || cast(_limite_2_o as varchar(7)); 
					
					BEGIN
					ON EXCEPTION IN(-239,-268)
						update tmp_sim_auto
						   set	robo_limites		=_limites,
								robo_tasa           =_tasa,
								robo_prima_anual    =_prima_anual,
								robo_prima          =_prima,
								robo_descuento      =_descuento,
								robo_prima_neta     =_prima_neta,
								robo_limites_o      =_limites_o,
								robo_tasa_o         =_tasa_o,
								robo_prima_anual_o  =_prima_anual_o,
								robo_prima_o        =_prima_o,
								robo_descuento_o    =_descuento_o,
								robo_prima_neta_o   =_prima_neta_o
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad;
					END EXCEPTION			

					insert into tmp_sim_auto(
					subramo,
					poliza,
					forma_pago,
					vigencia_inic,
					vigencia_final,
					no_poliza,
					no_poliza_n,
					no_unidad,
					nom_producto,
					corredor,
					zona_ventas,
					no_motor,
					cod_marca,
					marca,
					cod_modelo,
					modelo,
					nuevo,
					ano_auto,
					ano_tarifa,
					ano_tarifa_o,									
					diezporc,											
					saldo,                                               
					incurrido,                                 
					robo_limites,                          		
					robo_tasa,                              	
					robo_prima_anual,                         
					robo_prima,                                    
					robo_descuento,                            
					robo_prima_neta,                           
					robo_limites_o,                             
					robo_tasa_o,                                   
					robo_prima_anual_o,                     
					robo_prima_o,                                 
					robo_descuento_o,                         
					robo_prima_neta_o,
					incremento	                        
					)
					values (
						_subramo,
						_no_documento,
						_forma_pago,
						_vigencia_inic,
						_vigencia_final,
						_no_poliza,
						_no_poliza_n,
						_no_unidad,
						_nom_producto,
						_corredor,
						_zona_ventas,
						_no_motor,
						_cod_marca,
						_marca,
						_cod_modelo,
						_modelo,
						_nuevo,
						_ano_auto,
						_ano_tarifa,
						_ano_tarifa_o,
						_diezporc,
						_saldo,
						_incurrido,
						_limites,
						_tasa,
						_prima_anual,
						_prima,
						_descuento,
						_prima_neta,
						_limites_o,
						_tasa_o,
						_prima_anual_o,
						_prima_o,
						_descuento_o,
						_prima_neta_o,
						_incremento	
						);
					END
			
				end if 
				
				if _lesiones_prima_neta is null then 
					let _lesiones_prima_neta = 0;
				end if
				if _lesiones_prima_neta_o is null then 
					let _lesiones_prima_neta_o = 0;
				end if
				if _danos_prima_neta is null then 
					let _danos_prima_neta = 0;
				end if
				if _danos_prima_neta_o is null then 
					let _danos_prima_neta_o = 0;
				end if
				if _asist_prima_neta is null then 
					let _asist_prima_neta = 0;
				end if
				if _asist_prima_neta_o is null then 
					let _asist_prima_neta_o = 0;
				end if
				if _comp_prima_neta is null then 
					let _comp_prima_neta = 0;
				end if
				if _comp_prima_neta_o is null then 
					let _comp_prima_neta_o = 0;
				end if
				if _col_prima_neta is null then 
					let _col_prima_neta = 0;
				end if
				if _col_prima_neta_o is null then 
					let _col_prima_neta_o = 0;
				end if
				if _robo_prima_neta is null then 
					let _robo_prima_neta = 0;
				end if
				if _robo_prima_neta_o is null then 
					let _robo_prima_neta_o = 0;
				end if
				if _prima is null then 
					let _prima = 0;
				end if
				if _prima_o is null then 
					let _prima_o = 0;
				end if
				
				let _suma_prima_neta = _lesiones_prima_neta + _danos_prima_neta + _asist_prima_neta + _comp_prima_neta +_col_prima_neta + _robo_prima_neta +_prima;
				let _total_prima_neta = _lesiones_prima_neta_o + _danos_prima_neta_o + _asist_prima_neta_o + _comp_prima_neta_o + _col_prima_neta_o + _robo_prima_neta_o +_prima_o;					
				if _suma_prima_neta is null then
					let _suma_prima_neta = 0;
				end if
				if _total_prima_neta is null then
					let _total_prima_neta = 0;
				end if	
				{if _suma_prima_neta = 0.00 and _total_prima_neta = 0.00 then
					select nvl(lesiones_prima_neta,0.00) + nvl(danos_prima_neta,0.00) + nvl(asist_prima_neta,0.00) + nvl(comp_prima_neta,0.00) + nvl(col_prima_neta,0.00) + nvl(robo_prima_neta,0.00) ,
						   nvl(lesiones_prima_neta_o,0.00) + nvl(danos_prima_neta_o,0.00) + nvl(asist_prima_neta_o,0.00) + nvl(comp_prima_neta_o,0.00) + nvl(col_prima_neta_o,0.00) + nvl(robo_prima_neta_o,0.00) 
					into _suma_prima_neta, 
						_total_prima_neta												
				  from tmp_sim_auto
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad;	
					if _suma_prima_neta is null then
						let _suma_prima_neta = 0;
					end if
					if _total_prima_neta is null then
						let _total_prima_neta = 0;
					end if			
				end if}
				
				--update tmp_sim_auto
				--	set suma_prima_neta  = _suma_prima_neta,
				--		total_prima_neta = _total_prima_neta
				--where no_poliza = _no_poliza
				--   and no_unidad = _no_unidad;	
				   
				
			end foreach			
			 
			update emipomae
				set renovada  = 0
			 where no_poliza = _no_poliza;			 

			call sp_sis61b(_no_poliza_n) returning _error, _error_desc;				
		
		else
			update emipomae
				set renovada  = 0
			 where no_poliza = _no_poliza;

			     call sp_sis61b(_no_poliza_n) returning _error, _error_desc;	
			   return _error,	_error_isam, _error_desc with resume;
              continue foreach;
			  
		end if	
	
		let _incremento= 0;	
			
--		exit foreach;
	else
		continue foreach;
	end if
end foreach

update tmp_sim_auto
	set suma_prima_neta  = lesiones_prima_neta + danos_prima_neta + asist_prima_neta + comp_prima_neta + col_prima_neta + robo_prima_neta + end_prima,
		total_prima_neta = lesiones_prima_neta_o + danos_prima_neta_o + asist_prima_neta_o + comp_prima_neta_o + col_prima_neta_o + robo_prima_neta_o + end_prima_o,
		incremento_neto = (lesiones_prima_neta_o + danos_prima_neta_o + asist_prima_neta_o + comp_prima_neta_o + col_prima_neta_o + robo_prima_neta_o + end_prima_o) * incremento / 100 + (lesiones_prima_neta_o + danos_prima_neta_o + asist_prima_neta_o + comp_prima_neta_o + col_prima_neta_o + robo_prima_neta_o + end_prima_o);

end
end procedure;