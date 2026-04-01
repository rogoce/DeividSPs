-- Procedimiento que carga la tabla para el presupuesto de ventas 2010

-- Creado    : 09/03/2010 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par300;

create procedure "informix".sp_par300(
a_cod_vendedor	char(3),
a_cod_agente	char(5),
a_cod_ramo		char(3),
a_periodo		char(7),
a_tipo			char(1),
a_prima			dec(16,2),
a_cod_subramo   char(3)
)

define _cantidad	smallint;

--SET DEBUG FILE TO "sp_sp_par300.trc";      
--TRACE ON;     

select count(*)
  into _cantidad
  from deivid_bo:preventas
 where cod_vendedor = a_cod_vendedor
   and cod_agente   = a_cod_agente
   and cod_ramo     = a_cod_ramo
   and periodo		= a_periodo
   and cod_subramo 	= a_cod_subramo;

if a_prima is null then
	let a_prima = 0.00;
end if 

if a_tipo = "N" then

	if _cantidad = 0 then
	
		insert into deivid_bo:preventas
		values (a_cod_vendedor, a_cod_agente, a_cod_ramo, a_periodo, a_prima, 0, a_prima, 0,0,0,0,a_cod_subramo);

	else

		update deivid_bo:preventas
		   set ventas_nuevas = ventas_nuevas + a_prima,
		       ventas_total  = ventas_total  + a_prima
		 where cod_vendedor  = a_cod_vendedor
		   and cod_agente    = a_cod_agente
		   and cod_ramo      = a_cod_ramo
		   and periodo		 = a_periodo
		   and cod_subramo 	 = a_cod_subramo;

	end if

else

	if _cantidad = 0 then
	
		insert into deivid_bo:preventas
		values (a_cod_vendedor, a_cod_agente, a_cod_ramo, a_periodo, 0, a_prima, a_prima, 0,0,0,0,a_cod_subramo);

	else

		update deivid_bo:preventas
		   set ventas_renovadas = ventas_renovadas + a_prima,
		       ventas_total     = ventas_total     + a_prima
		 where cod_vendedor     = a_cod_vendedor
		   and cod_agente       = a_cod_agente
		   and cod_ramo         = a_cod_ramo
		   and periodo		    = a_periodo
		   and cod_subramo 		= a_cod_subramo;

	end if

end if

end procedure
