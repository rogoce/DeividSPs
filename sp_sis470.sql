--Creado: 05/05/2022 
--Autor: Román Gordón
--Simulación de Renovación para Pool Automático
--execute procedure sp_sis245a2('2022-06') 

drop procedure sp_sis470;
create procedure sp_sis470(a_periodo char(7), a_tipo_ren smallint)
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
define  _cod_grupo              char(5);
define  _cnt_oficina			SMALLINT; 
define	_cnt_cob_completa   	SMALLINT;   


define  _saldo_pend_120			DEC(16,2);

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
--set debug file to "sp_sis470.trc";
--trace on;
let _error = 0;
let _error_isam = 0;
let _nom_cobertura = '';
let _no_poliza = '';
let _no_documento = '';
let _incremento = 0;
let _descuento = 0;

set isolation to dirty read;

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
no_poliza					char(10),
incremento                  dec(16,2),
diezporc                    dec(16,2),
saldo                       dec(16,2),
descuento                   dec(16,2),
primary key(no_poliza)) with no log;

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

if a_tipo_ren = 1 then -- Particulares
	foreach
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
			  inner join emipomae emi on emi.no_poliza = aut.no_poliza--emi.no_poliza = aut.no_poliza
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
			  inner join emipomae emi on emi.no_poliza = aut.no_poliza--emi.no_poliza = aut.no_poliza
			 where aut.vigencia_final between _fecha_desde and _fecha_hasta
			   and emi.cod_ramo = '002'
			   and emi.cod_subramo = '001'
			   and aut.estatus in (1,4)
			   and emi.no_renovar = 0 and emi.renovada = 0
					   and aut.no_poliza not in (
						select emi.no_poliza
				  from emirepo aut
			  inner join emipomae emi on emi.no_poliza = aut.no_poliza--emi.no_poliza = aut.no_poliza
			 where aut.vigencia_final between _fecha_desde and _fecha_hasta
			   and emi.cod_ramo = '002'
			   and emi.cod_subramo = '001'
			 --  and aut.estatus in (1,4)
			   and emi.no_renovar = 0 and emi.renovada = 0
			   )

		--Excluir del proceso en ambos simuladores los siguientes productos:
		-- 02282	PETROAUTOS / SCOTIA BANK (SEDANES)	
		-- 02283	PETROAUTOS / SCOTIA BANK (CAMIONETA Y PICK UP)	
		-- 03335	MOTOS PARTICULAR	
		-- 03336	MOTOS PARTICULAR RC	
		-- 03810	AUTO COMPLETA - BANISI	
		-- 03811	PETROAUTOS / BANISI (SEDANES)	
		-- 03812	PETROAUTOS / BANISI (CAMIONETA Y PICK UP)	
		-- 04563	AUTO COMPLETA (UNPAC) EXTRA-PLUS	
		-- 05662	RC REMOLQUE PARTICULAR	
		-- 06659	AUTO COMPLETA / TRASPASO GENERALLI ASSA BANISI	
		-- 07213	AUTO COMP - PETROAUTOS / SCOTIA BANK	
		-- 07214	AUTO COMP - PETROAUTOS / BANISI	
		-- 07215	AUTO COMPLETA - BANISI / UNITY	
		-- 07754	AUTO COMPLETA - CORP. DE CREDITO	
		-- 07755	AUTO COMPLETA - BANISI / UNITY	
		-- 08267	AUTORC - SICACHI / CANATRACA B/.90.00	
		-- 08268	AUTORC - SICACHI / CANATRACA B/.112.00	
		-- 08278	AUTO COMPLETA - GENERAL REPRESENTATIVE	
		-- 08305	AUTORC - SICACHI / CANATRACA B/.134.00	
		-- 08306	AUTORC - SICACHI / CANATRACA B/.169.00	
		-- 08307	AUTORC - SICACHI / CANATRACA B/.236.00	
		
		--Se volvió a incluir el plan usadito por tecnico Meivis -- Amado 21-05-2025
		--00318 USADITO 
		
		let _cnt_prod_exc = 0;
		
		select count(*)
		  into _cnt_prod_exc
		  from emipouni
		 where no_poliza = _no_poliza
		   and cod_producto in ('04563','07755','03812','03811','02283','08268','08307','08305','08306','03810','07754','07213','02282','08267','08278','07215','06659','03335','03336','05662','07214');
		 
		if _cnt_prod_exc is null then
			let _cnt_prod_exc = 0;
		end if	
		
		if _cnt_prod_exc > 0 then		 
			continue foreach;
		end if

	-- SD #15456 Ajuste Programa de Renovaciones Automóvil -- Amado 20-11-2025
	-- Excluir  (NoGenerarPreliminar) y mostrar con mensaje de error: POLIZA CARTERA DIRECTA. Las pólizas suscritas con código de corredor del tipo O (OFICINA), 
	-- excepto los códigos. Estas pólizas si deben generarse preliminar de renovación. 
    --        00085 CUENTAS ESPECIALES
    --        02532 CORREDOR DIRECTO (FELIX ABADIA)

		if _cod_formapag not in ('003','005') then 
			let _cnt_prod_exc = 0;
			
			select count(*)
			  into _cnt_prod_exc
			  from emipoagt
			 where no_poliza = _no_poliza
			   and cod_agente in ('00085','02532');
			 
			if _cnt_prod_exc is null then
				let _cnt_prod_exc = 0;
			end if	
			
			if _cnt_prod_exc = 0 then		 	
				let _cnt_oficina = 0;
				
				select count(*)
				  into _cnt_oficina
				  from emipoagt a, agtagent b
				 where a.cod_agente = b.cod_agente
				   and no_poliza = _no_poliza
				   and b.tipo_agente <> 'O';
				 
				if _cnt_oficina is null then
					let _cnt_oficina = 0;
				end if	
				
				if _cnt_oficina = 0 then		 
					let _cnt_cob_completa = 0; --Verificar si es cobertura completa -- correo de Jacky 12-12-2025 -- Amado 
					select count(*)
					  into _cnt_cob_completa
					  from emipouni a, prdcobpd b
					 where a.cod_producto = b.cod_producto
					   and a.no_poliza = _no_poliza
					   and b.cod_cobertura in ('00121','00119')
					   and b.cob_default = 1;

					if _cnt_cob_completa is null then
						let _cnt_cob_completa = 0;
					end if	
					
					if _cnt_cob_completa = 0 then
						continue foreach;
					end if
				end if
			end if
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
		
		let _saldo_porc = 10;

		let _diezporc = 0;
		let _diezporc = _prima_bruta * (_saldo_porc/100);
	  
		-- a_tipo_ren = 3 Banisi: Van todas aunque tenga saldo -- Boni 16-09-2024
		
		--Solo pólizas con saldo <= al 10% de la prima
		if _saldo > _diezporc then		
			continue foreach;
		end if
				
		select emi.cod_ramo,
			   emi.cod_subramo,
			   emi.cod_no_renov,
			   emi.estatus_poliza,
			   emi.cod_grupo,
			   ram.nombre,
			   cli.nombre,
			   cli.fecha_aniversario,
			   cli.tipo_persona
		  into _cod_ramo,
			   _cod_subramo,
			   _cod_no_renov,
			   _estatus_poliza,
			   _cod_grupo,
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

		if _cod_no_renov in ('039') or _estatus_poliza in (2,4) then --Vigentes, excluir Motivo No Renovación = 039 Cese de Coberturas 
			continue foreach;
		end if
		
		-- Grupos a excluir
		-- 01122	- GRUPO DUCRUET BANISI 
		-- 77982 	- CORPORACION DE CREDITO - PRIMA NIVELADA 
		-- 1090 	- COLECTIVO SCOTIABANK -PETROAUTO 
		-- 124 		- LIZSENELL BERNAL - BANISI 
		-- 125 		- FELIX ABADIA - BANISI 
		-- 1050 	- FELIX A. ABADIA- PETROAUTOS 
		-- 00068    - SERAFIN NIÑO
		-- 77978 	- REFERIDOS - SERAFIN NIÑO
		-- 00112 	- GRUPO CANATRA
		-- 77974 	- CANATRACA
		-- 77980 	- ASOCIADOS CANATRACA
		-- 77973 	- SICACHI
		-- 77979 	- ASOCIADOS SICACHI
		
		if _cod_grupo in ('01122','77982','1090','124','125','1050','00068','77978','00112','77974','77980','77973','77979','78020') then
			continue foreach;
		end if		

