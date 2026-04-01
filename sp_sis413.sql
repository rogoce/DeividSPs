-- Actualizacion de los registros de morosidad y cobros para BO
-- Modificacion del sp_bo032 para actualizar la morosidad del nuevo periodo
-- Modificado    : 12/09/2011 

--drop procedure sp_sis413; 

create procedure "informix".sp_sis413()
returning integer,
          char(50);

define _emi_periodo_cerrado	smallint;
define _cob_periodo_cerrado	smallint;
define a_periodo			char(7);
define _cob_periodo         char(7);

define _error	   			integer;
define _error_isam			integer;
define _error_desc			char(50);
define _descripcion			char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc;
end exception

-- Diferencia con el sp_bo032--	  Jorge


	--Cargar cobmoros2 (NIIF) de cobmoros, solo cuando es cierre de mes.Armando Moreno. Puesto en Prod. 08/07/2013
	insert into deivid_cob:cobmoros2
	select * 
	  from deivid_cob:cobmoros;

	return 0, "Actualizacion Exitosa";

end

end procedure