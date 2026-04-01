-- crear registros para programa de opciones en renovacion por primera vez.

-- CREADO: 		26/11/2004 POR: Armando
-- modificado:	13/01/2005 POR: Armando

drop procedure sp_pro561;

create procedure sp_pro561(v_poliza char(10), a_unidad char(5))
returning	smallint;	--saber si se han usado los descuentos en las opciones

define _cod_producto, _cod_prod_new, _cod_producto_ori char(5);
define _factor_vigencia 	dec(9,6);
define _cod_ramo 			char(3);
define _suma_aseg 			dec(16,2);
define _no_motor 			char(30);
define _uso_auto 			char(1);
define _cod_marca 			char(5);
define _cod_cobertura 		char(5);
define _cod_coberturax 		char(5);
define _ld_tarifa 			dec(16,2);
define _ld_prima 			dec(16,2);
define _ld_prima_deduc 		dec(16,2);
define _ld_deduc_nuevo		varchar(50);
define _orden 				smallint;
define _limite_1			dec(16,2);
define _limite_2			dec(16,2);
define _descuento			dec(16,2);
define _recargo				dec(16,2);
define _deducible           dec(16,2);
define _desc_limite1		varchar(50);
define _desc_limite2		varchar(50);
define _cambio              smallint;
define _no_documento        char(20);
define _descuento_be        dec(5,2);
define _descuento_fl        dec(5,2);
define _texto               references text;
define _error               smallint;
define _cant_cob            smallint;
define _cant_tasec          smallint;
define _busqueda            char(1);
define _ramo_sis            smallint;
define _capacidad           smallint;

DEFINE _porc_depre_uni      DEC(9,6);
DEFINE _factor_vigencia2     DEC(9,6);


define _ld_porc_depr	     dec(9,6);
define _ld_sum_aseg_1	     dec(16,2);
define _ld_sum_aseg_2	     dec(16,2);
define _suma_asegurada	     dec(16,2);
define _nuevo                smallint;
define _resultado		     integer;
define _ano_auto		     integer;
define _ano_actual		     smallint;
DEFINE _Factor_Vigencia_a    DEC(16,4);
DEFINE _Factor_Vigencia_b    DEC(16,4);
DEFINE _Factor_Vigenciax     DEC(16,4);
DEFINE v_vig_ini_pol         DATE;
DEFINE v_vig_fin_pol         DATE;
DEFINE v_vigen_ini           DATE;
define _chek_o               integer;
define _cob_requerida        integer;
define _cob_default          integer;
define _tiene_cob            integer;
define _porc_partic_prima	dec(9,6);
define _porc_partic_suma	dec(9,6);
define _cod_ruta			char(5); 
define _vigencia_final		date;
define _vigencia_inic		date;
define _cnt					smallint;
define _cod_contrato		char(5);
define _fecha_primer_pago	date;
define _error_desc			varchar(100);
define _no_unidad           CHAR(5);
define _cod_tipoveh     char(3);
let _ano_actual = year(current);

let _cambio = 0;
let _chek_o = 1;
let _cob_requerida = 1;
let _cob_default = 1;
let _texto = null;
let _tiene_cob = 0;
--- Actualizacion de Polizas
--IF v_poliza = '1404323' AND a_unidad = '00008' THEN
--IF v_poliza = '0001096937' AND a_unidad = '00005' THEN 
--  set debug file to "sp_pro561.trc";
--  trace on;
--END IF

begin
	select cod_ramo,
	       no_documento,
		   factor_vigencia,
		   year(vigencia_inic)
	  into _cod_ramo,
	       _no_documento,
		   _factor_vigencia,
		   _ano_actual
	  from emipomae
	 where no_poliza = v_poliza;
 	  
   select suma_aseg,
          cod_producto
     into _suma_aseg,
	      _cod_producto
     from emireaut
    where no_poliza = v_poliza
	  and no_unidad = a_unidad;
	  
    select cod_producto, suma_asegurada
      into _cod_producto, _suma_asegurada
      from emipouni
     where no_poliza = v_poliza
	   and no_unidad = a_unidad;  

		let _ld_sum_aseg_1 = _suma_asegurada; --//H*Giron31/05/2020,CASO:34750 USER: JEPEREZ 	inicio
		let _ld_sum_aseg_2 = _suma_asegurada;
		--let a_porc_depre_pol = _ld_porc_depr2;	
