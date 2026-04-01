-- Procedimiento que carga los datos para el presupuesto del 2013
 
-- Creado     :	27/10/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo0682;		

create procedure "informix".sp_bo0682()
returning integer,
		  char(100);

define _cod_vendedor	char(3);
define _cod_ramo		char(3);
define _tipo_mov		char(1);
define _tipo_poliza		char(1);
define _cod_agente		char(5);
define _cnt_existe 		smallint;
define _cnt_vendedor 	smallint;
define _cnt_agentes 	smallint;
define _total_renov 	decimal(16,2);
define _total_nuevas 	decimal(16,2);
define _total_vendedor 	decimal(16,2);
define _total_corredor 	decimal(16,2);
define _nov 			decimal(16,2);
define _dic 			decimal(16,2);
define _prima_suscrita	dec(16,2); 
define _tot_estado      dec(16,2);
		
  foreach
	  select distinct(cod_vendedor)
		into _cod_vendedor
		from sac999:preven2010
			
		foreach
			 select distinct(cod_ramo)
			   into _cod_ramo
			   from sac999:preven2010
			--Noviembre
			foreach
				select tipo_mov,
					   tipo_poliza,
					   nov,
					   cod_agente
				  into _tipo_mov,
					   _tipo_poliza,
					   _nov,
					   _cod_agente
				  from sac999:preven2010
				 where cod_vendedor 	= _cod_vendedor
				   and cod_ramo 		= _cod_ramo
				   and tipo_mov    	    = "1"
				   and tipo_poliza 	    in(1,2)
				   and nov <> 0
			  order by 1,2

				select count(*)
				  into _cnt_agentes
				  from  sac999:preven2010
				 where tipo_mov    	    = _tipo_mov
				   and tipo_poliza 	    = _tipo_poliza
				   and cod_ramo 	 	= _cod_ramo
				   and cod_vendedor 	= _cod_vendedor
				   and nov 		 	    <> 0;
				   
			-- conteo de vendedores
			 select count(distinct(cod_vendedor))
			   into _cnt_vendedor
			   from sac999:preven2010
			  where tipo_mov    = _tipo_mov
                and tipo_poliza = _tipo_poliza
                and cod_ramo    = _cod_ramo
                and nov         <> 0;
				
				--nuevas 
				if _tipo_poliza = "1" and _tipo_mov = "1" then
					 select count(*)
					   into _cnt_existe
					   from sac999:forecast
					  where cod_ramo = _cod_ramo
						and periodo[6,7] = '11';
						
					if _cnt_existe > 0 then
						 select tot_nueva
						   into _total_nuevas
						   from sac999:forecast
						  where cod_ramo = _cod_ramo
							and periodo[6,7] = '11';
							
						if _nov <> 0 then				
							 let _total_vendedor = _total_nuevas/_cnt_vendedor; 
							 let _total_corredor = _total_vendedor/_cnt_agentes;
							 let _prima_suscrita = _total_corredor;
						else
							 let _prima_suscrita = 0.00;
						end if
					end if
					
				update sac999:preven2010
				   set nov          = _prima_suscrita
				 where cod_vendedor = _cod_vendedor
				   and cod_ramo     = _cod_ramo
				   and tipo_mov     = _tipo_mov
				   and tipo_poliza  = _tipo_poliza
				   and cod_agente   = _cod_agente;
				   
				end if
				-- Renovadas
				if _tipo_poliza = "2" and _tipo_mov = "1" then
					 select count(*)
					   into _cnt_existe
					   from sac999:forecast
					  where cod_ramo 		= _cod_ramo
						and periodo[6,7] 	= '11';
					if _cnt_existe > 0 then
						 select tot_renov
						   into _total_renov
						   from sac999:forecast
						  where cod_ramo 	 = _cod_ramo
							and periodo[6,7] = '11';
							
						if _nov <> 0 then		
							 let _total_vendedor = _total_renov/_cnt_vendedor; 
							 let _total_corredor = _total_vendedor/_cnt_agentes;
							 let _prima_suscrita = _total_corredor;
						else
							 let _prima_suscrita = 0.00;
						end if
					end if
					
				update sac999:preven2010
				   set nov          = _prima_suscrita
				 where cod_vendedor = _cod_vendedor
				   and cod_ramo     = _cod_ramo
				   and tipo_mov     = _tipo_mov
				   and tipo_poliza  = _tipo_poliza
				   and cod_agente   = _cod_agente;
					
				end if
			end foreach
			
			--Diciembre
			foreach
				select tipo_mov,
					   tipo_poliza,
					   dic,
					   cod_agente
				  into _tipo_mov,
					   _tipo_poliza,
					   _dic,
					   _cod_agente
				  from sac999:preven2010
				 where cod_vendedor 	= _cod_vendedor
				   and cod_ramo 		= _cod_ramo
				   and tipo_mov    	    = "1"
				   and tipo_poliza 	    in(1,2)
				   and dic			    <> 0
			  order by 1,2

				select count(*)
				  into _cnt_agentes
				  from  sac999:preven2010
				 where tipo_mov    	    = _tipo_mov
				   and tipo_poliza 	    = _tipo_poliza
				   and cod_ramo 	 	= _cod_ramo
				   and cod_vendedor 	= _cod_vendedor
				   and dic 		 		<> 0;
			-- conteo de vendedores
				 select count(distinct(cod_vendedor))
				   into _cnt_vendedor
				   from sac999:preven2010
				  where tipo_mov    = _tipo_mov
					and tipo_poliza = _tipo_poliza
					and cod_ramo    = _cod_ramo
					and dic         <> 0;				   
				--nuevas 
				if _tipo_poliza = "1" and _tipo_mov = "1" then
					 select count(*)
					   into _cnt_existe
					   from sac999:forecast
					  where cod_ramo = _cod_ramo
						and periodo[6,7] = '12';
						
					if _cnt_existe > 0 then
						 select tot_nueva
						   into _total_nuevas
						   from sac999:forecast
						  where cod_ramo = _cod_ramo
							and periodo[6,7] = '12';
							
						if _dic <> 0 then				
							 let _total_vendedor = _total_nuevas/_cnt_vendedor; 
							 let _total_corredor = _total_vendedor/_cnt_agentes;
							 let _prima_suscrita = _total_corredor;
						else
							 let _prima_suscrita = 0.00;
						end if
					end if
					
				update sac999:preven2010
				   set dic          = _prima_suscrita
				 where cod_vendedor = _cod_vendedor
				   and cod_ramo     = _cod_ramo
				   and tipo_mov     = _tipo_mov
				   and tipo_poliza  = _tipo_poliza
				   and cod_agente   = _cod_agente;
				   
				end if
				-- Renovadas
				if _tipo_poliza = "2" and _tipo_mov = "1" then
					 select count(*)
					   into _cnt_existe
					   from sac999:forecast
					  where cod_ramo 		= _cod_ramo
						and periodo[6,7] 	= '12';
					if _cnt_existe > 0 then
						 select tot_renov, tot_estado
						   into _total_renov,_tot_estado
						   from sac999:forecast
						  where cod_ramo 	 = _cod_ramo
							and periodo[6,7] = '12';
							
						if _dic <> 0 then		
							 let _total_vendedor = _total_renov/_cnt_vendedor; 
							 let _total_corredor = _total_vendedor/_cnt_agentes;
							 let _prima_suscrita = _total_corredor;
							 
							 if _cod_vendedor = '047' then
								let _tot_estado = _tot_estado/_cnt_agentes;
								let _prima_suscrita = _prima_suscrita + _tot_estado;
							 end if
						else
							 let _prima_suscrita = 0.00;
						end if
					end if
					
				update sac999:preven2010
				   set dic          = _prima_suscrita
				 where cod_vendedor = _cod_vendedor
				   and cod_ramo     = _cod_ramo
				   and tipo_mov     = _tipo_mov
				   and tipo_poliza  = _tipo_poliza
				   and cod_agente   = _cod_agente;
					
				end if
			end foreach

		end foreach
	end foreach
	return 0, "Actualizacion Exitosa";

end procedure