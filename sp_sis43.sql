

create procedure sp_sis43(
a_no_poliza		char(10),
a_no_endoso		char(10),
a_vigen_desde	date,
a_vigen_hasta	date
)

if a_no_endoso = "00000" then

	update emipomae
	   set vigencia_inic  = a_vigen_desde,
	       vigencia_final = a_vigen_hasta
	 where no_poliza      = a_no_poliza;

	update emipouni
	   set vigencia_inic  = a_vigen_desde,
	       vigencia_final = a_vigen_hasta
	 where no_poliza      = a_no_poliza;

	update emireama
	   set vigencia_inic  = a_vigen_desde,
	       vigencia_final = a_vigen_hasta
	 where no_poliza      = a_no_poliza
	   and no_cambio      = 0;

end if

update endedmae
   set vigencia_inic      = a_vigen_desde,
       vigencia_final     = a_vigen_hasta,
       vigencia_inic_pol  = a_vigen_desde,
       vigencia_final_pol = a_vigen_hasta
 where no_poliza          = a_no_poliza
   and no_endoso          = a_no_endoso;

update endeduni
   set vigencia_inic      = a_vigen_desde,
       vigencia_final     = a_vigen_hasta
 where no_poliza          = a_no_poliza
   and no_endoso          = a_no_endoso;

end procedure
