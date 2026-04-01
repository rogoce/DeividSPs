-- Procedimiento que carga la tabla para el presupuesto de ventas 

-- Creado    : 03/03/2017 - Autor: Federico Coronado 

drop procedure sp_par2996;

create procedure "informix".sp_par2996(a_ano char(4))
returning integer,
          char(50);

define _cod_agente		 char(5);
define _cod_ramo		 char(3);
define _ano				 char(4);
define _periodo          char(7);
define _prima_total      dec(16,2);
define _primas_nuevas    dec(16,2);
define _primas_renovadas dec(16,2);
define _cobros           dec(16,2);
define _ene				dec(16,2);
define _feb				dec(16,2);
define _mar				dec(16,2);
define _abr				dec(16,2);
define _may				dec(16,2);
define _jun				dec(16,2);
define _jul				dec(16,2);
define _ago				dec(16,2);
define _sep				dec(16,2);
define _oct				dec(16,2);
define _nov				dec(16,2);
define _dic				dec(16,2);

let _ano = a_ano;

--SET DEBUG FILE TO "sp_sp_par299.trc";      
--TRACE ON;     
                                                                
-- Se actualiza el codigo de vendedor 
--trace on;
-- Ventas Nuevas

foreach
	select cod_ramo,
           periodo,
		   ventas_renovadas 
	  into _cod_ramo,
	       _periodo,
		   _ene
      from preventas
	 where cod_agente = '00099'
	   and periodo[1,4] = '2018'
	   and ventas_renovadas <> '0'
	/*
	let _prima_total = _primas_nuevas + _primas_renovadas;
	let _cobros      = _prima_total  * 0.95;
	*/

	update deivid_bo:preventas
	   set ventas_renovadas 	= _ene + '147.70'
	 where cod_ramo   	= _cod_ramo
       and periodo 		= _periodo
	   and cod_agente   = '00099';
	/*   
	update deivid_bo:preventas
	   set ventas_renovadas 	= ventas_renovadas + _feb
	 where cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-02"
	   and cod_agente   = '00030';
	   
   	update deivid_bo:preventas
	   set ventas_renovadas 	= ventas_renovadas + _mar
	 where cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-03"
	   and cod_agente   = '00030';
	   
	update deivid_bo:preventas
	   set ventas_renovadas 	= ventas_renovadas + _abr
	 where cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-04"
	   and cod_agente   = '00030';
	   
	update deivid_bo:preventas
	   set ventas_renovadas 	= ventas_renovadas + _may
	 where cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-05"
	   and cod_agente   = '00030';
	   
	update deivid_bo:preventas
	   set ventas_renovadas 	= ventas_renovadas + _jun
	 where cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-06"
	   and cod_agente   = '00030';	   

	update deivid_bo:preventas
	   set ventas_renovadas 	= ventas_renovadas + _jul
	 where cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-07"
	   and cod_agente   = '00030';
	   
	update deivid_bo:preventas
	   set ventas_renovadas 	= ventas_renovadas + _ago
	 where cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-08"
	   and cod_agente   = '00030';
	   
   	update deivid_bo:preventas
	   set ventas_renovadas 	= ventas_renovadas + _sep
	 where cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-09"
	   and cod_agente   = '00030';
	   
	update deivid_bo:preventas
	   set ventas_renovadas 	= ventas_renovadas + _oct
	 where cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-10"
	   and cod_agente   = '00030';
	   
	update deivid_bo:preventas
	   set ventas_renovadas 	= ventas_renovadas + _nov
	 where cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-11"
	   and cod_agente   = '00030';
	   
	update deivid_bo:preventas
	   set ventas_renovadas 	= ventas_renovadas + _dic
	 where cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-12"
	   and cod_agente   = '00030';
	 */  
end foreach

return 0, "Actualizacion Exitosa";

end procedure


