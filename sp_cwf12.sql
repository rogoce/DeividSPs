-- Procedimiento para sacar el limite minimo y maximo especial de descentralizacion para la firma electronica salud.
-- 
-- creado: 03/09/2009 - Autor: Amado Perez.

DROP PROCEDURE sp_cwf12;
CREATE PROCEDURE "informix".sp_cwf12() 
			RETURNING DEC(16,2), DEC(16,2);  

DEFINE v_ld_lim_max			DEC(16,2);
DEFINE v_ld_lim_min			DEC(16,2);

SET ISOLATION TO DIRTY READ;

--set debug file to "sp_rwf37.trc";
--trace on;

	select valor_parametro
	  into v_ld_lim_min
	  from inspaag
	 where codigo_compania  = '001'
	   and codigo_agencia   = '001'
		and aplicacion       = 'CHE'
		and version          = '02'
		and codigo_parametro = "min_aut_salud";

	select valor_parametro
	  into v_ld_lim_max
	  from inspaag
	 where codigo_compania  = '001'
	   and codigo_agencia   = '001'
		and aplicacion       = 'CHE'
		and version          = '02'
		and codigo_parametro = "max_aut_salud";

-- rollback work;

 RETURN v_ld_lim_min, v_ld_lim_max;
END PROCEDURE