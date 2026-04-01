-- crear registros para programa de opciones en renovacion por primera vez.

-- CREADO: 		26/11/2004 POR: Armando
-- modificado:	13/01/2005 POR: Armando

drop procedure sp_pro82e;

create procedure sp_pro82e(
v_usuario			char(8),
v_poliza			char(10),
a_no_documento		char(20),
a_vigencia_final	date,
a_porc_depre_pol	dec(5,2)
)
returning	char(5),	--cod_producto
			char(10),	--_no_poliza
			char(5),	--no_unidad
			dec(16,2),	--suma depreciada
			integer;	--saber si se han usado los descuentos en las opciones

--- Actualizacion de Polizas
define _desc_limite1		char(50);
define _desc_limite2		char(50);
define _direccion_1			char(50);
define _direccion_2			char(50);
define _direcc_cob1			char(50);
define _direcc_cob2			char(50);
define _deducible			char(50);
define _no_motor			char(30);
define _no_documento		char(20);
define _no_tarjeta			char(19);
define _no_cuenta			char(17);
define _cod_manzana			char(15);
define _cod_pagador2		char(10);
define _cod_pagador			char(10);
define _telefono1			char(10);
define _telefono2			char(10);
define _no_poliza			char(10);
define _fecha_exp			char(7);
define _cod_cobertura		char(5);
define _cod_producto		char(5);
define _no_unidad			char(5);
define _cod_prod1			char(5);
define _cod_prod2			char(5);
define _unidad				char(5);
define ls_cod_perpago		char(3);
define _cod_tipoprod		char(3);
define _cod_formapag		char(3);
define _cod_perpago			char(3);
define _cod_subramo			char(3);
define _cod_origen			char(3);
define _cod_banco			char(3);
define _cod_ramo			char(3);
define _valor_asignar		char(1); 
define _tipo_tarjeta		char(1);
define _cobra_poliza		char(1);
define _tipo_cuenta			char(1);
define _porc_descuento1		dec(5,2);
define _porc_descuento2		dec(5,2);
define _porc_descuento		dec(5,2);
define _porc_depre_uni		dec(5,2);
define _porc_depre_pol		dec(5,2);
define _porc_depre			dec(5,2);
define _factor_vigencia		dec(9,6);
define _tarifa				dec(9,6);
define _suma_decimal		dec(16,2);
define _prima_anual			dec(16,2);
define _monto_visa			dec(16,2);
define _prima_neta			dec(16,2);
define _suma_difer			dec(16,2);
define _descuento			dec(16,2);
define _suma_ant			dec(16,2);
define _limite_1			dec(16,2);
define _limite_2			dec(16,2);
define ld_imp_r				dec(16,2);
define ld_imp_1				dec(16,2);
define ld_imp_2				dec(16,2);
define ld_imp_3				dec(16,2);
define _recargo				dec(16,2);
define _prima				dec(16,2);
define _imp					dec(16,2);
define r_anos				smallint;
define li_dia				smallint;
define _orden				smallint;
define li_mes				smallint;
define li_ano				smallint;
define li_meses				smallint;
define _tipo_incendio		smallint;
define _dia_cobros1			smallint;
define _dia_cobros2			smallint;
define li_no_pagos			smallint;
define _aplica_imp			smallint;
define _cantidad			smallint;
define _no_pagos			smallint;
define _leasing				smallint;
define _canti				smallint;
define _suma_asegurada		integer;
define _cant_unidades		integer;
define _anos_pagador		integer;
define ll_impuesto			integer;
define _fecha_primer_pago	date;
define ld_fecha_1_pago		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _cod_ramo_uni        char(3);
define _cod_prod_new        char(5);

define _ld_porc_depr	     dec(9,6);
define _ld_porc_depr2	     dec(9,6);
define _ld_sum_aseg_1	     dec(16,2);
define _ld_sum_aseg_2	     dec(16,2);
define _nuevo                smallint;
define _resultado		     integer;
define _ano_auto		     integer;
define _uso_auto		     char(1);
define _ano_actual		     smallint;
DEFINE _Factor_Vigencia_a    DEC(16,4);
DEFINE _Factor_Vigencia_b    DEC(16,4);
DEFINE _Factor_Vigenciax     DEC(16,4);
DEFINE v_vig_ini_pol         DATE;
DEFINE v_vig_fin_pol         DATE;
DEFINE v_vigen_ini           DATE;
define _chek_o               integer;
define _flag                 integer;
define _cob_requerida        integer;
define _cob_default          integer;
define _limite_1_ox		     dec(16,2);
define _limite_1_1x		     dec(16,2);
define _limite_1_2x		     dec(16,2);
define _tiene_cob            integer;
define _descuento_be        dec(5,2);
define _descuento_fl        dec(5,2);
define _texto               references text;
define _cod_tipoveh     char(3);


