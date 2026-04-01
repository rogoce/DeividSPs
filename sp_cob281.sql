-- procedimiento que trae las polizas para el cte. seleccionado.
-- creado    : 10/08/2011 - autor: Roman Gordon C.
-- sis v.2.0 - deivid, s.a.

drop procedure sp_cob281;

create procedure sp_cob281(a_user char(8),a_no_poliza char(10))
returning char(10),	  		-- _cod_contratante	
		  char(10),			-- _cod_pagador		
		  char(20),			-- _no_documento		
		  date,				-- _vigencia_inic	
		  date,				-- _vigencia_final	
		  smallint,			-- _no_pagos				
		  smallint,			-- _direc_cobros		
		  smallint,			-- _dia_cobros1		
		  smallint,			-- _dia_cobros2		
		  smallint,			-- _carta_aviso_canc	
		  smallint,			-- _carta_prima_gan	
		  smallint,			-- _carta_vencida_sal
		  smallint,			-- _carta_recorderis	
		  date,				-- _fecha_aviso_canc	
       	  date,				-- _fecha_prima_gan	
       	  date,				-- _fecha_vencida_sal
	      date,				-- _fecha_recorderis	
	      dec(16,2),		-- _saldo			
	      char(19),			-- _no_tarjeta		
	      char(7),			-- _fecha_exp					
		  char(17),			-- _no_cuenta			
		  date,				-- _fecha_primer_pago
		  date,				-- _fecha_cancelacion
		  char(10),			-- _no_recibo		
		  varchar(50),		-- _nom_banco		
		  varchar(50),		-- _nom_perpago		
		  varchar(50),		-- _nom_tipocalc		
		  varchar(50),		-- _tipo_produccion	
		  varchar(50),		-- _nom_formapag		
		  varchar(50),		-- _nom_contratante	
		  varchar(50),		-- _nom_pagador		
  		  varchar(15),		-- _tipo_tarjeta_char
		  varchar(10),		-- _tipo_cuenta_char	
		  varchar(15),		-- _status_char		
		  char(50),			-- _zona_cobros
		  char(50),			-- _nom_div_cob
		  char(1),			-- _periodo_tcr
		  char(1);			-- _periodo_ach

define _nom_banco			varchar(50);
define _nom_perpago			varchar(50);
define _nom_tipocalc		varchar(50);
define _tipo_produccion		varchar(50);
define _nom_formapag		varchar(50);
define _nom_contratante		varchar(50);
define _nom_pagador			varchar(50);
define _no_tarjeta_final	varchar(30);
define _no_cuenta_final		varchar(17);
define _tipo_tarjeta_char	varchar(15);
define _status_char			varchar(15);
define _tipo_cuenta_char	varchar(10);
define _zona_cobros			char(50);
define _no_documento		char(20);
define _no_tarjeta			char(19);
define _no_cuenta			char(17);
define _cod_contratante		char(10);
define _cod_pagador			char(10);
define _no_poliza			char(10);
define _no_recibo			char(10);				   
define _no_tarjeta_parte1	char(5);
define _no_tarjeta_parte2	char(5);
define _cod_tipocalc		char(3);
define _cod_formapag		char(3);
define _cod_tipoprod		char(3);
define _cod_perpago			char(3);
define _cod_banco			char(3);
define _fecha_exp			char(7);
define _tipo_tarjeta		char(1);
define _tipo_cuenta			char(1);
define v_cod_agente			char(5);
define v_agente				char(100);
define _nom_div_cob			char(50);						   
define _cod_zona			char(3);
define _cod_div_cob			char(1);
define _periodo_tcr			char(1);
define _saldo				dec(16,2);
define _periodo_ach			char(1);
define _vigencia_inic		date;
define _vigencia_final		date;
define _no_pagos			smallint;
define _estatus_poliza		smallint;
define _direc_cobros		smallint;
define _dia_cobros1			smallint;
define _dia_cobros2			smallint;
define _carta_aviso_canc	smallint;
define _carta_prima_gan		smallint;
define _carta_vencida_sal	smallint;
define _carta_recorderis	smallint;
define _len_tarjeta			smallint;
define _len_cuenta			smallint;
define _rol					smallint;
define _fecha_aviso_canc	date;
define _fecha_prima_gan		date;
define _fecha_vencida_sal	date;
define _fecha_recorderis	date;
define _fecha_primer_pago	date;					   
define _fecha_cancelacion	date;					   
define v_leasing			smallint;

