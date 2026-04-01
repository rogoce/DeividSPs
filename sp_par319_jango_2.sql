-- Envios masivos de correos por prioridad de envio 
-- Creado por :    Roman Gordon		 08/04/2011
-- SIS v.2.0 - DEIVID, S.A. 

drop procedure sp_par319_jango_2;

create procedure "informix".sp_par319_jango_2() 
returning	char(384),	--_email,  
			smallint,	--_enviado, 
			smallint,	--_adjunto, 
			char(3000),	--_html_body, 
			integer,	--_secuencia,
			char(100),	--_sender_tipo,	
			char(5),	--_cod_tipo,
			char(100),	--_sender_send,
			char(100),	--_asunto
			char(100),	--_ruta_image
			char(50),	--_nom_tipo
			varchar(50);
		  	

define _a_nombre_de     varchar(100);
define _html_body		char(3000);
define _nombre_agente2	char(255);
define _no_documento2	char(255);
define _email			char(384);
define _asunto			char(100);
define _asunto_orig		char(100);
define _sender_send		char(100);
define _ruta_image2		char(100);
define _ruta_image		char(100);
define _nombre_cliente	char(50);
define _nombre_agente	char(50);
define _sender_tipo		char(50);
define _nom_tipo		char(50);
define _no_documento	char(20);
define _enviado			char(20);
define _no_tarjeta		char(19);
define _no_cuenta		char(17);
define _cod_cliente		char(10);
define _no_poliza		char(10);
define _no_requis       char(10);
define _no_lote			char(5);
define _cod_agente		char(5);
define _cod_tipo		char(5);
define _tipo_tran		char(1);
define _secuencia		integer;
define _adjunto			smallint;
define _renglon			smallint;
define _cnt_ach			smallint;
define _cnt_tcr			smallint;
define _bandera  		smallint;
define _cnt_rechazo		smallint;
define _fecha_suspension	date;
define _fecha_susp_orig		date;
define _fecha_proceso		date;
define _grupo_trans     varchar(50);
define _flag            smallint;   
define _date_added      date;
define _dias            integer;

set isolation to dirty read;
--set debug file to "sp_par319_jango.trc";
--trace on;

let _cod_tipo		= '';
let	_asunto			= '';
let	_email			= '';
let	_sender_tipo	= '';
let	_html_body		= '';
let _sender_send	= '';
let	_enviado		= 0;
let	_adjunto		= 0;
let	_secuencia		= 0;
let	_bandera		= 0;
let	_nombre_agente2 = '';
let _no_documento2	= '';
let _flag = 0;

select valor_parametro
  into _ruta_image
  from inspaag
 where codigo_compania	= '001'
   and codigo_agencia	= '001'
   and aplicacion		= 'PAR'
   and version			= '02'
   and codigo_parametro	= 'imagen_correo';

foreach
	select cod_tipo,
		   sender,
		   asunto,
		   nombre,
		   grupo_trans
	  into _cod_tipo,
	  	   _sender_tipo,
	  	   _asunto_orig,
		   _nom_tipo,
		   _grupo_trans
	  from parmailtipo
     where envio_jango = 1
	 order by prioridad ,cod_tipo

	let _ruta_image2 = trim(_ruta_image) || trim(_nom_tipo) || '\' ;

	foreach
		select email,
			   enviado,
			   adjunto,
			   trim(html_body),
			   secuencia,
			   sender,
			   date(date_added)
		  into _email,
			   _enviado,
			   _adjunto,
			   _html_body,
			   _secuencia,
			   _sender_send,
			   _date_added
	  	  from parmailsend
	 	 where cod_tipo = _cod_tipo
		   and enviado in (3)
