-- Procedimiento para verificar las polizas de salud con morosidad a 60 dias
--
-- Creado    : 21/03/2011 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob271;
create procedure sp_cob271(
a_no_poliza	char(10),
a_usuario   char(8)
) returning integer,
            char(50);

define _desc_gestion		varchar(250);
define _html_body			char(512);
define _e_mail_send			char(384);
define _nombre_aseg			char(100);
define _email_cobros		char(50);
define _error_desc			char(50);
define _email_agt			char(50);
define _e_mail				char(50);
define _no_documento		char(20);
define _cod_asegurado		char(10);
define _cod_pagador			char(10);
define _usuario_supervisor	char(8);	
define _usuario_vende		char(8);
define _usuario_cob			char(8);
define _periodo				char(7);
define _cod_supervisor		char(5);
define _cod_cobrador		char(5);
define _cod_vendedor		char(3);
define _cod_agente			char(5);
define _cod_tipo			char(5);
define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _cod_formapag		char(3);
define _por_vencer			dec(16,2);
define _exigible			dec(16,2);      
define _corriente			dec(16,2);    
define _monto_30			dec(16,2);
define _monto_60			dec(16,2);      
define _monto_90			dec(16,2);
define _saldo				dec(16,2);   
define _monto_60_mas		dec(16,2);
define _prima_mensual		dec(16,2);
define _secuencia_comp		integer;
define _error_isam			integer;
define _secuencia			integer;
define _error				integer;
define _fecha				date;
define _fecha_gestion		datetime year to second;
define _mail_err            integer;
define _mail_err2           integer;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--SET DEBUG FILE TO "sp_cob271.trc";
--TRACE ON;


let _fecha         	= today;
let _fecha_gestion	= current;
let _periodo       	= sp_sis39(_fecha);
let _e_mail_send	= '';

let _saldo        	= 0;
let _monto_60 	  	= 0;
let _monto_90	  	= 0;
let _monto_60_mas 	= 0;
  
select no_documento,
       cod_compania,
	   cod_sucursal,
	   cod_pagador,
	   cod_contratante,
	   cod_formapag
  into _no_documento,
       _cod_compania,
	   _cod_sucursal,
	   _cod_pagador,
	   _cod_asegurado,
	   _cod_formapag
  from emipomae
 where no_poliza = a_no_poliza;

call sp_cob33(_cod_compania, _cod_sucursal, _no_documento, _periodo, _fecha) 
returning _por_vencer,
 		  _exigible,
		  _corriente,
		  _monto_30,
		  _monto_60,
		  _monto_90,
		  _saldo;

let _monto_60_mas = _monto_60 + _monto_90;

if _monto_60_mas >= 5.00 then

