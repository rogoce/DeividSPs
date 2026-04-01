-- Actualizacion de los registros de morosidad y cobros con diferencia

-- Creado    : 06/04/2015 - Autor: Jorge Contreras

--drop procedure sp_bo089; 

create procedure "informix".sp_bo089(a_periodo char(7))
returning integer,
          char(50);

define _emi_periodo_cerrado	smallint;
define _cob_periodo_cerrado	smallint;
--define a_periodo			char(7);

define _error	   			integer;
define _error_isam			integer;
define _error_desc			char(50);
define _descripcion			char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc;
end exception

{
select emi_periodo_cerrado,
       cob_periodo_cerrado,
	   par_periodo_act
  into _emi_periodo_cerrado,
       _cob_periodo_cerrado,
	   a_periodo
  from parparam;
}

let _emi_periodo_cerrado = 1;
let _cob_periodo_cerrado = 1;
--let a_periodo            = "2009-11";

if _emi_periodo_cerrado = 1 and
   _cob_periodo_cerrado = 1 then

	--	Eliminar Cobmoros
	call sp_bo048() returning _error, _descripcion;

	if _error <> 0 then
		return _error, _descripcion;
	end if		

	-- Calcular la Morosidad
	call sp_bo089a(a_periodo, 1) returning _error, _descripcion;

	{
	update deivid_cob:cobmoros
	   set subir_bo = 0
	 where periodo  = a_periodo;
	}

	if _error <> 0 then
		return _error, _descripcion;
	end if		

	call sp_bo089b(a_periodo) returning _error, _descripcion;

	if _error <> 0 then
		return _error, _descripcion;
	end if		

	call sp_bo021(a_periodo) returning _error, _descripcion;

	if _error <> 0 then
		return _error, _descripcion;
	end if	
	
 {	--Cargar cobmoros2 si se da algun problema de carga
	insert into deivid_cob:cobmoros2
	select * 
	from deivid_cob:cobmoros; 	}
	

	return 0, "Actualizacion Exitosa";

else

	return 1, "Cierre No Es Necesario";

end if

end

end procedure