-- Proceso Generar el informe de Morosidad por Corredor	para los Ramos Personales
-- Creado por :     Roman Gordon	08/02/2011
-- SIS v.2.0 - DEIVID, S.A.


drop procedure sp_cob266;
Create Procedure sp_cob266(a_cod_agente char(5), a_compania char(3), a_sucursal char(3))
Returning char(100),  	 -- 2_nombre_cliente,		 
		  char(20),		 -- 1_no_documento,			 
		  char(50),		 -- 11_nom_ramo,			 
		  char(10),		 -- 10_status_poliza,		 
		  char(50),		 -- 9_nom_formapag,
		  char(50),		 -- acreedor		  	 
		  date,			 -- 4_vigencia_inic,		 
		  integer,		 -- 5_vig_fin_dia,			 
		  integer,		 -- 6_vig_fin_mes,			 
		  integer,		 -- 7_vig_fin_anio,			 
		  date,			 -- 20_fecha_ult_pago,		 
		  dec(16,2),  	 -- 19_monto_ult_pago,		 
		  dec(16,2),  	 -- _prima_bruta 		 	 
		  dec(16,2),  	 -- 12_saldo,			 	 
		  dec(16,2),  	 -- 13_por_vencer,		 	 
		  dec(16,2),  	 -- 14_exigible,		 	 
		  dec(16,2),  	 -- 15_corriente,		 	 
		  dec(16,2),  	 -- 16_monto_30		 		 
		  dec(16,2),  	 -- 17_monto_60,		 	 
		  date,			 -- 18_fecha_aviso_canc		 
		  smallint,		 -- 8_cant_pagos,			 
		  varchar(30),	 -- 3_cedula				 
		  char(100),	 -- 23_nombre_agente,		 
		  char(50),		 -- 24v_compania_nombre,
		  smallint;		 -- 25_aviso_cancelacion

Define _cedula				varchar(30);			
Define _nombre_agente		char(100);
Define _nombre_cliente		char(100);
Define _email_agente		char(50);
Define _nom_formapag		char(50);
Define _nom_ramo			char(50);
Define _nom_cobrador		char(50);
Define _nom_vendedor		char(50);
Define _nom_acre			char(50);
Define _no_documento		char(20);
Define _cod_cliente			char(10);
Define _no_poliza			char(10);
Define _status_poliza		char(10);  
Define _periodo2			char(7);
Define _cod_acre			char(5);
Define _vig_fin_anio		char(4);
Define _cod_formapag		char(3);
Define _cod_pagos			char(3);
Define _cod_ramo			char(3);
Define _cod_tiporamo		char(3);
Define _cod_cobrador		char(3);
Define _cod_vendedor		char(3);
Define _vig_fin_dia			char(2);
Define _vig_fin_mes			char(2);
Define _fecha_ult_pago		date;
Define _vigencia_inic		date;
Define _vigencia_fin		date;
Define _vig_fin_dia_int		integer;
Define _vig_fin_mes_int		integer;
Define _vig_fin_anio_int	integer;
Define _cod_estatus			smallint;
Define _cant_pagos			smallint;
Define _carta_aviso_canc	smallint;
Define _monto_ult_pago		dec(16,2);
Define _saldo				dec(16,2);
Define _por_vencer			dec(16,2);
Define _exigible			dec(16,2);
Define _corriente			dec(16,2);
Define _monto_30			dec(16,2);
Define _monto_60			dec(16,2);
Define _monto_90			dec(16,2);
Define _prima_bruta			dec(16,2);
Define _monto				dec(16,2);
Define v_compania_nombre	char(50);
Define _fecha_aviso_canc	date;
Define _fecha_hoy			date;
define _leasing             smallint;

SET ISOLATION TO DIRTY READ;

--set debug file to "sp_cob265.trc";
--trace on;

let	_no_documento	= '';
let _fecha_hoy    = today;
let _periodo2		= sp_sis39(_fecha_hoy);	
let	v_compania_nombre = sp_sis01(a_compania);
let _leasing      = 0;
let	_no_poliza		= '';
Select nombre
  into _nombre_agente
  from agtagent
 where cod_agente = a_cod_agente; 

-- RGORDON:Se incluye join con emipoagt HGIRON 11/06/208
 foreach
	select a.no_documento, a.no_poliza
	  into _no_documento, _no_poliza
	  from emipoliza a, emipoagt b
	 where a.cod_agente = a_cod_agente
       and a.no_poliza  = b.no_poliza
       and a.cod_agente = b.cod_agente

		let	_nombre_cliente	= '';
		
		let	_cod_cliente	= '';	
