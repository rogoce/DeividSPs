-- Procedimiento que carga la tabla para el presupuesto de ventas 

-- Creado    : 03/03/2017 - Autor: Federico Coronado 

drop procedure sp_par2994;

create procedure "informix".sp_par2994(a_ano char(4), a_cod_vendedor char(3) )
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
define _ene_1			dec(16,2);
define _feb_1			dec(16,2);
define _mar_1			dec(16,2);
define _abr_1			dec(16,2);
define _may_1			dec(16,2);
define _jun_1			dec(16,2);
define _jul_1			dec(16,2);
define _ago_1			dec(16,2);
define _sep_1			dec(16,2);
define _oct_1			dec(16,2);
define _nov_1			dec(16,2);
define _dic_1			dec(16,2);
define _total_restante  dec(16,2);
define _resultado_total_restante  dec(16,2);
define _cnt_agente      integer;
define _produccion      smallint;
define _cod_vendedor    char(3);

let _ano = a_ano;
--SET DEBUG FILE TO "sp_sp_par299.trc";      
--TRACE ON;     
                                                                

-- Se actualiza el codigo de vendedor 
--trace on;

/*foreach
 select	cod_vendedor,
        cod_agente
   into _cod_vendedor,
        _cod_agente
   from deivid:agtagent
  group by 1, 2
  order by 1, 2

	update deivid_tmp:preven2012
	   set cod_vendedor = _cod_vendedor
	 where cod_agente   = _cod_agente;

end foreach
*/
-- Ventas Nuevas
foreach
		select cod_ramo, 
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
		  and cod_agente = '-----'
		  and ano  = _ano
	 group by 1
	 order by 1
	/*
	let _prima_total = _primas_nuevas + _primas_renovadas;
	let _cobros      = _prima_total  * 0.95;
	*/
	let _produccion = 0;
		SELECT count(*)
		  into _cnt_agente
		  from deivid_tmp:preven2012
		 where cod_vendedor = a_cod_vendedor 
		   and tipo_mov 	= '5' 
		   and tipo_poliza 	= '4' 
		   and cod_ramo 	= _cod_ramo
		   and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
		   and total_2009 <> 0;
		   
			if _cnt_agente = 0 then
				SELECT count(*)
				  into _cnt_agente
				  from deivid_tmp:preven2012
				 where cod_vendedor = a_cod_vendedor 
				   and tipo_mov 	= '5' 
				   and tipo_poliza 	= '4' 
				   and cod_ramo 	= _cod_ramo
				   and cod_agente in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
				   and total_2009 <> 0;	
				let _produccion = 1;
			end if
		-- Enero
let _resultado_total_restante = 0;
let _total_restante           = 0;		
		if _ene <> 0 then	
			if _produccion = 0 then
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _ene_1 = _ene / _cnt_agente;
				
					update deivid_bo:preventas
					   set ventas_nuevas 	= _ene_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-01";
				end foreach
			else
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _ene_1 = _ene / _cnt_agente;
					
					update deivid_bo:preventas
					   set ventas_nuevas 	= ventas_nuevas + _ene_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-01";
				end foreach
			end if
			 select sum(ventas_nuevas) 
			   into _total_restante
			   from deivid_bo:preventas
			  where cod_vendedor 	= a_cod_vendedor
			    and cod_ramo   		= _cod_ramo
			    and periodo			= _ano||"-01"
			    and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
			    and ventas_nuevas <> 0;
				
			if _total_restante < _ene then
				let _resultado_total_restante =  _ene - _total_restante;
				update deivid_bo:preventas
				   set ventas_nuevas 	= ventas_nuevas + _resultado_total_restante
				 where cod_vendedor 	= a_cod_vendedor
				   and cod_agente 		= _cod_agente
				   and cod_ramo   		= _cod_ramo
				   and periodo 			= _ano||"-01";
			end if
		end if	
let _resultado_total_restante = 0;
let _total_restante           = 0;			
		-- Febrero	
		if _feb <> 0 then	
			if _produccion = 0 then
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _feb_1 = _feb / _cnt_agente;
				
					update deivid_bo:preventas
					   set ventas_nuevas 	= _feb_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-02";
				end foreach
			else
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _feb_1 = _feb / _cnt_agente;
					
					update deivid_bo:preventas
					   set ventas_nuevas 	= ventas_nuevas + _feb_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-02";
				end foreach
			end if
			 select sum(ventas_nuevas) 
			   into _total_restante
			   from deivid_bo:preventas
			  where cod_vendedor 	= a_cod_vendedor
			    and cod_ramo   		= _cod_ramo
			    and periodo			= _ano||"-02"
			    and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
			    and ventas_nuevas <> 0;
				
			if _total_restante < _feb then
				let _resultado_total_restante =  _feb - _total_restante;
				update deivid_bo:preventas
				   set ventas_nuevas 	= ventas_nuevas + _resultado_total_restante
				 where cod_vendedor 	= a_cod_vendedor
				   and cod_agente 		= _cod_agente
				   and cod_ramo   		= _cod_ramo
				   and periodo 			= _ano||"-02";
			end if
		end if
