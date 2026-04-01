--Creado: 09/08/20224
--Autor: Amado Perez
--Pre Renovación a partir de polizas vencidas el 2024 09


drop procedure sp_sis245gCom;

create procedure sp_sis245gCom()
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
define _cnt_prod_exc            integer;
define _saldo_elect, _saldo_porc, _tipo_forma smallint;
define _cod_formapag            char(3);
define _incremento              dec(5,2);

--set debug file to "sp_sis245g.trc";
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
	select distinct a.no_poliza,
	       b.no_documento,
		   a.saldo
	  into _no_poliza,
	       _no_documento,
		   _saldo
	  from emirepo a,  deivid_tmp:renov_recar b
	 where a.no_documento = b.no_documento
	   and b.procesado = 0
	   and a.estatus in (1, 4)
	   and b.prima_neta <> 0
    union
    	select distinct a.no_poliza,
	       b.no_documento,
		   a.saldo
		  from emirepol a,  deivid_tmp:renov_recar b
	 where a.no_documento = b.no_documento
	   and b.procesado = 0
	   and a.estatus in (1, 4)
	   and b.prima_neta <> 0
           and a.no_poliza not in (
 	select  distinct  a.no_poliza
	  from emirepo a,  deivid_tmp:renov_recar b
	 where a.no_documento = b.no_documento
	   and b.procesado = 0
	   and a.estatus in (1, 4))

   SELECT  prima_bruta,
		   cod_formapag
	  INTO _prima_bruta,
		   _cod_formapag
	  FROM emipomae
     WHERE no_poliza = _no_poliza;

	SELECT tipo_forma
	  INTO _tipo_forma
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;
	 
	select saldo_elect,
	       saldo_porc
	  into _saldo_elect,
	       _saldo_porc
	  from emirepar;
		  
	if _tipo_forma = 2 or _tipo_forma = 3 or _tipo_forma = 4 then	--2=visa,3=desc salario,4=ach
		let _saldo_porc = _saldo_elect;
	end if

  if _saldo_porc is null then
	let _saldo_porc = 10;
  end if

  let _diezporc = 0;
  let _diezporc = _prima_bruta * (_saldo_porc/100);
	

	if _saldo > _diezporc then
		update deivid_tmp:renov_recar
		   set procesado = 3,
			   actualizado = 0
		 where no_documento = _no_documento;
	
		continue foreach;
	end if
	
	let _no_poliza_n = sp_sis13('001', 'PRO', '02', 'par_no_poliza');
	call sp_pro320dCom('DEIVID',_no_poliza, _no_poliza_n) returning _error, _error_desc;
	
	let _incremento = 0;
	
	foreach
		select no_unidad,
		       recargo
		  into _no_unidad,
		       _incremento
		  from deivid_tmp:renov_recar
		 where no_documento = _no_documento
		   and prima_neta <> 0
		   
		if _incremento is null then   
			let _incremento = 0;
		end if	
		
		select suma_asegurada, 
			   cod_producto
		  into _suma_asegurada,
			   _cod_producto
		  from emipouni
		 where no_poliza = _no_poliza_n
		   and no_unidad = _no_unidad;
		   
		-- Descuento de Producto AUTORC 00313
		
		if _cod_producto in ('00313','07159') then
			call sp_proe01f(_no_poliza_n, _no_unidad, '001') returning _error;	--Actualiza emipocob

			call sp_proe04(_no_poliza_n, _no_unidad,_suma_asegurada, '001') returning _error; --Actualiza emifacon

			call sp_proe02(_no_poliza_n,_no_unidad,'001') returning _error; --Actualiza emipouni
			
			call sp_proe03(_no_poliza_n,'001') returning _error; --Actualiza emipomae
		else
	--			call sp_proe01bk(_no_poliza_n, _no_unidad, '001') returning _error;	--Actualiza emipocob 
				-- Incremento
			if _incremento > 0 then
				let _ld_prima_neta_t = 0;   
				
				select sum(e.prima_neta)
				  into _ld_prima_neta_t
				  from emipocob e, prdcobpd c
				 where e.no_poliza = _no_poliza_n
				   and e.no_unidad = _no_unidad
				   and c.cod_cobertura = e.cod_cobertura
				   and c.cod_producto = _cod_producto
				   and c.acepta_desc = 1;
				   
				if _ld_prima_neta_t is null then
					let _ld_prima_neta_t = 0;
				end if	

				let _prima_neta_sin = 0;   

				select sum(e.prima_neta)
				  into _prima_neta_sin
				  from emipocob e, prdcobpd c
				 where e.no_poliza = _no_poliza_n
				   and e.no_unidad = _no_unidad
				   and c.cod_cobertura = e.cod_cobertura
				   and c.cod_producto = _cod_producto
				   and c.acepta_desc = 0;
					   
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

				call sp_proe01f(_no_poliza_n, _no_unidad, '001') returning _error;	--Actualiza emipocob
				
				call sp_proe04(_no_poliza_n, _no_unidad,_suma_asegurada, '001') returning _error; --Actualiza emifacon

				call sp_proe02(_no_poliza_n,_no_unidad,'001') returning _error; --Actualiza emipouni
				
				call sp_proe03(_no_poliza_n,'001') returning _error; --Actualiza emipomae
			end if
				
		end if
		
		select prima_neta
		  into _prima_resultado
		  from emipouni
		 where no_poliza = _no_poliza_n
		   and no_unidad = _no_unidad;
		   
		if _error = 0 then
			update deivid_tmp:renov_recar
			   set procesado = 1,
				   actualizado = 0,
				   no_poliza_r = _no_poliza_n,
				   prima_resultado = _prima_resultado
			 where no_documento = _no_documento
			   and no_unidad = _no_unidad;
		end if
		
		return _error,0,_no_poliza,_no_poliza_n with resume;
		
	end foreach
	   
		{if _error = 0 then
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
		}
end foreach
end
end procedure;