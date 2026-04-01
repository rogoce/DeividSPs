drop procedure sp_sac146;

create procedure sp_sac146()
returning integer,
          char(50);

define _cuenta		char(25);
define _referencia	char(20);

foreach
 select cuenta,
        referencia
   into _cuenta,
        _referencia
   from deivid_tmp:referencia_cuentas
	
	update sac006:cglcuentas
	   set referencia = _referencia
	 where cta_cuenta = _cuenta;

end foreach

return 0, "Actualizacion Existosa";

end procedure 