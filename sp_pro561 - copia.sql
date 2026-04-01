-- crear registros para programa de opciones en renovacion por primera vez.

-- CREADO: 		26/11/2004 POR: Armando
-- modificado:	13/01/2005 POR: Armando

drop procedure sp_pro561;

create procedure "informix".sp_pro561(v_poliza char(10), a_unidad char(5))
returning	smallint;	--saber si se han usado los descuentos en las opciones

define _cod_producto, _cod_prod_new char(5);
define _factor_vigencia 	dec(9,6);
define _cod_ramo 			char(3);
define _suma_aseg 			dec(16,2);
define _no_motor 			char(30);
define _uso_auto 			char(1);
define _cod_marca 			char(5);
define _cod_cobertura 		char(5);
define _ld_tarifa 			dec(16,2);
define _ld_prima 			dec(16,2);
define _ld_prima_deduc 		dec(16,2);
define _ld_deduc_nuevo		varchar(50);
define _orden 				smallint;
define _limite_1			dec(16,2);
define _limite_2			dec(16,2);
define _descuento			dec(16,2);
define _recargo				dec(16,2);
define _desc_limite1		varchar(50);
define _desc_limite2		varchar(50);
define _cambio              smallint;

let _cambio = 0;

--- Actualizacion de Polizas

--set debug file to "sp_pro561.trc";
--trace on;

begin
	select cod_ramo,
		   factor_vigencia
	  into _cod_ramo,
		   _factor_vigencia
	  from emipomae
	 where no_poliza = v_poliza;
 
   select suma_aseg,
          cod_producto
     into _suma_aseg,
	      _cod_producto
     from emireaut
    where no_poliza = v_poliza
	  and no_unidad = a_unidad;
	  
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
	 
	if _cod_prod_new is not null then
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
		   
        foreach with hold
			select cod_cobertura,
			       orden,
				   limite_1,
				   limite_2,
				   desc_limite1,
				   desc_limite2
			  into _cod_cobertura,
			       _orden,
				   _limite_1,
				   _limite_2,
				   _desc_limite1,
				   _desc_limite2
			  from emipocob
			 where no_poliza     = v_poliza
				and no_unidad    = a_unidad
				
			let _ld_tarifa = 0;
			let _ld_prima_deduc = 0;
			let _descuento = 0;
			let _recargo = 0;
			let _ld_deduc_nuevo = 0.00;
			let _ld_prima = 0;

			call sp_pro51t(v_poliza, _cod_producto, _cod_ramo, a_unidad,  _cod_cobertura,  _suma_aseg) returning _ld_tarifa;       --prima anual
			call sp_pro563(v_poliza, _cod_producto, _cod_ramo, a_unidad,  _cod_cobertura,  _suma_aseg) returning _ld_prima_deduc, _descuento, _recargo;	--prima neta
			call sp_pro51u(v_poliza, _cod_producto, _cod_ramo, a_unidad,  _cod_cobertura,  _cod_marca, _suma_aseg, _ld_tarifa, _uso_auto) returning _ld_deduc_nuevo;	--deducible
			
			let _ld_prima = _ld_tarifa * _factor_vigencia / 100;
			
			update emireau1 
			   set orden = _orden, 
				   chek_o = 1, 
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
			  					  
{			Insert Into emireau1 (no_poliza, no_unidad, cod_cobertura, orden, chek_o, 
										 deducible_o, limite_1_o, limite_2_o, prima_anual_o, prima_o, 
										 descuento_o, recargo_o, prima_neta_o, chek_1, 
										 deducible_1, limite_1_1, limite_2_1, prima_anual_1, prima_1, 
										 descuento_1, recargo_1, prima_neta_1, chek_2, 
										 deducible_2, limite_1_2, limite_2_2, prima_anual_2, prima_2, 
										 descuento_2, recargo_2, prima_neta_2, 
										 deducible_3, limite_1_3, limite_2_3, prima_anual_3, prima_3, 
										 descuento_3, recargo_3, prima_neta_3, 
										 factor_vigencia, desc_limite1, desc_limite2)
			Values (v_poliza, a_unidad, _cod_cobertura, _orden, 1, 
					  _ld_deduc_nuevo, _limite_1, _limite_2, _ld_tarifa, _ld_prima, 
					  _descuento, _recargo, _ld_prima_deduc, 1, 
					  _ld_deduc_nuevo, _limite_1, _limite_2, _ld_tarifa, _ld_prima, 
					  _descuento, _recargo, _ld_prima_deduc, 1, 
  					  _ld_deduc_nuevo, _limite_1, _limite_2, _ld_tarifa, _ld_prima, 
					  _descuento, _recargo, _ld_prima_deduc, 
  					  _ld_deduc_nuevo, _limite_1, _limite_2, _ld_tarifa, _ld_prima, 
					  _descuento, _recargo, _ld_prima_deduc, 
					  _factor_vigencia, _desc_limite1, _desc_limite2);
}			
		end foreach

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
		
	end if
				
	return _cambio;
	

end
end procedure;