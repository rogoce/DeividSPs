-- Actualizacion de los registros de morosidad y cobros para BO
-- Modificacion del sp_bo032 para actualizar la morosidad del periodo actual
-- Creado    : 6/09/2011 
--execute procedure sp_bo080()

drop procedure sp_bo080; 

create procedure sp_bo080()
returning integer,
          char(50);

define _emi_periodo_cerrado	smallint;
define _cob_periodo_cerrado	smallint;
define a_periodo			char(7);

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

select emi_periodo_cerrado,
       cob_periodo_cerrado,
	   emi_periodo
  into _emi_periodo_cerrado,
       _cob_periodo_cerrado,
	   a_periodo
  from parparam;

----------------------------------
let _emi_periodo_cerrado = 1;
let _cob_periodo_cerrado = 1;
--let a_periodo            = "2020-09";
--return 0, "Actualizacion Exitosa";

if _emi_periodo_cerrado = 1 and
   _cob_periodo_cerrado = 1 then

	--	Eliminar Cobmoros
	call sp_bo048() returning _error, _descripcion;

	if _error <> 0 then
		return _error, _descripcion;
	end if		

	-- Calcular la Morosidad
	call sp_cob134(a_periodo, 0) returning _error, _descripcion;

	{
	update deivid_cob:cobmoros4
	   set subir_bo = 0
	 where periodo  = a_periodo;
	}

	if _error <> 0 then
		return _error, _descripcion;
	end if		

	call sp_bo003(a_periodo) returning _error, _descripcion;

	if _error <> 0 then
		return _error, _descripcion;
	end if		

	--call sp_bo021(a_periodo) returning _error, _descripcion; --La informacion que se busca se agrego en el sp_bo003 Amado 13-01-2025

	--if _error <> 0 then
	--	return _error, _descripcion;
	--end if		


	return 0, "Actualizacion Exitosa";

else

	return 1, "Cierre No Es Necesario";

end if

end

end procedure