{		--	Excluir del proceso de renovación a los corredores:
		--  JUSTINIANO BALLESTEROS
			let _cnt_prod_exc = 0;
			
			select count(*)
			  into _cnt_prod_exc
			  from emipoagt
			 where no_poliza = _no_poliza
			   and (cod_agente in (select cod_agente from agtagent where nombre like 'JUSTINIANO%BALLESTER%'));
			 
			if _cnt_prod_exc is null then
				let _cnt_prod_exc = 0;
			end if	
			
			if _cnt_prod_exc > 0 then		 
				continue foreach;
			end if
}
		if _cod_ramo = '002' and _vigencia_final between _fecha_desde and _fecha_hasta then
						
			call sp_pro82m2(_no_documento) returning _cant_recl,_inc_total,_saldo_rec,_cant_mov, _no_sinis_ult, _no_sinis_pro, _siniestralidad, _desc_desc;
			
			let _incremento = 0;
			let _descuento = 0;
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
					let _descuento = 5;
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
						let _incremento = 25;
					else
					   let _incremento = 0;
					end if
				end if
			end if	

			if _cant_recl >= 1 and _cant_recl <= 2 and _incremento = 0 then
				if _siniestralidad >= 50 and _siniestralidad <= 55 then
					let _incremento = 10;
				else
					if _siniestralidad > 55 then
						let _incremento = 15;
					else
					   let _incremento = 0;
					end if
				end if
			end if			

			if _cant_recl >= 1 and _incremento = 0 then
				if  _siniestralidad <= 50 then
					let _incremento = 3;
				else
				   let _incremento = 0;
				end if
			end if	
			--------------------------------------------------
					
			BEGIN
			ON EXCEPTION IN(-239,-268)
			END EXCEPTION	
			
			insert into tmp_sim_auto(
			no_poliza,
			incremento,
			diezporc,
			saldo,
			descuento
			)
			values (
				_no_poliza,
				_incremento,
				_diezporc,
				_saldo,
				_descuento
				);
			END				
		else
			continue foreach;
		end if
	end foreach
