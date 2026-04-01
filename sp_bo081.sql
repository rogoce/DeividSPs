-- Actualizacion de los registros de morosidad y cobros para BO
-- Modificacion del sp_bo032 para actualizar la morosidad del nuevo periodo
-- Modificado    : 12/09/2011 

drop procedure sp_bo081; 

create procedure "informix".sp_bo081()
returning integer,
          char(50);

define _descripcion			char(50);
define _error_desc			char(50);
define _cob_periodo         char(7);
define _periodo				char(7);
define _emi_periodo_cerrado	smallint;
define _cob_periodo_cerrado	smallint;
define _error_isam			integer;
define _error	   			integer;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc;
end exception

-- Diferencia con el sp_bo032--	  Jorge

select emi_periodo_cerrado,
       cob_periodo_cerrado,
	   par_periodo_act
  into _emi_periodo_cerrado,
       _cob_periodo_cerrado,
	   _periodo
  from parparam;

----------------------------------

--let _emi_periodo_cerrado = 1;
--let _cob_periodo_cerrado = 1;
--let _periodo            = "2026-02";

--if _emi_periodo_cerrado = 1 and _cob_periodo_cerrado = 1 then

	--	Eliminar Cobmoros
	--call sp_bo048() returning _error, _descripcion;

	--if _error <> 0 then
	--	return _error, _descripcion;
	--end if		

if _emi_periodo_cerrado = 1 and _cob_periodo_cerrado = 1 then

	-- Calcular la Morosidad
	call sp_cob134(_periodo, 1) returning _error, _descripcion;

	if _error <> 0 then
		return _error, _descripcion;
	end if		

	call sp_bo003(_periodo) returning _error, _descripcion; 

	if _error <> 0 then
		return _error, _descripcion;
	end if		

	--call sp_bo021(_periodo) returning _error, _descripcion; --La informacion que se busca se agrego en el sp_bo003 Amado 13-01-2025

	--if _error <> 0 then
	--	return _error, _descripcion;
	--end if		

	--Cargar cobmoros2 (NIIF) de cobmoros, solo cuando es cierre de mes.Armando Moreno. Puesto en Prod. 08/07/2013
	delete from deivid_cob:cobmoros2
	 where periodo = _periodo;

	insert into deivid_cob:cobmoros2
	select * 
	  from deivid_cob:cobmoros4;

	return 0, "Actualizacion Exitosa";
else
	return 1, "No ha cerrado el periodo de cobros";
end if

end

end procedure;