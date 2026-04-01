-- listado de pólizas en suspensión de cobertura para un rango de fecha.	
-- Creado    : 11/10/2021 - Autor: Henry Giron

drop procedure sp_atc30;
create procedure "informix".sp_atc30(a_fecha_desde date, a_fecha_hasta date)						
returning 		
		char(20) as Poliza,		
		char(10) as cod_pagador,		
		char(100) as contratante,   --nombre_cliente,	
		date as fecha_primer_pago,		
		char(50) as Corredor,	  					
		char(50) as Zona_de_Cobros,	
		char(50) as cod_Ramo,		
		char(50) as Ramo,	 
		dec(16,2) as prima_bruta, 
		dec(16,2) as saldo,  		
		dec(16,2) as por_vencer,  
		dec(16,2) as exigible,  		
		varchar(10) as Tipo_de_Poliza, 
		date as Cubierto_Hasta,   ---fecha_cubierto,		
		date as Cese_de_Cobertura,   ---fecha_suspension,		
		smallint as dias_diferencia,		
		smallint as VIP,   ----cliente_vip,		
		date as fecha_actual,
        char(3) as cod_vendedor,		
		char(50) as zona_de_ventas 
		;
	
		
define _no_documento		char(20);
define _cod_pagador   		char(10);
define _n_cliente	        char(100);
define _fecha_primer_pago	date;
define _nom_agente			char(50);
define _zona				char(50);
define _cod_ramo			char(3);
define _nom_ramo			char(50);
define _prima_bruta   		dec(16,2);
define _saldo   			dec(16,2);
define _por_vencer   		dec(16,2);			
define _exigible   			dec(16,2); 
define _desc_n_r			varchar(10);
define _fecha_cubierto		date;
define _fecha_suspension    date;
define _dias_diferencia     smallint;
define _cliente_vip			smallint;
define _fecha_actual		date;
define _cod_cliente			char(10);
define _cod_agente   		char(5);
define _cod_zona   			char(3);
define _no_poliza			char(10);
define _mensaje				varchar(250);
define _cod_vendedor		char(3);
define _nom_vendedor	    char(50);

set isolation to dirty read;

--set debug file to "sp_pro4966.trc"; 
--trace on;

let _no_documento		= '';
let _cod_pagador   		= '';
let _n_cliente   		= '';
let	_fecha_primer_pago  = null;
let _nom_agente			= '';
let _zona				= '';
let _cod_ramo			= '';
let _nom_ramo			= '';
let _cod_vendedor		= '';
let _nom_vendedor        = '';
let _prima_bruta  		= 0.00;
let _saldo   			= 0.00;
let _por_vencer			= 0.00;		
let _exigible  			= 0.00;
let _desc_n_r		    = '';
let	_fecha_cubierto     = null;
let	_fecha_suspension   = null;
let _dias_diferencia    = 0;
let _cliente_vip      	= 0;
let	_fecha_actual       = null;
let _fecha_actual       = current;

Create Temp Table tmp_pro4966(
		no_documento char(20),		 
		cod_pagador char(10),
		n_cliente char(100), 
		fecha_primer_pago	date,
		nom_agente char(50),
		zona char(50),
		cod_ramo char(3),
		nom_ramo char(50),
		prima_bruta dec(16,2),
		saldo dec(16,2),   
		por_vencer dec(16,2),   
		exigible dec(16,2),   
		desc_n_r varchar(10),
		fecha_cubierto	date,
		fecha_suspension	date,		
		dias_diferencia smallint,
		cliente_vip smallint,
		fecha_actual date,		
		cod_vendedor char(3),
		nom_vendedor char(50),
		seleccion smallint
	 ) With No Log;		   		
		 
select *
  from emipoliza
 where saldo > 0 and fecha_suspension between a_fecha_desde and a_fecha_hasta
   into temp tmp_emipoliza;

			    
				
