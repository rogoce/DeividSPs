-- Procedimiento para traer el reporte de Campañas a Activar 	

-- Creado    : 15/07/2011 - Autor: Roman Gordon 

drop procedure sp_cob284;

create procedure "informix".sp_cob284(a_cod_campana char(10)) 
returning char(20) as Poliza,	  	--1 _no_documento,		  
		char(50) as Ramo,	  	--2 _nom_ramo,
		char(50) as Subramo,	  	--3 _nom_subramo,
		char(50) as Forma_de_Pago,	  	--4 _nom_formapag,
		char(50) as Zona_de_Cobros,	  	--5 _zona,
		char(50) as Corredor,	  	--6 _nom_agente,
		char(50) as Sucursal,	  	--7 _nom_agencia
		char(5) as Area,	  	--8 _cod_area,
		char(10) as Estatus,	  	--9 _status,		  
		char(50) as Grupo,	  	--10_nom_grupo,
		char(3) as Cantidad_de_Pagos,	  	--11_cod_pagos,		
		char(10) as cod_cliente,		--cod_cliente,	  --1
		char(100) as nombre_cliente,	  	-- 12_n_cliente,
		char(50) as correo,		--_e_mail,		  --2
		char(30) as cedula,		--_cedula		  --3
		char(20) as celular,		--_celular,		  --4
		char(20) as telefono1,		--_telefono1,	  --5
		char(20) as telefono2,		--_telefono2,	  --6  
		char(20) as telefono3,		--_telefono3,	  --7			  
		smallint as dia_de_cobros1,	  	--13_dia_cobros1,  
		smallint as dia_de_cobros2,	  	--14_dia_cobros2,  
		date as vigencia_inicial,		  	--15_vigencia_inic,
		date as vigencia_final,		  	--16_vigencia_fin, 
		dec(16,2) as exigible,  	--17_exigible,   
		dec(16,2) as por_vencer,  	--18_por_vencer,   
		dec(16,2) as corriente,  	--19_corriente,   
		dec(16,2) as monto_30,  	--20_monto_30,   
		dec(16,2) as monto_60,  	--21_monto_60,   
		dec(16,2) as monto_90,  	--22_monto_90,   
		dec(16,2) as monto_120,  	--23_monto_120,   
		dec(16,2) as monto_150,  	--24_monto_150,   
		dec(16,2) as monto_180,  	--25_monto_180,   
		dec(16,2) as saldo,  	--26_saldo,   
		dec(16,2) as prima_bruta,  	--27_prima_bruta,
		char(15) as Acreedor,   	--28_acreencia
		date as Fecha_Aviso_Cancelacion,		  	--29_fecha_aviso_canc,	  
		varchar(50) as Motivo_Rechazo,	--30_motivo_rechazo,
		char(7) as Fecha_Expiracion;	  	--31_fecha_exp		
	
define _motivo_rechazo  	varchar(50);
define _nom_ramo			char(50);
define _nom_subramo			char(50);
define _nom_formapag		char(50);
define _zona				char(50);
define _nom_agente			char(50);
define _nom_agencia			char(50);
define _nom_grupo			char(50);
define _nom_pagador			char(50);
define _no_documento		char(20);
define _acreencia			char(15);
define _no_poliza			char(10);
define _cod_pagador   		char(10);
define _status				char(10);
define _fecha_exp			char(7);
define _cod_area   			char(5);
define _cod_agente   		char(5);
define _cod_grupo   		char(5);  
define _cod_ramo			char(3);
define _cod_subramo   		char(3);
define _cod_formapag   		char(3);
define _cod_zona   			char(3);
define _cod_sucursal   		char(3);
define _cod_pagos   		char(3);
define _cod_status   		char(1);
define _dia_cobros1   		smallint;
define _dia_cobros2   		smallint;
define _cod_acreencia   	smallint;
define _carta_aviso_canc	smallint;
define _fecha_aviso_canc	date;
define _vigencia_inic   	date;
define _vigencia_fin   		date;
define _exigible   			dec(16,2);
define _por_vencer   		dec(16,2);
define _corriente   		dec(16,2);
define _monto_30   			dec(16,2);
define _monto_60   			dec(16,2);
define _monto_90   			dec(16,2);
define _monto_120   		dec(16,2);
define _monto_150   		dec(16,2);
define _monto_180   		dec(16,2);
define _saldo   			dec(16,2);
define _prima_bruta   		dec(16,2);