let _resultado_total_restante = 0;
let _total_restante           = 0;			
		-- Marzo	
		if _mar <> 0 then	
			if _produccion = 0 then
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _mar_1 = _mar / _cnt_agente;
				
					update deivid_bo:preventas
					   set ventas_nuevas 	= _mar_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-03";
				end foreach
			else
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _mar_1 = _mar / _cnt_agente;
					
					update deivid_bo:preventas
					   set ventas_nuevas 	= ventas_nuevas + _mar_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-03";
				end foreach
			end if
			 select sum(ventas_nuevas) 
			   into _total_restante
			   from deivid_bo:preventas
			  where cod_vendedor 	= a_cod_vendedor
			    and cod_ramo   		= _cod_ramo
			    and periodo			= _ano||"-03"
			    and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
			    and ventas_nuevas <> 0;
				
			if _total_restante < _mar then
				let _resultado_total_restante =  _mar - _total_restante;
				update deivid_bo:preventas
				   set ventas_nuevas 	= ventas_nuevas + _resultado_total_restante
				 where cod_vendedor 	= a_cod_vendedor
				   and cod_agente 		= _cod_agente
				   and cod_ramo   		= _cod_ramo
				   and periodo 			= _ano||"-03";
			end if
		end if
let _resultado_total_restante = 0;
let _total_restante           = 0;	
		-- Abril	
		if _abr <> 0 then	
			if _produccion = 0 then
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _abr_1 = _abr / _cnt_agente;
				
					update deivid_bo:preventas
					   set ventas_nuevas 	= _abr_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-04";
				end foreach
			else
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _abr_1 = _abr / _cnt_agente;
					
					update deivid_bo:preventas
					   set ventas_nuevas 	= ventas_nuevas + _abr_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-04";
				end foreach
			end if
			 select sum(ventas_nuevas) 
			   into _total_restante
			   from deivid_bo:preventas
			  where cod_vendedor 	= a_cod_vendedor
			    and cod_ramo   		= _cod_ramo
			    and periodo			= _ano||"-04"
			    and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
			    and ventas_nuevas <> 0;
				
			if _total_restante < _abr then
				let _resultado_total_restante =  _abr - _total_restante;
				update deivid_bo:preventas
				   set ventas_nuevas 	= ventas_nuevas + _resultado_total_restante
				 where cod_vendedor 	= a_cod_vendedor
				   and cod_agente 		= _cod_agente
				   and cod_ramo   		= _cod_ramo
				   and periodo 			= _ano||"-04";
			end if
		end if	
let _resultado_total_restante = 0;
let _total_restante           = 0;	
		-- Mayo	
		if _may <> 0 then	
			if _produccion = 0 then
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _may_1 = _may / _cnt_agente;
				
					update deivid_bo:preventas
					   set ventas_nuevas 	= _may_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-05";
				end foreach
			else
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _may_1 = _may / _cnt_agente;
					
					update deivid_bo:preventas
					   set ventas_nuevas 	= ventas_nuevas + _may_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-05";
				end foreach
			end if
			 select sum(ventas_nuevas) 
			   into _total_restante
			   from deivid_bo:preventas
			  where cod_vendedor 	= a_cod_vendedor
			    and cod_ramo   		= _cod_ramo
			    and periodo			= _ano||"-05"
			    and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
			    and ventas_nuevas <> 0;
				
			if _total_restante < _may then
				let _resultado_total_restante =  _may - _total_restante;
				update deivid_bo:preventas
				   set ventas_nuevas 	= ventas_nuevas + _resultado_total_restante
				 where cod_vendedor 	= a_cod_vendedor
				   and cod_agente 		= _cod_agente
				   and cod_ramo   		= _cod_ramo
				   and periodo 			= _ano||"-05";
			end if
		end if