--		if _cod_ramo in ('023') then	--preguntar '002',
		if _cod_ramo in ('023','020','002') then	--preguntar '002',SD#5155 JEPËREZ
		
 		 SELECT vigencia_inic,
				vigencia_final
		   INTO v_vig_ini_pol,
				v_vig_fin_pol
		  from emipomae
		 where no_poliza = v_poliza;
			 
		 SELECT vigencia_inic
		   INTO v_vigen_ini
		   FROM emipouni 
		  WHERE no_poliza = v_poliza
		     and no_unidad = a_unidad
			and activo = 1; 
			
		    let _ano_actual = year(current); --year(v_vigen_ini);
			let _ld_porc_depr	= 0.00;

			select no_motor,
				   uso_auto,
				   cod_tipoveh
			  into _no_motor,
				   _uso_auto,
				   _cod_tipoveh
			  from emiauto
			 where no_poliza = v_poliza
			   and no_unidad = a_unidad;

			let _resultado = 0;

			select ano_auto,nuevo
			  into _ano_auto,_nuevo
			  from emivehic
			 where no_motor = _no_motor;
			 
			let _resultado = _ano_actual - _ano_auto;

			if (_resultado <= 0) or (_resultado = 1) then
				let _resultado = 1;
			else
				if _nuevo <> 1 then
					let _resultado = _resultado + 1;
				end if	
			end if					
			
			select porc_depre
			  into _ld_porc_depr
			  from emidepre
			 where uso_auto  = _uso_auto
			   and _resultado between ano_desde and ano_hasta;	
			   
                 --- adicion SD#5155 JEPEREZ inicio			   
				 {
				 TIPO VEHICULO	003 TAXIS
				 USO	COMERCIAL – C
				 CONDICION	NUEVO	USADO
				 % DEPRECIACION	20	15			 
				 }
				 
				 if _cod_tipoveh = '003' then
					if _uso_auto = 'C' then
						if _nuevo = 1 then
							let _ld_porc_depr	= 20;	
						else
							let _ld_porc_depr	= 15;							
						end if	
					end if
				 end if 			   
				 --- adicion SD#5155 JEPEREZ fin  
				 
				let _Factor_Vigencia_a =	v_vig_fin_pol - v_vigen_ini;
				let _Factor_Vigencia_b =	v_vig_fin_pol - v_vig_ini_pol;
				let _Factor_Vigenciax  =	_Factor_Vigencia_a / _Factor_Vigencia_b;				   

            	let _ld_porc_depr = _ld_porc_depr * _Factor_Vigenciax ;		
				if 	_ld_sum_aseg_1 is null then
					let _ld_sum_aseg_1  = 0;
				end if

				let _ld_sum_aseg_2 = _ld_sum_aseg_1 - (_ld_sum_aseg_1 *  (_ld_porc_depr/100));	
				let _ld_sum_aseg_2 = round(_ld_sum_aseg_2,0);
				let _suma_aseg = _ld_sum_aseg_2;

		end if	--//H*Giron31/05/2020,CASO:34750 USER: JEPEREZ fin	
		
	let _cod_producto_ori = _cod_producto;
	   
    select no_motor,
           uso_auto
   	  into _no_motor,
   	       _uso_auto
   	  from emiauto
     where no_poliza = v_poliza
   	   and no_unidad = a_unidad;
   	  
	select cod_marca
  	  into _cod_marca
  	  from emivehic
 	 where no_motor = _no_motor;
	
	--Busqueda de producto nuevo
	let _cod_prod_new = null;
	
	select producto_nuevo
	  into _cod_prod_new
	  from prdnewpro3
	 where cod_producto = _cod_producto
	   and activo = 1;  

	
	If _cod_ramo = '023' Then -- hg:18-6-2020
		let _chek_o = 0;
		let _cob_requerida = 0;
		let _cob_default = 0;
		if _cod_prod_new is null then
		   foreach
			select a.cod_producto
			  into _cod_prod_new
			  from prdprod a, prdpolpd b
			 where a.cod_producto = b.cod_producto
			   and a.cod_producto = _cod_producto
			   and a.activo = 1
			   and b.no_documento = _no_documento
			   and b.status = 'ACT'
			   exit foreach;
			   end foreach
		end if			
	else
		if _cod_prod_new is null then
		   foreach
			select a.cod_producto
			  into _cod_prod_new
			  from prdprod a, prdpolpd b
			 where a.cod_producto = b.cod_producto
			   and a.activo = 1
			   and b.no_documento = _no_documento
			   and b.status = 'ACT'
			   exit foreach;
			   end foreach
		end if	
	end if
	 
	if _cod_prod_new is not null then --and _cod_producto_ori <> _cod_prod_new then
		let _cambio = 1;
				
		let _cod_producto = _cod_prod_new;		
		
		update emireaut 
		   set cod_producto = _cod_producto
		 where no_poliza = v_poliza
		   and no_unidad = a_unidad;
		
