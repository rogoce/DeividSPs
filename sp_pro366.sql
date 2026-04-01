-- Procedure que borra los datos de prdemielect y prdemielectdet
-- Creado: 14/07/2012	- Autor: Roman Gordon


drop procedure sp_pro366; 													   
create procedure sp_pro366(a_cod_agente char(5),a_num_carga char(10),a_opcion char(1))
returning integer,
          char(100);

define _numero	char(10);
define _cant	integer;
define _error	integer;

--set debug file to "sp_pro366.trc";
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
   and num_carga	= a_num_carga
   and proceso		= a_opcion;

if _cant = 0 Then
	return 1, "Carga no Valida para ser Eliminada " || a_num_carga;
end if

delete from equierror 
	  where cod_agente	= a_cod_agente
		and num_carga	= a_num_carga
		and proceso		= a_opcion;
delete from prdemielctdet	
	  where cod_agente	= a_cod_agente 
	    and num_carga	= a_num_carga
	    and proceso		= a_opcion;
delete from prdemielect
	  where cod_agente	= a_cod_agente 
	    and num_carga	= a_num_carga
	    and proceso		= a_opcion;
delete from prdemielecben
	  where cod_agente	= a_cod_agente 
	    and num_carga	= a_num_carga
	    and proceso		= a_opcion;

end

return 0, "Carga Eliminada con Exito.";

end procedure