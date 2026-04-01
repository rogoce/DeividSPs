
drop procedure sp_par81;

create procedure sp_par81(
a_no_poliza			char(10),
a_vigencia_inic		date,
a_vigencia_final	date
)

update emipomae
   set vigencia_inic  = a_vigencia_inic,
       vigencia_final = a_vigencia_final
 where no_poliza      = a_no_poliza;

update emipouni
   set vigencia_inic  = a_vigencia_inic,
       vigencia_final = a_vigencia_final
 where no_poliza      = a_no_poliza;

update endedmae
   set vigencia_inic      = a_vigencia_inic,
       vigencia_final     = a_vigencia_final,
       vigencia_inic_pol  = a_vigencia_inic,
       vigencia_final_pol = a_vigencia_final
 where no_poliza          = a_no_poliza
   and no_endoso          = "00000";

update endeduni
   set vigencia_inic      = a_vigencia_inic,
       vigencia_final     = a_vigencia_final
 where no_poliza          = a_no_poliza
   and no_endoso          = "00000";

update emireama
   set vigencia_inic      = a_vigencia_inic,
       vigencia_final     = a_vigencia_final
 where no_poliza          = a_no_poliza
   and no_cambio          = 0;

end procedure
