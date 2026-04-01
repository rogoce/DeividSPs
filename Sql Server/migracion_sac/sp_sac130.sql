-- Procedure que actualiza el campo de periodo para las cuentas de los cheques

-- Creado    : 09/10/2009 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_sac130;

create procedure sp_sac130() 
returning integer,
          char(100);

define _no_requis	char(10);
define _renglon		integer;
define _cuenta		char(25);
define _fecha		date;
define _periodo		char(7);

foreach
 select no_requis,
        renglon,
		cuenta,
		fecha
   into _no_requis,
        _renglon,
		_cuenta,
		_fecha
   from chqchcta
  where year(fecha)  = 2008
	and month(fecha) = 12

	let _periodo = sp_sis39(_fecha);

	update chqchcta
	   set periodo   = _periodo
	 where no_requis = _no_requis
	   and renglon   = _renglon
	   and cuenta    = _cuenta;

end foreach

return 0, "Actualizacion Exitosa";

end procedure