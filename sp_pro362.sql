-- Procedure que borra los datos de prdemielect y prdemielectdet
-- Creado: 31/07/2012	- Autor: Roman Gordon


 													   
drop procedure sp_pro362;

create procedure sp_pro362(a_num_carga char(5),a_cod_agente char(5))
returning integer,
          char(100);

define _numero	char(10);
define _cant	integer;
define _error	integer;

--set debug file to "sp_rrh02.trc";
--trace on;

begin
on exception set _error
	return _error, "Error Borrar Carga de Emisiones Electrónicas.";
end exception

let _cant = 0;

select count(*)
  into _cant
  from prdemielect
 where cod_agente	= a_cod_agente
   and num_carga	= a_num_carga;

if _cant = 0 Then
	return 1, "Carga no Válida para ser Eliminada " || a_num_carga;
end if

delete from prdemielectdet
 where cod_agente	= a_cod_agente
   and num_carga	= a_num_carga;

delete from prdemielect	
 where cod_agente	= a_cod_agente
   and num_carga	= a_num_carga;

end

return 0, "Carga Eliminada con Exito.";

end procedure
