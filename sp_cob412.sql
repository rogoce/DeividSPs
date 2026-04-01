--*****************************************************************
-- Procedimiento que Genera TXT - VOCEM
--*****************************************************************
-- Execute procedure sp_cob412()
-- Creado    : 26/06/2018      -- Autor: Henry Giron

DROP PROCEDURE sp_cob412;
CREATE PROCEDURE sp_cob412()
RETURNING VARCHAR(20)	as	no_documento	,
		VARCHAR(10)	as	vigencia_inic	,
		VARCHAR(10)	as	vigencia_fin	,
		VARCHAR(16)	as	exigible	,
		VARCHAR(16)	as	por_vencer	,
		VARCHAR(16)	as	corriente	,
		VARCHAR(16)	as	monto_30	,
		VARCHAR(16)	as	monto_60	,
		VARCHAR(16)	as	monto_90	,
		VARCHAR(10)	as	fecha_cubierto	,
		VARCHAR(10)	as	fecha_suspension	,
		VARCHAR(20)	as	cedula	,
		VARCHAR(60)	as	nombre	,
		VARCHAR(10)	as	telefono9	,
		VARCHAR(10)	as	telefono2	,
		VARCHAR(50)	as	e_mail	,
		VARCHAR(150)	as	direccion_1	,
		VARCHAR(150)	as	direccion_2	,
		VARCHAR(10)	as	tipo_persona,
		VARCHAR(3) as cod_ramo,
		VARCHAR(50) as desc_ramo,
		VARCHAR(3) as cod_formapago,
		VARCHAR(50) as desc_formapago,
		VARCHAR(5) 	as cod_agente,
		VARCHAR(50) as nom_agente,
		VARCHAR(5) 	as cod_acreedor,
		VARCHAR(50) as nom_acreedor	,			
		VARCHAR(16)	as saldo,
		VARCHAR(16)	as prima_bruta;

define _nombre            char(50);
define _no_documento      char(20); 
define _no_poliza         char(10);
define _vig_inic          date;      
define _vig_final         date;      
define _exigible		  dec(16,2);
define _por_vencer        dec(16,2);
define _corriente         dec(16,2);
define _monto_30		  dec(16,2);
define _monto_60		  dec(16,2);
define _monto_90		  dec(16,2);
define _saldo			  dec(16,2);   
define _fecha_cubierto    date;      
define _fecha_suspension  date;      	
define _cedula            char(30);	 
define _telefono2         VARCHAR(10);
define _telefono9         VARCHAR(10);
define _e_mail			  VARCHAR(50);
define _direccion_1		  VARCHAR(150);
define _direccion_2		  VARCHAR(150);
Define _tipo_persona	  char(1);
define _fronting          smallint;
define _cod_tipoprod      char(3);
define _cod_campana			char(10);
define _cod_cliente			char(10);
define _cnt_cascliente		smallint;
define _cnt_caspoliza		smallint;
define _fecha_ult_pro		date;
define _a_pagar				dec(16,2);
Define _dia_cob1			smallint;
Define _dia_cob2			smallint;
define _monto_180			dec(16,2);
define _monto_150			dec(16,2);
define _monto_120			dec(16,2);
define _mayor_90            dec(16,2);
define _cod_pagos			char(3);
Define _cod_ramo			char(3);
Define _cod_formapag		char(3);
define _desc_formapag	    CHAR(50); 
define _desc_ramo		    CHAR(50); 
define _es_taller           smallint;
define _cod_grupo           char(3);
define _cod_agente			char(5);
define _nom_agente			varchar(50); 
define _cod_acreedor		char(5);
define _nom_acreedor		varchar(50); 
define _cliente_vip			smallint;
define _msg_vip				varchar(100);
define _cnt_crediclaro      smallint;
define _prima_bruta         dec(16,2);


--SET DEBUG FILE TO "sp_cob412.trc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;

let _cod_campana = '01656'; --dataserver
let _mayor_90 = 0.00;
let _a_pagar = 0.00;
let _cliente_vip = 0;
let _msg_vip = '';
let _prima_bruta = 0;