let _resultado_total_restante = 0;
let _total_restante           = 0;			
		-- Junio	
		if _jun <> 0 then	
			if _produccion = 0 then
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _jun_1 = _jun / _cnt_agente;
				
					update deivid_bo:preventas
					   set ventas_nuevas 	= _jun_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-06";
				end foreach
			else
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _jun_1 = _jun / _cnt_agente;
					
					update deivid_bo:preventas
					   set ventas_nuevas 	= ventas_nuevas + _jun_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-06";
				end foreach
			end if
			 select sum(ventas_nuevas) 
			   into _total_restante
			   from deivid_bo:preventas
			  where cod_vendedor 	= a_cod_vendedor
			    and cod_ramo   		= _cod_ramo
			    and periodo			= _ano||"-06"
			    and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
			    and ventas_nuevas <> 0;
				
			if _total_restante < _jun then
				let _resultado_total_restante =  _jun - _total_restante;
				update deivid_bo:preventas
				   set ventas_nuevas 	= ventas_nuevas + _resultado_total_restante
				 where cod_vendedor 	= a_cod_vendedor
				   and cod_agente 		= _cod_agente
				   and cod_ramo   		= _cod_ramo
				   and periodo 			= _ano||"-06";
			end if
		end if	
let _resultado_total_restante = 0;
let _total_restante           = 0;	
		-- Julio	
		if _jul <> 0 then	
			if _produccion = 0 then
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _jul_1 = _jul / _cnt_agente;
				
					update deivid_bo:preventas
					   set ventas_nuevas 	= _jul_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-07";
				end foreach
			else
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _jul_1 = _jul / _cnt_agente;
					
					update deivid_bo:preventas
					   set ventas_nuevas 	= ventas_nuevas + _jul_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-07";
				end foreach
			end if
			 select sum(ventas_nuevas) 
			   into _total_restante
			   from deivid_bo:preventas
			  where cod_vendedor 	= a_cod_vendedor
			    and cod_ramo   		= _cod_ramo
			    and periodo			= _ano||"-07"
			    and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
			    and ventas_nuevas <> 0;
				
			if _total_restante < _jul then
				let _resultado_total_restante =  _jul - _total_restante;
				update deivid_bo:preventas
				   set ventas_nuevas 	= ventas_nuevas + _resultado_total_restante
				 where cod_vendedor 	= a_cod_vendedor
				   and cod_agente 		= _cod_agente
				   and cod_ramo   		= _cod_ramo
				   and periodo 			= _ano||"-07";
			end if
		end if	
let _resultado_total_restante = 0;
let _total_restante           = 0;	
		-- Agosto	
		if _ago <> 0 then	
			if _produccion = 0 then
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _ago_1 = _ago / _cnt_agente;
				
					update deivid_bo:preventas
					   set ventas_nuevas 	= _ago_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-08";
				end foreach
			else
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _ago_1 = _ago / _cnt_agente;
					
					update deivid_bo:preventas
					   set ventas_nuevas 	= ventas_nuevas + _ago_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-08";
				end foreach
			end if
			 select sum(ventas_nuevas) 
			   into _total_restante
			   from deivid_bo:preventas
			  where cod_vendedor 	= a_cod_vendedor
			    and cod_ramo   		= _cod_ramo
			    and periodo			= _ano||"-08"
			    and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
			    and ventas_nuevas <> 0;
				
			if _total_restante < _ago then
				let _resultado_total_restante =  _ago - _total_restante;
				update deivid_bo:preventas
				   set ventas_nuevas 	= ventas_nuevas + _resultado_total_restante
				 where cod_vendedor 	= a_cod_vendedor
				   and cod_agente 		= _cod_agente
				   and cod_ramo   		= _cod_ramo
				   and periodo 			= _ano||"-08";
			end if
		end if
let _resultado_total_restante = 0;
let _total_restante           = 0;			
		-- Septiembre	
		if _sep <> 0 then	
			if _produccion = 0 then
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _sep_1 = _sep / _cnt_agente;
				
					update deivid_bo:preventas
					   set ventas_nuevas 	= _sep_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-09";
				end foreach
			else
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _sep_1 = _sep / _cnt_agente;
					
					update deivid_bo:preventas
					   set ventas_nuevas 	= ventas_nuevas + _sep_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-09";
				end foreach
			end if
             select sum(ventas_nuevas) 
			   into _total_restante
			   from deivid_bo:preventas
			  where cod_vendedor 	= a_cod_vendedor
			    and cod_ramo   		= _cod_ramo
			    and periodo			= _ano||"-09"
			    and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
			    and ventas_nuevas <> 0;
				
			if _total_restante < _sep then
				let _resultado_total_restante =  _sep - _total_restante;
				update deivid_bo:preventas
				   set ventas_nuevas 	= ventas_nuevas + _resultado_total_restante
				 where cod_vendedor 	= a_cod_vendedor
				   and cod_agente 		= _cod_agente
				   and cod_ramo   		= _cod_ramo
				   and periodo 			= _ano||"-09";
			end if
		end if	