--		   and secuencia in (3472897)
		   and email is not null
		   and email not like '%/%'
		   and email <> ''
		   and email <> 'actualiza@asegurancon.com'
		   and email <> 'actualizaciones@asegurancon.com'
		   and email like '%@%'
		   and email not like '@%'
		   and email not like '% %'
		   and email not like '%,%'
           and date_added is not null
           and today - date(date_added) < 5
		 order by secuencia

        let _dias = today - _date_added;

		if _cod_tipo in ('00021','00022','00023') and _dias > 4  then
			continue foreach;
		end if

		select count(*)
		  into _cnt_rechazo
		  from parmailerr
		 where email = _email;

		if _cnt_rechazo > 0 then
			update parmailsend
			   set enviado = 2
			 where secuencia = _secuencia;
			continue foreach;
		end if

		let _bandera = 0;
		let _nombre_agente2 = '';
		let _no_documento2	= '';
		
		--No Reintentar enviar los correos de estos Tipos (COMPROBANTES DE PAGOS, No Facturacion Salud, ESTADOS DE CUENTAS, 
		--Notificacion de Rechazos TCR, Notificacion de Rechazos ACH)

		if _enviado = 3 and _cod_tipo in ('00030','00031','00004','00017','00015','00019','00021','00023') then
		--	continue foreach;
		end if

		let _asunto = _asunto_orig;

		if _cod_tipo in ('00004','00015') then
			foreach
				Select asegurado
				  into _cod_cliente
				  from parmailcomp
				 where mail_secuencia = _secuencia
				exit foreach;
			end foreach

			if _cod_cliente is not null or _cod_cliente <> '' then
				select nombre
				  into _nombre_cliente
				  from cliclien
				 where cod_cliente = _cod_cliente;
					
				let _asunto = trim(_asunto) || '-' || trim(_cod_cliente) || '-' || trim(_nombre_cliente);
			end if
		elif _cod_tipo = '00010' and _bandera = 0 then
			foreach
				select distinct trim(no_documento)
				  into _no_documento
				  from parmailcomp
				 where mail_secuencia = _secuencia
				   and no_documento is not null

				if _no_documento is not null or _no_documento <> '' then
					let _no_documento2 = trim(_no_documento2) || ' ' || trim(_no_documento);	
				end if
			end foreach
			let _asunto = trim(_asunto) || ' ' || trim(_no_documento2);	
			let _bandera = 1;
		elif _cod_tipo = '00011' and _bandera = 0 then
			foreach
				select distinct trim(asegurado)
			 	  into _cod_agente
				  from parmailcomp
				 where mail_secuencia = _secuencia
				   and asegurado is not null

				select trim(nombre)
				  into _nombre_agente
				  from agtagent
				 where cod_agente = _cod_agente;

					if _cod_agente is not null or _cod_agente <> '' then
						let _nombre_agente2 = trim(_nombre_agente2) || ' '|| _cod_agente || ' ' || trim(_nombre_agente);	
					end if
			end foreach					 					
			let _asunto		= trim(_asunto) || ' ' || trim(_nombre_agente2);
			let _bandera	= 1;

		elif _cod_tipo = '00040' then
			call sp_sis448(_secuencia) returning _html_body;
			
			if _html_body = '' then
				continue foreach;
			end if

		elif _cod_tipo = '00019' then
			select no_remesa
		 	  into _cod_agente
			  from parmailcomp
			 where mail_secuencia = _secuencia;
			
			select nombre
			  into _nombre_agente
			  from agtagent
			 where cod_agente = _cod_agente;

			let _asunto = trim(_asunto) || _cod_agente || ' ' || trim(_nombre_agente);
		elif _cod_tipo in ('00017','00018','00030','00031','00037','00038','00039') then

			select no_documento,
				   fecha
			  into _no_documento,
				   _fecha_susp_orig
			  from parmailcomp
			 where mail_secuencia = _secuencia;

			if _cod_tipo in ('00037','00038','00039') then
				select fecha_suspension
				  into _fecha_suspension
				  from emipoliza
				 where no_documento = _no_documento;

				{if _fecha_suspension <> _fecha_susp_orig or _no_documento <> '0217-00252-05' then
					update parmailsend
					   set enviado = 2
					  where secuencia = _secuencia;
					continue foreach;
				end if}
				
				call sp_sis448(_secuencia) returning _html_body;

				if _html_body = '' then
					continue foreach;
				end if
			end if

			if _no_documento is null then
				let _no_documento= '';
			end if
			
			let _asunto = trim(_asunto) || ' ' || trim(_no_documento);
			---
		elif _cod_tipo = '00021' then
			select no_documento,
				   asegurado
			  into _no_documento,
				   _no_tarjeta
			  from parmailcomp
			 where mail_secuencia = _secuencia;
			 
			select count(*)
			  into _cnt_tcr
			  from cobtatra
			 where no_documento = _no_documento
			   and no_tarjeta	= _no_tarjeta
			   and procesar		= 0; 
			
			if _cnt_tcr = 0 then
				update parmailsend
				   set enviado = 3
				 where secuencia = _secuencia;
				continue foreach;
			end if
			
			let _asunto = trim(_asunto) || ' TCR -' || trim(_no_documento);
		elif _cod_tipo = '00022' then
			{select no_documento,
				   asegurado
			  into _no_documento,
				   _no_tarjeta
			  from parmailcomp
			 where mail_secuencia = _secuencia;
			 
			select count(*)
			  into _cnt_tcr
			  from cobtatra
			 where no_documento = _no_documento
			   and no_tarjeta	= _no_tarjeta
			   and procesar		= 0; 
			
			if _cnt_tcr = 0 then
				update parmailsend
				   set enviado = 3
				 where secuencia = _secuencia;
				continue foreach;
			end if
			
			let _asunto = trim(_asunto) || ' TCR -' || trim(_no_documento);}

		elif _cod_tipo = '00023' then
			--continue foreach;
			select no_documento,
				   asegurado,
				   fecha
			  into _no_documento,
				   _no_cuenta,
				   _fecha_proceso
			  from parmailcomp
			 where mail_secuencia = _secuencia;

			select count(*)
			  into _cnt_ach
			  from cobcutmpre
			 where no_documento = _no_documento
			   and no_cuenta = _no_cuenta
			   and date(date_added) = _fecha_proceso;

			if _cnt_ach = 0 then
				update parmailsend
				   set enviado = 3
				 where secuencia = _secuencia;
				continue foreach;
			end if

			let _asunto = trim(_asunto) || ' ACH -' || trim(_no_documento);		
 		elif _cod_tipo in ('00016','00034') then
		    let _no_requis = null;
		    foreach
				select no_remesa
			 	  into _no_requis
				  from parmailcomp
				 where mail_secuencia = _secuencia

                exit foreach;
			end foreach
			if _no_requis is not null then
				select a_nombre_de
				  into _a_nombre_de
				  from chqchmae
				 where no_requis = _no_requis;

				let _asunto = trim(_asunto) || ' ' || trim(_a_nombre_de);
			else
			    continue foreach;
			end if 
   		elif _cod_tipo = '99999' then
			let _asunto = trim(_asunto) || ' ' || 'Nuevo Reporte de Morosidad';

			select html
			  into _html_body
			  from parmailtipo
			 where cod_tipo = _cod_tipo;

		end if

		return _email,
			   _enviado,
			   _adjunto,
			   _html_body,
	 		   _secuencia,
			   _sender_tipo,
			   _cod_tipo,
			   _sender_send,
			   _asunto,
			   _ruta_image,
			   _nom_tipo,
			   _grupo_trans with resume;
	end foreach
end foreach
end procedure



	