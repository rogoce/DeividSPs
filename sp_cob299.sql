-- procedimiento para insertar el correo del reporte de inconsistencia de polizas 
-- que reciben pago y estan canceladas por falta de pago	en el proceso de envio masivo
-- creado    : 09/11/2011 - autor: roman gordon

drop procedure sp_cob299;

create procedure "informix".sp_cob299()
returning	integer,  --
			char(30); -- 

define _error				integer;
define _error_isam			integer;
define _secuencia 			integer;
define _secuencia_comp		integer;
define _renglon				smallint;
define _prima_devengada		dec(16,2);
define _credito_favor		dec(16,2);
define _monto_recibido		dec(16,2);
define _html_body			char(100);
define _nombre_cli			char(50);
define _forma_pag			char(50);
define _error_desc			char(30);
define _no_documento		char(20);
define _no_poliza			char(10);
define _cod_cliente			char(10);
define _no_remesa			char(10);
define _cod_tipo			char(5);
define _cod_no_renov		char(3);
define _fecha_remesas		date;


--set debug file to "sp_cob299.trc";
--trace on;


set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception
end

let _fecha_remesas = today - 1 units day;

foreach
	select no_remesa
	  into _no_remesa
	  from cobremae
	 where cod_banco	= '146'
	   --and cod_chequera in ('024','036','037','038','039')
	   and date_posteo = _fecha_remesas
	   and actualizado	= 1
	foreach
		select doc_remesa,
			   no_poliza,
			   saldo,
			   monto,
			   renglon
		  into _no_documento,
		  	   _no_poliza,
		  	   _prima_devengada,
		  	   _monto_recibido,
			   _renglon
		  from cobredet
		 where no_remesa = _no_remesa
		   and tipo_mov	 = 'K'

		let _credito_favor	= _prima_devengada - _monto_recibido;
		
		select cod_pagador,
			   cod_no_renov
		  into _cod_cliente,				   
			   _cod_no_renov
		  from emipomae
		 where no_poliza = _no_poliza;
		
		if _cod_no_renov is null or _cod_no_renov = '' then				
			let _cod_no_renov	= '000';
		end if

		if _cod_no_renov <> '016' then
			continue foreach;
		end if

		select nombre
		  into _nombre_cli
		  from cliclien
		 where cod_cliente = _cod_cliente;

		let _cod_tipo  = "00024";
		
		select secuencia
		  into _secuencia
		  from parmailsend
		 where enviado  = 0 
		   and cod_tipo = _cod_tipo;

		if _secuencia is null then
			let _secuencia = sp_sis148();
			let _html_body = "<html><img src=cid:" ||  _secuencia || ".jpg width=1100 height=850>";

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
			'cobros@asegurancon.com',
			0,
			0,
			_secuencia,
			_html_body,
			null
			);			
		end if

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
		_no_remesa,
		_renglon,
		_secuencia,
		_no_documento,
		_nombre_cli,
		_prima_devengada,
		_credito_favor,
		_monto_recibido
		);
	end foreach
end foreach

return 0, 'Insercion Exitosa';

end procedure;