foreach
		select no_documento,
				cod_pagador,
				cod_agente,
				cod_zona,
				cod_ramo,				
				prima_bruta,
				saldo,   
				por_vencer,				
				exigible,   			
				fecha_cubierto,
				fecha_suspension
		  into _no_documento,
				_cod_pagador,
				_cod_agente,
				_cod_zona,
				_cod_ramo,				
				_prima_bruta,
				_saldo,   
				_por_vencer,				
				_exigible,   			
				_fecha_cubierto,
				_fecha_suspension
		  from tmp_emipoliza  	 

	   	call sp_sis21(_no_documento) returning _no_poliza;
		
		 SELECT cod_contratante,fecha_primer_pago,(case when nueva_renov = 'N' then "NUEVA" else "RENOVADA" end) desc_n_r
	       INTO _cod_cliente, _fecha_primer_pago, _desc_n_r
		   FROM emipomae
		  WHERE no_poliza = _no_poliza;		

		select nombre
		  into _nom_ramo
		  from prdramo
		 where cod_ramo = _cod_ramo;					  

		select nombre
		  into _zona
		  from cobcobra
		 where cod_cobrador = _cod_zona;

		select nombre, cod_vendedor
		  into _nom_agente, _cod_vendedor
		  from agtagent
		 where cod_agente = _cod_agente;
	 
		select upper(nombre)
		  into _n_cliente
		  from cliclien
		 where cod_cliente = _cod_cliente;  		 		 
		 
		  CALL sp_sis233 (_cod_cliente) returning _cliente_vip, _mensaje; 
		   let _dias_diferencia = _fecha_actual - _fecha_suspension;
		   
		select nombre
		  into _nom_vendedor
		  from agtvende
		 where cod_vendedor = _cod_vendedor;
			
	 
		  Insert into tmp_pro4966(
				no_documento,
				cod_pagador,
				n_cliente,   
				fecha_primer_pago,
				nom_agente,
				zona,
				cod_ramo,
				nom_ramo,
				prima_bruta,
				saldo,   
				por_vencer,				
				exigible,   
				desc_n_r,
				fecha_cubierto,
				fecha_suspension,
				dias_diferencia,
				cliente_vip,
				fecha_actual,
				cod_vendedor,
				nom_vendedor,
				seleccion				
			  )			  
			  Values (			
				_no_documento,
				_cod_pagador,
				_n_cliente,   
				 _fecha_primer_pago,
				_nom_agente,
				_zona,
				_cod_ramo,
				_nom_ramo,
				_prima_bruta,
				_saldo,   
				_por_vencer,				
				_exigible,   
				 _desc_n_r,
				_fecha_cubierto,
				_fecha_suspension,
				 _dias_diferencia,
				_cliente_vip,
				_fecha_actual,
				_cod_vendedor,
				_nom_vendedor,
				1);
			 
end foreach 

foreach
	SELECT no_documento,
			cod_pagador,
			n_cliente,   
			fecha_primer_pago,
			nom_agente,
			zona,
			cod_ramo,
			nom_ramo,
			prima_bruta,
			saldo,   
			por_vencer,				
			exigible,   
			desc_n_r,
			fecha_cubierto,
			fecha_suspension,
			dias_diferencia,
			cliente_vip,
			fecha_actual,
            cod_vendedor,
            nom_vendedor			
	INTO _no_documento,
			_cod_pagador,
			_n_cliente,   
			 _fecha_primer_pago,
			_nom_agente,
			_zona,
			_cod_ramo,
			_nom_ramo,
			_prima_bruta,
			_saldo,   
			_por_vencer,				
			_exigible,   
			 _desc_n_r,
			_fecha_cubierto,
			_fecha_suspension,
			 _dias_diferencia,
			_cliente_vip,
			_fecha_actual,
			_cod_vendedor,
			_nom_vendedor
		FROM tmp_pro4966
	   WHERE seleccion = 1
	   order by fecha_suspension desc
	   
		   if _saldo < 0 then 
				continue foreach;
		   end if
				
     
		  return 
				_no_documento,
				_cod_pagador,
				_n_cliente,   
				 _fecha_primer_pago,
				_nom_agente,				
				_zona,
				_cod_ramo,
				_nom_ramo,
				_prima_bruta,
				_saldo,   
				_por_vencer,				
				_exigible,   
				 _desc_n_r,
				_fecha_cubierto,
				_fecha_suspension,
				 _dias_diferencia,
				_cliente_vip,
				_fecha_actual				,
				_cod_vendedor,
				_nom_vendedor
			with resume;



end foreach
DROP TABLE tmp_pro4966;
	
	
end procedure

	

	
    
      