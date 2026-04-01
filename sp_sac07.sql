-- Procedure que Reemplaza las cuentas con guiones con cuentas sin guiones
-- solo de la tabla de asientos de cobros

-- Creado    : 21/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.


drop procedure sp_sac07;

create procedure sp_sac07() 
returning smallint,
          char(100);

define _no_remesa	char(10);
define _renglon		smallint;

define _cuenta_con	char(25);
define _cuenta_sin	char(25);
define _nombre		char(100);

define _error		smallint;
define _cantidad	smallint;
define _descripcion	char(100);

set isolation to dirty read;

foreach
 select no_remesa
   into _no_remesa
   from cobremae
  where fecha = today

	foreach
	 select cuenta,
	        renglon
	   into _cuenta_con,
	        _renglon
	   from cobasien
	  where no_remesa = _no_remesa
	  	
		let _cuenta_sin = sp_sac03(_cuenta_con);
		
		update cobasien
		   set cuenta    = _cuenta_sin
		 where no_remesa = _no_remesa
		   and renglon   = _renglon
		   and cuenta    = _cuenta_con;

	end foreach

end foreach

end procedure