set isolation to dirty read;

--set debug file to "sp_cob281.trc";
--trace on ;

let _no_tarjeta_final	= '';
let _no_cuenta_final	= '';
let _periodo_tcr		= '';
let	_periodo_ach		= '';

select cod_perpago,   
       cod_tipocalc,   
       cod_formapag,   
       cod_tipoprod,   
       cod_contratante,   
       cod_pagador,   
       no_documento,   
       vigencia_inic,   
       vigencia_final,   
       no_pagos,   
       estatus_poliza,   
       direc_cobros,   
       dia_cobros1,   
       dia_cobros2,   
       carta_aviso_canc,   
       carta_prima_gan,   
       carta_vencida_sal,   
       carta_recorderis,   
       fecha_aviso_canc,   
       fecha_prima_gan,   
       fecha_vencida_sal,   
       fecha_recorderis,   
       saldo,   
       no_tarjeta,   
       fecha_exp,   
       tipo_tarjeta,   
       cod_banco,   
       no_poliza,   
       no_cuenta,   
       tipo_cuenta,   
       fecha_primer_pago,   
       fecha_cancelacion,   
       no_recibo
  into _cod_perpago,			
	   _cod_tipocalc,		
	   _cod_formapag,		
  	   _cod_tipoprod,		
  	   _cod_contratante,		
  	   _cod_pagador,			
  	   _no_documento,		
  	   _vigencia_inic,		
  	   _vigencia_final,		
  	   _no_pagos,			
  	   _estatus_poliza,		
  	   _direc_cobros,		
  	   _dia_cobros1,			
  	   _dia_cobros2,			
  	   _carta_aviso_canc,	
  	   _carta_prima_gan,		
  	   _carta_vencida_sal,
  	   _carta_recorderis,	
  	   _fecha_aviso_canc,	
  	   _fecha_prima_gan,		
  	   _fecha_vencida_sal,
  	   _fecha_recorderis,	
  	   _saldo,				
  	   _no_tarjeta,			
  	   _fecha_exp,			
  	   _tipo_tarjeta,		
  	   _cod_banco,			
  	   _no_poliza,			
  	   _no_cuenta,			
  	   _tipo_cuenta,			
  	   _fecha_primer_pago,
  	   _fecha_cancelacion,
  	   _no_recibo			
  from emipomae  																			
 where no_poliza = a_no_poliza;																

select nombre																				
  into _nom_banco																			
  from chqbanco																			
 where cod_banco = _cod_banco;																

select nombre																				
  into _nom_perpago
  from cobperpa													   
 where cod_perpago = _cod_perpago;									   

select nombre														   
  into _nom_tipocalc												   
  from emitical													   
 where cod_tipocalc = _cod_tipocalc;								   

select nombre														   
  into _tipo_produccion											   
  from emitipro													   
 where cod_tipoprod = _cod_tipoprod;								   

select nombre
  into _nom_formapag
  from cobforpa
 where cod_formapag = _cod_formapag;

select nombre
  into _nom_contratante
  from cliclien
 where cod_cliente = _cod_contratante;

select nombre
  into _nom_pagador
  from cliclien
 where cod_cliente = _cod_pagador;

select count(*)
  into _rol
  from cobcobra
 where usuario = a_user
   and activo	= 1;

call sp_cob116(a_no_poliza) 
returning	v_cod_agente,  
			v_agente,      
			_cod_zona,
			_zona_cobros,
			v_leasing,
			_cod_div_cob,
			_nom_div_cob;  

foreach
	select no_tarjeta,
		   periodo,
		   dia
	  into _no_tarjeta,
		   _periodo_tcr,
		   _dia_cobros1
	  from cobtacre
	 where no_documento = _no_documento
	exit foreach;
end foreach

foreach
	select no_cuenta,
		   periodo,
		   dia
	  into _no_cuenta,
		   _periodo_ach,
		   _dia_cobros1
	  from cobcutas
	 where no_documento = _no_documento
	exit foreach;
 end foreach

