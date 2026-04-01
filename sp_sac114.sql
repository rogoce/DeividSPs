-- Procedure que cambia el Centro de Costos en cobasien

-- Creado    : 13/09/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac114;

create procedure sp_sac114()
returning smallint,
          char(50);
		  
define _cuenta		char(25);
define _fechatrx	date;
define _notrx		integer;

define _no_remesa	char(10);
define _renglon		smallint;

set isolation to dirty read;

foreach
 select res_cuenta,
		res_notrx
   into _cuenta,
		_notrx
   from cglresumen
  where res_origen         = "COB"
	and year(res_fechatrx) = 2009
	and res_ccosto         = "017"

	update cobasien
	   set centro_costo = "017"
	 where sac_notrx    = _notrx
	   and cuenta       = _cuenta;

end foreach

foreach
 select no_remesa,
        renglon
   into _no_remesa,
        _renglon
   from cobasien
  where centro_costo = "017"

	update cobasien
	   set centro_costo = "017"
	 where no_remesa    = _no_remesa
	   and renglon      = _renglon;

end foreach

return 0, "Actualizacion Exitosa";

end procedure