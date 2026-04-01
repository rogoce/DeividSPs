-- listado de pólizas en suspensión de cobertura para un rango de fecha.	
-- Creado    : 11/10/2021 - Autor: Henry Giron

drop procedure sp_pro4966;
create procedure "informix".sp_pro4966(a_fecha_desde date, a_fecha_hasta date)						
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
		date as fecha_actual
		;
		{
		,		
		char(50) as Subramo,	  	
		char(50) as Forma_de_Pago,	
		char(50) as Sucursal,	  
		char(5) as Area,	  
		char(10) as Estatus,	
		char(50) as Grupo,	  
		char(3) as Cantidad_de_Pagos,	
		char(10) as cod_cliente,	
		char(50) as correo,	
		char(30) as cedula,	
		char(20) as celular,	
		char(20) as telefono1,	
		char(20) as telefono2,	
		char(20) as telefono3,	
		smallint as dia_de_cobros1,	
		smallint as dia_de_cobros2,	
		date as vigencia_inicial,	
		date as vigencia_final,					
		dec(16,2) as corriente,  	
		dec(16,2) as monto_30,  	
		dec(16,2) as monto_60,  	
		dec(16,2) as monto_90,  	
		dec(16,2) as monto_120,  	
		dec(16,2) as monto_150,  	
		dec(16,2) as monto_180,  	
		char(15) as Acreedor,   	
		date as Fecha_Aviso_Cancelacion,	
		varchar(50) as Motivo_Rechazo,
		char(7) as Fecha_Expiracion,
		char(50) as nom_pagador;		
}
		

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
define _cod_cliente			char(10);
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
define _estatus_poliza		smallint;
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
define _formato	            char(20);
define _cliente_vip			smallint;
define _mensaje				varchar(250);
define _fecha_primer_pago	date;
define _desc_n_r			varchar(10);
define _fecha_actual		date;
define _fecha_cubierto		date;
define _fecha_suspension    date;	 
define _dias_diferencia     smallint;

set isolation to dirty read;
--set debug file to "sp_pro4966.trc"; 
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
let _cod_cliente		= '';
let _mensaje		    = '';
let _desc_n_r		    = '';
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
let _dias_diferencia      	= 0;

let _fecha_aviso_canc	= null;
let _vigencia_inic   	= null;
let	_vigencia_fin   	= null;
let	_fecha_primer_pago  = null;
let	_fecha_actual       = null;
let	_fecha_cubierto     = null;
let	_fecha_suspension   = null;
let _fecha_actual = current;

Create Temp Table tmp_pro4966(
		no_documento char(20) ,		 
		nom_ramo char(50),
		nom_subramo char(50),
		nom_formapag char(50),
		zona char(50),
		nom_agente char(50),
		nom_agencia char(50),
		cod_area char(5),
		status char(10),		  
		nom_grupo char(50),
		cod_pagos  char(3),			   			   
		cod_cliente char(10),  
		n_cliente char(100),  
		email char(50),
		cedula char(30),
		celular char(20),				   
		telefono1 char(20),
		telefono2 char(20),
		telefono3 char(20),  
		dia_cobros1 smallint,  
		dia_cobros2 smallint,  
		vigencia_inic date,
		vigencia_fin date, 
		exigible dec(16,2),   
		por_vencer dec(16,2),   
		corriente dec(16,2),   
		monto_30 dec(16,2),   
		monto_60 dec(16,2),   
		monto_90 dec(16,2),   
		monto_120 dec(16,2),   
		monto_150 dec(16,2),   
		monto_180 dec(16,2),   
		saldo dec(16,2),   
		prima_bruta dec(16,2),
		acreencia char(15),
		fecha_aviso_canc date,
		motivo_rechazo varchar(50),
		fecha_exp  char(7),
		cliente_vip smallint,
		fecha_primer_pago	date,
		desc_n_r varchar(10),
        fecha_cubierto	date,
        fecha_suspension	date,		
		fecha_actual date,		
		dias_diferencia smallint,
		nom_pagador	char(50),   
		cod_pagador char(10),
		cod_ramo char(3),
		seleccion smallint
	 ) With No Log;		   
	 
	 
