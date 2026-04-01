-- procedimiento para insertar el correo del reporte de inconsistencia de polizas 
-- que reciben pago y estan canceladas por falta de pago	en el proceso de envio masivo
-- creado    : 09/11/2011 - autor: roman gordon

drop procedure sp_cob354;
create procedure "informix".sp_cob354()
returning	integer,  --
			char(30); -- 

define _email_agtmail		varchar(50);
define _email_cobros		varchar(50);
define _asegurado			varchar(50);
define _poliza				varchar(50);
define _doc_suspenso		varchar(30);
define _cedula				varchar(30);
define _email_send			char(384);
define _html_body			char(100);
define _nombre_cli			char(50);
define _forma_pag			char(50);
define _error_desc			char(30);
define _no_documento		char(20);
define _no_poliza			char(10);
define _cod_cliente			char(10);
define _no_remesa			char(10);
define _cod_agente			char(5);
define _cod_tipo			char(5);
define _cod_no_renov		char(3);
define _prima_devengada		dec(16,2);
define _monto_recibido		dec(16,2);
define _credito_favor		dec(16,2);
define _error				integer;
define _error_isam			integer;
define _secuencia 			integer;
define _secuencia_comp		integer;
define _renglon				smallint;
define _fecha_susp			date;


--set debug file to "sp_cob299.trc";
--trace on;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception
end

let _fecha_susp = today - 1 units day;
let _cod_tipo  = "00033";

foreach
	select doc_suspenso,
		   poliza,
		   ramo,
		   asegurado,
		   cedula,
		   monto,
	  into _doc_suspenso
		   _poliza,
		   _ramo,
		   _asegurado,
		   _cedula,
		   _monto_recibido
	  from cobsuspe
	 where fecha = _fecha_susp

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza

		select email_cobros
		  into _email_cobros
		  from agtagent
		 where cod_agente = _cod_agente;

		if _email_cobros is null then
			let _email_cobros = '';
		end if

		foreach
			select email
			  into _email_agtmail
			  from agtmail
			 where cod_agente = _cod_agente
			   and tipo_correo = 'COB'
			
			if trim(_email_agtmail) = '' or _email_agtmail is null then
				continue foreach;
			end if
			if _email_agtmail = _email_cobros then
				continue foreach;
			else
				let _email_send = trim(_email_send) || trim(_email_agtmail) || ';';
			end if
		end foreach

		let _secuencia = sp_par336(_cod_tipo, _email_send, 1);-- amado - se cambia para que solo envie la primera imagen - 18/06/2013
			{let _secuencia = sp_sis148();
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
			);}			
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