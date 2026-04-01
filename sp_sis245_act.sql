--Creado: 05/05/2022 
--Autor: Román Gordón
--Simulación de Renovación para Pool Automático
--execute procedure sp_sis245b('2024-09') 

drop procedure sp_sis245d;

create procedure sp_sis245d()
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
define _cnt_descu               smallint;

---set debug file to "sp_sis245.trc";
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
	select a.no_poliza,
	       b.no_documento,
	       b.no_unidad
	  into _no_poliza,
	       _no_documento,
	       _no_unidad
	  from emirepo a,  deivid_tmp:renov_recar b
	 where a.no_documento = b.no_documento
	   and b.procesado = 0
	   and a.estatus = 1
	   and b.prima_neta <> 0
	   --and b.recargo > 8 
	   and b.no_documento in ('0219-01124-01',
'0219-02770-09',
'0218-00875-01',
'0217-00707-09',
'0222-02084-09',
'0221-01445-09',
'0219-01325-01',
'0219-02388-09',
'0215-01104-01',
'0216-01110-01',
'0222-01824-09',
'0220-01068-09',
'0223-03971-09',
'0223-04189-09',
'0223-04246-09',
'0223-01696-01',
'0221-01060-01',
'0218-00160-02',
'0219-00116-02',
'0210-00124-02',
'0210-00366-03',
'0223-00929-03',
'0223-00939-03',
'0212-00226-03',
'0216-01028-03',
'0216-01044-03',
'0216-00648-03',
'0217-00858-03',
'0219-00643-03',
'0219-00590-03',
'0216-00930-03',
'0217-00821-03',
'0220-00378-03',
'0205-00183-04',
'0207-01098-04',
'0209-00455-04',
'0216-00505-05',
'0216-00565-05',
'0219-00440-05',
'0222-00382-05',
'0223-00482-05',
'0212-00300-06',
'0216-00446-06',
'0217-00307-06',
'0222-00077-06',
'0219-00362-06',
'0222-00086-06',
'0217-00308-06',
'0215-00392-06',
'0219-00364-06',
'0221-00277-07',
'0217-00261-07',
'0221-00267-07',
'0216-00251-07',
'0221-00243-07',
'0222-00261-07',
'0223-00233-07',
'0223-00254-07',
'0212-00051-10',
'0219-00448-10',
'0219-00463-10',
'0219-00464-10',
'0219-00458-10',
'0217-00349-10',
'0216-00260-10',
'0221-00230-10',
'0223-00426-10',
'0223-00676-10',
'0223-00260-11',
'0217-00425-11',
'0217-00430-11',
'0218-00499-11',
'0218-00525-11',
'0219-00418-11',
'0219-00429-11',
'0218-00482-11',
'0218-01594-09',
'0219-14105-47',
'0221-15733-47',
'0219-13985-47',
'0220-01087-09',
'0210-00266-09',
'0213-00577-09',
'0213-00661-09',
'0213-01612-01',
'0215-01091-01',
'0217-00701-09',
'0217-01038-01',
'0219-02465-09',
'0210-01082-01',
'0210-01082-01',
'0217-00165-12',
'0216-01225-01',
'0216-01237-01',
'0215-01184-01',
'0215-00147-12',
'0214-00847-09',
'0214-00778-09',
'0218-01371-09',
'0222-01022-01',
'0222-01976-09',
'0219-02742-09',
'0218-01367-09',
'0218-01339-09',
'0219-02372-09',
'0222-01057-01',
'0218-00913-01')
	--   AND b.no_poliza_r = 'ERROR'
	
	let _no_poliza_n = sp_sis13('001', 'PRO', '02', 'par_no_poliza');
	call sp_pro320e('DEIVID',_no_poliza, _no_poliza_n, _no_unidad) returning _error, _error_desc;
	
	call sp_proe01bk(_no_poliza_n, _no_unidad, '001') returning _error;	
	
	select suma_asegurada
	  into _suma_asegurada
	  from emipouni
	 where no_poliza = _no_poliza_n
	   and no_unidad = _no_unidad;
	   
	let _ld_prima_neta_t = 0;  	   
	
	select sum(e.prima_neta)
	  into _ld_prima_neta_t
	  from emipocob e, prdcober c
	 where e.no_poliza = _no_poliza_n
	   and e.no_unidad = _no_unidad
	   and c.cod_cobertura = e.cod_cobertura
	   and e.descuento <> 0;
	   
    if _ld_prima_neta_t is null then
		let _ld_prima_neta_t = 0;
	end if	
	   
	let _prima_neta_sin = 0;  

	select sum(e.prima_neta)
	  into _prima_neta_sin
	  from emipocob e, prdcober c
	 where e.no_poliza = _no_poliza_n
	   and e.no_unidad = _no_unidad
	   and c.cod_cobertura = e.cod_cobertura
	   and e.descuento = 0;
	
    if _prima_neta_sin is null then
		let _prima_neta_sin = 0;
	end if	
	
	if _ld_prima_neta_t = 0 and _prima_neta_sin <> 0 then
		let _ld_prima_neta_t = _prima_neta_sin;
	    let _prima_neta_sin = 0;
	end if	
	   
	select prima_neta
      into _prima_neta
      from deivid_tmp:renov_recar
     where no_documento = _no_documento
       and no_unidad = _no_unidad;	 
	   
	LET _prima_neta = _prima_neta - _prima_neta_sin;   
	
    LET _calculo = ((_prima_neta - _ld_prima_neta_t) / _ld_prima_neta_t ) * 100;
		
	let _cnt_descu = 0; 
	 
	select count(*) 
	  into _cnt_descu
	  from emiunide
	 where no_poliza = _no_poliza_n
	   and no_unidad = _no_unidad
	   and cod_descuen = '001';
	   
	if _cnt_descu is null then
		let _cnt_descu = 0;
	end if	
	   
	if _cnt_descu > 0 then   
		update emiunide
		   set porc_descuento = porc_descuento + (_calculo * (-1))
		 where no_poliza = _no_poliza_n
		   and no_unidad = _no_unidad
		   and cod_descuen = '001';
	else	
		insert into emiunide
		values (_no_poliza_n,
				_no_unidad,
			   '001',
			   _calculo * (-1),
			   1);
	end if		   

	call sp_proe01bk(_no_poliza_n, _no_unidad, '001') returning _error;	
		
	call sp_proe04(_no_poliza_n, _no_unidad,_suma_asegurada, '001') returning _error;

	call sp_proe02(_no_poliza_n,_no_unidad,'001') returning _error;
	
	call sp_proe03(_no_poliza_n,'001') returning _error;
	
	select prima_neta
	  into _prima_resultado
	  from emipouni
	 where no_poliza = _no_poliza_n
	   and no_unidad = _no_unidad;
	   
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