-- Procedimiento que carga la tabla para el presupuesto de ventas 

-- Creado    : 03/03/2017 - Autor: Federico Coronado 

drop procedure sp_par2992;

create procedure "informix".sp_par2992(a_ano char(4), a_cod_vendedor char(3) )
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
define _cod_subramo     char(3);

let _ano = a_ano;

--SET DEBUG FILE TO "sp_sp_par299.trc";      
--TRACE ON;     
                                                                
update deivid_bo:preventas
   set ventas_nuevas    = 0.00
 where periodo[1,4] = _ano 
   and cod_vendedor = a_cod_vendedor
   and cod_agente <> '00687';
  -- and cod_ramo <> '008';

-- Se actualiza el codigo de vendedor 
--trace on;
-- Ventas Nuevas

foreach
		select cod_ramo,
			   cod_subramo,
		       cod_agente, 
			   sum(ene),
			   sum(feb),
			   sum(mar),
			   sum(abr),
			   sum(may),
			   sum(jun),
			   sum(jul),
			   sum(ago),
			   sum(sep),
			   sum(oct),
			   sum(nov),
			   sum(dic)
		 into _cod_ramo,
			  _cod_subramo,
			  _cod_agente,
			  _ene,
		      _feb,
		      _mar,
		      _abr,
		      _may,
		      _jun,
		      _jul,
		      _ago,
		      _sep,
		      _oct,
		      _nov,
		      _dic	
	     from deivid_bo:actuario_2018
		where cod_vendedor = a_cod_vendedor
		  and tipo = 'N'
		  and cod_agente <> '-----'
		  and ano  = _ano
	  --  and cod_ramo <> '008'
	 group by 1,2,3
	 order by 1,2,3
	/*
	let _prima_total = _primas_nuevas + _primas_renovadas;
	let _cobros      = _prima_total  * 0.95;
	*/

	update deivid_bo:preventas
	   set ventas_nuevas 	= _ene
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-01"
	   and cod_agente <> '00687'
	   and cod_subramo  = _cod_subramo;
	   
	update deivid_bo:preventas
	   set ventas_nuevas 	= _feb
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-02"
	    and cod_agente <> '00687'
		and cod_subramo  = _cod_subramo;
	   
   	update deivid_bo:preventas
	   set ventas_nuevas 	= _mar
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-03"
	    and cod_agente <> '00687'
		and cod_subramo  = _cod_subramo;
	   
	update deivid_bo:preventas
	   set ventas_nuevas 	= _abr
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-04"
	    and cod_agente <> '00687'
		and cod_subramo  = _cod_subramo;
	   
	update deivid_bo:preventas
	   set ventas_nuevas 	= _may
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-05"
	    and cod_agente <> '00687'
		and cod_subramo  = _cod_subramo;
	   
	update deivid_bo:preventas
	   set ventas_nuevas 	= _jun
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-06"
	   and cod_agente <> '00687'
	   and cod_subramo  = _cod_subramo;	   

	update deivid_bo:preventas
	   set ventas_nuevas 	= _jul
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-07"
	    and cod_agente <> '00687'
		and cod_subramo  = _cod_subramo;
	   
	update deivid_bo:preventas
	   set ventas_nuevas 	= _ago
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-08"
	   and cod_agente <> '00687'
	   and cod_subramo  = _cod_subramo;
	   
   	update deivid_bo:preventas
	   set ventas_nuevas 	= _sep
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-09"
	   and cod_agente <> '00687'
	   and cod_subramo  = _cod_subramo;
	   
	update deivid_bo:preventas
	   set ventas_nuevas 	= _oct
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-10"
	    and cod_agente <> '00687'
		and cod_subramo  = _cod_subramo;
	   
	update deivid_bo:preventas
	   set ventas_nuevas 	= _nov
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-11"
	    and cod_agente <> '00687'
		and cod_subramo  = _cod_subramo;
	   
	update deivid_bo:preventas
	   set ventas_nuevas 	= _dic
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-12"
	    and cod_agente <> '00687'
		and cod_subramo  = _cod_subramo;
	   
end foreach

return 0, "Actualizacion Exitosa";

end procedure