let _ano_actual = year(current);
let _ld_porc_depr2 = a_porc_depre_pol;
let _chek_o = 1;
let _cob_requerida = 1;
let _cob_default = 1;
let _limite_1_ox = 0;
let _limite_1_1x = 0;
let _limite_1_2x = 0;
let _tiene_cob = 0;

--if a_no_documento = '2318-00048-01' then
--	set debug file to "sp_pro82e.trc";
--	trace on;
--end if

begin
	select vigencia_final,
		   cod_pagador,
		   cod_tipoprod,
		   cod_origen,
		   cod_ramo,
		   cod_subramo,
		   no_documento,
		   fecha_primer_pago,
		   leasing
	  into a_vigencia_final,
		   _cod_pagador,
		   _cod_tipoprod,
		   _cod_origen,
		   _cod_ramo,
		   _cod_subramo,
		   _no_documento,
		   _fecha_primer_pago,
		   _leasing
	  from emipomae
	 where no_poliza = v_poliza;

	let _vigencia_inic  =  a_vigencia_final;
	let li_mes = month(_fecha_primer_pago);
	let li_dia = day(_fecha_primer_pago);
	let li_ano = year(a_vigencia_final);

	if li_mes = 2 then
		if li_dia > 28 then
			let li_dia = 28;
		end if
	end if

	let _fecha_primer_pago = mdy(li_mes, li_dia, li_ano);
	let li_mes = month(a_vigencia_final);
	let li_dia = day(a_vigencia_final);
	let li_ano = year(a_vigencia_final);

	if li_mes = 2 then
		if li_dia > 28 then
			let li_dia = 28;
		    let _vigencia_final = mdy(li_mes, li_dia, li_ano);
			let _vigencia_final = _vigencia_final + 1 units year;
		else
			let _vigencia_final = a_vigencia_final + 1 units year;
		end if
	else
		let _vigencia_final = a_vigencia_final + 1 units year;
	end if

	select direccion_1,
	       direccion_2,
		   telefono1,
		   telefono2
	  into _direccion_1,   
	       _direccion_2,
		   _telefono1,
		   _telefono2
	  from cliclien
	 where cod_cliente = _cod_pagador;

	select direccion_1,
	       direccion_2
	  into _direcc_cob1,
	       _direcc_cob2
	  from emidirco
	 where no_poliza = v_poliza;

	select count(*)
	  into _canti 
	  from emipolim
	 where no_poliza = v_poliza;

	select sum(p.factor_impuesto)
	  into ll_impuesto
	  from emipolim e, prdimpue p
	 where e.no_poliza    = v_poliza
	   and p.cod_impuesto = e.cod_impuesto;

	if ll_impuesto is null then
		let ll_impuesto = 0;
	end if

	if _canti = 0 then
		select aplica_impuesto
		  into _aplica_imp
		  from parorig
		 where cod_origen = _cod_origen;

		if _no_documento in("0218-00430-01","0210-01288-01","0213-03051-01",'2315-00106-01','2315-00107-01','0218-00354-12') then
			let _aplica_imp = 0;
		end if

		if _aplica_imp = 1 then
			select sum(p.factor_impuesto)
			  into ll_impuesto
			  from prdimpue p, prdimsub a
			 where p.cod_impuesto = a.cod_impuesto
			   and a.cod_ramo    = _cod_ramo
			   and a.cod_subramo = _cod_subramo;
		end if
	end if

	foreach
		select cod_producto,
			   no_unidad,
			   suma_asegurada,
			   tipo_incendio,
			   cod_formapag,
			   cod_perpago,
			   no_pagos,
			   --fecha_primer_pago,
			   tipo_tarjeta,
			   no_tarjeta,
			   fecha_exp,
			   cod_banco,
			   cobra_poliza,
			   no_cuenta,
			   tipo_cuenta,
			   cod_pagador,
			   dia_cobros1,
			   dia_cobros2,
			   anos_pagador,
			   monto_visa,
			   cod_manzana,
			   cod_ramo
		  into _cod_producto,
			   _no_unidad,
			   _suma_decimal,
			   _tipo_incendio,
			   _cod_formapag,
			   _cod_perpago,
			   _no_pagos,
			   --_fecha_primer_pago,
			   _tipo_tarjeta,
			   _no_tarjeta,
			   _fecha_exp,
			   _cod_banco,
			   _cobra_poliza,
			   _no_cuenta,
			   _tipo_cuenta,
			   _cod_pagador2,
			   _dia_cobros1,
			   _dia_cobros2,
			   _anos_pagador,
			   _monto_visa,
			   _cod_manzana,
			   _cod_ramo_uni
		  from emipouni
		 where no_poliza = v_poliza		 

		--Busqueda de producto nuevo
{		let _cod_prod_new = null;
		
		select producto_nuevo
		  into _cod_prod_new
		  from prdnewpro3
		 where cod_producto = _cod_producto
		   and activo = 1;
		 
		if _cod_prod_new is not null then
			let _cod_producto = _cod_prod_new;			
		end if
}		 
		if _cod_pagador2 is null then
			let _cod_pagador2 = _cod_pagador;
		end if
		
		let _suma_asegurada = _suma_decimal;
		let _cod_prod1 = null;
		let _cod_prod2 = null;
		if _cod_ramo = '024' then
			if _cod_ramo_uni = '020' then
				let ll_impuesto = 6;
			else
				let ll_impuesto = 5;
			end if
		end if
		
		let _ld_sum_aseg_1 = _suma_asegurada; --//H*Giron31/05/2020,CASO:34750 USER: JEPEREZ 	inicio
		let _ld_sum_aseg_2 = _suma_asegurada;
		let a_porc_depre_pol = _ld_porc_depr2;	
		
		if _cod_ramo in ('023') then	--'002',preguntar		 
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
				and no_unidad = _no_unidad
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
				   and no_unidad = _no_unidad;

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
					let a_porc_depre_pol = _ld_porc_depr ;	
			
					if 	_ld_sum_aseg_1 is null then
						let _ld_sum_aseg_1  = 0;
					end if

					let _ld_sum_aseg_2 = _ld_sum_aseg_1 - (_ld_sum_aseg_1 *  (_ld_porc_depr/100));	

					foreach 
						select cod_cobertura, cob_requerida, cob_default	
						  into _cod_cobertura, _cob_requerida, _cob_default
						  from prdcobpd
						 where cod_producto = _cod_producto							  

						   let _flag = 0;
						   let _chek_o = 0;
						  select count(*)
							into _flag
						   from prdcober 
						  where cod_cobertura in (_cod_cobertura)						  
							and ( upper(trim(nombre)) like 'INCENDIO'
							   OR upper(trim(nombre)) like 'ROBO'
							   OR upper(trim(nombre)) like 'COLISION O VUELCO' OR upper(trim(nombre)) like 'COLISION Y VUELCO'
							   OR upper(trim(nombre)) like 'COMPRENSIVO'
								);
								
							 if _flag is NULL then
								 LET _flag = 0;
							end if
							
							if _flag = 0 then		
							
								  select limite_1_o,limite_1_1,limite_1_2 --,factor_vigencia	
									into _limite_1_ox,_limite_1_1x,_limite_1_2x --,_factor_vigenciax							
									from emireau1
								   where no_poliza = v_poliza
									 and no_unidad = _no_unidad
									 and cod_cobertura = _cod_cobertura;
							 else
								   let _limite_1_ox = _ld_sum_aseg_2; 
								   let _limite_1_1x = _ld_sum_aseg_2;
								   let _limite_1_2x = _ld_sum_aseg_2;
							 end if
							 
								if _cob_requerida = 1 then  -- hg:18-6-2020
								   let _chek_o = 1;
								else
								   let _chek_o = 0;
								   let _no_unidad = _no_unidad;
								   let _cod_producto = _cod_producto;
								   let _cod_cobertura = _cod_cobertura;
								end if
								
								if _chek_o = 0 then
										let _tiene_cob = 0;							
									 select count(*)
									   into _tiene_cob
									   from emipocob   
									  where no_poliza = v_poliza
										and no_unidad = _no_unidad
										and cod_cobertura = _cod_cobertura;
									  
									 if _tiene_cob is NULL then
										 LET _tiene_cob = 0;
									end if	
									 if _tiene_cob <>  0 then
										 let _chek_o = 1;
									end if									
									  
								end if

									
							update emireau1 
								set limite_1_o = _limite_1_ox, 
								   limite_1_1  = _limite_1_1x, 
								   limite_1_2  = _limite_1_2x,
								   factor_vigencia = _Factor_Vigenciax,
								   chek_o = _chek_o
							 where no_poliza = v_poliza
							   and no_unidad = _no_unidad
							   and trim(cod_cobertura) = trim(_cod_cobertura);		   
		
							   
					end foreach		



				if _cod_ramo = '023' then	----- inicia	        
					delete from emiredes
					 where no_poliza = v_poliza
					   and no_unidad = _no_unidad;
					   
					select descuento_be,
						   descuento_fl
					  into _descuento_be,
						   _descuento_fl
					  from prdprod
					 where cod_producto = _cod_producto;
					
					delete from emirede0
					 where no_poliza = v_poliza
					   and no_unidad = _no_unidad
					   and cod_descuen = '001';
				
					delete from emirede1
					 where no_poliza = v_poliza
					   and no_unidad = _no_unidad
					   and cod_descuen = '001';
					   
					delete from emirede2
					 where no_poliza = v_poliza
					   and no_unidad = _no_unidad
					   and cod_descuen = '001';
					   
					if _descuento_be > 0 then   
						insert into emirede0(
						 no_poliza,
						 no_unidad,
						 cod_descuen,
						 porc_descuento)
						 values (
						 v_poliza,
						 _no_unidad,
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
						 _no_unidad,
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
						 _no_unidad,
						 '001',
						 _descuento_be
						 );
					end if
					
									 
					delete from emirede0
					 where no_poliza = v_poliza
					   and no_unidad = _no_unidad
					   and cod_descuen = '002';
				
					delete from emirede1
					 where no_poliza = v_poliza
					   and no_unidad = _no_unidad
					   and cod_descuen = '002';
					   
					delete from emirede2
					 where no_poliza = v_poliza
					   and no_unidad = _no_unidad
					   and cod_descuen = '002';
						   
					if _descuento_fl > 0 then		   
						   
						insert into emirede0(
						 no_poliza,
						 no_unidad,
						 cod_descuen,
						 porc_descuento)
						 values (
						 v_poliza,
						 _no_unidad,
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
						 _no_unidad,
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
						 _no_unidad,
						 '002',
						 _descuento_fl
						 );
					end if
					
					let _texto = null;
					
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
					_no_unidad,
					_texto);			
				end if	------ hasta aqui						
			 
		end if	--//H*Giron31/05/2020,CASO:34750 USER: JEPEREZ fin	 

		select ((sum(prima_neta_o) * ll_impuesto) / 100),
			   ((sum(prima_neta_1) * ll_impuesto) / 100),
			   ((sum(prima_neta_2) * ll_impuesto) / 100),
			   ((sum(prima_neta_3) * ll_impuesto) / 100)
		  into ld_imp_r,
			   ld_imp_1,
			   ld_imp_2,
			   ld_imp_3
		  from emireau1
		 where no_poliza = v_poliza
		   and no_unidad = _no_unidad;

		insert into emireaut(
		no_poliza,
		cod_asegurado,
		vigencia_inic,
		vigencia_final,
		suma_aseg,
		estatus_ren,
		cod_producto,
		cod_product1,
		cod_product2,
		opcion_final,
		user_added,
		no_documento,
		direccion_1,
		direccion_2,
		telefono1,
		telefono2,
		direcc_cob1,
		direcc_cob2,
		suma_aseg_anterior,
		porc_depreciacion,
		impuesto_o,
		impuesto_r,
		impuesto_1,
		impuesto_2,
		no_unidad,
		cod_no_renov,
		cod_tipoprod,
		tipo_incendio,
		cod_formapag,
		cod_perpago,
		no_pagos,
		fecha_primer_pago,
		tipo_tarjeta,
		no_tarjeta,
		fecha_exp,
		cod_banco,
		cobra_poliza,
		no_cuenta,
		tipo_cuenta,
		cod_pagador,
		dia_cobros1,
		dia_cobros2,
		anos_pagador,
		monto_visa,
		cod_manzana,
		leasing
		)
		values (v_poliza,
			   _cod_pagador,
		       _vigencia_inic,
		       _vigencia_final,
			   _ld_sum_aseg_2,   --_suma_decimal, -- hg09062020
			   1,
			   _cod_producto,
			   null,
			   null,
			   9,
		       v_usuario,
			   a_no_documento,
			   _direccion_1,
			   _direccion_2,
			   _telefono1,
			   _telefono2,
			   _direcc_cob1,
			   _direcc_cob2,
			   _ld_sum_aseg_1,   --_suma_decimal, --hg09062020
			   a_porc_depre_pol,
			   ld_imp_3,
			   ld_imp_r,
			   ld_imp_1,
			   ld_imp_2,
			   _no_unidad,
			   null,
			   _cod_tipoprod,
			   _tipo_incendio,
			   _cod_formapag,
			   _cod_perpago,
			   _no_pagos,
			   _fecha_primer_pago,
			   _tipo_tarjeta,
			   _no_tarjeta,
			   _fecha_exp,
			   _cod_banco,
			   _cobra_poliza,
			   _no_cuenta,
			   _tipo_cuenta,
			   _cod_pagador2,
			   _dia_cobros1,
			   _dia_cobros2,
			   _anos_pagador,
			   _monto_visa,
			   _cod_manzana,
			   _leasing
			   );  


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
			   and no_unidad = _no_unidad;
	end foreach

	foreach
		select no_unidad,
			   cod_producto
		  into _no_unidad,
			   _cod_producto
		  from emireaut
		 where no_poliza = v_poliza
		 order by 1
	  exit foreach;
	end foreach

	return _cod_producto,
	       v_poliza,					  
		   _no_unidad, 
		   0,
		   0;
end
end procedure;