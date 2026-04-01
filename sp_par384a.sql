
DROP PROCEDURE sp_par384a;
CREATE PROCEDURE "informix".sp_par384a(a_flag smallint, a_fecha date)
	RETURNING 	  SMALLINT, varchar(50);  --Sucessful
SET ISOLATION TO DIRTY READ;
if a_flag = 1 then
	delete from MigrarReclamos;
elif a_flag = 0 then
	    insert into MigrarReclamos
 
		select distinct rec.no_reclamo
		  from rectrmae trx
		 inner join recrcmae rec
				 on trx.no_reclamo = rec.no_reclamo
				and trx.fecha = a_fecha --and trx.fecha between '21/10/2024' and today
				and trx.actualizado = 1
		 inner join emipomae emi
				 on emi.no_poliza = rec.no_poliza
				and emi.cod_ramo in ('002','020','023','001','005','006','007','009','010','011','012','013','014','015','021','022','003','017')
		   left join MigrarReclamos mig on mig.no_reclamo = rec.no_reclamo
		  where mig.no_reclamo is null
		    and rec.yoseguro = 0; 
end if
return 0, 'Proceso Exitoso';
END PROCEDURE 	