foreach
	select distinct p.cod_contratante
	  into _cod_cliente
	  from emipomae p	  
	 where p.actualizado = 1
	   and p.estatus_poliza = 1	   	  
	   and p.cod_ramo in ('002','020')
	   and p.cod_formapag in ('006','005')                        -- Solo: ANC y ACH 
	   and p.cod_grupo not in ('1090','124','125','00000','1000','78020') -- Excluye: Grupo Scotiabank, Banisi y Gobierno
	   and p.fronting = 0                                         -- Excluye: Fronting
	   and p.cod_tipoprod not in ("001","002")     
	   
	   CALL sp_sis233 (_cod_cliente) returning _cliente_vip, _msg_vip; 
		if _cliente_vip = 1 then		-- JBRITO:24/7/2018 Se excluye Clientes VIP
			continue foreach;
		end if	   
	   
	 select nombre,		        
			cedula,			
			telefono1,
			celular, 
			e_mail, 
			direccion_1, 
			direccion_2,
			tipo_persona
	   into _nombre,		        
			_cedula,			
			_telefono9,
			_telefono2, 
			_e_mail, 
			_direccion_1, 
			_direccion_2,
			_tipo_persona				
	   from cliclien 
	  where cod_cliente = _cod_cliente;	  		   

foreach
	select e.no_documento,
			e.no_poliza, 
			e.vigencia_inic,
			e.vigencia_fin,
	        e.por_vencer,
			e.exigible,
			e.corriente,
			e.monto_30,
			e.monto_60,
			e.monto_90,
			e.monto_120,
			e.monto_150,
			e.monto_180,
			e.saldo,			
			e.fecha_cubierto,
			e.fecha_suspension,
			e.cod_pagos,
			e.dia_cobros1,
			e.dia_cobros2,
            e.cod_grupo,
			e.cod_formapag,
			e.cod_ramo,
			e.prima_bruta
	   into _no_documento,
			_no_poliza,	
			_vig_inic,
			_vig_final,
			_por_vencer,
			_exigible,
			_corriente,
			_monto_30,
			_monto_60,
			_monto_90,
			_monto_120,
			_monto_150,
			_monto_180,
			_saldo,
			_fecha_cubierto,
			_fecha_suspension,
			_cod_pagos,
		    _dia_cob1,
		    _dia_cob2,
			_cod_grupo,
			_cod_formapag,
			_cod_ramo,
			_prima_bruta
	  from emipoliza e	  
	 where e.cod_pagador = _cod_cliente   	    
	   and e.cod_status = 1	   	   
	   and e.cod_formapag in ('006','005')                        -- Solo: ANC y ACH 
	   and e.cod_grupo not in ('1090','124','125','00000','1000') -- Excluye: Grupo Scotiabank, Banisi y Gobierno	   	                 
	   
	   	if _exigible = 0 then		-- JBRITO:24/7/2018 Se excluye exigible cero
			continue foreach;
		end if
	   	if _cod_ramo = '023' or _cod_ramo = '008' then		-- JBRITO:24/7/2018 Se excluye flotas,  --JBRITO Fianza tampoco
			continue foreach;
		end if				
		
		let _cnt_crediclaro = 0;
		
     select count(*)
	   into _cnt_crediclaro
	   from emipoacr 
	  where cod_acreedor = '02483'  
		and no_poliza = _no_poliza;		
		
	   	if _cnt_crediclaro > 0 then		-- JBRITO, Se excluye crediclaro
			continue foreach;
		end if		
		
	-- Informacion de Polizas
	select fronting, cod_tipoprod
	  into _fronting, _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;	   
	 
	 select es_taller
	   into _es_taller  
	   from cligrupo 
	  where cod_grupo = _cod_grupo;
	  
	   	if _es_taller = 1 then		-- taller excluido
			continue foreach;
		end if	  
	 
	 	if _cod_tipoprod in ("001","002")   then		-- Excluye: Coaseguro mayoritario y minoritario
			continue foreach;
		end if	   
	   
	   	if _fronting <> 0 then		--se excluye fronting
			continue foreach;
		end if				 			  
		
	 select nombre
	   into _desc_formapag
	   from cobforpa
	  where cod_formapag = _cod_formapag;		
	  
	 select nombre
	   into _desc_ramo	
	   from prdramo
	  where cod_ramo = _cod_ramo;	  
		
		let _mayor_90 = _monto_90 + _monto_120 + _monto_150 + _monto_180;
		
		select count(*)
		  into _cnt_cascliente
		  from cascliente
		 where cod_campana = _cod_campana
		   and cod_cliente = _cod_cliente;

		if _cnt_cascliente is null then
			let _cnt_cascliente = 0;
		end if
		
		if _cnt_cascliente = 0 then			
			let _fecha_ult_pro = current;
			insert into cascliente(
					cod_cliente,
					dia_cobros1,
					dia_cobros2,
					procesado,
					fecha_ult_pro,
					cod_gestion,
					dia_cobros3,
					cod_cobrador_ant,
					ultima_gestion,
					cant_call,
					pago_fijo,
					mando_mail,
					cod_campana,
					corriente,
					exigible,
					monto_30,
					monto_60,
					monto_90,
					monto_120,
					monto_150,
					monto_180,
					saldo,
					por_vencer,
					cod_pagos,
					cod_cobrador,
					nuevo)
			values(	_cod_cliente,
					_dia_cob1,
					_dia_cob2,
					0,
					_fecha_ult_pro,
					null,
					0,
					null,
					'',
					0,
					0,
					0,
					_cod_campana,
					_corriente,
					_exigible,
					_monto_30,
					_monto_60,
					_monto_90,
					_monto_120,
					_monto_150,
					_monto_180,
					_saldo,
					_por_vencer,
					_cod_pagos,
					null,
					1);			  						
		end if		
		
	select count(*)
	  into _cnt_caspoliza
	  from caspoliza
	 where cod_campana = _cod_campana
	   and cod_cliente = _cod_cliente
	   and no_documento = _no_documento;

		if _cnt_caspoliza = 0 then
			let _a_pagar = _a_pagar + _exigible;
			insert into caspoliza(
					no_documento,
					cod_cliente,
					dia_cobros1,
					dia_cobros2,
					a_pagar,
					cod_campana)
			values(	_no_documento,
					_cod_cliente,
					_dia_cob1,
					_dia_cob2,
					_a_pagar,
					_cod_campana);
		end if 
		let _nom_acreedor = '';
		let _nom_agente = '';
		
		foreach
			select a.cod_agente, n.nombre
			  into _cod_agente, _nom_agente
			  from emipoagt a, agtagent n
			 where a.no_poliza = _no_poliza
			   and a.cod_agente = n.cod_agente
			 order by a.porc_partic_agt desc
			  exit foreach;
		end foreach		
		

		 foreach
    select distinct n.cod_acreedor,n.nombre
	           into _cod_acreedor, _nom_acreedor
		       from emipoacr e, emiacre n
		      where e.cod_acreedor = n.cod_acreedor
		        and e.no_poliza = _no_poliza
	           exit foreach;
	    end foreach		
		
		if _nom_acreedor is null or _nom_acreedor = '' then		
			 foreach		
				 select distinct n.cod_cliente, n.nombre
				   into _cod_acreedor, _nom_acreedor			 
				   from emipouni e, cliclien n
				  where e.cod_asegurado = n.cod_cliente
					and e.no_poliza = _no_poliza				  
				   exit foreach;
			end foreach
		end if
		  
		 return _no_documento,
				_vig_inic,
				_vig_final,
				_exigible,
				_por_vencer,
				_corriente,
				_monto_30,
				_monto_60,
				_mayor_90, 
				_fecha_cubierto,
				_fecha_suspension,
				_cedula,
				_nombre,
				_telefono9,
				_telefono2,
				_e_mail,
				_direccion_1,
				_direccion_2,
				_tipo_persona,
                _cod_ramo,
				_desc_ramo,
				_cod_formapag,
				_desc_formapag,				
				_cod_agente,   -- agente
				_nom_agente,   -- 
				_cod_acreedor, -- acreedor
				_nom_acreedor, --				
				_saldo,         -- saldo
				_prima_bruta
				with resume;	
		
	end foreach		
	
end foreach



END PROCEDURE;