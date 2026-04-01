--- Validar cumpla condiciones 002 y 023
--- Creado 30/01/2017 por Henry
drop procedure sp_sis500;
create procedure "informix".sp_sis500(a_poliza char(10))
returning integer;

begin

define _cod_ramo    char(3);
define _nueva_renov char(1);
define _vigencia_inic  date;
define _fecha_hoy   date;

-- SET DEBUG FILE TO "sp_sis500.trc"; 
-- TRACE ON;                                                                
set isolation to dirty read;
--return 0;

let _fecha_hoy    = CURRENT ;
   -- solo renovaciones antes del 14/3/2017. Ley SOBAT, se tomara vigencia desde 14 de Marzo de 2017
	select nueva_renov,
	       cod_ramo,
           vigencia_inic		   
	  into _nueva_renov,
	       _cod_ramo,
		   _vigencia_inic
	  from emipomae
	 where no_poliza = a_poliza;
	 
   -- solo ramos 002, 020 y 023	 
	 if _cod_ramo not in ('002','023','020') then
	    return 0;	 
	 end if	 	 
	if _fecha_hoy < '14/03/2017' then  
			if _vigencia_inic < '14/03/2017' then
				return 0;
			end if	 			
			if _nueva_renov <> 'R' then			     
				return 0;
			end if	 			
	end if
	return 1;
end 

end procedure;
