-- Procedimiento para polizas con 15 dias en suspension - Emipoliza (Correo al Corredor)
-- Creado: 21/11/2017 - Autor: Henry Giron
-- execute procedure sp_cob406(today)
drop procedure sp_cob406;
create procedure sp_cob406(a_fecha date default today)
returning	integer			as cod_error,
			varchar(100)	as mensaje;

define _mensaje				varchar(100);
define _no_documento		char(20);
define _no_poliza			char(10);
define _cod_tipo			char(5);
define _cod_ramo			char(3);
define _excepcion			smallint;
define _ramo_sis			smallint;
define _pagada				smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_suspension	date;
define _desc_vip			varchar(50);
define _cliente_vip			smallint;
define _cod_cliente			char(10);
define _fecha_3d_email      date;
define _fecha_3d_supension  date;
define _fecha_cubierto      date;
define _existe              integer;
define _monto_pagado	    dec(16,2);
define _fecha_ult_pago      date;
define _fecha_primer_pago   date;
define _no_pagos            integer;
define _prima_bruta	        dec(16,2);
define _letra_mensual	    dec(16,2);
define _monto_pen	        dec(16,2);

set isolation to dirty read;

--set debug file to "sp_cob406.trc";
--trace on;

begin
on exception set _error,_error_isam,_mensaje
return _error,_mensaje;
end exception
let _monto_pen = 0;
let _fecha_suspension   = a_fecha + 15 units day;
let _fecha_3d_email     =  a_fecha - 3 units day;            -- que no se haiga envido los dos dias anteriores
let _fecha_3d_supension =  _fecha_suspension - 3 units day;  -- que no se revise tres dias anteriores a supension

foreach
	select no_documento,
		   cod_ramo,
		   cod_pagador
	  into _no_documento,
		   _cod_ramo,
		   _cod_cliente
	  from emipoliza
	 where (cod_ramo not in('023','016','018'))      -- or (cod_ramo in ('018') and cod_subramo not in ('012')))
	   and fecha_suspension >= _fecha_3d_supension
       and fecha_suspension <= _fecha_suspension     -- and fecha_suspension = _fecha_suspension 
	   and exigible > 0
	   
			select ramo_sis
			  into _ramo_sis
			  from prdramo
			 where cod_ramo = _cod_ramo;

			if _ramo_sis = 1 then --Auto,Soda,Flota
				let _cod_tipo = '00038';
			else
				let _cod_tipo = '00037';
			end if	

			 select count(*)	   
			   into _existe	
			   FROM parmailsend env
			  INNER JOIN parmailcomp com
				 ON env.secuencia = com.mail_secuencia
			  WHERE com.no_documento = _no_documento
				AND env.cod_tipo = _cod_tipo
				AND date(env.date_added) between _fecha_3d_email and a_fecha;				   
			   
			if _existe is null then
				let _existe = 0;
			end if	   
			   
			if _existe > 0 then  -- ya existe no se vuelve a enviar
				continue foreach;
			end if	   	   

			call sp_ley003(_no_documento,2) returning _error,_mensaje;

			if _error < 0 then
				let _mensaje = _mensaje || ' Poliza: ' || trim(_no_documento);
				return _error,_mensaje;
			elif _error = 1 then
				continue foreach;
			end if

			call sp_sis21(_no_documento) returning _no_poliza;

			if _no_poliza is null then
				continue foreach;
			end if

			let _cliente_vip = 0; 
			call sp_sis233(_cod_cliente) returning _cliente_vip,_desc_vip; -- HG[JBRITO]14052019 Incumplimiento de Pago 1916-00044-01 si es VIP no lleva notificacion
			if _cliente_vip = 1 then
				continue foreach;
			end if 			
			
			select monto_pen
			  into _monto_pen
			  from emiletra
			 where no_poliza = _no_poliza
			   and no_letra = 1;
			   
			if _monto_pen is null then
				let _monto_pen = 0;
			end if				   

			if  _monto_pen <= 5 then		--RGORDON 06/09/2022  12pm monto <= 5	HGIRON	
				
				call sp_sis455(_no_poliza) returning _error,_mensaje;

				if _error <> 0 then
					let _mensaje = _mensaje || ' Poliza: ' || trim(_no_documento);
					return _error,_mensaje;
				end if
			else
				continue foreach;				  				  
			end if
end foreach

return 0,'Exito';

end
end procedure;