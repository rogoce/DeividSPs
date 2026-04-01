-- Reporte de Aviso de Cancelacion
-- Creado    : 31/07/2000 - Autor: Henry Giron
-- SIS v.2.0 - d_cobr_sp_cob748b_dw1 - DEIVID, S.A.  -- x corredor
drop procedure sp_cob748b; 
create procedure sp_cob748b(a_cod_avican char(10)) 
returning char(20),	  	--1  no_documento		  
		  char(50),	  	--2  nom_ramo
		  char(50),	  	--4  nom_formapag
		  char(50),	  	--5  zona
		  char(50),	  	--6  nom_agente
		  char(50),	  	--7  nom_agencia
		  char(5),	  	--8  cod_area
		  char(10),	  	--9  status		  
		  char(50),	  	--10 nom_grupo
		  char(3),	  	--11 cod_pagos
		  char(50),	  	--12 nom_pagador
		  smallint,	  	--13 dia_cobros1
		  smallint,	  	--14 dia_cobros2
		  date,		  	--15 vigencia_inic
		  date,		  	--16 vigencia_fin 
		  dec(16,2),  	--17 exigible   
		  dec(16,2),  	--18 por_vencer   
		  dec(16,2),  	--19 corriente   
		  dec(16,2),  	--20 monto_30   
		  dec(16,2),  	--21 monto_60   
		  dec(16,2),  	--22 monto_90   
		  dec(16,2),  	--23 monto_120   
		  dec(16,2),  	--24 monto_150   
		  dec(16,2),  	--25 monto_180   
		  dec(16,2),  	--26 saldo   
		  dec(16,2);  	--27 prima_bruta

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

set isolation to dirty read;
--set debug file to "sp_cob748b.trc"; 
--trace on;

let _motivo_rechazo		= '';
let _nom_ramo			= '';
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
         prima_bruta
    into _no_documento,   
    	 _cod_ramo,			   	   
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
    	 _prima_bruta
    from avicanpoliza  
   where cod_avican = a_cod_avican
   
   	call sp_sis21(_no_documento) returning _no_poliza;

	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;					  
	  															  
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

	select descripcion
	  into _status
	  from statuspoli
	 where cod_status = _cod_status;
	 
	select descripcion 
	  into _acreencia
	  from acreehip
	 where cod_acreencia = _cod_acreencia;

	return _no_documento,		 
		   _nom_ramo,
		   _nom_formapag,
		   _zona,
		   _nom_agente,
		   _nom_agencia,
		   _cod_area,
		   _status,		  
		   _nom_grupo,
		   _cod_pagos,
		   _nom_pagador,
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
		   _prima_bruta		
		   with resume;			     
	 
end foreach 
end procedure	  