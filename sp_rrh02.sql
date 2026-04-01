-- Procedure que borra los datos de prdemielect y prdemielectdet
-- Creado: 14/07/2012	- Autor: Roman Gordon


drop procedure sp_rrh02; 													   
create procedure sp_rrh02(a_num_planilla char(10))
returning integer,
          char(100);

define _numero	char(10);
define _cant	integer;
define _error	integer;

--set debug file to "sp_rrh02.trc";
--trace on;

begin
on exception set _error
	return _error, "Error Borrar Carga de Asientos de Planilla.";
end exception

let _cant = 0;

select count(*)
  into _cant
  from chqpayasien
 where num_planilla = a_num_planilla;

if _cant = 0 Then
	return 1, "Carga no Valida para ser Eliminada " || a_num_planilla;
end if

delete from chqpaydet	where num_planilla = a_num_planilla;
delete from chqpayasien	where num_planilla = a_num_planilla;

end

return 0, "Carga Eliminada con Exito.";

end procedure