let _resultado_total_restante = 0;
let _total_restante           = 0;	
		-- Octubre	
		if _oct <> 0 then	
			if _produccion = 0 then
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _oct_1 = _oct / _cnt_agente;
				
					update deivid_bo:preventas
					   set ventas_nuevas 	= _oct_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-10";
				end foreach
			else
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _oct_1 = _oct / _cnt_agente;
					
					update deivid_bo:preventas
					   set ventas_nuevas 	= ventas_nuevas + _oct_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-10";
				end foreach
			end if
		     select sum(ventas_nuevas) 
			   into _total_restante
			   from deivid_bo:preventas
			  where cod_vendedor 	= a_cod_vendedor
			    and cod_ramo   		= _cod_ramo
			    and periodo			= _ano||"-10"
			    and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
			    and ventas_nuevas <> 0;
				
			if _total_restante < _oct then
				let _resultado_total_restante =  _oct - _total_restante;
				update deivid_bo:preventas
				   set ventas_nuevas 	= ventas_nuevas + _resultado_total_restante
				 where cod_vendedor 	= a_cod_vendedor
				   and cod_agente 		= _cod_agente
				   and cod_ramo   		= _cod_ramo
				   and periodo 			= _ano||"-10";
			end if
		end if
let _resultado_total_restante = 0;
let _total_restante           = 0;			
		-- Noviembre	
		if _nov <> 0 then	
			if _produccion = 0 then
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _nov_1 = _nov / _cnt_agente;
				
					update deivid_bo:preventas
					   set ventas_nuevas 	= _nov_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-11";
				end foreach
			else
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _nov_1 = _nov / _cnt_agente;
					
					update deivid_bo:preventas
					   set ventas_nuevas 	= ventas_nuevas + _nov_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-11";
				end foreach
			end if
			 select sum(ventas_nuevas) 
			   into _total_restante
			   from deivid_bo:preventas
			  where cod_vendedor 	= a_cod_vendedor
			    and cod_ramo   		= _cod_ramo
			    and periodo			= _ano||"-11"
			    and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
			    and ventas_nuevas <> 0;
				
			if _total_restante < _nov then
				let _resultado_total_restante =  _nov - _total_restante;
				update deivid_bo:preventas
				   set ventas_nuevas 	= ventas_nuevas + _resultado_total_restante
				 where cod_vendedor 	= a_cod_vendedor
				   and cod_agente 		= _cod_agente
				   and cod_ramo   		= _cod_ramo
				   and periodo 			= _ano||"-11";
			end if			
		end if
let _resultado_total_restante = 0;
let _total_restante           = 0;			
		-- Diciembre	
		if _dic <> 0 then	
			if _produccion = 0 then
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _dic_1 = _dic / _cnt_agente;
				
					update deivid_bo:preventas
					   set ventas_nuevas 	= _dic_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-12";
				end foreach
			else
				foreach
					SELECT cod_agente
					  into _cod_agente
					  from deivid_tmp:preven2012
					 where cod_vendedor = a_cod_vendedor 
					   and tipo_mov 	= '5' 
					   and tipo_poliza 	= '4' 
					   and cod_ramo 	= _cod_ramo
					   and cod_agente in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
					   and total_2009 <> 0
					   
					let _dic_1 = _dic / _cnt_agente;
					
					update deivid_bo:preventas
					   set ventas_nuevas 	= ventas_nuevas + _dic_1
					 where cod_vendedor 	= a_cod_vendedor
					   and cod_agente 		= _cod_agente
					   and cod_ramo   		= _cod_ramo
					   and periodo 			= _ano||"-12";
				end foreach
			end if
				 select sum(ventas_nuevas) 
			   into _total_restante
			   from deivid_bo:preventas
			  where cod_vendedor 	= a_cod_vendedor
			    and cod_ramo   		= _cod_ramo
			    and periodo			= _ano||"-12"
			    and cod_agente not in(select cod_agente from deivid_bo:actuario_2018 where cod_vendedor = a_cod_vendedor and cod_ramo = _cod_ramo and tipo = 'N')
			    and ventas_nuevas <> 0;
				
			if _total_restante < _dic then
				let _resultado_total_restante =  _dic - _total_restante;
				update deivid_bo:preventas
				   set ventas_nuevas 	= ventas_nuevas + _resultado_total_restante
				 where cod_vendedor 	= a_cod_vendedor
				   and cod_agente 		= _cod_agente
				   and cod_ramo   		= _cod_ramo
				   and periodo 			= _ano||"-12";
			end if		
		end if			
end foreach

return 0, "Actualizacion Exitosa";

end procedure


