--drop procedure unidad;

create procedure "informix".unidad(
) RETURNING   INTEGER;


define _error	   integer;	

BEGIN
ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION


				INSERT INTO emireau2(
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
				desc_limite2,
				requerida_0)
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
					desc_limite2,
					requerida_0
				  from emireau1
				 where no_poliza = "184549"
				   and no_unidad = "00003";
return 0;
END
end procedure;