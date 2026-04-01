--Creado: 05/05/2022 
--Autor: Román Gordón
--Simulación de Renovación para Pool Automático sin incremento
--execute procedure sp_sis245b('2024-09') 

drop procedure sp_sis245tr;

create procedure sp_sis245tr()
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
DEFINE _ld_prima_neta_t, _prima_resultado    DEC(16,2);
DEFINE _prima_neta_sin, _suma_asegurada      DEC(16,2);
DEFINE _calculo         DEC(5,2);
define _cnt_descu, _cnt_autorc,_actualizado  smallint;
define _cnt_prod_exc            integer;
define _saldo_elect, _saldo_porc, _tipo_forma smallint;
define _cod_formapag            char(3);

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

foreach
	select no_documento,
		   no_poliza,
		   actualizado
	  into _no_documento,
		   _no_poliza,
		   _actualizado
  from emipomae
 where vigencia_final = '31/07/2024'
   and renovada = 0
   and no_documento in ('0922-00109-01',
'0922-00118-01',
'0922-00127-01',
'0922-00128-01',
'0922-00131-01',
'0922-00134-01',
'0922-00144-01',
'0922-00158-01',
'0922-00159-01',
'0922-00160-01',
'0922-00181-01',
'0922-00194-01',
'0922-00195-01',
'0922-00208-01',
'0922-00209-01',
'0922-00218-01',
'0922-00219-01',
'0922-00221-01',
'0922-00224-01',
'0922-00236-01',
'0922-00237-01',
'0922-00238-01',
'0922-00242-01',
'0922-00244-01',
'0922-00249-01',
'0922-00251-01',
'0922-00252-01',
'0922-00253-01',
'0922-00254-01',
'0922-00267-01',
'0922-00272-01',
'0922-00277-01',
'0922-00306-01',
'0922-00307-01',
'0922-00308-01',
'0922-00309-01',
'0922-00310-01',
'0922-00318-01',
'0922-00319-01',
'0922-00323-01',
'0922-00326-01',
'0922-00331-01',
'0922-00334-01',
'0922-00341-01',
'0922-00343-01',
'0922-00344-01',
'0922-00345-01',
'0922-00346-01',
'0922-00347-01',
'0922-00348-01',
'0922-00350-01',
'0922-00352-01',
'0922-00378-01',
'0922-00390-01',
'0922-00430-01',
'0922-00449-01',
'0922-00476-01',
'0922-00478-01',
'0922-00490-01',
'0922-00498-01',
'0922-00512-01',
'0922-00525-01',
'0922-00532-01',
'0922-00533-01',
'0922-00534-01',
'0922-00540-01',
'0922-00543-01',
'0922-00544-01',
'0922-00571-01',
'0922-00574-01',
'0922-00577-01',
'0922-00584-01',
'0922-00587-01',
'0922-00588-01',
'0922-00594-01',
'0922-00600-01',
'0922-00617-01',
'0922-00621-01',
'0922-00651-01',
'0922-00653-01',
'0922-00656-01',
'0922-00661-01',
'0922-00662-01',
'0922-00663-01',
'0922-00674-01',
'0922-00686-01',
'0922-10009-01',
'0922-10010-01',
'0922-10012-01',
'0922-10013-01',
'0922-10030-01',
'0922-10031-01',
'0922-10046-01',
'0922-10051-01',
'0922-10060-01',
'0922-10066-01',
'0922-10083-01',
'0922-10099-01',
'0922-10108-01',
'0922-10109-01',
'0922-10110-01',
'0922-10114-01',
'0922-10119-01',
'0922-10120-01',
'0922-10130-01',
'0922-10131-01',
'0922-10136-01',
'0922-10139-01',
'0922-10145-01',
'0922-10152-01',
'0922-10156-01',
'0922-10177-01',
'0922-10179-01',
'0922-10191-01',
'0922-10196-01',
'0923-00079-01',
'0923-00206-01')
	
	
	let _no_poliza_n = sp_sis13('001', 'PRO', '02', 'par_no_poliza');
	call sp_pro320d('DEIVID',_no_poliza, _no_poliza_n) returning _error, _error_desc;
	
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
			
			update deivid_tmp:renov_recar
			   set procesado = 1,
				   actualizado = 1,
				   no_poliza_r = _no_poliza_n,
				   prima_resultado = _prima_resultado
			 where no_documento = _no_documento
			   and no_unidad = _no_unidad;
			
			return 0,0,_no_poliza,_no_poliza_n with resume;
		else
			return _error,1,'Error Al Actualizar Póliza' || trim(_no_documento) || '. '|| trim(_no_poliza_n),_error_desc with resume;
		end if
		
end foreach
end
end procedure;