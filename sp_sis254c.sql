--Creado: 24/09/2024
--Autor: Amado Perez
--Renovación de polizas


drop procedure sp_sis254c;

create procedure sp_sis254c(a_periodo char(7), a_tipo_ren smallint, a_no_documento char(20))
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
define _estatus_1, _estatus_2, _estatus_3 	smallint;
define _cod_grupo   			char(5);

--set debug file to "sp_sis254.trc";
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

-- a_tipo_ren = 1 Particular, 2 Comercial, 3 Banisi

let _return = 0;
let _estatus_1 = 1;
let _estatus_2 = 4;
let _estatus_3 = 4;
let _estatus_poliza = 0;

if a_tipo_ren = 3 then
	let _estatus_3 = 2; --a_tipo_ren = 3 Banisi:Se incluye las que estan en Tecnico osea con saldo
end if

foreach
select distinct a.no_poliza_ant,
                a.no_documento,
		        a.saldo,
				a.cod_grupo
 	  into _no_poliza,
	       _no_documento,
		   _saldo,
		   _cod_grupo
     from prdpreren a
       where a.periodo = a_periodo 
	   and tipo_ren = a_tipo_ren
	   and a.procesado = 0
	   and a.prima_neta <> 0
	   and a.pre_renovado = 1
	   and a.no_documento = a_no_documento
		