--	select sum(prima_asegurado)
	select sum(prima_bruta)
	  into _prima_mensual
	  from emipouni
	 where no_poliza = a_no_poliza; 

	-- email para el Cliente	
	select e_mail
	  into _e_mail
	  from cliclien
	 where cod_cliente = _cod_pagador;

	select count(*)
	  into _mail_err
	  from parmailerr
	 where email = _e_mail;
	 	 
	select nombre
	  into _nombre_aseg
	  from cliclien
	 where cod_cliente = _cod_asegurado;
	-- email para el Corredor
	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = a_no_poliza
		 order by porc_partic_agt desc

			select email_cobros
			  into _email_agt
			  from agtagent
			 where cod_agente = _cod_agente;

			select count(*)
			  into _mail_err2
			  from parmailerr
			 where email = _email_agt;
			 
			if _email_agt is null or _email_agt = '' or _mail_err2 > 0 then
				continue foreach;
			end if	 
			exit foreach;
	end foreach		
    --let _email_agt = 'cobros@asegurancon.com;' || trim(_email_agt);

	--let _e_mail = "demetrio@asegurancon.com";
	--{
	if _e_mail is not null and _mail_err = 0 then

		let _cod_tipo  = "00017";
		let _secuencia = sp_sis148();
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
		_e_mail,
		0,
		0,
		_secuencia,
		_html_body,
		_email_agt
		);
	
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
		a_no_poliza,
		0,
		_secuencia,
		_no_documento,
		_nombre_aseg,
		_saldo,
		_monto_60_mas,
		_prima_mensual
		);
		--return _secuencia, "Secuencia de Mail";
	end if
	-- email para Comercializacion
    --TRACE ON;
	let _cod_tipo  = "00018";
	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = a_no_poliza
	  order by no_poliza,porc_partic_agt desc
	  	exit foreach;
	end foreach
	
	select cod_cobrador
	  into _cod_cobrador
	  from cobforpa
	 where cod_formapag = _cod_formapag;
	 
	if _cod_cobrador is null or _cod_cobrador = '' then
		select cod_cobrador
		  into _cod_cobrador
		  from agtagent
		 where cod_agente = _cod_agente;
	end if
	select cod_vendedor,
		   email_cobros
	  into _cod_vendedor,
		   _email_cobros
	  from agtagent
	 where cod_agente = _cod_agente;

	if _email_cobros is null then
		let _email_cobros = '';
	end if
	
	if _email_cobros <> '' then
		let _e_mail_send = trim(_e_mail_send) || trim(_email_cobros) || ';';
	end if
	
	foreach
		Select email
		  into _email_agt
		  from agtmail
		 where cod_agente = _cod_agente
		   and tipo_correo = 'COB'
		
		if trim(_email_agt) = '' or _email_agt is null then
			continue foreach;
		end if
		if _email_agt = _email_cobros then
			continue foreach;
		else
			let _e_mail_send = trim(_e_mail_send) || trim(_email_agt) || ';';
		end if
	end foreach
   --	if _email_agt is not null or _email_agt <> '' then
   --		let _e_mail_send = trim(_email_agt) || ';';
   --	end if  	
	select usuario
	  into _usuario_vende
	  from agtvende
	 where cod_vendedor = _cod_vendedor
	   and activo = 1;

	select usuario,
		   cod_supervisor
	  into _usuario_cob,
		   _cod_supervisor
	  from cobcobra
	 where cod_cobrador = _cod_cobrador
	   and activo = 1;

	select usuario
	  into _usuario_supervisor
	  from cobcobra
	 where cod_cobrador = _cod_supervisor
	   and activo = 1;

	foreach  
		select e_mail
		  into _e_mail
		  from insuser
		 where usuario in(_usuario_vende,_usuario_cob,_usuario_supervisor)
		   and usuario not in('ENILDA')									--Caso 1654 puesto en fecha 05/10/2021
		 
		let _e_mail_send = trim(_e_mail_send) || trim(_e_mail) || ";";

	end foreach 	

	foreach
		select email
		  into _e_mail
		  from parcocue
		 where cod_correo = "058"
		   and activo = 1

		let _e_mail_send = trim(_e_mail_send) || trim(_e_mail) || ";";

	end foreach

	if _e_mail_send is not null then

		let _secuencia = sp_sis148();
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
		_e_mail_send,
		0,
		0,
		_secuencia,
		_html_body,
		null
		);
	
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
		a_no_poliza,
		0,
		_secuencia,
		_no_documento,
		_nombre_aseg,
		_saldo,
		_monto_60_mas,
		_prima_mensual
		);	 
	end if
   
	-- Gestion en la Bitacora

	
	let _desc_gestion ="SE HA DEJADO DE FACTURAR LA POLIZA DEBIDO A LA MOROSIDAD EXISTENTE A MAS DE 61 DIAS.  SALDO: " || _saldo || " A +61 DIAS: " || _monto_60_mas;
	 
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
	a_no_poliza,
	_fecha_gestion,
	_desc_gestion,
	a_usuario,
	_no_documento,
	null,
	0,
	null,
	_cod_pagador);

	update emipomae
	   set cod_no_renov   = '027',
	       fecha_no_renov = today,
	       user_no_renov  = a_usuario  		 --Saldo Pendiente y Facturacion atrasada
	 where no_poliza      = a_no_poliza;

	return 1, "No Realizar Facturacion";

else

	return 0, "Actualizacion Exitosa";

end if

end

end procedure