elif a_tipo_ren = 2 then -- Subramo comercial y transporte publico
--trace on;
	foreach
		select emi.no_poliza,
					aut.no_documento,
					aut.vigencia_inic,
					aut.vigencia_final,
					emi.saldo,
					aut.incurrido,
					emi.prima_bruta,
					emi.cod_subramo,
					emi.cod_formapag,
			        emi.cod_grupo
			  into _no_poliza,
					_no_documento,
					_vigencia_inic,
					_vigencia_final,
					_saldo,
					_incurrido,
					_prima_bruta,
					_subramo,
					_cod_formapag,
					_cod_grupo
			  from emirepo aut
			  inner join emipomae emi on emi.no_poliza = aut.no_poliza--emi.no_poliza = aut.no_poliza
			 where aut.vigencia_final between _fecha_desde and _fecha_hasta  --'01/10/2023' and '31/10/2023'
			   and emi.cod_ramo = '002'
			   and emi.cod_subramo in ('002','005') --Se incluye sub ramo TRANSPORTE PUBLICO 005 a petición de tecnico de auto Bonizuth 07-01-2025
			   and aut.estatus in (1,4)
			   and emi.no_renovar = 0 and emi.renovada = 0 --and emi.no_documento = '0224-01101-03'
--               and emi.cod_grupo = '77851'			   
--			   and aut.no_documento = '0225-00576-10'			   
		  union 
		  select emi.no_poliza,
					aut.no_documento,
					aut.vigencia_inic,
					aut.vigencia_final,
					emi.saldo,
					aut.incurrido,
					emi.prima_bruta,
					emi.cod_subramo,
					emi.cod_formapag,
			        emi.cod_grupo
				  from emirepol aut
			  inner join emipomae emi on emi.no_poliza = aut.no_poliza--emi.no_poliza = aut.no_poliza
			 where aut.vigencia_final between _fecha_desde and _fecha_hasta
			   and emi.cod_ramo = '002'
			   and emi.cod_subramo in ('002','005')
			   and aut.estatus in (1,4)
			   and emi.no_renovar = 0 and emi.renovada = 0 --and emi.no_documento = '0224-01101-03'
