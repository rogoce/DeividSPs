-- Pool de logistica para cancelacion - estados impresion 1 - 2 - 3  
-- Creado		: 16/2/2016 - Autor: Henry Giron.  
-- execute procedure sp_log006("I") 
--drop procedure pr1009 

drop procedure sp_log006; 
create procedure "informix".sp_log006(a_estatus char(1) default "I")  
              returning char(15),  
						char(55),  
						char(15), 
						date, 
						float, 
						int, 
						char(15),  
						date,  
						char(1);  

define _no_aviso        char(15); 
define _nombre_ramo     char(55); 
define _user_proceso    char(15); 
define _fecha_proceso   date; 
define _sum_saldo       float; 
define _count_no_poliza int; 
define _user_imp_aviso_log char(15); 
define _date_imp_aviso_log date; 
define _estatus	 char(1);

set isolation to dirty read;  	 
foreach  
 select d.no_aviso, 
           a.nombre, 
		   d.user_proceso, 
		   d.fecha_proceso, 
		   sum(d.saldo), 
		   count(distinct d.no_poliza), 
		   d.user_imp_aviso_log,
		   d.date_imp_aviso_log,
		   d.estatus
      into _no_aviso,
           _nombre_ramo,
           _user_proceso,
           _fecha_proceso,
           _sum_saldo,
           _count_no_poliza,
           _user_imp_aviso_log,
           _date_imp_aviso_log,
           _estatus		   
	  from avicanpar a, avisocanc d
     where d.estatus in ('I') --,'Y')
       and (d.imp_aviso_log = 0 or d.imp_aviso_log is null)
       and a.cod_avican = d.no_aviso
     group by d.no_aviso,a.nombre,d.user_proceso,d.fecha_proceso,d.user_imp_aviso_log,d.date_imp_aviso_log,d.estatus	 
	 order by d.estatus asc,1,2,3,4
	 
	return _no_aviso,
           _nombre_ramo,
           _user_proceso,
           _fecha_proceso,
           _sum_saldo,
           _count_no_poliza,
           _user_imp_aviso_log,
           _date_imp_aviso_log,           
           _estatus
		   with resume;

end foreach
end procedure



   




























































