--		let	_no_poliza		= '';
		let	_cod_formapag	= '';
		let _email_agente	= '';
		let	_fecha_ult_pago	= null;
		let	_vigencia_inic	= null;
		let	_vigencia_fin	= null;
		let	_cod_estatus	= 0;
		let	_cant_pagos		= 0;	
		let	_monto_ult_pago	= 0.00;
		let	_saldo			= 0.00;
		let	_prima_bruta	= 0.00;

	--	let _no_poliza = sp_sis21(_no_documento);
		   	
			Select cod_formapag,
				   prima_bruta,
				   cod_pagador,
				   carta_aviso_canc,
				   fecha_aviso_canc,
				   no_pagos
			  into _cod_formapag,
				   _prima_bruta,
				   _cod_cliente,
				   _carta_aviso_canc,
				   _fecha_aviso_canc,
				   _cant_pagos
			  from emipomae
			 where no_poliza = _no_poliza;
			
			--if _carta_aviso_canc = 0 then
			--	continue foreach;
			--end if
			
			if _cod_formapag  = '084' or _cod_formapag = '085' or _cod_formapag = '089' then
				continue foreach;
			end if   

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
			
			let _vig_fin_dia  = day(_vigencia_fin);
			let _vig_fin_mes  = month(_vigencia_fin);
			let _vig_fin_anio = year(_vigencia_fin); 
			let _vig_fin_dia_int  =	cast(_vig_fin_dia as integer);
			let _vig_fin_mes_int  =	cast(_vig_fin_mes as integer) ;
			let _vig_fin_anio_int =	cast(_vig_fin_anio as integer);


			Select nombre,
				   cod_tiporamo
			  into _nom_ramo,
				   _cod_tiporamo
			  from prdramo
			 where cod_ramo = _cod_ramo;

			if _cod_tiporamo <> '001' then
				continue foreach;
			end if
			
			let	_por_vencer		= 0.00;
			let	_exigible		= 0.00;
			let	_corriente		= 0.00;
			let	_monto_30		= 0.00;
			let	_monto_60		= 0.00;
			let	_monto_90		= 0.00;

			--Morosidad Total
			CALL sp_cob33(a_compania,a_sucursal,_no_documento,_periodo2,_fecha_hoy)			
			RETURNING  _por_vencer,
					  _exigible,
					  _corriente,
					  _monto_30,
					  _monto_60,
					  _monto_90,
					  _saldo;


			let _monto_60 = _monto_60 + _monto_90;
			 
			if _saldo < 2.50 or _monto_60 <= 2.50 then
				continue foreach;
			end if
		  
									
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

		   --	CALL sp_cob263(_no_documento) RETURNING _cant_pagos;
			 
			Select nombre,
				   cedula
			  into _nombre_cliente,
				   _cedula
			  from cliclien
			 where cod_cliente = _cod_cliente;

			Return _nombre_cliente,		  -- 2_nombre_cliente,		 			  
				   _no_documento,		  -- 1_no_documento,			 			  
				   _nom_ramo,		   	  -- 11_nom_ramo,
				   _status_poliza,		  -- 10_status_poliza,
				   _nom_formapag,		  -- 9_nom_formapag,
				   _nom_acre,			  -- acreedor			 	
				   _vigencia_inic,		  -- 4_vigencia_inic,		 		  	  
				   _vig_fin_dia_int,	  -- 5_vig_fin_dia,			  	 			  
				   _vig_fin_mes_int,	  -- 6_vig_fin_mes,			 			  
				   _vig_fin_anio_int,	  -- 7_vig_fin_anio,		 		  	  
				   _fecha_ult_pago,		  -- 20_fecha_ult_pago,		 		  	  							   		
				   _monto_ult_pago,		  -- 19_monto_ult_pago,	
				   _prima_bruta,	 	  -- _prima_bruta 		 	    		   							  
				   _saldo,			  	  -- 12_saldo,			 	 		  	  
				   _por_vencer,		  	  -- 13_por_vencer,		 	 		  	  
				   _exigible,		 	  -- 14_exigible,		 	 		  	  
				   _corriente,		  	  -- 15_corriente,		 	 		  	  
				   _monto_30,		  	  -- 16_monto_30		 	 		  	  
				   _monto_60,		  	  -- 17_monto_60,		 	 		  	  
				   _fecha_aviso_canc,	  -- 18_fecha_aviso_canc	 		   	  
				   _cant_pagos,			  -- 8_cant_pagos,				 	
				   _cedula,			  	  -- 3_cedula				 	   		  
				    _nombre_agente,		  -- 23_nombre_agente,			 			  
				    v_compania_nombre,    -- 24v_compania_nombre,	 		  	  
				    _carta_aviso_canc	  -- 25_aviso_cancelacion			    
				   with resume;		  
    let	_no_poliza		= '';
	end foreach
end procedure;