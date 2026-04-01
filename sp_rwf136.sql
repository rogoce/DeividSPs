-- Procedure que verifica los montos del detalle vs maestro ajuste de ordenes 													   
-- Creado por: Amado Perez 08/10/2014

drop procedure sp_rwf136;

create procedure sp_rwf136(a_incidente integer)
returning integer, varchar(50), dec(16,2);

define _cantidad        integer;
define _pieza           varchar(50);
define _no_orden        char(10);
define _error           integer;
define _descripcion		varchar(50);
define _monto           dec(16,2);
define _retorno         integer;

--SET DEBUG FILE TO "sp_rec233.trc"; 
--TRACE ON;                                                                
set isolation to dirty read;

begin

ON EXCEPTION SET _error 
 	RETURN _error, "Error al buscar las piezas", null;         
END EXCEPTION

let _error = 0;
let _retorno = 0;

let _descripcion = "Verificacion exitosa";

--delete from recordadd where no_ajus_orden =	a_ajus_orden and despachado = 0;

foreach	with hold
	select cantidad, wf_pieza, cantidad * wf_monto
	  into _cantidad, _pieza, _monto
	  from wf_ordcomp
	 where wf_incidente = a_incidente
	   and tipo_orden = 'R'

return _cantidad, _pieza, _monto with resume;

end foreach

end
end procedure