--		delete from emireau1
--		 where no_poliza = v_poliza
--		   and no_unidad = a_unidad;
		
		delete from emireau2
		 where no_poliza = v_poliza
		   and no_unidad = a_unidad;
		   
		-- Caso SD 10411 - Eliminacion Beneficio Odontológico Planes Auto - SIGMA DENTAL
		if _cod_producto in ('10460','10461','10462','10463') then
			delete from emireau1 
			 where no_poliza = v_poliza
			   and no_unidad = a_unidad
			   and cod_cobertura in ('01579','01577');
		end if
		   
		   
		If _cod_ramo in ('023','020','002') Then
			foreach with hold
				select cod_cobertura,
					   orden,
					   desc_limite1,
					   desc_limite2
				  into _cod_cobertura,
					   _orden,
					   _desc_limite1,
					   _desc_limite2
				  from prdcobpd
				 where cod_producto = _cod_producto
				 
				if _desc_limite1 is null then
					let _desc_limite1 = ' ';
				end if

				if _desc_limite2 is null then
					let _desc_limite2 = ' ';
				end if
			   
				let _cant_cob = 0;
			   
				select count(*)
				  into _cant_cob
				  from emipocob
				 where no_poliza = v_poliza
				   and no_unidad = a_unidad			              
				   and cod_cobertura  = _cod_cobertura;
			   
				if _cant_cob > 0 then
					select count(*)
					  into _cant_tasec
					  from prdtasec
					 where cod_producto  = _cod_producto
					   and cod_cobertura  = _cod_cobertura;
					  
					if _cant_tasec = 1 then  
						select rango_monto1,
							   rango_monto2
						  into _limite_1,
							   _limite_2
						  from prdtasec
						 where cod_producto  = _cod_producto
						   and cod_cobertura  = _cod_cobertura;
					else
						select limite_1,
							   limite_2
						  into _limite_1,
							   _limite_2
						  from emipocob
						 where no_poliza = v_poliza
						   and no_unidad = a_unidad			              
						   and cod_cobertura  = _cod_cobertura;	
					end if							   
				else
					select count(*)
					  into _cant_tasec
					  from prdtasec
					 where cod_producto  = _cod_producto
					   and cod_cobertura  = _cod_cobertura;
					  
					if _cant_tasec = 1 then  
						select rango_monto1,
							   rango_monto2
						  into _limite_1,
							   _limite_2
						  from prdtasec
						 where cod_producto  = _cod_producto
						   and cod_cobertura  = _cod_cobertura;
					else
						let _limite_1 = 0.00;
						let _limite_2 = 0.00;
					end if
				end if
				   
				if _limite_1 is null then
					let _limite_1 = 0.00;
				end if

				if _limite_2 is null then
					let _limite_2 = 0.00;
				end if
			   
				if _cod_ramo in ('023') then		        
					delete from emiredes
					 where no_poliza = v_poliza
					   and no_unidad = a_unidad;
					   
					select descuento_be,
						   descuento_fl
					  into _descuento_be,
						   _descuento_fl
					  from prdprod
					 where cod_producto = _cod_producto;
									 					 
					if _descuento_be > 0 then
						delete from emirede0
						 where no_poliza = v_poliza
						   and no_unidad = a_unidad
						   and cod_descuen = '001';
					
						delete from emirede1
						 where no_poliza = v_poliza
						   and no_unidad = a_unidad
						   and cod_descuen = '001';
						   
						delete from emirede2
						 where no_poliza = v_poliza
						   and no_unidad = a_unidad
						   and cod_descuen = '001';
						   
						insert into emirede0(
						 no_poliza,
						 no_unidad,
						 cod_descuen,
						 porc_descuento)
						 values (
						 v_poliza,
						 a_unidad,
						 '001',
						 _descuento_be
						 );
						insert into emirede1(
						 no_poliza,
						 no_unidad,
						 cod_descuen,
						 porc_descuento)
						 values (
						 v_poliza,
						 a_unidad,
						 '001',
						 _descuento_be
						 );
						insert into emirede2(
						 no_poliza,
						 no_unidad,
						 cod_descuen,
						 porc_descuento)
						 values (
						 v_poliza,
						 a_unidad,
						 '001',
						 _descuento_be
						 );
					end if
					
					if _descuento_fl > 0 then					 
						delete from emirede0
						 where no_poliza = v_poliza
						   and no_unidad = a_unidad
						   and cod_descuen = '002';
					
						delete from emirede1
						 where no_poliza = v_poliza
						   and no_unidad = a_unidad
						   and cod_descuen = '002';
						   
						delete from emirede2
						 where no_poliza = v_poliza
						   and no_unidad = a_unidad
						   and cod_descuen = '002';
						   
						insert into emirede0(
						 no_poliza,
						 no_unidad,
						 cod_descuen,
						 porc_descuento)
						 values (
						 v_poliza,
						 a_unidad,
						 '002',
						 _descuento_fl
						 );
						insert into emirede1(
						 no_poliza,
						 no_unidad,
						 cod_descuen,
						 porc_descuento)
						 values (
						 v_poliza,
						 a_unidad,
						 '002',
						 _descuento_fl
						 );
						insert into emirede2(
						 no_poliza,
						 no_unidad,
						 cod_descuen,
						 porc_descuento)
						 values (
						 v_poliza,
						 a_unidad,
						 '002',
						 _descuento_fl
						 );
					end if
					
					FOREACH
						select descripcion
						  into _texto
						  from prddesc
						 where cod_producto = _cod_producto
						EXIT FOREACH;
					END FOREACH
					
					insert into emiredes (
					no_poliza,
					no_unidad,
					descripcion)
					values (
					v_poliza,
					a_unidad,
					_texto);			
				end if
				   
				let _ld_tarifa = 0;
				let _ld_prima_deduc = 0;
				let _descuento = 0;
				let _recargo = 0;
				let _ld_deduc_nuevo = "";
				let _deducible = 0.00;
				let _ld_prima = 0;

