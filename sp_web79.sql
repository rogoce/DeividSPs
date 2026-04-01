-- Procedimiento que saca de excepcion las polizas del producto 10602 cuya fecha final de excepcion sea hoy
-- Creado     :	13/03/2025 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_web79;		
create procedure sp_web79()
returning integer,
		  char(10),
		  char(20),
		  varchar(16),
		  VARCHAR(50),
		  VARCHAR(50),
		  VARCHAR(10),
		  DATE,
		  varchar(20),
		  varchar(19);
		  
define _cod_producto   char(5);
define _cod_formapag   char(3);
define _activo         integer;
define _error   	   smallint;
define _excep_fin      date;
define _monto_visa     dec(16,2);
define _no_documento   char(20);
define _no_tarjeta	   char(19);
define _no_poliza	   char(10);
define _cotizacion	   varchar(16);
define _cnt_pagos      smallint;
define _asegurado      varchar(50);
define _corredor       varchar(50);
define _placa          varchar(10);
define _fecha_emi	   date;
define _cod_contratante varchar(10); 
define _no_unidad       char(5);
define _estado_poliza   varchar(15);                 

set isolation to dirty read;

let _error = 0;

--SET DEBUG FILE TO "sp_web78.trc";
--TRACE ON;

foreach
	select no_tarjeta, 
		   no_documento, 
		   excep_fin
	  into _no_tarjeta,
		   _no_documento,
		   _excep_fin
	 from cobtacre 
	where excep_fin = today

	let _no_poliza = sp_sis21(_no_documento);
	let _activo = 0;
	let _asegurado = "";
	let _corredor = ""; 
	let _placa = "";   
	let _fecha_emi = "";
	select monto_visa,
		   trim(cod_formapag),
		   cotizacion,
		   cod_contratante,
		   fecha_suscripcion,
           CASE estatus_poliza
			   WHEN 1 THEN 'VIGENTE'
			   WHEN 2 THEN 'CANCELADA'
			   WHEN 3 THEN 'VENCIDA'
			   ELSE 'ANULADA'
		   END AS estatus_poliza
	  into _monto_visa,
		   _cod_formapag,
		   _cotizacion,
		   _cod_contratante,
		   _fecha_emi,
		   _estado_poliza
	  from emipomae
	 where no_poliza = _no_poliza;

	foreach
		select trim(cod_producto),
		       no_unidad
		  into _cod_producto,
		       _no_unidad
		  from emipouni
		 where no_poliza = _no_poliza
		 
		if _cod_producto = '10602' and _cod_formapag = '003' then
			let _activo = 1;
			exit foreach;
		end if
	end foreach
	if _activo = 1 then
		select count(*)
		  into _cnt_pagos
		  from cobredet
		 where actualizado = 1
		   and tipo_mov IN ('P','N')
		   and doc_remesa = _no_documento;
		   
			if _cnt_pagos > 0 then
				/* Se comento porque primero se debe verificar si la poliza fue verificada en el visor web. el update se paso para el diario webserver/diario/enviar_correo.php
				update cobtacre
				   set excep_fin   =  _excep_fin + 8 UNITS DAY
				where no_documento = _no_documento
				  and no_tarjeta   = _no_tarjeta;
				*/	
				select nombre
				  into _asegurado
				  from cliclien
				 where cod_cliente = _cod_contratante;
				 
				select placa
				  into _placa
				from emivehic a inner join emiauto b on a.no_motor = b.no_motor
			   where no_poliza = _no_poliza 
			     and no_unidad = _no_unidad; 
				 
				select FIRST 1 nombre
                  into _corredor				
				  from emipoagt a inner join agtagent b on a.cod_agente = b.cod_agente
                 where no_poliza = _no_poliza; 
				
				let _activo = 2;
			else	
				update cobtacre
				   set excep_ini 		= '',
					   excep_fin 		= '',
					   excepcion 		= 0,
					   cargo_especial 	= _monto_visa, 
					   fecha_inicio   	= _excep_fin + 1 UNITS DAY,
					   fecha_hasta 		= _excep_fin + 1 UNITS DAY, 
					   dia_especial 	= day(_excep_fin + 1 UNITS DAY)
				where no_documento = _no_documento
				  and no_tarjeta   = _no_tarjeta;	
			end if  
		return _activo,
		       _no_poliza,
			   _no_documento,
			   _cotizacion,
			   _asegurado,
			   _corredor,
			   _placa,
			   _fecha_emi,
			   _estado_poliza,
			   _no_tarjeta
			   WITH RESUME;
	else
		continue foreach;  
	end if
end foreach
end procedure 