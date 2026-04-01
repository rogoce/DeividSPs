-- Procedure que Vuelve a generar los asientos de reaseguro

--drop procedure sp_sac184;

create procedure sp_sac184()
returning integer,
          char(50);

define _periodo		char(7);
define _no_registro	char(10);
define _res_no_reg	integer;

let _periodo = "2010-04";

foreach
 select no_registro
   into _no_registro
   from sac999:reacomp
  where periodo >= _periodo

	update sac999:reacomp 
	   set sac_asientos = 0 
	 where no_registro  = _no_registro; 

end foreach

foreach
 select res_noregistro
   into _res_no_reg
   from cglresumen
  where res_origen   = "REA"
    and res_fechatrx >= "01/04/2010"

	delete from sac:cglresumen1 where res1_noregistro = _res_no_reg;
	delete from sac:cglresumen  where res_noregistro  = _res_no_reg;

end foreach

return 0, "Actualizacion Exitosa";

end procedure
