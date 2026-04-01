-- Procedimiento que carga la tabla para el presupuesto de ventas 

-- Creado    : 03/03/2017 - Autor: Federico Coronado 

drop procedure sp_par2993;

create procedure "informix".sp_par2993(a_ano char(4), a_cod_vendedor char(3) )
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
   set ventas_renovadas = 0.00
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
		  and tipo = 'R'
		  and cod_agente <> '-----'
		  and ano  = _ano
		  --and cod_ramo <> '008'
	 group by 1,2,3
	 order by 1,2,3
	/*
	let _prima_total = _primas_nuevas + _primas_renovadas;
	let _cobros      = _prima_total  * 0.95;
	*/
	/*call sp_par300(a_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-01", "R", _ene,_cod_subramo);
	call sp_par300(a_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-02", "R", _feb,_cod_subramo);
	call sp_par300(a_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-03", "R", _mar,_cod_subramo);
	call sp_par300(a_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-04", "R", _abr,_cod_subramo);
	call sp_par300(a_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-05", "R", _may,_cod_subramo);
	call sp_par300(a_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-06", "R", _jun,_cod_subramo);
	call sp_par300(a_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-07", "R", _jul,_cod_subramo);
	call sp_par300(a_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-08", "R", _ago,_cod_subramo);
	call sp_par300(a_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-09", "R", _sep,_cod_subramo);
	call sp_par300(a_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-10", "R", _oct,_cod_subramo);
	call sp_par300(a_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-11", "R", _nov,_cod_subramo);
	call sp_par300(a_cod_vendedor, _cod_agente, _cod_ramo, _ano || "-12", "R", _dic,_cod_subramo);*/
	

	update deivid_bo:preventas
	   set ventas_renovadas 	= _ene
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-01"
	   and cod_subramo  = _cod_subramo;
	   
	update deivid_bo:preventas
	   set ventas_renovadas 	= _feb
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-02"
	   and cod_subramo  = _cod_subramo;
	   
   	update deivid_bo:preventas
	   set ventas_renovadas 	= _mar
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-03"
	   and cod_subramo  = _cod_subramo;
	   
	update deivid_bo:preventas
	   set ventas_renovadas 	= _abr
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-04"
	   and cod_subramo  = _cod_subramo;
	   
	update deivid_bo:preventas
	   set ventas_renovadas 	= _may
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-05"
	   and cod_subramo  = _cod_subramo;
	   
	update deivid_bo:preventas
	   set ventas_renovadas 	= _jun
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-06"
       and cod_subramo  = _cod_subramo;	   

	update deivid_bo:preventas
	   set ventas_renovadas 	= _jul
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-07"
	   and cod_subramo  = _cod_subramo;
	   
	update deivid_bo:preventas
	   set ventas_renovadas 	= _ago
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-08"
	   and cod_subramo  = _cod_subramo;
	   
   	update deivid_bo:preventas
	   set ventas_renovadas 	= _sep
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-09"
	   and cod_subramo  = _cod_subramo;
	   
	update deivid_bo:preventas
	   set ventas_renovadas 	= _oct
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-10"
	   and cod_subramo  = _cod_subramo;
	   
	update deivid_bo:preventas
	   set ventas_renovadas 	= _nov
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-11"
	   and cod_subramo  = _cod_subramo;
	   
	update deivid_bo:preventas
	   set ventas_renovadas 	= _dic
	 where cod_vendedor = a_cod_vendedor
	   and cod_agente 	= _cod_agente
       and cod_ramo   	= _cod_ramo
       and periodo 		= _ano||"-12"
	   and cod_subramo  = _cod_subramo;
	   
end foreach

return 0, "Actualizacion Exitosa";

end procedure


