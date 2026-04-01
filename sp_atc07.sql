-- Procedure que carga los registros de imagenes respaldadas

drop procedure sp_atc07;

create procedure sp_atc07()
returning integer,
          char(50),
          integer;

define _cod_asignacion	char(10);
define _transaccion  	char(10);
define _cod_entrada  	char(10);
define _cnt             integer;
define _cantidad        integer;
define _cant_reg        integer;
define _cant_tot        integer;
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

begin
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_desc, _error_isam;
end exception

let _cant_reg = 0;
let _cant_tot = 0;

foreach	with hold

 select	cod_asignacion
   into _cod_asignacion
   from imagen:atcdocba
  where year(fecha_completado) >= 2007
  	
	if _cant_reg = 0 then
		begin work;
	end if

	let _cant_tot = _cant_tot + 1;
	let _cant_reg = _cant_reg + 1;

	delete from imagen:atcdocba
	 where cod_asignacion = _cod_asignacion;

	if _cant_reg >= 30 then
		commit work;
		return 0, "Actualizacion Exitosa ", _cant_reg with resume;
		let _cant_reg = 0;
	end if

	if _cant_tot >= 30 then
		exit foreach;
	end if


end foreach

--commit work;
--return 0, "Fin ", _cant_reg with resume;


{foreach	with hold
 select	cod_asignacion,
        transaccion
   into _cod_asignacion,
		_transaccion
   from recasign
  	
   	update rectrmae
	   set cod_asignacion = _cod_asignacion
	 where transaccion    = _transaccion;

	select cod_entrada
	  into _cod_entrada
	  from atcdocde
	 where cod_asignacion = _cod_asignacion;

	update atcdocde
	   set completado     = 1,
	       escaneado	  = 1,
		   cod_ajustador  = "091"
	 where cod_asignacion = _cod_asignacion;

	select count(*)
	  into _cnt
	  from atcdocde
	 where cod_entrada = _cod_entrada
	   and completado  = 1;

	select cant_registros
	  into _cantidad
	  from atcdocma
	 where cod_entrada = _cod_entrada;

	if _cantidad = _cnt then
		update atcdocma
		   set completado  = 1,
		       procesado   = 1
		 where cod_entrada = _cod_entrada;
	end if

end foreach}
 
end 

end procedure