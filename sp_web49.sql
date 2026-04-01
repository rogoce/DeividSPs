-- Procedimiento que consulta la tabla emivehic para generar el pdf de automovil
-- Creado    : 17/10/2018 -- Federico Coronado

drop procedure sp_web49;

create procedure "informix".sp_web49(a_no_motor varchar(30))
returning varchar(5),
          varchar(5),
		  integer,
		  integer,
		  varchar(30),
		  dec(16,2); 

define _cod_marca varchar(5);
define _cod_modelo varchar(5);
define _ano_auto   integer;
define _capacidad  integer;
define _no_chasis  varchar(30);
define _valor_auto dec(16,2);

set isolation to dirty read;

--set debug file to "sp_repo06.trc";
	SELECT cod_marca, 
	       cod_modelo,
		   ano_auto, 
		   capacidad,    
		   no_chasis, 
		   valor_auto
	  into _cod_marca,
	       _cod_modelo,
		   _ano_auto,
		   _capacidad,
		   _no_chasis,
		   _valor_auto
	 from emivehic 
	 where no_motor = a_no_motor; 
	
	if _capacidad is null then
		let _capacidad = 0;
	end if

	return _cod_marca, 
	       _cod_modelo,
	       _ano_auto,
	       _capacidad,
	       _no_chasis,
	       _valor_auto;
end procedure;