--drop procedure sp_cie01;

create procedure "informix".sp_cie01()

update cglperiodo
   set per_status = "A";

update cglperiodo
   set per_status = "C"
 where per_ano    <= "2004" ;

update cglparam
   set par_mesfiscal = "01",
       par_anofiscal = "2005";

end procedure