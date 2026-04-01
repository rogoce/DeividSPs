--Creado: 13/07/2024 
--Autor: Amado Pérez
--Endoso de cambio de producto
--

drop procedure sp_end18;

create procedure sp_end18(a_no_poliza char(10), a_no_endoso char(5))
returning	integer			as err,
			integer			as error_isam;

define _desc_error				varchar(100);       
define _error_desc 				varchar(100);       
define _no_documento			char(20);           
define _cod_contratante			char(10);           
define _no_poliza 				char(10);           
define _cod_producto			char(5);            
define _no_unidad 				char(5);            
define _cod_descuen	 			char(3);            
define _cod_ramo		 		char(3);            
define _error_isam				integer;
define _error					integer;
define _existe					integer;
define _vigencia_final			date;
define _fecha_aniversario		date;
DEFINE _ld_prima_neta_t, _prima_resultado    DEC(16,2);
DEFINE _prima_neta_sin, _suma_asegurada      DEC(16,2);
DEFINE _calculo         		DEC(5,2);
define _cod_cliente				char(10);
define _tar_salud               smallint;  
define _tarifa_dep_tot          dec(16,2);   
define _fecha_nac				date;  
define _edad					smallint;   
define _prima_plan				dec(16,2);
define _prima_vida				dec(16,2);  
define _prima_nueva             dec(16,2);
define _cod_depend				char(10);
define _prima_plan_dep			dec(16,2);
define _prima_vida_dep			dec(16,2);
define _tarifa_dep          	dec(16,2);
define _cod_parentesco  		char(3);
define _tipo_pariente,_tipo_par_prod	smallint;
define _descuento               dec(16,2);
define _recargo               	dec(16,2);
define ld_prima_resta			dec(16,2);
define _meses                	smallint;
define _cod_perpago				char(3);
define _porc_impuesto   		dec(5,2);
define _porc_descuento  		dec(5,2);
define _porc_recargo    		dec(5,2);
define _prima_tar               dec(16,2);
define _prima_tar_dep           dec(16,2);
define _descuento_tot           dec(16,2);
define _recargo_tot             dec(16,2);
define ld_recargo_dep  			dec(16,2);
define _prima                   dec(16,2);
define _prima_neta              dec(16,2);
define _impuesto                dec(16,2);
define _prima_bruta             dec(16,2);
define _prima_suscrita          dec(16,2);
define _porc_coas       		dec(7,4);
define _cod_tipoprod			char(3);
define _cnt             		integer;
define _cod_cober       		char(5);
define _desc_limite1    		varchar(50,0);
define _desc_limite2			varchar(50,0);
define _orden_n         		smallint;
define _ded_n           		varchar(50);
define _ded_nn          		dec(16,2);
define v_fecha_r        		date;
define _prima_nn        		dec(16,2);

--set debug file to "sp_end18.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc
	
	return	_error,
			_error_isam;
end exception

return 0, 0;

let _error = 0;
LET v_fecha_r = current;
let _cnt      = 0;

UPDATE emipomae
	  SET prima_bruta    = 0,
		  impuesto       = 0,
		  prima_neta     = 0,
		  descuento      = 0,
		  recargo        = 0,
		  prima          = 0
	WHERE no_poliza      = a_no_poliza;
	
