-- Actualizacion de los casos
-- 
-- Creado    : 03/08/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - ASEGURADORA ANCON, S.A.

DROP PROCEDURE sp_pro82e_unidad2;

create procedure "informix".sp_pro82e_unidad2(
a_poliza CHAR(10),
a_unidad CHAR(5))
returning     integer;

define _error	integer;
define _factor_vigencia dec(9,6);

--SET DEBUG FILE TO "sp_rwf62.trc";
--TRACE ON ;

set lock mode to wait 60;

begin
on exception set _error
	return _error;
end exception

delete from	emireau1 where no_poliza = a_poliza;

select factor_vigencia Into _factor_vigencia from emipomae where no_poliza = a_poliza;

Insert Into emireau1 (no_poliza, no_unidad, cod_cobertura, orden, chek_o, 
					 deducible_o, limite_1_o, limite_2_o, prima_anual_o, prima_o, 
					 descuento_o, recargo_o, prima_neta_o, chek_1, 
					 deducible_1, limite_1_1, limite_2_1, prima_anual_1, prima_1, 
					 descuento_1, recargo_1, prima_neta_1, chek_2, 
					 deducible_2, limite_1_2, limite_2_2, prima_anual_2, prima_2, 
					 descuento_2, recargo_2, prima_neta_2, 
					 deducible_3, limite_1_3, limite_2_3, prima_anual_3, prima_3,
					 descuento_3, recargo_3, prima_neta_3, 
					 factor_vigencia, desc_limite1, desc_limite2)
			select a_poliza, a_unidad, cod_cobertura,orden, 1, 
			       deducible,limite_1,limite_2,prima_anual,prima, 
				   descuento,recargo,prima_neta, 1,
			       deducible,limite_1,limite_2,prima_anual,prima, 
				   descuento,recargo,prima_neta, 1,
			       deducible,limite_1,limite_2,prima_anual,prima, 
				   descuento,recargo,prima_neta, 
			       deducible,limite_1,limite_2,prima_anual,prima, 
				   descuento,recargo,prima_neta, 
				   _factor_vigencia,desc_limite1,desc_limite2
			  from emipocob
			 where no_poliza     = a_poliza
				and no_unidad     = a_unidad ;

end

return 0;

end procedure
