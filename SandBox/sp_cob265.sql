-- Proceso Generar el informe de Morosidad por Corredor
-- Creado por :     Roman Gordon	07/02/2011
-- SIS v.2.0 - DEIVID, S.A.


Drop Procedure sp_cob265;

Create Procedure "informix".sp_cob265(a_cod_agente char(5), a_compania char(3), a_sucursal char(3))
Returning char(100),	--cliente
		  char(20),		--no_poliza       
		  char(50),		--ramo		      	  
		  char(10),		--estatus_poliza  
		  char(50),		--forma_pago
		  char(50),		--acreedor      
		  date,			--vigencia_inic   
		  integer,		--vig_fin_dia  char(2),	  
		  integer,		--vig_fin_mes  char(2),	  
		  integer,		--vig_fin_anio char(4),		  
		  date,			--fecha_utl_pago	  
		  dec(16,2),	--mont_ult_pago		  
		  dec(16,2),	--prima_bruta		  
		  dec(16,2),	--saldo				  
		  dec(16,2),	--por_vencer		  
		  dec(16,2),	--exigible			  
		  dec(16,2),	--corriente			  
		  dec(16,2),	--monto30			  
		  dec(16,2),	--monto60			  
		  dec(16,2),	--monto90			  
		  dec(16,2),	--monto120			  
		  dec(16,2),	--monto150			  
		  dec(16,2),	--monto180			  
		  smallint,		--no_pagos
		  varchar(30),	--cedula					  
		  char(50),		--compania					  
		  char(100),	--agente			  
		  smallint;		--aviso_canc
		
		
Define _cedula				varchar(30);			
Define _nombre_agente		char(100);
Define _nombre_cliente		char(100);
Define _email_agente		char(50);
Define _nom_formapag		char(50);
Define _nom_ramo			char(50);
Define _nom_acre			char(50);
Define v_compania_nombre	char(50);
Define _no_documento		char(20);
Define _cod_cliente			char(10);
Define _no_poliza			char(10);
Define _status_poliza		char(10);
Define _periodo				char(7);
Define _cod_acre			char(5);
Define _vig_fin_anio		char(4);
Define _cod_formapag		char(3);
Define _cod_pagos			char(3);
Define _cod_ramo			char(3);
Define _vig_fin_dia 		char(2);
Define _vig_fin_mes 		char(2);
Define _fecha_hoy			date;
Define _fecha_ult_pago		date;
Define _vigencia_inic		date;
Define _vigencia_fin		date;
Define _cod_estatus			smallint;
Define _cant_pagos			smallint;
Define _carta_aviso_canc	smallint;
Define _vig_fin_dia_int		integer;
Define _vig_fin_mes_int		integer;
Define _vig_fin_anio_int	integer;
Define _monto_ult_pago		dec(16,2);
Define _saldo				dec(16,2);
Define _por_vencer			dec(16,2);
Define _exigible			dec(16,2);
Define _corriente			dec(16,2);
Define _monto_30			dec(16,2);
Define _monto_60			dec(16,2);
Define _monto_90			dec(16,2);
Define _monto_120			dec(16,2);
Define _monto_150			dec(16,2);
Define _monto_180			dec(16,2);
Define _prima_bruta			dec(16,2);
Define _monto				dec(16,2);
Define _saldo_acum			dec(16,2);
Define _por_vencer_acum		dec(16,2);
Define _exigible_acum		dec(16,2);
Define _corriente_acum		dec(16,2);
Define _monto_30_acum		dec(16,2);
Define _monto_60_acum		dec(16,2);
Define _monto_90_acum		dec(16,2);
Define _prima_bruta_acum	dec(16,2);
Define _monto_120_acum		dec(16,2);
Define _monto_150_acum		dec(16,2);
Define _monto_180_acum		dec(16,2);
Define _leasing             smallint;


SET ISOLATION TO DIRTY READ;

--set debug file to "sp_cob265.trc";
--trace on;

 CREATE TEMP TABLE temp_morosidad_corredor
             (no_poliza      	char(20),							
              ramo			   	char(50),					 			
              cliente     		char(100),
              cedula			varchar(30),				
              estatus_poliza   	char(10),					
              forma_pago    	char(50),
              acreedor			char(50),					
              vigencia_inic   	date,						
              vig_fin_dia	   	integer,
              vig_fin_mes		integer,
              vig_fin_anio		integer,	
              fecha_utl_pago	date,						
              monto_ult_pago	dec(16,2),					
              prima_bruta		dec(16,2),					
              saldo				dec(16,2),					
              por_vencer		dec(16,2),					
              exigible			dec(16,2),					
              corriente			dec(16,2),					
              monto30			dec(16,2),					
              monto60			dec(16,2),					
              monto90			dec(16,2),					
              monto120			dec(16,2),					
              monto150			dec(16,2),					
              monto180			dec(16,2),					
              no_pagos			smallint,					
              agente			char(100),					
              compania			char(50),
              carta_aviso_canc	smallint) WITH NO LOG;


