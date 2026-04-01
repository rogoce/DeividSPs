-- Envios caratula
-- Creado por :   Henry Girón 26/04/2017
-- SIS v.2.0 - DEIVID, S.A. 

drop procedure sp_log027;
create procedure "informix".sp_log027(a_envio_correo smallint default 0) 
returning	char(384),	--_email,  
			smallint,	--_enviado, 
			smallint,	--_adjunto, 
			char(512),	--_html_body, 
			integer,	--_secuencia,
			char(100),	--_sender_tipo,	
			char(5),	--_cod_tipo,
			char(100),	--_sender_send,
			char(100),	--_asunto
			char(100),	--_ruta_image
			char(50);	--_nom_tipo
		  	

define _a_nombre_de     varchar(100);
define _html_body		char(512);
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
define _fecha_proceso	date;


set isolation to dirty read;
--set debug file to "sp_log027.trc";
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
		   nombre
	  into _cod_tipo,
	  	   _sender_tipo,
	  	   _asunto_orig,
		   _nom_tipo
	  from parmailtipo
  	 where cod_tipo in ('00001') 	   
	 order by prioridad ,cod_tipo

	let _ruta_image2 = trim(_ruta_image) || trim(_nom_tipo) || '\' ;	

	foreach
		select email,
			   enviado,
			   adjunto,
			   html_body,
			   secuencia,
			   sender
		  into _email,
			   _enviado,
			   _adjunto,
			   _html_body,
			   _secuencia,
			   _sender_send
	  	  from parmailsend
	 	 where enviado in (0)
		   and cod_tipo = _cod_tipo
		   and email is not null
		   and secuencia in ('4416165') --3028782')
		   --and secuencia in ('2297286','2324875','2325396','2325429','2325532','2327021') -- '1718616') -- 1689148')
		 order by secuencia

		select count(*)
		  into _cnt_rechazo
		  from parmailerr
		 where email = _email;

		if _cnt_rechazo > 0 then
			-- update parmailsend
			 --  set enviado = 2
			 -- where secuencia = _secuencia;
			continue foreach;
		end if
		
		--let _email = 'fcoronado@asegurancon.com';
		--	let _email = 'hgiron@asegurancon.com';
		let _bandera = 0;
		let _nombre_agente2 = '';
		let _no_documento2	= '';
		

		if _enviado = 3 and _cod_tipo in ('00030','00031','00017') then
			continue foreach;
		end if

		let _asunto = _asunto_orig;

		if _cod_tipo = '00030' or _cod_tipo = '00031' or _cod_tipo = '00017' then
			
			select no_documento
			  into _no_documento
			  from parmailcomp
			 where mail_secuencia = _secuencia;

			if _no_documento is null then
				let _no_documento= '';
			end if
			
			let _asunto = trim(_asunto) || ' ' || trim(_no_documento);
		
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
			   _nom_tipo	
			   with resume;
	end foreach
end foreach
end procedure



	