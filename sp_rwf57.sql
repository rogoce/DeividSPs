-- Procedimiento para sacar el limite medio para la firma electronica.
-- 
-- creado: 20/12/2004 - Autor: Amado Perez.

DROP PROCEDURE sp_rwf57;
CREATE PROCEDURE "informix".sp_rwf57() 
			RETURNING DEC(16,2);  

DEFINE v_ld_lim_med			DEC(16,2);

SET ISOLATION TO DIRTY READ;

--set debug file to "sp_rwf37.trc";
--trace on;

	select valor_parametro
	  into v_ld_lim_med
	  from inspaag
	 where codigo_compania  = '001'
	   and codigo_agencia   = '001'
		and aplicacion       = 'CHE'
		and version          = '02'
		and codigo_parametro = "lim_med_firma";


-- rollback work;

 RETURN v_ld_lim_med;
END PROCEDURE