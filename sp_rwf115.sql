-- Procedure que Actualiza los valores de los modelos (Grande, Mediano, Pequeño)

-- Creado    : 10/07/2013 - Autor: Amado Perez Mendoza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_rwf115;

create procedure "informix".sp_rwf115(a_tramite varchar(10), a_motor varchar(30), a_tamano char(1), a_tipor char(1)) 
returning integer,
		  char(50);

define _no_reclamo	char(10);
define _cod_marca	char(5);
define _cod_modelo	char(5);
define _tamano      smallint;

define _error           integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

--SET DEBUG FILE TO "sp_rwf115.trc ";
--TRACE ON;

begin

on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

foreach

	select no_reclamo
	  into _no_reclamo
	  from recrcmae
	 where no_tramite = trim(a_tramite)

	if a_tamano = "P" then
	   let _tamano = 1;
	elif a_tamano = "M" then
	   let _tamano = 2;
	else
	   let _tamano = 3;
	end if

	let _cod_modelo = null;

	if a_tipor = "A" then
		select cod_modelo
		  into _cod_modelo
		  from emivehic
		 where no_motor = trim(a_motor);
	else
	   foreach
	   	select cod_modelo
	   	  into _cod_modelo
	   	  from recterce
	   	 where no_reclamo = _no_reclamo
		   and no_motor = trim(a_motor)
	   	 
	   	exit foreach;

	   end foreach
	end if   

	update emimodel
	   set tamano = _tamano
	 where cod_modelo = _cod_modelo
	   and tamano = 0;

end foreach

return 0, "Actualizacion Exitosa";

end

end procedure