define _n_cliente	        char(100);
define _email			    char(50);  
define _telefono1		    char(20);  
define _telefono2		    char(20);  
define _telefono3		    char(20);  
define _celular		        char(20);
define _cedula			    char(30);
define _formato	            char(32);
define _cod_cliente			char(10);

set isolation to dirty read;
--set debug file to "sp_cob284.trc"; 
--trace on;

let _motivo_rechazo		= '';
let _nom_ramo			= '';
let _nom_subramo		= '';	
let _nom_formapag		= '';
let _zona				= '';
let _nom_agente			= '';
let _nom_agencia		= '';	
let _nom_grupo			= '';
let _nom_pagador		= '';	
let _no_documento		= '';
let _acreencia			= '';
let _no_poliza			= '';
let _cod_pagador   		= '';
let _status				= '';
let _fecha_exp			= '';
let _cod_area   		= '';	
let _cod_agente   		= '';
let _cod_grupo   		= '';
let _cod_ramo			= '';
let _cod_subramo   		= '';
let _cod_formapag  		= '';
let _cod_zona   		= '';	
let _cod_sucursal  		= '';
let _cod_pagos   		= '';
let _cod_status   		= '';
let _exigible  			= 0.00;
let _por_vencer			= 0.00;
let _corriente 			= 0.00;
let _monto_30  			= 0.00;
let _monto_60  			= 0.00;
let _monto_90  			= 0.00;
let _monto_120 			= 0.00;
let _monto_150 			= 0.00;
let _monto_180 			= 0.00;
let _saldo   			= 0.00;
let _dia_cobros1   		= 0;
let _dia_cobros2   		= 0;
let _cod_acreencia   	= 0;
let _carta_aviso_canc	= 0;
let _fecha_aviso_canc	= null;
let _vigencia_inic   	= null;
let	_vigencia_fin   	= null;

