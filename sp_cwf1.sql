-- Actualizacion de la tabla de Cheques desde Ultimus Workflow
-- 
-- Creado    : 31/05/2004 - Autor: Amado Perez M. 
--
-- SIS v.2.0 - - ASEGURADORA ANCON, S.A.

DROP PROCEDURE sp_cwf1;
CREATE PROCEDURE "informix".sp_cwf1(a_no_requis char(10), a_incidente integer)
returning integer, 
          char(26);

define _error			integer;

--set debug file to "sp_cwf1.trc";
--trace on;


begin
on exception set _error
	return _error, "Error al Actualizar Cheques";	
end exception

update chqchmae
   set incidente = a_incidente
 where no_requis = a_no_requis;

end

return 0, "Actualizacion Exitosa ... ";	

end procedure