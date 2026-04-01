-- Procedimiento que carga la tabla para el presupuesto de ventas 

-- Creado    : 09/03/2010 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_zona_web;

create procedure "informix".sp_zona_web(a_cod_vendedor char(3))
returning integer,
          char(50);

define _cod_agente		char(5);

--SET DEBUG FILE TO "sp_sp_par299.trc";      
--TRACE ON;     
                                                                


foreach
	 select cod_agente
	   into _cod_agente
	   from deivid:agtagent
	  where cod_vendedor = a_cod_vendedor
   order by 1

	 update deivid_tmp:preven2012
		set cod_vendedor = a_cod_vendedor
	  where cod_agente   = _cod_agente; 

end foreach

return 0, "Actualizacion Exitosa";

end procedure