let	_no_documento	= '';
let _email_agente	= '';
let _leasing        = 0;

	
LET v_compania_nombre = sp_sis01(a_compania);
LET _fecha_hoy = today;
LET _periodo = sp_sis39(_fecha_hoy);

Select nombre
  into _nombre_agente
  from agtagent
 where cod_agente = a_cod_agente;

foreach
	   {	Select no_poliza
		  into _no_poliza
		  from emipoagt
		 where cod_agente = a_cod_agente
		   and porc_partic_agt >= 50}

		Select no_documento
		  into _no_documento
		  from emipoliza
		 where cod_agente = a_cod_agente


		let	_nombre_cliente	= '';
		let	_cod_cliente	= '';	
		let	_no_poliza		= '';
		let	_cod_formapag	= '';
		let _nom_acre		= '';
		let	_fecha_ult_pago	= null;
		let	_vigencia_inic	= '01/01/1900';
		let	_vigencia_fin	= '01/01/1900';
		let	_cod_estatus	= 0;
		let	_cant_pagos		= 0;	
		
			let _no_poliza = sp_sis21(_no_documento);

			Select no_documento,
				   cod_formapag,
				   prima_bruta,
				   cod_pagador,
				   carta_aviso_canc,
				   no_pagos,
				   leasing
			  into _no_documento,
			  	   _cod_formapag,
				   _prima_bruta,
				   _cod_cliente,
				   _carta_aviso_canc,
				   _cant_pagos,
				   _leasing
			  from emipomae
			 where no_poliza = _no_poliza;
			
			if _cod_formapag  = '084' or _cod_formapag = '085' then
				continue foreach;
			end if   

			--trace on;
			let _nom_acre = '... SIN ACREEDOR ...';
			let _cod_acre    = '';

			foreach
				Select cod_acreedor
				  into _cod_acre
				  from emipoacr
				 where no_poliza = _no_poliza
				 order by no_unidad
				 
				if _cod_acre is not null then
					Select nombre
					  into _nom_acre
					  from emiacre
					 where cod_acreedor = _cod_acre;
					exit foreach;
				end if
			end foreach

			if _cod_acre is null then
				let _cod_acre = '';
			end if

			if _leasing = 1 then --Tiene leasing

			  foreach
				  SELECT emipouni.cod_asegurado,   
				         cliclien.nombre
				    INTO _cod_acre,
				         _nom_acre      
				    FROM cliclien,   
				         emipouni  
				   WHERE (cliclien.cod_cliente = emipouni.cod_asegurado)
				     and ((emipouni.no_poliza  = _no_poliza))   
				GROUP BY emipouni.cod_asegurado,   
				         cliclien.nombre
			   exit foreach;
			  end foreach

			end if

			Select cod_status,				       
				   vigencia_inic,
				   vigencia_fin,
				   cod_ramo
			  into _cod_estatus,					   
				   _vigencia_inic,
				   _vigencia_fin,
				   _cod_ramo
			  from emipoliza
			 where no_documento = _no_documento;				   
			
			let _vig_fin_dia = day(_vigencia_fin);
			let _vig_fin_mes = month(_vigencia_fin);
			let _vig_fin_anio = year(_vigencia_fin);

			let _vig_fin_dia_int =	cast(_vig_fin_dia as integer);
			let _vig_fin_mes_int =	cast(_vig_fin_mes as integer) ;	
			let _vig_fin_anio_int = cast(_vig_fin_anio as integer);

			--trace off;
			let	_monto_ult_pago	= 0.00;
			let	_saldo			= 0.00;
			let	_por_vencer		= 0.00;
			let	_exigible		= 0.00;
			let	_corriente		= 0.00;
			let	_monto_30		= 0.00;
			let	_monto_60		= 0.00;
			let	_monto_90		= 0.00;
			--let	_prima_bruta	= 0.00;
			let	_monto_120		= 0.00;
			let	_monto_150		= 0.00;
			let	_monto_180		= 0.00;
						
			CALL sp_cob245(
				 "001",
				 "001",	
				 _no_documento,
				 _periodo,
				 _fecha_hoy
				 ) RETURNING _por_vencer,
							 _exigible,  
							 _corriente, 
							 _monto_30,  
							 _monto_60,  
							 _monto_90,
							 _monto_120,
							 _monto_150,
							 _monto_180,
							 _saldo;
					 
			if _saldo < 2.50 then
				continue foreach;
			end if

			{let _saldo_acum			= _saldo_acum		+ _saldo;  	
			let _por_vencer_acum	= _por_vencer_acum	+ _por_vencer;
			let _exigible_acum		= _exigible_acum	+ _exigible; 	
			let _corriente_acum		= _corriente_acum	+ _corriente;	
			let _monto_30_acum		= _monto_30_acum	+ _monto_30; 	
			let _monto_60_acum		= _monto_60_acum	+ _monto_60; 	
			let _monto_90_acum		= _monto_90_acum	+ _monto_90;				
			let _monto_120_acum		= _monto_120_acum	+ _monto_120;	
			let _monto_150_acum		= _monto_150_acum	+ _monto_150;	
			let _monto_180_acum		= _monto_180_acum	+ _monto_180;	
			let _prima_bruta_acum	= _prima_bruta_acum	+ _prima_bruta;	 }


			Select nombre
			  into _nom_ramo
			  from prdramo
			 where cod_ramo = _cod_ramo;
							
			if _cod_estatus = 1 then
				let _status_poliza = 'Vigente';
			elif _cod_estatus = 2 then
				let _status_poliza = 'Cancelada';
			elif _cod_estatus = 3 then
				let _status_poliza = 'Vencida';
			elif _cod_estatus = 4 then
				let _status_poliza = 'Anulada';
			end if  
			 
			foreach
				SELECT fecha,
					   monto
				  INTO _fecha_ult_pago,
				       _monto_ult_pago
				  FROM cobredet
				 WHERE doc_remesa   = _no_documento	-- Recibos de la Poliza
			       AND actualizado  = 1			    -- Recibo este actualizado
				   AND tipo_mov     = 'P'       	-- Pago de Prima(P)
				 order by 1 desc
				exit foreach;
			end foreach

			Select nombre
			  into _nom_formapag
			  from cobforpa
			 where cod_formapag = _cod_formapag;

			 
			Select nombre,
				   cedula
			  into _nombre_cliente,
				   _cedula
			  from cliclien
			 where cod_cliente = _cod_cliente;

			insert into temp_morosidad_corredor
			values (_no_documento,	
					_nom_ramo,		
					_nombre_cliente,
					_cedula,	
					_status_poliza,	
					_nom_formapag,
					_nom_acre,	
					_vigencia_inic,	
					_vig_fin_dia_int, 	
					_vig_fin_mes_int, 	
					_vig_fin_anio_int,	
					_fecha_ult_pago,	
					_monto_ult_pago,	
					_prima_bruta,	
					_saldo,			
					_por_vencer,		
					_exigible,		
					_corriente,		
					_monto_30,		
					_monto_60,		
					_monto_90,		
					_monto_120,		
					_monto_150,		
					_monto_180,		
					_cant_pagos,		
					_nombre_agente,	
					v_compania_nombre,
					_carta_aviso_canc);

