-- Procedimiento que carga la tabla para el presupuesto de ventas 

-- Creado    : 03/03/2017 - Autor: Federico Coronado 

drop procedure sp_par2991;

create procedure "informix".sp_par2991(a_ano char(4), a_cod_vendedor char(3) )
returning integer,
          char(50);

define _cod_vendedor	 char(3);
define _cod_agente		 char(5);
define _cod_ramo		 char(3);
define _ano				 char(4);
define _periodo          char(7);
define _prima_total      dec(16,2);
define _primas_nuevas    dec(16,2);
define _primas_renovadas dec(16,2);
define _cobros           dec(16,2);
define _cod_subramo      char(3);

let _ano = a_ano;

--SET DEBUG FILE TO "sp_sp_par299.trc";      
--TRACE ON;     
                                                                
/*update deivid_bo:preventas
   set ventas_nuevas    = 0.00,
	   ventas_renovadas = 0.00,
	   ventas_total     = 0.00,
	   cobros           = 0.00
 where periodo[1,4] = _ano 
   and cod_vendedor = a_cod_vendedor
   and cod_agente <> '00687';
*/
/*
-- Se actualiza el codigo de vendedor 
--trace on;
-- Ventas Nuevas
{foreach
	select cod_vendedor
	into _cod_vendedor 
	from deivid:agtvende 
	where activo = 1
	order by nombre
}
*/
	foreach
		select cod_vendedor,
			   cod_agente,
			   cod_ramo,
			   cod_subramo,
			   periodo,
			   ventas_nuevas,
			   ventas_renovadas
		  into _cod_vendedor,
			   _cod_agente,
			   _cod_ramo,
			   _cod_subramo,
			   _periodo,
			   _primas_nuevas,
			   _primas_renovadas
		  from deivid_bo:preventas
		 where cod_vendedor = a_cod_vendedor
		   and periodo[1,4] = _ano 
		
		let _prima_total = _primas_nuevas + _primas_renovadas;
		let _cobros      = _prima_total  * 0.95;
		

		update deivid_bo:preventas
		   set ventas_total 	= _prima_total,  
			   cobros 			= _cobros
		 where cod_vendedor = _cod_vendedor
		   and cod_agente 	= _cod_agente
		   and cod_ramo   	= _cod_ramo
		   and periodo 		= _periodo
		   and cod_subramo  = _cod_subramo;
	   
	end foreach
--end foreach
return 0, "Actualizacion Exitosa";

end procedure