select *
  from emipoliza
 where fecha_suspension between a_fecha_desde and a_fecha_hasta
   into temp tmp_emipoliza;


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
		       fecha_exp,
			   fecha_cubierto,
			   fecha_suspension
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
			   _fecha_exp,
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
		 where cod_cliente = _cod_cliente;  
		 
 
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
		 
		 	CALL sp_sis233 (_cod_cliente) returning _cliente_vip, _mensaje; 
			let _dias_diferencia = _fecha_actual - _fecha_suspension;
		 
		  Insert into tmp_pro4966(
				no_documento,		 
				nom_ramo,
				nom_subramo,
				nom_formapag,
				zona,
				nom_agente,
				nom_agencia,
				cod_area,
				status,		  
				nom_grupo,
				cod_pagos,			   			   
				cod_cliente, 
				n_cliente,   
				email,
				cedula,
				celular,				   
				telefono1,
				telefono2,
				telefono3, 		   
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
				prima_bruta,
				acreencia,
				fecha_aviso_canc,
				motivo_rechazo,
				fecha_exp,
				cliente_vip,
				fecha_primer_pago,
				desc_n_r,
				fecha_cubierto,
				fecha_suspension,
				fecha_actual,
				dias_diferencia,
				nom_pagador,
				cod_pagador,
				cod_ramo,
                seleccion				
			  )
			  Values (
				_no_documento,		 
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
				_cod_cliente, 
				_n_cliente,   
				_email,
				_cedula,
				_celular,				   
				_telefono1,
				_telefono2,
				_telefono3, 		   
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
				_fecha_exp,
				_cliente_vip,
				_fecha_primer_pago,
				_desc_n_r,
				_fecha_cubierto,
				_fecha_suspension,
				_fecha_actual,				
				_dias_diferencia,
				_nom_pagador,
				_cod_pagador,
				_cod_ramo,
                1				
			  );


			 
end foreach 

foreach
  SELECT no_documento,		 
				nom_ramo,
				nom_subramo,
				nom_formapag,
				zona,
				nom_agente,
				nom_agencia,
				cod_area,
				status,		  
				nom_grupo,
				cod_pagos,			   			   
				cod_cliente, 
				n_cliente,   
				email,
				cedula,
				celular,				   
				telefono1,
				telefono2,
				telefono3, 		   
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
				prima_bruta,
				acreencia,
				fecha_aviso_canc,
				motivo_rechazo,
				fecha_exp,
                cliente_vip,
                fecha_primer_pago,
                desc_n_r,
				fecha_cubierto,
				fecha_suspension,
				fecha_actual,				
				dias_diferencia,
				nom_pagador,
				cod_pagador,
				cod_ramo
    into 		_no_documento,		 
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
				_cod_cliente, 
				_n_cliente,   
				_email,
				_cedula,
				_celular,				   
				_telefono1,
				_telefono2,
				_telefono3, 		   
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
				_fecha_exp,
                _cliente_vip,
                _fecha_primer_pago,
                _desc_n_r,
				_fecha_cubierto,
				_fecha_suspension,
				_fecha_actual,
                _dias_diferencia,
                _nom_pagador,
				_cod_pagador,
				_cod_ramo				
    FROM tmp_pro4966
   WHERE seleccion = 1


		  
		  
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
				_fecha_actual
			with resume;

{			
				_nom_subramo,
				_nom_formapag,
				_nom_agencia,
				_cod_area,
				_status,
				_nom_grupo,
				_cod_pagos,
				_cod_cliente, 
				_email,
				_cedula,
				_celular,
				_telefono1,
				_telefono2,
				_telefono3, 
				_dia_cobros1,  
				_dia_cobros2,  
				_vigencia_inic,
				_vigencia_fin,    
				_corriente,   
				_monto_30,   
				_monto_60,   
				_monto_90,   
				_monto_120,   
				_monto_150,   
				_monto_180,   
				_acreencia,
				_fecha_aviso_canc,
				_motivo_rechazo,
				_fecha_exp,
				_nom_pagador
			with resume;
}

end foreach
DROP TABLE tmp_pro4966;
	
	
end procedure

	

	
    
      