end foreach
			
foreach
		Select no_poliza,      	 
			   ramo,			 
			   cliente,     	 
			   cedula,			 
			   estatus_poliza,	   
			   forma_pago,  
			   acreedor,  	 
			   vigencia_inic, 	  
			   vig_fin_dia,		 
			   vig_fin_mes,		 
			   vig_fin_anio,	 
			   fecha_utl_pago,	   
			   monto_ult_pago,	  
			   prima_bruta,		 
			   saldo,			   
			   por_vencer,		   
			   exigible,		 
			   corriente,		   
			   monto30,			 
			   monto60,			 
			   monto90,			 
			   monto120,		   
			   monto150,		   
			   monto180,		   
			   no_pagos,		  
			   agente,			  
			   compania,
			   carta_aviso_canc			 	  
		  into _no_documento,			  
		  	   _nom_ramo,				  
		  	   _nombre_cliente,
		  	   _cedula,	
		  	   _status_poliza,	
		  	   _nom_formapag,
		  	   _nom_acre,	
		  	   _vigencia_inic,	
		  	   _vig_fin_dia_int, 	
		  	   _vig_fin_mes_int, 	
		  	   _vig_fin_anio_int,			  	   	
		  	   _fecha_ult_pago,	
		  	   _monto_ult_pago,	
		  	   _prima_bruta,	
		  	   _saldo,			
		  	   _por_vencer,		
		  	   _exigible,		
		  	   _corriente,		
		  	   _monto_30,		
		  	   _monto_60,		
		  	   _monto_90,		
		  	   _monto_120,		
		  	   _monto_150,		
		  	   _monto_180,		
		  	   _cant_pagos,		
		  	   _nombre_agente,	
		  	   v_compania_nombre,
			   _carta_aviso_canc
		  from temp_morosidad_corredor			   

		  Return _nombre_cliente,
		  		 _no_documento,				
		  		 _nom_ramo,				
				 _status_poliza,	
				 _nom_formapag,	
				 _nom_acre,	
				 _vigencia_inic,	
				 _vig_fin_dia_int,	
				 _vig_fin_mes_int,	
				 _vig_fin_anio_int,	
				 _fecha_ult_pago,	
				 _monto_ult_pago,	
				 _prima_bruta,		
				 _saldo,			
				 _por_vencer,		
				 _exigible,			
				 _corriente,		
				 _monto_30,			
				 _monto_60,			
				 _monto_90,			
				 _monto_120,		
				 _monto_150,		
				 _monto_180,		
				 _cant_pagos,		
				 _cedula,				
				 v_compania_nombre,
				 _nombre_agente,	
				 _carta_aviso_canc	
				 with resume;									
end foreach	
	
	drop table temp_morosidad_corredor;											
																	
end procedure														
																	
																	                                                                                                                                                                                 
