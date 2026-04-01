-- Creacion de la Transaccion Inicial de Reclamos
-- 
-- Creado    : 04/05/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_wfh02;
CREATE PROCEDURE "informix".sp_wfh02(a_no_caso char(10), a_user_solucion char(8))
returning integer, 
          char(26);

define _error			integer;

--set debug file to "sp_cwf1.trc";
--trace on;


begin
on exception set _error
--	return _error, "Error al Actualizar Helpdesk2";	
end exception

update helpdesk2
   set atendiendo = 0,
       fecha_solucion = current
 where user_solucion = a_user_solucion
   and no_caso = a_no_caso;

end

begin
on exception set _error
	return _error, "Error al insertar Helpdesk2";	
end exception

insert into helpdesk2(
	no_caso,
	atendiendo,
	fecha_inicio,
	user_solucion
	)
	values(
	a_no_caso,
	1,
	current,
	a_user_solucion
	);

end

return 0, "Actualizacion Exitosa ... ";	

end procedure