if _tipo_tarjeta = '1' then
	let _tipo_tarjeta_char = 'Visa';
elif _tipo_tarjeta = '2' then
	let _tipo_tarjeta_char = 'Mastercard';
elif _tipo_tarjeta = '3' then
	let _tipo_tarjeta_char = 'Diners Club';
elif _tipo_tarjeta = '4' then
	let _tipo_tarjeta_char = 'American Express';
else
	let _tipo_tarjeta_char = '';
end if

if _rol = 0 then
	if _no_tarjeta is not null then
		let _len_tarjeta = length(_no_tarjeta);
		let _no_tarjeta_parte1 = _no_tarjeta[1,5];
		let _no_tarjeta_parte2 = substr(_no_tarjeta,-5);

	 	if _tipo_tarjeta = 4 then
			let _no_tarjeta_final = trim(_no_tarjeta_parte1) || 'xxxxxx' || trim(_no_tarjeta_parte2);
	 	else
			let _no_tarjeta_final = trim(_no_tarjeta_parte1) || 'XXXX-XXXX' || trim(_no_tarjeta_parte2);
	 	end if
	end if
else
	let _no_tarjeta_final = _no_tarjeta; 
end if

if _tipo_cuenta = 'D' then
	let _tipo_cuenta_char = 'Corriente';
elif _tipo_cuenta = 'S' then
	let _tipo_cuenta_char = 'Ahorro';
else
	let _tipo_cuenta_char = '';
end if

if _rol = 0 then
	let _no_cuenta_final = 'XXXX' || substring(_no_cuenta from 5);
else
	let _no_cuenta_final = _no_cuenta;
end if
 
if _estatus_poliza = 1 then
	let _status_char = 'Vigente';
elif _estatus_poliza = 2 then
	let _status_char = 'Cancelada';
elif _estatus_poliza = 3 then
	let _status_char = 'Vencida';
elif _estatus_poliza = 4 then
	let _status_char = 'Anulada';
else
	let _status_char = '';
end if  
 
return _cod_contratante,			-- _cod_contratante									
	   _cod_pagador,				-- _cod_pagador		
	   _no_documento,				-- _no_documento		
	   _vigencia_inic,				-- _vigencia_inic	
	   _vigencia_final,				-- _vigencia_final	
	   _no_pagos,					-- _no_pagos			
	   _direc_cobros,				-- _direc_cobros		
	   _dia_cobros1,				-- _dia_cobros1		
	   _dia_cobros2,				-- _dia_cobros2		
	   _carta_aviso_canc,			-- _carta_aviso_canc	
	   _carta_prima_gan,			-- _carta_prima_gan	
	   _carta_vencida_sal,			-- _carta_vencida_sal
	   _carta_recorderis,			-- _carta_recorderis	
	   _fecha_aviso_canc,			-- _fecha_aviso_canc	
	   _fecha_prima_gan,			-- _fecha_prima_gan	
	   _fecha_vencida_sal,			-- _fecha_vencida_sal
	   _fecha_recorderis,			-- _fecha_recorderis	
	   _saldo,						-- _saldo			
	   _no_tarjeta_final,			-- _no_tarjeta		
	   _fecha_exp,					-- _fecha_exp			
	   _no_cuenta_final,			-- _no_cuenta			
	   _fecha_primer_pago,			-- _fecha_primer_pago
	   _fecha_cancelacion,			-- _fecha_cancelacion
	   _no_recibo,					-- _no_recibo		
	   _nom_banco,					-- _nom_banco		
	   _nom_perpago,				-- _nom_perpago		
	   _nom_tipocalc,				-- _nom_tipocalc		
	   _tipo_produccion,			-- _tipo_produccion	
	   _nom_formapag,				-- _nom_formapag		
	   _nom_contratante,			-- _nom_contratante	
	   _nom_pagador,				-- _nom_pagador		
	   _tipo_tarjeta_char,			-- _tipo_tarjeta_char
	   _tipo_cuenta_char,			-- _tipo_cuenta_char	
	   _status_char,				-- _status_char		
	   _zona_cobros,				-- _zona_cobros
	   _nom_div_cob,				-- _nom_div_cob
	   _periodo_tcr,	
	   _periodo_ach;
end procedure;