foreach
	select cod_producto,
	       no_unidad,
		   cod_cliente
	  into _cod_producto,
	       _no_unidad,
		   _cod_cliente
	  from endeduni
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso
	   
	select no_documento,
	       vigencia_final,
		   cod_perpago,
		   cod_tipoprod
      into _no_documento,
	       _vigencia_final,
		   _cod_perpago,
		   _cod_tipoprod
      from emipomae
     where no_poliza = a_no_poliza;

	-- Verificacion si es Coaseguro Mayoritario

	IF _cod_tipoprod = "001" THEN

		SELECT porc_partic_coas
		  INTO _porc_coas
		  FROM emicoama
		 WHERE no_poliza    = a_no_poliza
		   AND cod_coasegur = "036";

		IF _porc_coas IS NULL THEN
			LET _porc_coas = 100;
		END IF

	ELSE
		LET _porc_coas = 100;
	END IF

    select tar_salud
	  into _tar_salud
	  from prdprod
	 where cod_producto = _cod_producto;
	 	
    let _tarifa_dep_tot	= 0;  
    let _prima_tar	= 0;  
    let _prima_tar_dep	= 0;  
    let _descuento_tot	= 0;  
    let _recargo_tot	= 0;  
	   
	select fecha_aniversario
	  into _fecha_nac
	  from cliclien
	 where cod_cliente = _cod_cliente;
 
	let _edad = sp_sis78(_fecha_nac, _vigencia_final);	   
	   
	select prima,
           prima_vida
	  into _prima_plan,
           _prima_vida
	  from prdtaeda
	 where cod_producto = _cod_producto
	   and edad_desde   <= _edad
	   and edad_hasta   >= _edad;	
	   
	let _prima_tar = _prima_plan;   

	-- Buscar Descuento
	let ld_prima_resta = _prima_plan;
	let _error_desc = 'Buscar Descuento . '|| _no_documento;
	let _descuento = 0.00;
	call sp_proe21(a_no_poliza, _no_unidad, _prima_plan) returning _descuento;

	if _descuento > 0 then
	   let ld_prima_resta = _prima_plan - _descuento;
	end if

	-- Buscar Recargo
	let _recargo = 0.00;
	call sp_proe22(a_no_poliza, _no_unidad, ld_prima_resta) returning _recargo;
	    
	let _prima_plan = _prima_plan - _descuento + _recargo;

	let _prima_nueva = 0;
	   
    select prima_nueva
      into _prima_nueva
      from deivid_tmp:salud_ren_rec
     where poliza = _no_documento
	   and codasegurado = _cod_cliente
	   and excluir = 0;
	   
	if  _prima_nueva is null then
		let _prima_nueva = 0;
	end if
	   
	LET _calculo = 0; 
	
	if _prima_nueva <> 0 then
		LET _calculo = ((_prima_nueva - _prima_plan) / _prima_plan ) * 100; 	
	
		IF _calculo <> 0 THEN
			delete from emiunire 
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad
			   and cod_recargo = '002';
			   
			insert into emiunire
			values (a_no_poliza,
					_no_unidad,
				   '002',
				   _calculo);		
			
		END IF
	end if
    	
	
    if _tar_salud = 5 then	--> Tarifas por edad (Aseg + Dep)
		FOREACH with hold
			SELECT cod_cliente
			  INTO _cod_depend
			  FROM emidepen
			 WHERE no_poliza = a_no_poliza
			   AND no_unidad = _no_unidad
			   AND activo = 1

			SELECT fecha_aniversario
			  INTO _fecha_aniversario
			  FROM cliclien
			 WHERE cod_cliente = _cod_depend;

			LET _edad = sp_sis78(_fecha_aniversario, _vigencia_final);

			let _tarifa_dep     = 0;
			let _prima_plan_dep = 0;
			let _prima_vida_dep = 0;
			 
			select prima,
				   prima_vida
			  into _prima_plan_dep,
				   _prima_vida_dep
			  from prdtaeda
			 where cod_producto = _cod_producto
			   and edad_desde   <= _edad
			   and edad_hasta   >= _edad;

			if _prima_plan_dep is null then
				let _prima_plan_dep = 0;
			end if

			if _prima_vida_dep is null then
				let _prima_vida_dep = 0;
			end if

			let _prima_tar_dep = _prima_plan_dep + _prima_vida_dep;

			let _tarifa_dep = _prima_plan_dep + _prima_vida_dep;
			
			-- Buscar Descuento
			let ld_prima_resta = _tarifa_dep;
			let _error_desc = 'Buscar Descuento . '|| _no_documento;
			let _descuento = 0.00;
			call sp_proe21(a_no_poliza, _no_unidad, _tarifa_dep) returning _descuento;			

			if _descuento > 0 then
			   let ld_prima_resta = _tarifa_dep - _descuento;
			end if
			
			-- Buscar Recargo
			let _recargo = 0.00;
			call sp_proe94(a_no_poliza, _no_unidad, _cod_depend, ld_prima_resta) returning _recargo;
			
			let _tarifa_dep = _tarifa_dep - _descuento + _recargo;
			
			let _prima_nueva = 0;
					
			select prima_nueva
			  into _prima_nueva
			  from deivid_tmp:salud_ren_rec
			 where poliza = _no_documento
			   and codasegurado = _cod_depend
			   and excluir = 0;
			   
			if  _prima_nueva is null then
				let _prima_nueva = 0;
			end if
			   
			LET _calculo = 0;    

			if _prima_nueva <> 0 then
			   
				LET _calculo = ((_prima_nueva - _tarifa_dep) / _tarifa_dep ) * 100; 
				
				IF _calculo <> 0 THEN		   
					delete from emiderec 
					 where no_poliza = a_no_poliza
					   and no_unidad = _no_unidad
					   and cod_cliente = _cod_depend
					   and cod_recargo = '002';
					   
					insert into emiderec
					values (a_no_poliza,
							_no_unidad,
							_cod_depend,
						   '002',
						   _calculo);		
				END IF
			 --   LET _tarifa_dep = _prima_nueva;
			end if
			
			UPDATE emidepen 
			   SET prima = _prima_tar_dep,
				   calcula_prima = 1
			 WHERE no_poliza = a_no_poliza
			   AND no_unidad = _no_unidad
			   AND cod_cliente = _cod_depend
			   AND activo = 1;
			
			let _tarifa_dep_tot	= _tarifa_dep_tot + _prima_tar_dep;
		END FOREACH
	  
		let _prima_plan = _prima_plan + _tarifa_dep_tot;
	--	let _prima_tar = _prima_tar + _prima_tar_dep;
	elif _tar_salud = 6 then	--> Tarifas por dependiente
		select prima
		  into _prima_plan
		  from prdtadep
		 where cod_producto = _cod_producto
		   and tipo         = 1; -- 1 = Aseurado Principal

		let _cod_parentesco = null;

		FOREACH with hold
			SELECT cod_parentesco,cod_cliente
			  INTO _cod_parentesco,_cod_depend
			  FROM emidepen
			 WHERE no_poliza = a_no_poliza
			   AND no_unidad = _no_unidad
			   AND activo = 1
			
			-- 1 = CONYUGUE, 2 = HIJO, HIJA ETC, 99 = OTRA COSA
			select tipo_pariente
			  into _tipo_pariente
			  from emiparen
			 where cod_parentesco = _cod_parentesco; 

			let _tarifa_dep     = 0;
			let _prima_plan_dep = 0;

			if _tipo_pariente = 1 then
				let _tipo_par_prod = 2;	 -- CONYUGUE EN PRODUCTO
			elif _tipo_pariente = 2 then 
				let _tipo_par_prod = 3;	 -- HIJO, HIJA EN PRODCUTO
			else
				let _tarifa_dep     = 0;
				let _prima_plan_dep = 0;
			end  if
			 
			select prima
			  into _prima_plan_dep
			  from prdtadep
			 where cod_producto = _cod_producto
			   and tipo         = _tipo_par_prod;

			if _prima_plan_dep is null then
				let _prima_plan_dep = 0;
			end if

			let _prima_tar_dep = _prima_plan_dep + _prima_vida_dep;

			let _tarifa_dep = _prima_plan_dep;
			
			-- Buscar Descuento
			let ld_prima_resta = _tarifa_dep;
			let _error_desc = 'Buscar Descuento . '|| _no_documento;
			let _descuento = 0.00;
			call sp_proe21(a_no_poliza, _no_unidad, _tarifa_dep) returning _descuento;

			if _descuento > 0 then
			   let ld_prima_resta = _tarifa_dep - _descuento;
			end if
			
			-- Buscar Recargo
			let _recargo = 0.00;
			call sp_proe94(a_no_poliza, _no_unidad, _cod_depend, ld_prima_resta) returning _recargo;
			
			let _tarifa_dep = _tarifa_dep - _descuento + _recargo;
			
			let _prima_nueva = 0;
					
			select prima_nueva
			  into _prima_nueva
			  from deivid_tmp:salud_ren_rec
			 where poliza = _no_documento
			   and codasegurado = _cod_depend
			   and excluir = 0;
			   
			if  _prima_nueva is null then
				let _prima_nueva = 0;
			end if
			   
			LET _calculo = 0;    

			if _prima_nueva <> 0 then
			   
				LET _calculo = ((_prima_nueva - _tarifa_dep) / _tarifa_dep ) * 100; 
				
				IF _calculo <> 0 THEN		   
					delete from emiderec 
					 where no_poliza = a_no_poliza
					   and no_unidad = _no_unidad
					   and cod_cliente = _cod_depend
					   and cod_recargo = '002';
					   
					insert into emiderec
					values (a_no_poliza,
							_no_unidad,
							_cod_depend,
						   '002',
						   _calculo);		
				END IF
			end if
			
			UPDATE emidepen 
			   SET prima = _prima_tar_dep,
				   calcula_prima = 1
			 WHERE no_poliza = a_no_poliza
			   AND no_unidad = _no_unidad
			   AND cod_cliente = _cod_depend
			   AND activo = 1;
			   
			let _tarifa_dep_tot	= _tarifa_dep_tot + _tarifa_dep;
		END FOREACH
		let _prima_plan = _prima_plan + _tarifa_dep_tot;		   
		--let _prima_tar = _prima_tar + _prima_tar_dep;
    end if
	
	-- Hasta Aqui las evaluaciones.

	select meses
	  into _meses
	  from cobperpa
	 where cod_perpago = _cod_perpago;

	if _meses = 0 then
		If _cod_perpago = '008' then  --Anual
			let _meses = 12;
		else
			let _meses = 1;
		End if
	end if

	-- Porcentaje de Impuesto
	
	select sum(factor_impuesto)
	  into _porc_impuesto
	  from emipolim p, prdimpue i
	 where p.cod_impuesto = i.cod_impuesto
	   and p.no_poliza    = a_no_poliza;

	IF _porc_impuesto IS NULL THEN
		LET _porc_impuesto = 0;
	END IF

	let _porc_impuesto = _porc_impuesto / 100;

	-- Calculos
			
	let _prima  		= (_prima_tar + _tarifa_dep_tot) * _meses;
	let ld_prima_resta = _prima;
	call sp_proe21(a_no_poliza, _no_unidad, _prima) returning _descuento;
	
	if _descuento > 0 then
	   let ld_prima_resta = _prima - _descuento;
	end if

	-- Buscar Recargo
	let _recargo = 0.00;
	call sp_proe22(a_no_poliza, _no_unidad, ld_prima_resta - _tarifa_dep_tot) returning _recargo;
	
	-- Buscar Recargo por dependiente
	let ld_recargo_dep = 0.00;
	call sp_proe53(a_no_poliza, _no_unidad) returning ld_recargo_dep;
	let _recargo = _recargo + ld_recargo_dep;
	
	let _prima_neta 	= _prima - _descuento + _recargo;
	let _impuesto   	= _prima_neta  * _porc_impuesto;
	let _prima_bruta	= _prima_neta + _impuesto;
	let _prima_suscrita = _prima_neta / 100 * _porc_coas;

	update emipouni
	   set cod_producto 	= _cod_producto,
	       prima        	= _prima,
		   descuento		= _descuento,
		   recargo			= _recargo,
		   prima_neta		= _prima_neta,
		   impuesto			= _impuesto,
		   prima_bruta 		= _prima_bruta,
		   prima_asegurado	= _prima_plan,
		   prima_total		= _prima,
		   prima_suscrita   = _prima_suscrita
	 where no_poliza		= a_no_poliza
	   and no_unidad		= _no_unidad;


		select count(*)
		  into _cnt
		  from prdcobpd
		 where cod_producto  = _cod_producto
		   and cob_requerida = 1;

		if _cnt > 0 then

			delete from emipocob
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad;

			let _desc_limite1 = null;
			let _desc_limite2 = null;
			let _ded_n        = "";

			foreach			--Actualizar los beneficios del producto en los campos de la cobertura, Armando 27/08/2012

				select cod_cobertura,
				       desc_limite1,
				       desc_limite2,
					   orden,
					   deducible
				  into _cod_cober,
				       _desc_limite1,
				       _desc_limite2,
					   _orden_n,
					   _ded_nn
				  from prdcobpd
				 where cod_producto  = _cod_producto
				   and cob_requerida = 1
			     order by orden

				if _ded_nn is null then
					let _ded_nn = 0;
				end if
				let _ded_n = _ded_nn;

				let _prima_nn = 0;
	            if _orden_n = 1 then
					let _prima_nn = 1;
				end if
				 
				insert into emipocob(
					   no_poliza,
					   no_unidad,
					   cod_cobertura,
					   orden,
					   tarifa,			
					   deducible,
					   limite_1,		
					   limite_2,		
					   prima_anual,		
					   prima,			
					   descuento,
					   recargo,			
					   prima_neta,		
					   date_added,		
					   date_changed,	
					   factor_vigencia,
					   desc_limite1,	
					   desc_limite2
					   )	
				       values (
				        a_no_poliza,
				        _no_unidad,
				        _cod_cober,
				        _orden_n,
				        0,
				        _ded_n,
				        0,     		 							
				        0,
				        _prima_nn,
				        0,	 	 							
				        0,	 		 							
				        0,
						0,
						v_fecha_r,
						v_fecha_r,
						1,
						_desc_limite1,
						_desc_limite2
						);

			end foreach
	    end if

	update emipocob
	   set prima        	= _prima,
		   descuento		= _descuento,
		   recargo			= _recargo,
		   prima_neta		= _prima_neta,
		   prima_anual		= _prima
	 where no_poliza		= a_no_poliza
	   and no_unidad		= _no_unidad
	   and prima_anual      <> 0.00;
	   
   UPDATE emipomae
	  SET prima_bruta    = prima_bruta + _prima_bruta,
		  impuesto       = impuesto + _impuesto,
		  prima_neta     = prima_neta + _prima_neta,
		  descuento      = descuento + _descuento,
		  recargo        = recargo + _recargo,
		  prima          = prima + _prima
	WHERE no_poliza      = a_no_poliza;
	   

	-- Realiza el cambio automatico de la nueva prima
	-- En caso de que sean Tarjetas de Credito 

	update cobtacre
	   set monto        = _prima_bruta,
	       modificado   = "*"
	 where no_documento = _no_documento;      	

	-- En caso de que sean ACH 

	update cobcutas
	   set monto        = _prima_bruta,
	       modificado   = "*"
	 where no_documento = _no_documento;
	 
			   
end foreach
end
return _error,0;
end procedure;