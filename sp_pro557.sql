-- Procedure que borra los datos de prdcacoestm y emicacoami
-- Creado: 14/07/2012	- Autor: Roman Gordon


drop procedure sp_pro557; 													   
create procedure sp_pro557(a_cod_agente char(5),a_num_carga integer)
returning integer,
          char(100);

define _numero	char(10);
define _cant	integer;
define _error	integer;

--set debug file to "sp_pro557.trc";
--trace on;

begin
on exception set _error
	return _error, "Error Borrar Carga de Emisiones Electrónicas.";
end exception

let _cant = 0;

select count(*)
  into _cant
  from prdcacoestm
 where cod_coasegur	= a_cod_agente 
   and num_carga	= a_num_carga;

if _cant = 0 Then
	return 1, "Carga no Valida para ser Eliminada " || a_num_carga;
end if

delete from equierroest 
 where cod_coasegur	= a_cod_agente
   and num_carga	= a_num_carga;
delete from emicacoami	
	  where cod_coasegur	= a_cod_agente 
	    and num_carga	= a_num_carga;
delete from prdcacoestm
 where cod_coasegur	= a_cod_agente 
   and num_carga	= a_num_carga;
end

return 0, "Carga Eliminada con Exito.";

end procedure;