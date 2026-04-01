--Creado: 11/03/2025
--Autor: Armando Moreno M.
--Verificación de duplicidad en cobtacre y actualización proveniente de cobcampl

drop procedure sp_sis257_v2;
create procedure sp_sis257_v2()
returning	char(3)         as forma_de_pago,
            char(50)        as n_forma_de_pago,
			char(10)        as no_poliza,
			char(20)        as poliza,
			char(10)        as max_no_cambio,
			char(19)        as no_tarjeta_e,
			integer         as no_pagos_e,
			char(7)         as fecha_exp_e,
			char(3)         as cod_banco_e,
			char(1)         as tipo_tarjeta,
			char(19)        as no_tarjeta_c,
			integer         as no_pagos_c,
			char(7)         as fecha_exp_c,
			char(3)         as cod_banco_c,
			char(1)         as tipo_tarjeta_campl,
			date            as fecha_cambio;
			
define _no_documento			char(20);
define _no_poliza,_no_cambio,_no_poliza_otr    char(10);           
define _no_tarjeta,_no_tarjeta_cre 			    char(19);           
define _n_forma			        char(50);
define _fecha_exp 				char(7);           
define _cod_banco 				char(3);           
define _tipo_tarjeta			char(1);     
define _no_pagos        		integer;      
define _cnt,_cnt2              		integer;  
define _fecha_cambio            date;

define _no_poliza_campl    char(10);
define _no_pagos_campl     integer;
define _fecha_cambio_campl,_vig_fin date;
define _no_tarjeta_campl   char(19);
define _fecha_exp_campl    char(7);
define _cod_banco_campl    char(3);
define _tipo_tarjeta_campl char(1);
define _cod_formapag	   char(3);
define _fecha_act          date;

--set debug file to "sp_sis245.trc";
--trace on;

begin

let _fecha_act = current;

foreach
	select no_documento,count(*)
	  into _no_documento,_cnt
	  from cobtacre
	group by 1
	having count(*) > 1
	
	select max(no_cambio)
	  into _no_cambio
	  from cobcampl
	 where no_documento = _no_documento;

	select no_poliza,
	       no_pagos,
		   fecha_cambio,
		   no_tarjeta,
		   fecha_exp,
		   cod_banco,
		   tipo_tarjeta
	  into _no_poliza_campl,
           _no_pagos_campl,
		   _fecha_cambio_campl,
		   _no_tarjeta_campl,
		   _fecha_exp_campl,
		   _cod_banco_campl,
		   _tipo_tarjeta_campl
	  from cobcampl
     where no_cambio = _no_cambio;
	 
	select no_pagos,
		   no_tarjeta,
		   fecha_exp,
		   cod_banco,
		   tipo_tarjeta,
		   cod_formapag,
		   vigencia_final
	  into _no_pagos,
		   _no_tarjeta,
		   _fecha_exp,
		   _cod_banco,
		   _tipo_tarjeta,
		   _cod_formapag,
		   _vig_fin
	  from emipomae
     where no_poliza = _no_poliza_campl;
	 
	select nombre into _n_forma from cobforpa
	where cod_formapag = _cod_formapag;

{	return _cod_formapag,_n_forma,_no_poliza_campl,_no_documento,_no_cambio,_no_tarjeta,_no_pagos,_fecha_exp,_cod_banco,_tipo_tarjeta,
           _no_tarjeta_campl,_no_pagos_campl,_fecha_exp_campl,_cod_banco_campl,_tipo_tarjeta_campl,_fecha_cambio_campl with resume;
}		   
		   
	--Actualizacion en emipomae del no_poliza del maximo no_cambio y los siguientes no_poliza
	if _cod_formapag = '003' then	--Tarjeta de credito
		foreach
			select no_poliza
			  into _no_poliza_otr
			  from emipomae
			 where actualizado = 1
			   and no_documento = _no_documento
			   and cod_formapag = '003'
               and vigencia_final >= _vig_fin		 
		
			update emipomae
			   set no_tarjeta   = _no_tarjeta_campl,
				   fecha_exp    = _fecha_exp_campl,
				   cod_banco    = _cod_banco_campl,
				   tipo_tarjeta = _tipo_tarjeta_campl
			 where no_poliza    = _no_poliza_otr;
		end foreach	 
		
		foreach
			select no_tarjeta
			  into _no_tarjeta_cre
			  from cobtacre
			 where no_documento = _no_documento
			   and no_tarjeta <> _no_tarjeta_campl
			  
			delete from cobtacre
			 where no_tarjeta   = _no_tarjeta_cre
			   and no_documento = _no_documento;
			   
			insert into deivid_tmp:cobtacre_e(
			no_documento,
			no_tarjeta,
			no_cambio,
			fecha_eliminado,
			cod_formapag)
			values(
			_no_documento,
			_no_tarjeta_cre,
			_no_cambio,
			_fecha_act,
			_cod_formapag);
			   
			select count(*)
              into _cnt2
              from cobtacre
			 where no_tarjeta = _no_tarjeta_cre;
			 
			if _cnt2 is null then
				let _cnt2 = 0;
			end if
			
			if _cnt2 = 0 then
				delete from cobtahab
				where no_tarjeta = _no_tarjeta_cre;
			end if
		end foreach
	else
		foreach
			select no_tarjeta
			  into _no_tarjeta_cre
			  from cobtacre
			 where no_documento = _no_documento
			 
			delete from cobtacre
			 where no_tarjeta   = _no_tarjeta_cre
			   and no_documento = _no_documento;
			   
			insert into deivid_tmp:cobtacre_e(
			no_documento,
			no_tarjeta,
			no_cambio,
			fecha_eliminado,
			cod_formapag)
			values(
			_no_documento,
			_no_tarjeta_cre,
			_no_cambio,
			_fecha_act,
			_cod_formapag);
			   
			select count(*)
              into _cnt2
              from cobtacre
			 where no_tarjeta = _no_tarjeta_cre;
			 
			if _cnt2 is null then
				let _cnt2 = 0;
			end if
			
			if _cnt2 = 0 then
				delete from cobtahab
				where no_tarjeta = _no_tarjeta_cre;
			end if
		end foreach 
	end if
    		
end foreach
end
end procedure;