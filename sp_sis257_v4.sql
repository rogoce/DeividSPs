--Corre en Diario Reporte_cobros, verificación de registros electronico TCR/ACH del dia anterior vs emipomae.
--De haber diferenicas, mostrarlas para su investigación.
--Creado: 12/03/2025
--Autor: Armando Moreno M.

drop procedure sp_sis257_v4;
create procedure sp_sis257_v4()
returning	smallint        as valor,
            date            as fecha_cambio,
			char(10)        as no_cambio,
			char(10)        as no_poliza,
			char(20)        as no_documento,			
			integer         as no_pagos_e,
			integer         as no_pagos_c,
			char(3)         as cod_banco_e,
			char(3)         as cod_banco_c,
			char(3)         as cod_perpago_e,
			char(3)         as cod_perpago_c,
			char(3)         as cod_formapag_e,
			char(3)         as cod_formapag_c,
			char(7)         as fecha_exp_e,
			char(7)         as fecha_exp_c,
			char(1)         as tipo_tarjeta_e,
			char(1)         as tipo_tarjeta_c,
			char(19)        as no_tarjeta_e,
			char(19)        as no_tarjeta_c,
			char(1)         as tipo_cuenta_e,
			char(1)         as tipo_cuenta_c,
			char(17)        as no_cuenta_e,
			char(17)        as no_cuenta_c;
			
define _no_documento			char(20);
define _no_poliza,_no_cambio,_no_poliza_otr    char(10);           
define _no_tarjeta,_no_tarjeta_cre 			    char(19);           
define _n_forma			        char(50);
define _fecha_exp 				char(7);           
define _cod_banco 				char(3);           
define _tipo_tarjeta			char(1);     
define _no_pagos        		integer;      
define _cnt,_cnt2              	integer;  
define _fecha_cambio            date;
define _flag					smallint;
define _no_poliza_campl    char(10);
define _no_pagos_campl     integer;
define _fecha_cambio_campl,_vig_fin date;
define _no_tarjeta_campl   char(19);
define _fecha_exp_campl    char(7);
define _cod_banco_campl    char(3);
define _tipo_tarjeta_campl,_tipo_cuenta char(1);
define _cod_formapag,_cod_formapag_campl,_cod_perpago,_cod_perpago_campl	   char(3);
define _no_cuenta_campl,_no_cuenta    char(17);
define _tipo_cuenta_campl  char(1);

--set debug file to "sp_sis245.trc";
--trace on;

set isolation to dirty read; --> agregado A.P.M. 11-08-2025

let _flag = 0;
begin
foreach
	select no_documento,max(no_cambio)
	  into _no_documento,_no_cambio
	  from cobcampl
     where fecha_cambio = today -1
     group by no_documento
     order by no_documento
	 
	select no_poliza,
	       no_pagos,
		   fecha_cambio,
		   no_tarjeta,
		   fecha_exp,
		   cod_banco,
		   tipo_tarjeta,
		   no_cambio,
		   no_cuenta,
		   tipo_cuenta,
		   cod_formapag,
		   cod_perpago
	  into _no_poliza_campl,
           _no_pagos_campl,
		   _fecha_cambio_campl,
		   _no_tarjeta_campl,
		   _fecha_exp_campl,
		   _cod_banco_campl,
		   _tipo_tarjeta_campl,
		   _no_cambio,
		   _no_cuenta_campl,
		   _tipo_cuenta_campl,
		   _cod_formapag_campl,
		   _cod_perpago_campl
	  from cobcampl
     where no_documento = _no_documento
	   and no_cambio    = _no_cambio;
	 
	select no_pagos,
		   no_tarjeta,
		   fecha_exp,
		   cod_banco,
		   tipo_tarjeta,
		   cod_formapag,
		   vigencia_final,
   		   no_cuenta,
		   tipo_cuenta,
		   cod_perpago,
		   no_cuenta
	  into _no_pagos,
		   _no_tarjeta,
		   _fecha_exp,
		   _cod_banco,
		   _tipo_tarjeta,
		   _cod_formapag,
		   _vig_fin,
		   _no_cuenta_campl,
		   _tipo_cuenta,
		   _cod_perpago,
		   _no_cuenta
	  from emipomae
     where no_poliza = _no_poliza_campl;
	 
	select nombre into _n_forma from cobforpa
	where cod_formapag = _cod_formapag;
	
	let _flag = 0;
	if _no_pagos_campl <> _no_pagos then
		let _flag = 1;
	elif _cod_banco_campl <> _cod_banco then
		let _flag = 1;
	elif _cod_perpago_campl <> _cod_perpago then
		let _flag = 1;
	elif _cod_formapag <> _cod_formapag_campl then
		let _flag = 1;
	end if
	
	if _cod_formapag_campl = '003' then	--F. P. Tarjeta de creidto
		if _fecha_exp_campl <> _fecha_exp then
			let _flag = 1;
		elif _tipo_tarjeta_campl <> _tipo_tarjeta then
		elif _no_tarjeta_campl <> _no_tarjeta then
			let _flag = 1;
		end if
	else
		if _tipo_cuenta_campl <> _tipo_cuenta then
			let _flag = 1;
		elif _no_cuenta_campl <> _no_cuenta then
			let _flag = 1;
		end if
	end if
	if _flag = 1 then
	
		return _flag,today -1,_no_cambio,_no_poliza_campl,_no_documento,_no_pagos,_no_pagos_campl,_cod_banco, _cod_banco_campl,_cod_perpago,_cod_perpago_campl,
		       _cod_formapag,_cod_formapag_campl,_fecha_exp,_fecha_exp_campl,_tipo_tarjeta,_tipo_tarjeta_campl,_no_tarjeta,_no_tarjeta_campl,
			   _tipo_cuenta,_tipo_cuenta_campl,_no_cuenta,_no_cuenta_campl with resume;
	end if
end foreach
return _flag,today -1,"","","",0,0,"", "","","","","","01/01/1900","01/01/1900","","","","","","","","";
end
end procedure;