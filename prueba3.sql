create procedure "informix".sp_pro348(
)returning	smallint,char(100);


define _error				integer;
define _error_isam			integer;
define _emi_fecha_salud		date;
define _vigencia_final		date;
define _fecha1				date;
define _fecha_hasta			date;
define _fecha_desde			date;
define _mes_vig_fin			smallint;
define _mes_fecha_salud		smallint;
define _cant_facturacion	smallint;
define _cont				smallint;
define _cantidad			smallint;
define _error_desc			char(100);
define _no_documento		char(20);
define _no_poliza			char(10);
define _cod_pagador			char(10);
define _usuario				char(8);
define _periodo				char(7);
define _secuencia_char		char(5);
define _ano					char(4);
define _mes					char(4);
define _secuencia			integer;
define _secuencia_comp		integer;
define _html_body			char(512);
define _cod_tipo			char(5);
define _email				char(50);
define _desc_gestion		char(100);
define _email_send			char(150);
define _fecha_gestion		datetime year to fraction(5);


on exception set _error, _error_isam, _error_desc
	--rollback work;
	return _error,_error_desc;
end exception


set isolation to dirty read;
begin

--SET DEBUG FILE TO "sp_pro348.trc"; 
--TRACE ON; 
let _email_send = '';
	
select count(*)
  into _cantidad
  from emifacsa;

if _cantidad > 0 then

	select emi_fecha_salud
	  into _emi_fecha_salud
	  from parparam;

	let _secuencia = sp_sis148();
	foreach
		select email
		  into _email
		  from parcocue
		 where cod_correo = '059'
		   and activo = 1

			let _email_send = trim(_email_send) || trim(_email) || ';';
	end foreach
	 
	let _cod_tipo  = "00020";	
	let _html_body = "<html><img src=cid:" ||  _secuencia || ".jpg width=850 height=1100>";

	insert into parmailsend(
	cod_tipo,
	email,
	enviado,
	adjunto,
	secuencia,
	html_body,
	sender
	)
	values(
	_cod_tipo,
	_email_send,
	0,
	0,
	_secuencia,
	_html_body,
	null);

	foreach
		select no_documento,
			   user_added
		  into _no_documento,
		  	   _usuario
		  from emifacsa

			call sp_sis21(_no_documento) returning _no_poliza;

			select vigencia_final,
				   cod_pagador
			  into _vigencia_final,
				   _cod_pagador
			  from emipomae
			 where no_poliza = _no_poliza;
			
			if _vigencia_final > _emi_fecha_salud then
				update emipomae				
				   set cod_no_renov = null
				 where no_documento = _no_documento;
				 				   	
				delete from emifacsa where no_documento = _no_documento;

				continue foreach;
			end if

		   	let _mes_vig_fin		= month(_vigencia_final);    
		   	let _mes_fecha_salud	= month(_emi_fecha_salud);
			let _cant_facturacion   = _mes_fecha_salud - _mes_vig_fin + 1;

			if _cant_facturacion < 0 then
				let _cant_facturacion = _cant_facturacion + 12;
			end if			
					
			for _cont = 1 to _cant_facturacion
				let _fecha1		= _vigencia_final + _cont units month; 
				call sp_sis39(_vigencia_final) returning _periodo;
				call sp_sis36(_periodo) returning _fecha_hasta;  

			   	let _ano				= _periodo[1,4];
				let _mes				= _periodo[6,7];
				let _fecha_desde		= mdy(_mes, 1, _ano);
				call sp_pro30h('001','001',_no_documento,_fecha_desde,_fecha_hasta,_usuario) returning _error,_error_desc;
				
				if _error <> 0 then
					return _error,_error_desc with resume;
				else
					update emipomae
					   set cod_no_renov = null
					 where no_documento = _no_documento;
					 				   	
					delete from emifacsa where no_documento = _no_documento;
				
					let _secuencia_comp = sp_sis149();

					insert into parmailcomp(
					secuencia,
					no_remesa,
					renglon,
					mail_secuencia,
					no_documento,
					asegurado,
					saldo,
					saldo61,
					prima_mensual
					)
					values(
					_secuencia_comp,
					_periodo,
					0,
					_secuencia,
					_no_documento,
					null,
					0.00,
					0.00,
					0.00
					); 
				end if					
			end for
			call sp_sis40() returning _fecha_gestion;
			let _desc_gestion ="Se ha procedido con Re facturación Automática de Salud";
	 
					insert into cobgesti(
					no_poliza,
					fecha_gestion,
					desc_gestion,
					user_added,
					no_documento,
					fecha_aviso,
					tipo_aviso,
					cod_gestion,
					cod_pagador
					)
					values(
					_no_poliza,
					_fecha_gestion,
					_desc_gestion,
					_usuario,
					_no_documento,
					null,
					0,
					null,
					_cod_pagador); 
	end foreach
	return 0,'facturación automática exitosa';
else
	return 0,'No hay Facturaciones automáticas por realizar';
end if
end
end procedure