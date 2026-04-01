-- Procedimiento para Cargar las pólizas desde Deivid a Temis.
-- creado: 10/06/2024 - Autor: Amado Perez M.

DROP PROCEDURE sp_par384;
CREATE PROCEDURE "informix".sp_par384(a_flag smallint, a_fecha date)
	RETURNING 	  SMALLINT, varchar(50);  --Incurrido bruto

DEFINE _cod_mala_refe        CHAR(3);
DEFINE _mala_referencia      SMALLINT;
DEFINE _bloqemirenaut      SMALLINT;

SET ISOLATION TO DIRTY READ;

if a_flag = 1 then
	delete from MigrarPolizas;
elif a_flag = 0 then
	    insert into MigrarPolizas 
		select distinct  fac.no_poliza
		  from emipomae emi
		 inner join endedmae fac
				 on emi.no_poliza = fac.no_poliza
				and emi.cod_ramo in ('002','020','023','001','005','006','007','009','010','011','012','013','014','015','021','022','003','017')
				and (fac.fecha_emision = a_fecha or fac.no_poliza in (select no_poliza from deivid_tmp:tmp_mig_poliza))
				and fac.actualizado = 1
				and fac.no_factura like '%-%'
		 inner join endeduni uni
				 on uni.no_poliza = fac.no_poliza
				and uni.no_endoso = fac.no_endoso
		 inner join prdprod prd
				 on prd.cod_producto = uni.cod_producto
		 inner join prdramo ram
				 on ram.cod_ramo = emi.cod_ramo
		 inner join prdsubra sub
				 on sub.cod_ramo = emi.cod_ramo
				and sub.cod_subramo = emi.cod_subramo
		  left join MigrarPolizas mig on mig.no_poliza = fac.no_poliza
		 where mig.no_poliza is null;
end if

return 0, 'Proceso Exitoso';
END PROCEDURE
