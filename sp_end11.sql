-- Procedimiento que Realiza la insercion a la tabla de endoso, Proceso de Endosos Electronicos Tecnica de seguros.
-- Creado    : 29/08/2014 - Autor: Federico Coronado 

drop procedure sp_end11;

create procedure "informix".sp_end11(
a_cod_agente	  char(5),
a_opcion		  char(1),
a_fecha_registro  date
)
returning smallint;
define _no_factura_tecnica    varchar(20);
define _cnt_factura_tecnica   integer;

--- Verificacion de facturas duplicadas enviadas por tecnica de seguro.

--set debug file to "sp_end09.trc"; 
--trace on;

set lock mode to wait;
	foreach
		select distinct(no_factura_tecnica) 
		  into _no_factura_tecnica
		  from prdemielctdet
		 where cod_agente 		= a_cod_agente
		   and fecha_registro 	= a_fecha_registro
		   and proceso          = a_opcion

		select count(*) 
		  into _cnt_factura_tecnica
		  from prdemielctdet
		 where no_factura_tecnica = _no_factura_tecnica
		 and actualizado = 1;
		
		if _cnt_factura_tecnica > 1 then
			update prdemielctdet
			  set actualizado 		 = 3
			where  cod_agente 		 = a_cod_agente
			  and no_factura_tecnica = _no_factura_tecnica
			  and fecha_registro 	 = a_fecha_registro
			  and proceso          	 = a_opcion;
		end if
		
	end foreach
return 0;
end procedure;