{	select distinct a.no_poliza,
	       b.no_documento,
		   a.saldo
	  into _no_poliza,
	       _no_documento,
		   _saldo
	  from emirepo a,  prdpreren b
	 where a.no_documento = b.no_documento
	   and b.procesado = 0
	   and a.estatus in (_estatus_1, _estatus_2, _estatus_3)
	   and b.prima_neta <> 0
	   and b.pre_renovado = 1
	   and b.periodo = a_periodo
	   and b.tipo_ren = a_tipo_ren
	   and b.no_documento = a_no_documento
    union
	select distinct a.no_poliza,
	   b.no_documento,
	   a.saldo
	  from emirepol a,  prdpreren b
	 where a.no_documento = b.no_documento
	   and b.procesado = 0
	   and a.estatus in (_estatus_1, _estatus_2, _estatus_3)
	   and b.prima_neta <> 0
	   and b.pre_renovado = 1
	   and b.periodo = a_periodo
	   and b.tipo_ren = a_tipo_ren
	   and b.no_documento = a_no_documento
       and a.no_poliza not in (
 	select  distinct  a.no_poliza
	  from emirepo a,  prdpreren b
	 where a.no_documento = b.no_documento
	   and b.procesado = 0
	   and b.pre_renovado = 1
	   and a.estatus in (_estatus_1, _estatus_2, _estatus_3)
	   and b.periodo = a_periodo
	   and b.tipo_ren = a_tipo_ren
	   and b.no_documento = a_no_documento)
}
   SELECT  prima_bruta,
		   cod_formapag,
		   estatus_poliza
	  INTO _prima_bruta,
		   _cod_formapag,
		   _estatus_poliza
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
  
	-- a_tipo_ren = 3 Banisi: Van todas aunque tenga saldo -- Boni 16-09-2024
	
	if _saldo > _diezporc and a_tipo_ren <> 3 then
		update prdpreren
		   set procesado = 3,
			   actualizado = 0,
			   desc_error = "Saldo Mayor al 10%"
		 where no_documento = _no_documento
		   and periodo = a_periodo;
	
		continue foreach;
	end if
	
	if _estatus_poliza = 2 then
		update prdpreren
		   set procesado = 3,
			   actualizado = 0,
			   desc_error = "La poliza esta cancelada"
		 where no_documento = _no_documento
		   and periodo = a_periodo;
	
		continue foreach;
	end if
	
	let _no_poliza_n = sp_sis13('001', 'PRO', '02', 'par_no_poliza');
	
	if a_tipo_ren = 1 then	
		call sp_pro320f('DEIVID',_no_poliza, _no_poliza_n) returning _error, _error_desc;
	elif a_tipo_ren = 2 then
		call sp_pro320dCom('DEIVID',_no_poliza, _no_poliza_n) returning _error, _error_desc;
	elif a_tipo_ren = 3 then
		call sp_pro320g('DEIVID',_no_poliza, _no_poliza_n) returning _error, _error_desc;
	end if	
	
	let _incremento = 0;
	let _descuento = 0;
	
	foreach
		select no_unidad,
		       incremento,
			   incremento_neto,
			   descuento_x_sini
		  into _no_unidad,
		       _incremento,
			   _prima_neta,
			   _descuento
		  from prdpreren
		 where no_documento = _no_documento
		   and prima_neta <> 0
		   and periodo = a_periodo
		   
		if _incremento is null then   
			let _incremento = 0;
		end if	
		
		if _descuento is null then   
			let _descuento = 0;
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
			-- Descuento
			if _descuento > 0 or _incremento > 0 then
				delete from emiunide
				 where no_poliza = _no_poliza_n
				   and no_unidad = _no_unidad
				   and cod_descuen <> '003';

				delete from emiunire
				 where no_poliza = _no_poliza_n
				   and no_unidad = _no_unidad;
				   
				let _ld_prima_neta_t = 0;  
				let _prima = 0;
				
				foreach
					select e.cod_cobertura, 
						   e.prima
					  into _cod_cobertura,
					       _prima					      
					  from emipocob e, prdcobpd c
					 where e.no_poliza = _no_poliza_n
					   and e.no_unidad = _no_unidad
					   and c.cod_cobertura = e.cod_cobertura
					   and c.cod_producto = _cod_producto
					   and c.acepta_desc = 1
					   
					if _prima is null then
						let _prima = 0;
					end if	
					
					let _porc_desc = 0;
					
					foreach 
						select porc_descuento
						  into _porc_desc
						  from emicobde
						 where no_poliza = _no_poliza_n
					       and no_unidad = _no_unidad
					       and cod_cobertura = _cod_cobertura

						if _porc_desc is null then
							let _porc_desc = 0;
						end if	
						   
						let _prima = _prima - (_prima * _porc_desc / 100);
					end foreach
					
					let _ld_prima_neta_t = _ld_prima_neta_t + _prima;
				end foreach	
				   
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
				   				   
				LET _prima_neta = _prima_neta - _prima_neta_sin;   
				
				LET _calculo = ((_prima_neta - _ld_prima_neta_t) / _ld_prima_neta_t ) * 100;
					
				let _cnt_descu = 0; 
				 
				select count(*) 
				  into _cnt_descu
				  from emiunide
				 where no_poliza = _no_poliza_n
				   and no_unidad = _no_unidad
				   and cod_descuen = '003';
				   
				if _cnt_descu is null then
					let _cnt_descu = 0;
				end if	
				   
				if _cnt_descu > 0 then   
					update emiunide
					   set porc_descuento = _calculo * (-1)
					 where no_poliza = _no_poliza_n
					   and no_unidad = _no_unidad
					   and cod_descuen = '003';
				else	
					insert into emiunide
					values (_no_poliza_n,
							_no_unidad,
						   '003',
						   _calculo * (-1),
						   1);
				end if	

				call sp_proe01f(_no_poliza_n, _no_unidad, '001') returning _error;	--Actualiza emipocob
				
				call sp_proe04(_no_poliza_n, _no_unidad,_suma_asegurada, '001') returning _error; --Actualiza emifacon

				call sp_proe02(_no_poliza_n,_no_unidad,'001') returning _error; --Actualiza emipouni
				
				call sp_proe03(_no_poliza_n,'001') returning _error; --Actualiza emipomae
			end if
			-- Incremento
{			if _incremento > 0 then
				delete from emiunide
				 where no_poliza = _no_poliza_n
				   and no_unidad = _no_unidad
				   and cod_descuen <> '001';

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
					   set porc_descuento = _calculo * (-1)
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
}				   
{				if _cnt_descu > 0 then   
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
}
{				call sp_proe01f(_no_poliza_n, _no_unidad, '001') returning _error;	--Actualiza emipocob
				
				call sp_proe04(_no_poliza_n, _no_unidad,_suma_asegurada, '001') returning _error; --Actualiza emifacon

				call sp_proe02(_no_poliza_n,_no_unidad,'001') returning _error; --Actualiza emipouni
				
				call sp_proe03(_no_poliza_n,'001') returning _error; --Actualiza emipomae
			end if
}				
		end if
		
		select prima_neta
		  into _prima_resultado
		  from emipouni
		 where no_poliza = _no_poliza_n
		   and no_unidad = _no_unidad;
		   		   
		if _error = 0 then
			update prdpreren
			   set procesado = 1,
				   actualizado = 0,
				   no_poliza_r = _no_poliza_n,
				   prima_resultado = _prima_resultado
			 where no_documento = _no_documento
			   and no_unidad = _no_unidad
			   and periodo = a_periodo;
		end if		
	end foreach	 

    --Cambio de grupo en banisi	
	{if _cod_grupo = '1122' then
		update emipomae
		   set cod_grupo = '78032'
		where no_poliza = _no_poliza_n;
	elif _cod_grupo = '77850' then
		update emipomae
		   set cod_grupo = '78033'
		where no_poliza = _no_poliza_n;
	elif _cod_grupo = '77995' then
 		update emipomae
		   set cod_grupo = '78034'
		where no_poliza = _no_poliza_n;
   end if}	
	
end foreach

end
return 0,0,null,null with resume;
end procedure;