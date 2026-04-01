-- 

-- CREADO: 		26/11/2004 POR: Armando
-- modificado:	13/01/2005 POR: Armando

drop procedure sp_proe90x;
create procedure "informix".sp_proe90x(a_producto char(5),a_poliza char(10), a_unidad char(5), a_suma DEC(16,2))
returning	smallint;	--saber si se han usado los descuentos en las opciones

define _cod_producto, _cod_prod_new, _cod_producto_ori char(5);
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
define _deducible           dec(16,2);
define _desc_limite1		varchar(50);
define _desc_limite2		varchar(50);
define _cambio              smallint;
define _no_documento        char(20);
define _descuento_be        dec(5,2);
define _descuento_fl        dec(5,2);
define _texto               references text;
define _error               integer;
define _cant_cob            smallint;
define _cant_tasec          smallint;
define _busqueda            char(1);
define _ramo_sis            smallint;
define _capacidad           smallint;

define li_orden, li_factor_div, li_tipo_deducible,li_tipo_descuento,li_acepta_desc,li_anos,li_capacidad,li_tipo_recargo,li_no_pagos,li_ano_auto,li_Rtn integer;
define ls_valor_asignar, ls_tipo_valor, ls_busqueda  char(1);
define ls_cobertura char(5);
define ls_deducible,ls_desc1,ls_desc2 varchar(50);
define ls_no_motor char(30);
define ld_tarifa, ld_porc_suma, ld_deducible, ld_deducible_min, ld_val_min, ld_val_max, ld_descuento_max, ld_prima_anual, ld_rango1, ld_rango2,ld_prima,ld_factor_vigencia,ld_prima_resta,ld_descuento,ld_recargo,ld_prima_neta dec(16,2);
define _error_isam			integer;
define _error_desc			char(100);


let _cambio = 0;
let _texto = null;
let li_Rtn = 0;
--- Actualizacion de Polizas
--IF v_poliza = '0001065914' AND a_unidad = '00001' THEN
--  set debug file to "sp_pro561.trc";
--  trace on;
--END IF

begin
on exception set _error,_error_isam,_error_desc 
 	return _error;	
end exception

select factor_vigencia
  into ld_factor_vigencia
  from emipomae
 where no_poliza = a_poliza;

foreach

	select cod_producto,
		   no_unidad,
		   suma_asegurada
	  into a_producto,
		   a_unidad,
		   a_suma
	  from emipouni
	 where no_poliza = a_poliza
	   and no_unidad >= '01500'

  
	FOREACH
		SELECT cod_cobertura,
			   orden,
			   valor_asignar,
			   tipo_valor,
			   factor_division,
			   busqueda,
			   porc_suma,
			   tipo_deducible,
			   deducible,
			   deducible_min,
			   tipo_descuento,
			   val_min,
			   val_max,
			   desc_limite1,
			   desc_limite2,
			   acepta_desc
		 INTO  ls_cobertura,
			   li_orden,
			   ls_valor_asignar, 
			   ls_tipo_valor,
			   li_factor_div,
			   ls_busqueda,
			   ld_porc_suma,
			   li_tipo_deducible,
			   ld_deducible,
			   ld_deducible_min,
			   li_tipo_descuento,
			   ld_val_min,
			   ld_val_max,
			   ls_desc1,
			   ls_desc2,
			   li_acepta_desc
		  FROM prdcobpd
		 WHERE cod_producto = a_producto
		   AND cob_default = 1
		   
		let ld_descuento_max = 0.00;
		
		if ls_busqueda = "1" then
			select count(*)
			  into _cant_cob
			  from  prdtasec
			 where cod_producto = a_producto
			   and cod_cobertura = ls_cobertura;
			   
			 if _cant_cob = 1 then
				select valor,
					   rango_monto1,
					   rango_monto2				   
				  into ld_tarifa,
					   ld_rango1,
					   ld_rango2
				  from prdtasec
				 where cod_producto = a_producto
				   and cod_cobertura = ls_cobertura;
				   
				If ls_tipo_valor = "P" Then
					let ld_prima_anual = ld_tarifa;
				Else
					If li_factor_div > 0 Then
						let ld_tarifa = ld_tarifa / li_factor_div;
						let ld_prima_anual = ld_tarifa * a_suma;
					End If
				End If

				if ls_valor_asignar = "S" then
					let ld_rango1 = 0.00;
					let ld_rango2 = 0.00;
						let ld_rango1 = a_suma * ld_porc_suma / 100;
						if ld_val_min > 0 and ld_val_max > 0 then	
							if ld_rango1 < ld_val_min then		
								let ld_rango1 = ld_val_min;	
							end if	
							if ld_rango1 > ld_val_max then	
								let ld_rango1 = ld_val_max;	
							end if	
						end if		
				End if
						
						
				If ld_deducible is null Then
					LET ld_deducible = 0.00;
				End If
				
				let ls_deducible = ld_deducible;
				
				let ld_prima = ld_factor_vigencia * ld_prima_anual;

				let ld_prima_resta = ld_prima;
				
				-- Buscar Descuento
				let ld_descuento = 0.00;
				If li_acepta_desc = 1 Then
					LET ld_descuento = sp_proe21(a_poliza, a_unidad, ld_prima);
				End If

				If ld_descuento > 0 Then
					let ld_prima_resta = ld_prima - ld_descuento;
				End If

				-- Buscar Recargo
				let ld_recargo = 0.00;
				If li_acepta_desc = 1 Then
					LET ld_recargo = sp_proe22(a_poliza, a_unidad, ld_prima_resta);
				End If
				
				-- Calcular Prima Neta
				LET ld_prima_neta = ld_prima + ld_recargo - ld_descuento;
				
				Insert Into emipocob (no_poliza, no_unidad, cod_cobertura, orden, tarifa, 
										 deducible, limite_1, limite_2, prima_anual, prima, 
										 descuento, recargo, prima_neta, date_added, 
										 date_changed, factor_vigencia, desc_limite1, 
										 desc_limite2)		
				Values (a_poliza, a_unidad, ls_cobertura, li_orden, 0, 
						ls_deducible, ld_rango1, ld_rango2, ld_prima_anual, ld_prima, 
						ld_descuento, ld_recargo, ld_prima_neta, today, 
						today, ld_factor_vigencia, ls_desc1, ls_desc2);
			End If
		End If
	END FOREACH

	let li_Rtn = sp_proe04x(a_poliza, a_unidad, a_suma, '001');
end foreach	

return li_Rtn;
end
end procedure;