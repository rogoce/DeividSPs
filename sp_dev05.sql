-- Procedimiento que calcula la Prima Devengada proveniente de la tabla Emiletra (montos pagados)
--01/02/2016
--Armando Moreno M.

drop procedure sp_dev05;
create procedure sp_dev05(
a_fecha_desde	date,
a_fecha_hasta 	date
) returning integer,
			char(50);
 
define _no_documento		char(20);
define _no_poliza			char(10);
define _vigencia_inic		date;
define _vigencia_final		date;
define _prima_pagada		dec(16,2);
define _prima_devengada		dec(16,2);
define _prima_diaria		dec(16,6);
define _dias_vigencia		integer;
define _dias_prorrata		integer;
define _cod_ramo			char(3);
define _condicion			integer;
define _error		        integer;
define _return_trace		char(20);

set isolation to dirty read;

--set debug file to "sp_dev05.trc";
--trace on;

let _error = 0;
let _return_trace = '';

--begin
--on exception set _error
--	return _error,_return_trace;  -- "Error de Base de Datos";
--end exception


create temp table tmp_pri_cob_dev(
no_documento		char(20),
vigencia_inic		date,
vigencia_final		date,
prima_pagada		dec(16,2),
prima_devengada	    dec(16,2)
);
--trace on;
foreach
	select no_documento,vigencia_inic,vigencia_final,monto_pag , monto_pag / ((vigencia_final - vigencia_inic) + 1) as  prima_diaria,
	 case
		 when vigencia_inic < a_fecha_desde and vigencia_final > a_fecha_hasta
		   then   ( monto_pag / ((vigencia_final - vigencia_inic) + 1 )) * ((date(a_fecha_desde) - date(vigencia_inic)  )  + 1 )
		 when  vigencia_inic >= a_fecha_desde  and   vigencia_final > a_fecha_hasta
		   then       ( monto_pag / ((vigencia_final - vigencia_inic) +1)) *    (( date(a_fecha_hasta) -   vigencia_inic )  + 1 )
		 when  vigencia_inic >= a_fecha_desde  and   vigencia_final <= a_fecha_hasta
		   then       ( monto_pag / ((vigencia_final - vigencia_inic) +1)) *   ( (vigencia_final  -   vigencia_inic ) + 1 )
		  when  vigencia_inic < a_fecha_desde  and   vigencia_final <= a_fecha_hasta
		   then       ( monto_pag / ((vigencia_final - vigencia_inic) +1)) *    ((vigencia_final  -  date(a_fecha_desde) + 1 ) )
		  else 0
	 end
	   as prima_devengada
	 into _no_documento,_vigencia_inic,_vigencia_final,_prima_pagada,_prima_diaria,_prima_devengada
	 from emiletra
	where vigencia_final > '31/12/2016'
	  and vigencia_inic <= a_fecha_hasta
	  and fecha_pago is not null
	  and fecha_pago <= a_fecha_hasta

--	  begin
--	  on exception in(-1202)
--
		--let _no_documento = _no_documento;	  
--		trace off;
--		return 1, "E";
	  
--      end exception }
						
		insert into tmp_pri_cob_dev
		values (_no_documento,
				_vigencia_inic,
				_vigencia_final,
				_prima_pagada,
				_prima_devengada
				);	
--	 end
end foreach	
--end 
return 0, "Actualizacion Exitosa";

end procedure