--               and emi.cod_grupo = '77851'			   
--			   and aut.no_documento = '0225-00576-10'			   
					   and aut.no_poliza not in (
						select emi.no_poliza
				  from emirepo aut
			  inner join emipomae emi on emi.no_poliza = aut.no_poliza--emi.no_poliza = aut.no_poliza
			 where aut.vigencia_final between _fecha_desde and _fecha_hasta
			   and emi.cod_ramo = '002'
			   and emi.cod_subramo in ('002','005')
			   and aut.estatus in (1,4)
			   and emi.no_renovar = 0 and emi.renovada = 0
--               and emi.cod_grupo = '77851'			   
			   )
			   
			   
			
	--	Excluir del proceso los productos cob. Completa -- Ya no se excluirán Jean -- Amado 11-06-2025
	--Productos: '07708','07702','07703','03330','03321','03323','03326','08263',
	--07708 WEB PESADO COB. COMPLETA  6 TONELADAS
	--07702 WEB LIVIANO COB. COMPLETA HASTA  2 TONELADAS
	--07703 WEB MEDIANO COB. COMPLETA  4 TONELADAS
	--03330 COB. COMPLETA + DE 6 TON (VOLQUETES Y MULAS)
	--03321 LIVIANO COMERCIAL 2 TON COB COMPLETA (ACTIVO)
	--03323 MEDIANO COMERCIAL 4 TON COB COMPLETA (ACTIVO)
	--03326 PESADO COMERCIAL 6 TON COB COMPLETA (ACTIVO)
	--08263 CORP. DE CREDITO COMERCIAL LIVIANO HASTA  2 TON.
	
	--Excluir nuevos productos -- DRN # 13869-- Amado 30-05-2025
	--09756 - FULL EXPERTA RC VOLQUETES Y MULAS 
	--09757 - FULL EXPERTA RC MULAS NAVIERA 
	--09719 - AVOMPASI RC VOLQUETES Y MULA 
	--09720 - AVOMPASI RC MULAS NAVIERA 
	--11016 - FULL EXPERTA RC CAMION PESADO 


		let _cnt_prod_exc = 0;
		
		--if _subramo <> '005' then
			select count(*)
			  into _cnt_prod_exc
			  from emipouni
			 where no_poliza = _no_poliza
			   and cod_producto in ('09756','09757','09719','09720','11016');
		--end if
			 
		if _cnt_prod_exc is null then
			let _cnt_prod_exc = 0;
		end if	
		
		if _cnt_prod_exc > 0 then		 
			continue foreach;
		end if
		
	-- SD #15456 Ajuste Programa de Renovaciones Automóvil
	-- CONDICIONES DE PRODUCTOS A RENOVAR PARA CARTERA COMERCIAL Y TRANSPORTE PUBLICO. 
	
	--No incluir productos que contengan las siguientes coberturas
	--00121- COLISION O VUELCO
	--00119- COLISION O VUELCO

	--Excepto productos:  
	--03138 - TARIFAS BASICAS PARA TAXIS (NUEVO 2016)
	--10461 - TARIFAS BASICAS PARA TAXIS (NUEVO 2024)
	--10288 - TARIFAS TAXIS VITRUVIO (2024)
	
	--Simulador solo debe incluir Productos RC para los subramos detallados.	
	
	{	let _cnt_prod_exc = 0;

		select count(*)
		  into _cnt_prod_exc
		  from emipouni a, prdprod b
		 where a.cod_producto = b.cod_producto
		   and a.no_poliza = _no_poliza
		   and (b.nombre like '%RC%' 
		    or b.cod_producto in ('03138','10461','10288'));
		
		if _cnt_prod_exc is null then
			let _cnt_prod_exc = 0;
		end if	
		
		if _cnt_prod_exc = 0 then}
		if _cod_grupo <> '77851' then
			let _cnt_oficina = 0;
			select count(*)
			  into _cnt_oficina
			  from emipouni a, prdcobpd b
			 where a.cod_producto = b.cod_producto
			   and a.no_poliza = _no_poliza
			   and b.cod_cobertura in ('00121','00119')
			   and b.cob_default = 1;

			if _cnt_oficina is null then
				let _cnt_oficina = 0;
			end if	
			
			if _cnt_oficina > 0 then
				continue foreach;
			end if
		end if
	--	end if
		
	-- SD #15456 Ajuste Programa de Renovaciones Automóvil -- Amado 20-11-2025
	-- Excluir  (NoGenerarPreliminar) y mostrar con mensaje de error: POLIZA CARTERA DIRECTA. Las pólizas suscritas con código de corredor del tipo O (OFICINA), 
	-- excepto los códigos. Estas pólizas si deben generarse preliminar de renovación. 
    --        00085 CUENTAS ESPECIALES
    --        02532 CORREDOR DIRECTO (FELIX ABADIA)

		if _cod_formapag not in ('003','005') then 
			let _cnt_prod_exc = 0;
			
			select count(*)
			  into _cnt_prod_exc
			  from emipoagt
			 where no_poliza = _no_poliza
			   and cod_agente in ('00085','02532');
			 
			if _cnt_prod_exc is null then
				let _cnt_prod_exc = 0;
			end if	
			
			if _cnt_prod_exc = 0 then		 	
				let _cnt_oficina = 0;
				
				select count(*)
				  into _cnt_oficina
				  from emipoagt a, agtagent b
				 where a.cod_agente = b.cod_agente
				   and no_poliza = _no_poliza
				   and b.tipo_agente <> 'O';
				 
				if _cnt_oficina is null then
					let _cnt_oficina = 0;
				end if	
				
				if _cnt_oficina = 0 then		 
					continue foreach;
				end if
			end if
		end if
		
	--	Excluir del proceso de renovación a los corredores:
	--WTW
	--TOTAL SEGUROS S.A.
	--PLATINUM INSURANCE CORPORATION
	--PLATINUM INSURANCE CORPORATION (CHIRIQUI)

		let _cnt_prod_exc = 0;
		
		select count(*)
		  into _cnt_prod_exc
		  from emipoagt
		 where no_poliza = _no_poliza
		   and (cod_agente in (select cod_agente from agtagent where nombre like '%WTW%')
			or  cod_agente in (select cod_agente from agtagent where nombre like 'TOTAL%SEGUROS%')
			or  cod_agente in (select cod_agente from agtagent where nombre like 'PLATINUM%INSURANCE%'));
		 
		if _cnt_prod_exc is null then
			let _cnt_prod_exc = 0;
		end if	
		
		if _cnt_prod_exc > 0 then		 
			continue foreach;
		end if

	--Productos RC -- ya no excluir los que no tengan estos productos Jean -- Amado 27-06-2025
	--07756 DICSA RC LIVIANO  2 TONELADAS (ACTIVO)
	--07757 DICSA RC MEDIANO 4 TONELADAS (ACTIVO)
	--03334 RC LIVIANO COMERCIAL 2 TONELADAS (ACTIVO)
	--03333 MEDIANO COMERCIAL 4 TONELADAS RC (ACTIVO)
	--03328 RC PESADOS COMERCIAL 6 TONELADAS (ACTIVO)
	--03332 RC PESADOS COMERCIAL + DE 6 TON (VOLQUETES Y MULA)
	--07132 RC WEB LIVIANO  2 TONELADAS (ACTIVO)
	--07133 RC WEB MEDIANO 4 TONELADAS (ACTIVO)
	--07134 RC WEB PESADO 6 TONELADAS (ACTIVO)
	--07135 RC WEB +6 TONELADAS  (VOLQUETES Y MULA) ACTIVO
	--09621 RC WEB PESADO 6 TON. - SIN ASIENTO
	--09620 RC WEB MEDIANO 4 TON. - SIN ASIENTO
	--09619 RC WEB LIVIANO 2 TON.- SIN ASIENTO