foreach
  select no_documento,   
         cod_ramo,
         cod_subramo,   
         cod_formapag,   
         cod_zona,   
         cod_agente,   
         cod_sucursal,   
         cod_area,   
         cod_status,   
         cod_grupo,   
         cod_pagos,   
         cod_pagador,   
         dia_cobros1,   
         dia_cobros2,   
         vigencia_inic,   
         vigencia_fin,   
         exigible,   
         por_vencer,   
         corriente,   
         monto_30,   
         monto_60,   
         monto_90,   
         monto_120,   
         monto_150,   
         monto_180,   
         saldo,   
         cod_acreencia,   
         prima_bruta,   
         carta_aviso_canc,   
         motivo_rechazo,   
         fecha_exp
    into _no_documento,   
    	 _cod_ramo,			   
    	 _cod_subramo,   	   
    	 _cod_formapag,   	   
    	 _cod_zona,   		   
    	 _cod_agente,   	   
    	 _cod_sucursal,   	   
    	 _cod_area,   		   
    	 _cod_status,   	   
    	 _cod_grupo,   		   
    	 _cod_pagos,   		   
    	 _cod_pagador,   	   
    	 _dia_cobros1,   
    	 _dia_cobros2,   
    	 _vigencia_inic,   
    	 _vigencia_fin,   
    	 _exigible,   
    	 _por_vencer,   
    	 _corriente,   
    	 _monto_30,   
    	 _monto_60,   
    	 _monto_90,   
    	 _monto_120,   
    	 _monto_150,   
    	 _monto_180,   
    	 _saldo,   
    	 _cod_acreencia,   
    	 _prima_bruta,   
    	 _carta_aviso_canc,
    	 _motivo_rechazo,  
      	 _fecha_exp
    from campoliza  
   where cod_campana = a_cod_campana
   order by monto_180 desc,monto_150 desc,monto_120 desc,monto_90 desc,monto_60 desc,monto_30 desc,corriente desc

   	call sp_sis21(_no_documento) returning _no_poliza;

	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre												  
	  into _nom_subramo											  
	  from prdsubra												  
	 where cod_ramo = _cod_ramo									  
	   and cod_subramo = _cod_subramo;							  
	  															  
	select nombre												  
	  into _nom_formapag										  
	  from cobforpa												  
	 where cod_formapag = _cod_formapag;						  
																  
	select nombre
	  into _zona
	  from cobcobra
	 where cod_cobrador = _cod_zona;

	select nombre
	  into _nom_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	select descripcion
	  into _nom_agencia
	  from insagen
	 where codigo_agencia = _cod_sucursal;

	select nombre
	  into _nom_grupo
	  from cligrupo
	 where cod_grupo = _cod_grupo;

	select nombre
	  into _nom_pagador
	  from cliclien	 
	 where cod_cliente = _cod_pagador;

	let _fecha_aviso_canc = null;
	 
	if _carta_aviso_canc = 1 then
		select fecha_aviso_canc
		  into _fecha_aviso_canc
		  from emipomae
		 where no_poliza = _no_poliza;
	end if

	select descripcion
	  into _status
	  from statuspoli
	 where cod_status = _cod_status;
	 
	select descripcion 
	  into _acreencia
	  from acreehip
	 where cod_acreencia = _cod_acreencia;
	 
	 let _cod_cliente =  _cod_pagador;
	 
	select upper(nombre),
		   nvl(e_mail,''),
		   nvl(cedula,''),
		   nvl(celular,''),			   
		   nvl(telefono1,''),
		   nvl(telefono2,''),
		   nvl(telefono3,'')
	  into _n_cliente,
		   _email,
		   _cedula,
		   _celular,				   
		   _telefono1,
		   _telefono2,
		   _telefono3
	  from cliclien
	 where cod_cliente = _cod_cliente;  --Todos campos son los relacionados al código del cliente almacenado en la Campaña.
	 
	let _formato = '';
	call sp_sis284a(_celular) returning _formato;
	let _celular = _formato;	
			
	 let _formato = '';
	 if trim(_telefono1) is null then		 		 
		let _telefono1 = '';
	 else		     
		call sp_sis284a(_telefono1) returning _formato;
		let _telefono1 = _formato;
		if trim(_celular) is null or _celular = '' then
			let _celular = _telefono1;		
		end if								
	 end if
	 let _formato = '';		 
	 if trim(_telefono2) is null then		 		 
		let _telefono2 = '';
	 else		     
		call sp_sis284a(_telefono2) returning _formato;
		let _telefono2 = _formato;	
		if trim(_celular) is null or _celular = '' then
			let _celular = _telefono2;		
		end if					
				
	 end if		 
	 let _formato = '';
	 if trim(_telefono3) is null then		 		 
		let _telefono3 = '';
	 else		     
		call sp_sis284a(_telefono3) returning _formato;
		let _telefono3 = _formato;	
		if trim(_celular) is null or _celular = '' then
			let _celular = _telefono3;		
		end if					
				
	 end if					 

		return _no_documento,		 
			   _nom_ramo,
			   _nom_subramo,
			   _nom_formapag,
			   _zona,
			   _nom_agente,
			   _nom_agencia,
			   _cod_area,
			   _status,		  
			   _nom_grupo,
			   _cod_pagos,			   			   
			   _cod_cliente,  --_nom_pagador,
			   _n_cliente,    --- reemplaza nom_pagador
			   _email,
			   _cedula,
			   _celular,				   
			   _telefono1,
			   _telefono2,
			   _telefono3,  -- hasta aqui			   
			   _dia_cobros1,  
			   _dia_cobros2,  
			   _vigencia_inic,
			   _vigencia_fin, 
			   _exigible,   
			   _por_vencer,   
			   _corriente,   
			   _monto_30,   
			   _monto_60,   
			   _monto_90,   
			   _monto_120,   
			   _monto_150,   
			   _monto_180,   
			   _saldo,   
			   _prima_bruta,
			   _acreencia,
			   _fecha_aviso_canc,
			   _motivo_rechazo,
			   _fecha_exp 			with resume;	
			   

	 
end foreach 
end procedure

	

	
    
      