--					call sp_pro51t(v_poliza, _cod_producto, _cod_ramo, a_unidad,  _cod_cobertura,  _suma_aseg) returning _ld_tarifa;       --prima anual
				call sp_pro51f(v_poliza, _cod_producto, _cod_ramo, a_unidad,  _cod_cobertura,  _suma_aseg, _limite_1, _limite_2) returning _ld_tarifa;       --prima anual
				call sp_pro563(v_poliza, _cod_producto, _cod_ramo, a_unidad,  _cod_cobertura,  _suma_aseg, _ld_tarifa, _limite_1, _limite_2) returning _ld_prima_deduc, _descuento, _recargo;	--prima neta
				call sp_pro51u(v_poliza, _cod_producto, _cod_ramo, a_unidad,  _cod_cobertura,  _cod_marca, _suma_aseg, _ld_tarifa, _uso_auto) returning _deducible;	--deducible
				
				select d.busqueda, d.cob_requerida, d.cob_default					  
				  into _busqueda, _cob_requerida, _cob_default
				  from prdcobpd d, prdcober c
				 where d.cod_cobertura = c.cod_cobertura
				   and d.cod_producto  = _cod_producto
				   and c.cod_cobertura = _cod_cobertura;

				if _busqueda = "6" then --Asiento
					select ramo_sis
					  into _ramo_sis
					  from prdramo
					 where cod_ramo = _cod_ramo;

					if _ramo_sis = 1 then
						select no_motor
						  into _no_motor
						  from emiauto 
						 where no_poliza = v_poliza
						   and no_unidad = a_unidad;

						select capacidad
						  into _capacidad
						  from emivehic
						 where no_motor = _no_motor;						
					
						select rango_monto1,
							   rango_monto2
						  into _limite_1,
							   _limite_2
						 FROM prdtasec
						WHERE cod_producto  = _cod_producto
						  AND cod_cobertura = _cod_cobertura
						  AND renglon       = _capacidad;
					end if							  
				end if

				
				if _deducible > 0 then
					let _ld_deduc_nuevo = _deducible;
					if _cod_cobertura = '01302' then
						let _ld_deduc_nuevo = trim(_ld_deduc_nuevo) || " " || "P/E";
					end if
				end if
				
				let _ld_prima = _ld_tarifa * _factor_vigencia;
				
				if _cob_requerida = 1 then  -- hg:18-6-2020
				   let _chek_o = 1;
				else
				   let _chek_o = 0;
				end if
				
				if _chek_o = 0 then
						let _tiene_cob = 0;							
					 select count(*)
					   into _tiene_cob
					   from emipocob   
					  where no_poliza = v_poliza
						and no_unidad = a_unidad
						and cod_cobertura = _cod_cobertura;
					  
					 if _tiene_cob is NULL then
						 LET _tiene_cob = 0;
					end if	
					 if _tiene_cob <>  0 then
						 let _chek_o = 1;
					end if									
					  
				end if	

				if _limite_1 is null then
					let _limite_1 = 0.00;
				end if

				if _limite_2 is null then
					let _limite_2 = 0.00;
				end if					
								
				BEGIN
				on exception set _error 
				if _error = -239 or _error = -268 then 			
					update emireau1 
					   set orden = _orden, 
						   chek_o = _chek_o,  --1, hg
						   deducible_o = _ld_deduc_nuevo, 
						   limite_1_o = _limite_1, 
						   limite_2_o = _limite_2, 
						   prima_anual_o = _ld_tarifa, 
						   prima_o = _ld_prima, 
						   descuento_o = _descuento, 
						   recargo_o = _recargo, 
						   prima_neta_o = _ld_prima_deduc, 
						   chek_1 = 1, 
						   deducible_1  = _ld_deduc_nuevo, 
						   limite_1_1 = _limite_1, 
						   limite_2_1 = _limite_2, 
						   prima_anual_1 = _ld_tarifa, 
						   prima_1 = _ld_prima, 
						   descuento_1 = _descuento, 
						   recargo_1 = _recargo, 
						   prima_neta_1 = _ld_prima_deduc, 
						   chek_2 = 1, 
						   deducible_2  = _ld_deduc_nuevo, 
						   limite_1_2 = _limite_1, 
						   limite_2_2 = _limite_2, 
						   prima_anual_2 = _ld_tarifa, 
						   prima_2 = _ld_prima, 
						   descuento_2 = _descuento, 
						   recargo_2 = _recargo, 
						   prima_neta_2 = _ld_prima_deduc, 
						   factor_vigencia = _factor_vigencia, 
						   desc_limite1 = _desc_limite1, 
						   desc_limite2 = _desc_limite2
					 where no_poliza = v_poliza
					   and no_unidad = a_unidad
					   and cod_cobertura = _cod_cobertura;
				 end if
				 
				 END EXCEPTION
									  
				Insert Into emireau1 (no_poliza, no_unidad, cod_cobertura, orden, chek_o, 
											 deducible_o, limite_1_o, limite_2_o, prima_anual_o, prima_o, 
											 descuento_o, recargo_o, prima_neta_o, chek_1, 
											 deducible_1, limite_1_1, limite_2_1, prima_anual_1, prima_1, 
											 descuento_1, recargo_1, prima_neta_1, chek_2, 
											 deducible_2, limite_1_2, limite_2_2, prima_anual_2, prima_2, 
											 descuento_2, recargo_2, prima_neta_2, 										 
											 factor_vigencia, desc_limite1, desc_limite2)
				Values (v_poliza, a_unidad, _cod_cobertura, _orden, _chek_o,  --1,hg 
						  _ld_deduc_nuevo, _limite_1, _limite_2, _ld_tarifa, _ld_prima, 
						  _descuento, _recargo, _ld_prima_deduc, 1, 
						  _ld_deduc_nuevo, _limite_1, _limite_2, _ld_tarifa, _ld_prima, 
						  _descuento, _recargo, _ld_prima_deduc, 1, 
						  _ld_deduc_nuevo, _limite_1, _limite_2, _ld_tarifa, _ld_prima, 
						  _descuento, _recargo, _ld_prima_deduc,  
						  _factor_vigencia, _desc_limite1, _desc_limite2);
			   END			
			   			   
			   update prdpolpd
				  set status = 'ACT' --NU'
				where no_documento = _no_documento
				  and cod_producto = _cod_producto_ori;
				  
				delete from prdpolpd
				where no_documento = _no_documento
				  and cod_producto = _cod_producto;
				
				insert into prdpolpd (
				 no_documento,
				 cod_producto,
				 status,
				 date_added)
				 values (
				 _no_documento,
				 _cod_producto,
				 'ACT',
				 date(today));
			   
			end foreach
				
		End If
						
		insert into emireau2(
		no_poliza,
		no_unidad ,
		cod_cobertura,
		orden,
		chek_o,
		limite_1_o,
		limite_2_o,
		prima_anual_o,
		prima_o,
		descuento_o,
		recargo_o,
		prima_neta_o,
		chek_1,
		limite_1_1,
		limite_2_1,
		prima_anual_1,
		prima_1,
		descuento_1,
		recargo_1,
		prima_neta_1,
		chek_2,
		limite_1_2,
		limite_2_2,
		prima_anual_2,
		prima_2,
		descuento_2,
		recargo_2,
		prima_neta_2,
		deducible_o,
		deducible_1,
		deducible_2,
		limite_1_3,
		limite_2_3,
		prima_anual_3,
		prima_3,
		descuento_3,
		recargo_3,
		prima_neta_3,
		deducible_3,
		requerida_1,
		requerida_2,
		factor_vigencia,
		desc_limite1,
		desc_limite2)
		select
			no_poliza,
			no_unidad,
			cod_cobertura,
			orden,
			chek_o,
			limite_1_o,
			limite_2_o,
			prima_anual_o,
			prima_o,
			descuento_o,
			recargo_o,
			prima_neta_o,
			chek_1,
			limite_1_1,			
			limite_2_1,
			prima_anual_1,
			prima_1,
			descuento_1,
			recargo_1,
			prima_neta_1,
			chek_2,
			limite_1_2,
			limite_2_2,
			prima_anual_2,
			prima_2,
			descuento_2,
			recargo_2,
			prima_neta_2,
			deducible_o,
			deducible_1,
			deducible_2,
			limite_1_3,
			limite_2_3,
			prima_anual_3,
			prima_3,
			descuento_3,
			recargo_3,
			prima_neta_3,
			deducible_3,
			requerida_1,
			requerida_2,
			factor_vigencia,
			desc_limite1,
			desc_limite2
		  from emireau1
		 where no_poliza = v_poliza
		   and no_unidad = a_unidad;
			   
		--//H*Giron31/05/2020,CASO:34750 USER: JEPEREZ fin	
		if _cod_ramo in ('023','002','020') then    ---preguntar '002',	
			update emireaut 
			   set suma_aseg          = _ld_sum_aseg_2,
				   suma_aseg_anterior = _ld_sum_aseg_1,
				   porc_depreciacion  = _ld_porc_depr
			 where no_poliza = v_poliza
			   and no_unidad = a_unidad;
				   
			foreach 
				select cod_cobertura
				  into _cod_coberturax
				  from prdcobpd
				 where cod_producto = _cod_producto					 
				   and cod_cobertura in (
					   select cod_cobertura from prdcober where  upper(trim(nombre)) = 'INCENDIO'
						   OR upper(trim(nombre)) = 'ROBO'
						   OR upper(trim(nombre)) = 'COLISION O VUELCO' OR upper(trim(nombre)) = 'COLISION Y VUELCO'
						   OR upper(trim(nombre)) = 'COMPRENSIVO'
							)
							
					update emireau1 
						set limite_1_o = _ld_sum_aseg_2, 
						   limite_1_1  = _ld_sum_aseg_2, 
						   limite_1_2  = _ld_sum_aseg_2,
						   factor_vigencia = _Factor_Vigenciax
					 where no_poliza = v_poliza
					   and no_unidad = a_unidad
					   and trim(cod_cobertura) = trim(_cod_coberturax);
					   --let _cambio = 1;
					update emireau2 
						set limite_1_o = _ld_sum_aseg_2, 
						   limite_1_1  = _ld_sum_aseg_2, 
						   limite_1_2  = _ld_sum_aseg_2,
						   factor_vigencia = _Factor_Vigenciax

					 where no_poliza = v_poliza
					   and no_unidad = a_unidad
					   and cod_cobertura = _cod_coberturax;   
					   
			end foreach						   
			--//H*Giron31/05/2020,CASO:34750 USER: JEPEREZ fin		 		   
		end if		   		
	end if
	
	if _cod_ramo in ('023') then	----- inicia	        
		delete from emiredes
		 where no_poliza = v_poliza
	       and no_unidad = a_unidad;
	   
		select descuento_be,
		       descuento_fl
	      into _descuento_be,
		       _descuento_fl
	      from prdprod
	     where cod_producto = _cod_producto;

		delete from emirede0
		 where no_poliza = v_poliza
		   and no_unidad = a_unidad
		   and cod_descuen = '001';
	
		delete from emirede1
		 where no_poliza = v_poliza
		   and no_unidad = a_unidad
		   and cod_descuen = '001';
		   
		delete from emirede2
		 where no_poliza = v_poliza
		   and no_unidad = a_unidad
		   and cod_descuen = '001';
		   
		if _descuento_be > 0 then		   
			insert into emirede0(
			 no_poliza,
			 no_unidad,
			 cod_descuen,
			 porc_descuento)
			 values (
			 v_poliza,
			 a_unidad,
			 '001',
			 _descuento_be
			 );
			insert into emirede1(
			 no_poliza,
			 no_unidad,
			 cod_descuen,
			 porc_descuento)
			 values (
			 v_poliza,
			 a_unidad,
			 '001',
			 _descuento_be
			 );
			insert into emirede2(
			 no_poliza,
			 no_unidad,
			 cod_descuen,
			 porc_descuento)
			 values (
			 v_poliza,
			 a_unidad,
			 '001',
			 _descuento_be
			 );
		end if
					 
		delete from emirede0
		 where no_poliza = v_poliza
		   and no_unidad = a_unidad
		   and cod_descuen = '002';
	
		delete from emirede1
		 where no_poliza = v_poliza
		   and no_unidad = a_unidad
		   and cod_descuen = '002';
		   
		delete from emirede2
		 where no_poliza = v_poliza
		   and no_unidad = a_unidad
		   and cod_descuen = '002';
		   
		if _descuento_fl > 0 then			   
			insert into emirede0(
			 no_poliza,
			 no_unidad,
			 cod_descuen,
			 porc_descuento)
			 values (
			 v_poliza,
			 a_unidad,
			 '002',
			 _descuento_fl
			 );
			insert into emirede1(
			 no_poliza,
			 no_unidad,
			 cod_descuen,
			 porc_descuento)
			 values (
			 v_poliza,
			 a_unidad,
			 '002',
			 _descuento_fl
			 );
			insert into emirede2(
			 no_poliza,
			 no_unidad,
			 cod_descuen,
			 porc_descuento)
			 values (
			 v_poliza,
			 a_unidad,
			 '002',
			 _descuento_fl
			 );
		end if
	
		FOREACH
			select descripcion
			  into _texto
			  from prddesc
			 where cod_producto = _cod_producto
			EXIT FOREACH;
		END FOREACH
	
		insert into emiredes (
		no_poliza,
		no_unidad,
		descripcion)
		values (
		v_poliza,
		a_unidad,
		_texto);	
	
		select count(*)
		  into _cnt
		  from emiporen
		 where no_poliza = v_poliza;

		if _cnt = 0 then
			select no_poliza,	
				   cod_compania,	
				   cod_sucursal,	
				   sucursal_origen,	
				   cod_grupo,	
				   cod_perpago,	
				   cod_tipocalc,	
				   cod_ramo,	
				   cod_subramo,	
				   cod_formapag,	
				   cod_tipoprod,	
				   cod_contratante,	
				   cod_pagador,	
				   cod_no_renov,	
				   serie,	
				   no_documento,	
				   no_factura,	
				   prima,	
				   descuento,	
				   recargo,	
				   prima_neta,	
				   impuesto,	
				   prima_bruta,	
				   prima_suscrita,	
				   prima_retenida,	
				   tiene_impuesto,	
				   vigencia_inic,	
				   vigencia_final,	
				   fecha_suscripcion,	
				   fecha_impresion,	
				   fecha_cancelacion,	
				   no_pagos,	
				   impreso,	
				   nueva_renov,	
				   estatus_poliza,	
				   direc_cobros,	
				   por_certificado,	
				   actualizado,	
				   dia_cobros1,	
				   dia_cobros2,	
				   fecha_primer_pago,	
				   no_poliza_coaseg,	
				   date_changed,	
				   renovada,	
				   date_added,	
				   periodo,	
				   carta_aviso_canc,	
				   carta_prima_gan,	
				   carta_vencida_sal,	
				   carta_recorderis,	
				   fecha_aviso_canc,	
				   fecha_prima_gan,	
				   fecha_vencida_sal,	
				   fecha_recorderis,	
				   cobra_poliza,	
				   user_added,	
				   ult_no_endoso,	
				   declarativa,	
				   abierta,	
				   fecha_renov,	
				   fecha_no_renov,	
				   no_renovar,	
				   perd_total,	
				   anos_pagador,	
				   saldo_por_unidad,	
				   factor_vigencia,	
				   suma_asegurada,	
				   incobrable,	
				   saldo,	
				   fecha_ult_pago,	
				   reemplaza_poliza,	
				   user_no_renov,	
				   posteado,	
				   no_tarjeta,	
				   fecha_exp,	
				   cod_banco,	
				   monto_visa,	
				   tipo_tarjeta,	
				   no_recibo,	
				   no_cuenta,	
				   tipo_cuenta,	
				   gestion,	
				   fecha_gestion,	
				   dia_cobro_anterior,	
				   incentivo,	
				   cod_origen,	
				   cotizacion,	
				   de_cotizacion,	
				   poliza_maestra,	
				   fecha_entrega_aviso,	
				   tiene_gastos,	
				   gastos,	
				   doble_cobertura,	
				   cia_doble_cob,	
				   continuidad_benef,	
				   colectiva,	
				   ind_fecha_coti,	
				   ind_fecha_aprob,	
				   ind_fecha_emi,	
				   ind_fecha_ent,	
				   linea_rapida,	
				   subir_bo,	
				   leasing,	
				   visa_ren,	
				   vigencia_fin_pol,	
				   fronting,	
				   wf_aprob,	
				   wf_firma_aprob,	
				   wf_incidente,	
				   wf_fecha_entro,	
				   wf_fecha_aprob,	
				   anticipo_comis,	
				   pol_maestra,
				   periodo_espera	
			  from emipomae
			 where no_poliza = v_poliza
			  into temp tmpemipo2;

			insert into emiporen
			select * from tmpemipo2
			 where no_poliza = v_poliza;

			foreach
				select fecha_primer_pago
				  into _fecha_primer_pago
				  from emireaut
				 where no_poliza = v_poliza
				exit foreach;
			end foreach

			update emiporen
			   set actualizado       = 0,
				   factor_vigencia   = 1.000000,
				   fecha_primer_pago = _fecha_primer_pago
			 where no_poliza         = v_poliza;

			drop table tmpemipo2;
		end if	

		for _cnt = 2 to 8
			call sp_pro82h(v_poliza,_cnt);
		end for
		--
		--Carga de Reaseguro Global de la Póliza en caso de que no exista
		let _cnt = 0;

		select count(*)
		  into _cnt
		  from emireglo
		 where no_poliza = v_poliza;

		if _cnt = 0 then
		   foreach
			select suma_aseg,
				   vigencia_inic
			  into _suma_asegurada,
				   _vigencia_inic
			  from emireaut
			 where no_poliza = v_poliza
			   order by no_unidad
			exit foreach;
			end foreach
			
			foreach
				select cod_ruta
				  into _cod_ruta
				  from rearumae  
				 where cod_compania = '001'
				   and cod_ramo = '023'
				   and _vigencia_inic between vig_inic and vig_final
				   and activo = 1
				 order by cod_ruta asc
				exit foreach;
			end foreach

			if _cod_ruta is null or _cod_ruta = '' then
				let _cambio = 292; -- falta reaeguro
				{select descripcion
				  into _error_desc
				  from inserror
				 where tipo_error = 2
				   and code_error = 291;		
				return -1,_error_desc;}
			end if
			
			foreach
				select orden,
					   cod_contrato,
					   porc_partic_prima,
					   porc_partic_suma
				  into _orden,
					   _cod_contrato,
					   _porc_partic_prima,
					   _porc_partic_suma
				  from rearucon
				 where cod_ruta = _cod_ruta

				insert into emireglo (
						no_poliza,
						no_endoso,
						orden,
						cod_contrato,
						porc_partic_prima,
						porc_partic_suma,
						suma_asegurada,
						prima,
						cod_ruta)
				values	(v_poliza,
						"00000",
						_orden,
						_cod_contrato,
						_porc_partic_prima,
						_porc_partic_suma,
						_ld_sum_aseg_2,
						0.00,
						_cod_ruta);
			end foreach
		end if

		foreach
		  select suma_aseg,
				  no_unidad
			 into _suma_aseg,
				  _no_unidad
			 from emireaut
			where no_poliza = v_poliza
			
			 call sp_pro82f(v_poliza,_no_unidad, _suma_aseg, '001',0) returning _error;
			 
		end foreach
		--
		update emireaut
		   set opcion_final = 0
		 where no_poliza = v_poliza;
			
		call sp_pro82c(v_poliza,0) returning _error,_error_desc; 

		select suma_asegurada
		  into _suma_asegurada
		  from emiporen
		 where no_poliza = v_poliza;
		 
		 foreach
		  select suma_aseg,
				  no_unidad
			 into _suma_aseg,
				  _no_unidad
			 from emireaut
			where no_poliza = v_poliza
			
			 call sp_pro82fa(v_poliza,_no_unidad, _suma_aseg, '001',0) returning _error;
	 
		end foreach
 
	end if	------ hasta aqui	
	
return _cambio;
	
end
end procedure;