{		let _cnt_prod_exc = 0;
		
		if _subramo <> '005' then
			select count(*)
			  into _cnt_prod_exc
			  from emipouni
			 where no_poliza = _no_poliza
			   and cod_producto not in ('07756','07757','03334','03333','03328','03332','07132','07133','07134','07135','09621','09620','09619');
		end if 
		
		if _cnt_prod_exc is null then
			let _cnt_prod_exc = 0;
		end if	
		
		if _cnt_prod_exc > 0 then		 
			continue foreach;
		end if
}		
		let _cnt_prod_exc = 0;
		
	{	if _subramo = '005' then 	
			select count(*)
			  into _cnt_prod_exc
			  from emipomae
			 where no_poliza = _no_poliza
			   and cod_contratante in (select cod_cliente from cliclien where nombre like '%VITRUVIO%');
		end if		
		 
		if _cnt_prod_exc is null then
			let _cnt_prod_exc = 0;
		end if	
		
		if _cnt_prod_exc > 0 then		 
			continue foreach;
		end if
		}
		-- Grupos a excluir -- DRN # 13869-- Amado 30-05-2025
		--01122 - GRUPO DUCRUET BANISI  
		--77982 - CORPORACION DE CREDITO - PRIMA NIVELADA 
		--00068 - SERAFIN NIÑO 
		--77978 - REFERIDOS - SERAFIN NIÑO 
		--00112 - GRUPO CANATRA 
		--77974 - CANATRACA 
		--77980 - ASOCIADOS CANATRACA 
		--77973 - SICACHI 
		--77979 - ASOCIADOS SICACHI 
		--77851 – VITRUVIO MOVILITY se incluirá VITRUVIO según correo del día 05-07-2025 como si fuera prima nivelada
		--77987 – FULL EXERTA 
		--77967 – AVOMPASI  
		
		if _cod_grupo in ('01122','77982','00068','77978','00112','77974','77980','77973','77979','77987','77967') then --,'77851'
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
		
		let _saldo_porc = 10;

		let _diezporc = 0;
		let _diezporc = _prima_bruta * (_saldo_porc/100);	

		--Solo pólizas con saldo <= al 10% de la prima
		if _saldo > _diezporc then		
			continue foreach;
		end if		
		
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

		if _cod_ramo in ('002') and _vigencia_final between _fecha_desde and _fecha_hasta then

			let _incremento = 0;
			let _descuento = 0;
						
			--------------------------------------------------
					
			BEGIN
			ON EXCEPTION IN(-239,-268)
			END EXCEPTION	
			
			insert into tmp_sim_auto(
			no_poliza,
			incremento,
			diezporc,
			saldo,
			descuento
			)
			values (
				_no_poliza,
				_incremento,
				_diezporc,
				_saldo,			
				_descuento
				);
			END				
		else
			continue foreach;
		end if
	end foreach
