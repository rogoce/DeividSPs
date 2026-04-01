--Creado: 05/05/2022 
--Autor: Román Gordón
--Simulación de Renovación para Pool Automático
--execute procedure sp_sis245b('2024-09') 

drop procedure sp_sis248no_renov;

create procedure sp_sis248no_renov()
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
define _cnt_descu, _cnt_autorc  smallint;

--set debug file to "sp_sis245.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc
	--if _no_poliza is null then
	--	let _no_poliza = '';
	--end if
	
	if _no_documento is null then
		let _no_documento = '';
	end if
	
	return	_error,
			_error_isam,
			_no_documento,
			'';
end exception

let _return = 0;

foreach
	select distinct a.no_poliza,
		   a.no_documento,
		   a.user_added
	  into _no_poliza,
		   _no_documento,
		   _user_added
      from emirepol a, emipomae c
	 where a.no_poliza = c.no_poliza
 	   and a.estatus = 4
       and c.no_renovar = 1
       and a.vigencia_final <= '31-08-2024'
       and c.cod_ramo in ('002','020','023')
	   
	let _return = sp_sis61d(_no_poliza);  --Borra tmporales
					 
	DELETE FROM emirepol WHERE no_documento = _no_documento;
					 			
	return 0,0,'',_no_poliza with resume;
		
end foreach

foreach
	select distinct a.no_poliza,
		   a.no_documento,
		   a.user_added
	  into _no_poliza,
		   _no_documento,
		   _user_added
      from emirepo a, emipomae c
	 where a.no_poliza = c.no_poliza
 	   and a.estatus in (1, 4)
       and c.no_renovar = 1
       and a.vigencia_final <= '31-08-2024'
       and c.cod_ramo in ('002','020','023')
	   
	let _return = sp_sis61d(_no_poliza);  --Borra tmporales
					 
	DELETE FROM emirepo WHERE no_poliza = _no_poliza;
			
	delete from emideren
	where no_poliza = _no_poliza;
					 			
	return 0,0,'',_no_poliza with resume;
		
end foreach

end
end procedure;