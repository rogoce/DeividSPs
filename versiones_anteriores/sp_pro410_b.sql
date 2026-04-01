-- diario pma_asistencia detalle por subramo
-- Creado    : 09/03/2023 - Autor: HGIRON
-- SIS v.2.0 - - DEIVID, S.A.
DROP PROCEDURE sp_pro410b;
CREATE PROCEDURE "informix".sp_pro410b()
returning VARCHAR(100) as desc_ramo,
			VARCHAR(100) as desc_subramo,
			VARCHAR(10) as desc_cantidad;


DEFINE _desc_ramo  VARCHAR(100);
DEFINE _desc_subramo VARCHAR(100);
DEFINE _desc_cantidad  VARCHAR(10);
define _blanquear VARCHAR(100);
DEFINE _desc_ramo2  VARCHAR(100);
define _cant1,_cant2 smallint;

--set debug file to "sp2_pro410.trc";
--trace on;

drop table if exists tmp_notramsub_1;
drop table if exists tmp_notramsub_2;
SET ISOLATION TO DIRTY READ;
let _blanquear = '';
let _desc_ramo2 = '';
let _cant1 = 0;
let _cant2  = 0;
select desc_ramo,		
		sum(cantidad) cantidad
 from notramsub
 group by 1 order by 1
  into temp tmp_notramsub_1; 

select desc_ramo,desc_subramo,
		sum(cantidad) cantidad
 from notramsub
 group by 1,2 order by 1
 into temp tmp_notramsub_2; 
 
foreach
	select desc_ramo,cantidad
	  into _desc_ramo,_cant1
	  from tmp_notramsub_1	
     order by upper(trim(desc_ramo)) 
	 
       let _desc_ramo2 = "Unidades de Ramo "||upper(trim(_desc_ramo))||" : "||cast(_cant1 as varchar(10));	 
	   
		foreach
			select "       Unidades de Subramo "||upper(trim(desc_subramo))||" : ",cantidad  -- ||"    "||cast(cantidad as varchar(10))
			into _desc_subramo,_cant2
			 from tmp_notramsub_2	
			 where desc_ramo = _desc_ramo
			 order by upper(trim(desc_subramo)) 
			 
			 let _desc_cantidad = cast(_cant2 as varchar(10));
 
			let _desc_ramo2 = _desc_ramo2;	 
			let _desc_ramo = _desc_ramo;
				
			RETURN  _desc_ramo2,
				_desc_subramo,
                _desc_cantidad				
				WITH RESUME;

			let _desc_ramo2 = '';					
			

		end foreach
end foreach		

return '','','';
--DROP TABLE tmp_notramsub;
END PROCEDURE;