elif a_tipo_ren = 3 then
	foreach
	select emi.no_poliza,
				aut.no_documento,
				aut.vigencia_inic,
				aut.vigencia_final,
				emi.saldo,
				aut.incurrido,
				emi.prima_bruta,
				emi.cod_subramo,
				emi.cod_formapag,
			    emi.cod_grupo
		  into _no_poliza,
				_no_documento,
				_vigencia_inic,
				_vigencia_final,
				_saldo,
				_incurrido,
				_prima_bruta,
				_subramo,
				_cod_formapag,
				_cod_grupo
		  from emirepo aut
		  inner join emipomae emi on emi.no_poliza = aut.no_poliza--emi.no_poliza = aut.no_poliza
		 where aut.vigencia_final between _fecha_desde and _fecha_hasta  --'01/10/2023' and '31/10/2023'
		   and emi.cod_ramo = '002'
		   and emi.cod_subramo = '001'
		   and aut.estatus in (1,2,4) -- Se incluye también con saldos o que están en técnico
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
				emi.cod_formapag,			        
				emi.cod_grupo
			  from emirepol aut
		  inner join emipomae emi on emi.no_poliza = aut.no_poliza--emi.no_poliza = aut.no_poliza
		 where aut.vigencia_final between _fecha_desde and _fecha_hasta
		   and emi.cod_ramo = '002'
		   and emi.cod_subramo = '001'
		   and aut.estatus in (1,2,4) -- Se incluye también con saldos o que están en técnico
 		   and emi.no_renovar = 0 and emi.renovada = 0
                   and aut.no_poliza not in (
                   	select emi.no_poliza
			  from emirepo aut
		  inner join emipomae emi on emi.no_poliza = aut.no_poliza--emi.no_poliza = aut.no_poliza
		 where aut.vigencia_final between _fecha_desde and _fecha_hasta
		   and emi.cod_ramo = '002'
		   and emi.cod_subramo = '001'
		 --  and aut.estatus in (1,4)
 		   and emi.no_renovar = 0 and emi.renovada = 0)
		
		let _cnt_prod_exc = 0;
		
	{02282 PETROAUTOS / SCOTIA BANK (SEDANES) no va
	02283 PETROAUTOS / SCOTIA BANK (CAMIONETA Y PICK UP) no va
	03810 AUTO COMPLETA – BANISI
	03811 PETROAUTOS / BANISI (SEDANES) no va
	03812 PETROAUTOS / BANISI (CAMIONETA Y PICK UP) no va
	07215 AUTO COMPLETA - BANISI / UNITY
	07755 AUTO COMPLETA - BANISI / UNITY
	07754 AUTO COMPLETA - CORP. DE CREDITO
	08278 AUTO COMPLETA - GENERAL REPRESENTATIVE
	06659 AUTO COMPLETA / TRASPASO GENERALLI ASSA BANISI
	}	
	
	--Productos a incluir -- DRN # 13869-- Amado 30-05-2025
	--02282 - PETROAUTOS / SCOTIA BANK (SEDANES) 
	--02283 - PETROAUTOS / SCOTIA BANK (CAMIONETA Y PICK UP) 
	--03810 - AUTO COMPLETA - BANISI 
	--03811 - PETROAUTOS / BANISI (SEDANES) 
	--03812 - PETROAUTOS / BANISI (CAMIONETA Y PICK UP) 
	--07215 - AUTO COMPLETA - BANISI / UNITY 
	--07755 - AUTO COMPLETA - BANISI / UNITY 
	--07754 - AUTO COMPLETA - CORP. DE CREDITO 
	--08278 - AUTO COMPLETA - GENERAL REPRESENTATIVE 
	--06659 - AUTO COMPLETA / TRASPASO GENERALLI ASSA BANISI 
	--07213 - AUTO COMP - PETROAUTOS / SCOTIA BANK 
	--07214 - AUTO COMP - PETROAUTOS / BANISI 
	--10692 - AUTO COMPLETA - BANISI / UNITY -- DRN # 15317-- Amado 29-10-2025 
	
		select count(*)
		  into _cnt_prod_exc
		  from emipouni
		 where no_poliza = _no_poliza
		   and cod_producto in ('07755','03810','07754','07215','08278','06659','02282','02283','03812','03811','07213','07214','10692'); --,'02282','02283','03812','03811'
		 
		if _cnt_prod_exc is null then
			let _cnt_prod_exc = 0;
		end if	
		
		if _cnt_prod_exc = 0 then		 
			continue foreach;
		end if
		
	-- Solamente estos grupos -- DRN # 13869-- Amado 30-05-2025
	--1122 - GRUPO DUCRUET BANISI 
	--77982 - CORPORACION DE CREDITO - PRIMA NIVELADA 
	--1090 - COLECTIVO SCOTIABANK -PETROAUTO 
	--124 - LIZSENELL BERNAL - BANISI 
	--125 - FELIX ABADIA - BANISI 
	--1050 - FELIX A. ABADIA- PETROAUTOS 
	--77850 - TRASPASO ASSA GENERALI BANISI -- Se agrega Roman 23-10-2025
	--77995 - PRESTAMOS CANCELADO (BANISI)
	--78032 - FORTIS SEGUROS, S.A. - BANISI
	--78033 - TRASPASO ASSA GENERALI BANISI - FORTIS
	--78034 - PRESTAMOS CANCELADO (BANISI) - FORTIS

		if _cod_grupo not in ('1122','77982','1090','124','125','1050','78020','77850','77995','78032','78033','78034') then
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
		
		let _saldo_porc = 10;

		let _diezporc = 0;
		let _diezporc = _prima_bruta * (_saldo_porc/100);
		
		-- a_tipo_ren = 3 Banisi: Van todas aunque tenga saldo -- Boni 16-09-2024
		-- Se volvió a incluir DRN # 13869 Amado 31-05-2025
		
		--Solo pólizas con saldo <= al 10% de la prima -- Van todas Meivis 03-06-2025 -- Amado
		--if _saldo > _diezporc then		
		--	continue foreach;
		--end if
		
		-- DRN # 13869 Amado 31-05-2025 Si grupo = 01122 - Saldo Pendiente en Morosidad <= 90 días.  
		let _saldo_pend_120 = 0.00;
		
	--	if _cod_grupo = '01122' then son todos Meivis 03-06-2025 -- Amado
			select monto_90 + monto_120 + monto_150 + monto_180
			  into _saldo_pend_120
			  from emipoliza
			 where no_documento = _no_documento;
			 
			if _saldo_pend_120 > 0 then  --and _no_documento <> '0219-00492-90' 
				continue foreach;
			end if
	--	end if
				
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

		if _cod_no_renov in ('039') or _estatus_poliza in (2,4) then --Vigentes, excluir Motivo No Renovación = 039 Cese de Coberturas 
			continue foreach;
		end if
		 
		if _cod_ramo = '002' and _vigencia_final between _fecha_desde and _fecha_hasta then
			
			let _incremento = 0;
			-------------------------------------------------
			BEGIN
			ON EXCEPTION IN(-239,-268)
			END EXCEPTION	
			
			insert into tmp_sim_auto(
			no_poliza,
			incremento,
			diezporc,
			saldo,
			descuento
			)
			values (
				_no_poliza,
				_incremento,
				_diezporc,
				_saldo,			
			    _descuento
				);
			END				
		else
			continue foreach;
		end if
	end foreach
	
end if

end
return 0,0,null;
end procedure;