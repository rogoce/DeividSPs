--      Polizas vigentes        --
----    Federico Coronado

drop procedure sp_rep14;
create procedure sp_rep14()
returning	char(3),
			char(50),
			char(20),
			char(5),
			char(3),
			varchar(30),
			varchar(15),
			varchar(50),
			dec(16,2),
			varchar(50),
			varchar(50),
			dec(9,6),
			dec(16,2),
			dec(5,2),
			varchar(50),
			varchar(50),
			date,
			date;   
			
	begin

	define v_no_documento					varchar(20); 
	define v_no_unidad						varchar(5); 
	define v_nombre_ramo					varchar(50);  
	define v_cod_ramo						varchar(3);
	define v_no_poliza      				varchar(10);
	define v_suma_asegurada 				dec(16,2);
	define v_cod_asegurado  				varchar(10);
	define v_cod_manzana    				varchar(15);
	define v_cod_cober_reas 				char(3);
	define v_cod_contrato   				varchar(10);
	define v_porc_partic_prima 				dec(9,6);
	define v_cod_ubica         				char(3);
	define v_cedula             			varchar(30);
	define v_nombre_asegurado   			varchar(50);
	define v_nombre_contrato    			varchar(50);
	define v_nombre_cober_rea   			varchar(50);
	define v_prima_neta         		    dec(16,2);
	define v_vigencia_final,v_vigencia_inic date;
	define v_comision                       dec(5,2);
	define v_cod_agente                     varchar(10);
	define v_nombre_agente                  varchar(50);
	define _max_cambio                      smallint;

	--SET DEBUG FILE TO "sp_rep14.trc"; 
	--trace on;

	set isolation to dirty read;

		foreach
			select cod_ramo,
			       no_poliza, 
				   no_documento,
				   vigencia_inic,
				   vigencia_final
			  into v_cod_ramo,
			       v_no_poliza,
				   v_no_documento,
				   v_vigencia_inic,
				   v_vigencia_final
			  from emipomae 
			 where actualizado 		= 1
               and estatus_poliza 	= 1
               and cod_ramo in ('001','003','005','006','007','009','010','011','013','014','015','017','022')
			   --and no_poliza = '944083'
			foreach   
				   select cod_agente,
						  porc_comis_agt
					 into v_cod_agente,
						  v_comision
					 from emipoagt
					where no_poliza = v_no_poliza
					
					select nombre
					  into v_nombre_agente
					  from agtagent
					 where cod_agente = v_cod_agente; 
				   
				foreach   
				   select cod_asegurado,
						  no_unidad,
						  suma_asegurada, 
						  cod_manzana,
						  prima_neta
					 into v_cod_asegurado,
						  v_no_unidad,
						  v_suma_asegurada,
						  v_cod_manzana,
						  v_prima_neta
					 from emipouni 
					where no_poliza = v_no_poliza
					
					select cedula, 
						   nombre_razon
					  into v_cedula,
						   v_nombre_asegurado
					  from cliclien
					 where cod_cliente = v_cod_asegurado;
					 
					select nombre
					  into v_nombre_ramo
					  from prdramo
					 where cod_ramo = v_cod_ramo;
					
					select cod_ubica
					  into v_cod_ubica
					  from emicupol
					 where no_poliza = v_no_poliza
					   and no_unidad = v_no_unidad;
					   
					select max(no_cambio)
					  into _max_cambio
					  from emireama
					 where no_poliza = v_no_poliza
					   and no_unidad = v_no_unidad;			   
					
					foreach
						select cod_cober_reas, 
							   cod_contrato, 
							   porc_partic_prima
						  into v_cod_cober_reas,
							   v_cod_contrato,
							   v_porc_partic_prima
						  from emireaco
						 where no_poliza = v_no_poliza
						   and no_unidad = v_no_unidad
						   and no_cambio = _max_cambio
						   
						select nombre
						  into v_nombre_contrato
						  from reacomae
						 where cod_contrato = v_cod_contrato;

						select nombre
						  into v_nombre_cober_rea
						  from reacobre
						 where cod_ramo = v_cod_ramo
						   and cod_cober_reas = v_cod_cober_reas;
						   
						
					
						return v_cod_ramo,            	-- ramo
							   v_nombre_ramo,         	-- nombre_ramo
							   v_no_documento,        	-- no_documento
							   v_no_unidad,           	-- unidad
							   v_cod_ubica,			  	-- zona_cresta
							   v_cedula, 			  	-- cedula
							   v_cod_manzana,         	-- cod_manzana
							   v_nombre_asegurado,     	-- nombre asegurado
							   v_suma_asegurada,        -- suma_asegurada
							   v_nombre_contrato,       -- nombre_contrato
							   v_nombre_cober_rea,      -- nombre cobertura reas
							   v_porc_partic_prima,     -- porc_comis_agt
							   v_prima_neta,            -- prima_neta 
							   v_comision,              -- v_comision
							   v_cod_agente,                     
							   v_nombre_agente,         -- v_nombre_agente
							   v_vigencia_inic,         -- v_vigencia_inic
							   v_vigencia_final         -- v_vigencia_final
							   with resume;
					end foreach  
				end foreach
			end foreach	
		end foreach

	end

end procedure;