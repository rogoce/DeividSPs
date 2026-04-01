--Creado: 05/05/2022 
--Autor: Román Gordón
--Simulación de Renovación para Pool Automático
--execute procedure sp_sis245b('2023-09') 

drop procedure sp_sis245b;

create procedure sp_sis245b(a_periodo char(7))
returning	integer			as err,
			integer			as error_isam,
			varchar(100)	as descrip,
			varchar(100)	as descripcion;

define _nom_cobertura 			varchar(100);       
define _nom_contratante			varchar(100);       
define _desc_error				varchar(100);       
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
define _return					integer;
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
define _vigencia_final			date;
define _fecha_aniversario		date;
define _vigencia_inic			date;
define _fecha_desde				date;
define _fecha_hasta				date;
define _fecha_selec				date;
define _fecha_hoy				date;

--set debug file to "sp_sis245.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc
	if _no_poliza is null then
		let _no_poliza = '';
	end if
	
	if _no_documento is null then
		let _no_documento = '';
	end if
	
	return	_error,
			_error_isam,
			_no_documento||' ' ||_no_poliza,
			'';
end exception

let _return = 0;
let _fecha_desde = mdy(a_periodo[6,7],1,a_periodo[6,7]);
let _fecha_hasta = sp_sis36(a_periodo);

foreach
/*select first 100 emi.no_poliza,
		    emi.no_documento,
			emi.cod_ramo,
			emi.vigencia_inic,
			emi.vigencia_final
	  into _no_poliza,
			_no_documento,
			_cod_ramo,
			_vigencia_inic,
			_vigencia_final
	  from emipomae emi
	 where emi.estatus_poliza in (1,3)
	   and emi.no_poliza in (select rep.no_poliza
							   from emirepo rep
							  inner join emipomae emi on emi.no_poliza = rep.no_poliza
							  inner join emipouni uni on uni.no_poliza = emi.no_poliza
							  inner join prdprod prd on prd.cod_producto = uni.cod_producto and prd.nombre like '%RC%'
							  where rep.vigencia_final between _fecha_desde and _fecha_hasta
							    and prd.cod_producto in ('00314','03999','00313','00340','07159') --('03321','03326','06731','00323','00324','00325')
								and emi.cod_no_renov is null
								and emi.cod_ramo = '002'
								and rep.estatus in (1,4)
							    and emi.estatus_poliza not in (4,2) and renovada = 0
							)
	order by emi.no_documento*/
	select act.no_poliza,act.no_documento,ant.no_poliza
	  into _no_poliza_n,_no_documento,_no_poliza
	  from emipomae act
	 inner join emipomae ant on ant.no_documento = act.no_documento and ant.vigencia_final = '31/07/2023' --and ant.vigencia_inic <> '31/07/2022'
	 where act.cod_ramo = '002'
	   and act.actualizado = 0
	   and act.vigencia_inic = '31/07/2023'
	   and act.user_added = 'DEIVID'
	 order by 2

	call sp_sis61b(_no_poliza_n) returning _error,_error_desc;
	
	if _error = 0 then
		
		let _no_poliza_n = sp_sis13('001', 'PRO', '02', 'par_no_poliza');
		call sp_pro320d_seraf('DEIVID',_no_poliza, _no_poliza_n) returning _error, _error_desc;
	
		if _error = 0 then
			call sp_sis17(_no_poliza_n) returning _return;

			if _return <> 0 Then
				if _return = 2 then
				   return 1,1,'Información', 'Numero de Factura Duplicado, Por Favor Actualice Nuevamente ...';
				elif _return = 3 then
					let _desc_error = 'Esta Póliza DEBE llevar Impuesto, Por Favor Verifique ...';
					return 1,1,'Información', _desc_error;
				elif _return = 4 then
					let _desc_error = 'La Sumatoria de porcentajes de Prima/Suma diferente de 100%, por favor verifique ...';
				elif _return = 5 then
					let _desc_error = 'El Numero de Recibo de Pago es Obligatorio, por favor verifique ...';
				elif _return = 7 then
					let _desc_error = 'El porcentaje de participacion de los agentes debe sumar 100.00';
				elif _return = 9 then
					let _desc_error = 'La Póliza no se puede emitir porque el Vehículo esta Bloqueado';
				elif _return = 10 then
					let _desc_error = 'El sistema ha detectado una restricción con este cliente. Por favor verique...';
				else		
					select descripcion
					  into _desc_error
					  from inserror
					 where tipo_error = 2
					   and code_error = _return;	   
				end if
				
				return 1,1,'Error Al Actualizar Póliza' || trim(_no_documento) || '. '|| trim(_no_poliza_n),_desc_error with resume;
				
				update emipomae
				   set renovada = 0
				 where no_poliza = _no_poliza;

				call sp_sis61b(_no_poliza_n) returning _error,_error_desc;
				
				continue foreach;
			end if
			return 0,0,_no_poliza,_no_poliza_n with resume;
		else
			return _error,1,'Error Al Actualizar Póliza' || trim(_no_documento) || '. '|| trim(_no_poliza_n),_error_desc with resume;
		end if
	else
		return 1,1,'Error Al Actualizar Póliza' || trim(_no_documento) || '. '|| trim(_no_poliza_n),_desc_error with resume;
	end if
end foreach
end
end procedure;