-- Procedimiento que genera el código html del proceso de correos masivo
-- Creado    :20/01/2017 - Autor: Román Gordón 
drop procedure sp_sis448;
create procedure "informix".sp_sis448(a_secuencia integer)
returning char(3000);

define _html			    char(3000);
define _fecha_completa	    varchar(60);
define _doc_electronico	    varchar(30);
define _nom_cliente		    varchar(100);
define _cod_pagador		    varchar(30);
define _no_documento	    varchar(20);
define _evento			    varchar(20);
define _no_poliza		    char(10);
define _cod_tipo		    char(5);
define _fecha        		date;
define _fecha_rechazo		date;
define _fecha_suspension    date;
define _fecha_cancelacion   date;  
define _exigible	        dec(10,2);
define _exigible2           varchar(10);
define _fecha_suspension2   varchar(10);
define _fecha_cancelacion2  varchar(10);
define _monto               dec(16,2);
define _monto2              varchar(10);
define _fecha2              varchar(10);
define _fecha_letra         varchar(50);
define _no_remesa           char(10);
define _renglon             smallint;
define _usuario_eval        char(8);
define _evaluadora          char(50);
define _vigencia_inic       date;
define _vigencia_final      date;
define _cod_formapag        char(3);
define _forma_pago          varchar(50);
define _no_pagos            smallint;
define _vigencia_inic2     	varchar(10);
define _vigencia_final2     varchar(10);
define _no_pagos2           varchar(2);
define _telefono1           varchar(10);
define _e_mail              varchar(50);
define _celular				varchar(10);
define _direccion_1			varchar(50);
define _cod_agente          char(5);
define _ano                 char(4);
define _mes                 char(2);
define _dia                 varchar(2);
define _fecha_char		    char(30);
define _periodo             date;
define v_monto          varchar(25);
set isolation to dirty read;

begin


--set debug file to "sp_sis448.trc";      
--trace on;

select cod_tipo
  into _cod_tipo
  from parmailsend
 where secuencia = a_secuencia;

select trim(html)
  into _html
  from parmailtipo
 where cod_tipo = _cod_tipo;

let _exigible = 0;

foreach
	select trim(no_documento),
		   asegurado,
		   fecha,
		   saldo,
		   no_remesa,
		   renglon
	  into _no_documento,
		   _cod_pagador,
		   _fecha_suspension,
		   _exigible,
		   _no_remesa,
		   _renglon
	  from parmailcomp
	 where mail_secuencia = a_secuencia
	exit foreach;
end foreach  

if _exigible is null then
	let _exigible = 0;
end if

let _exigible2 = _exigible;

select trim(nombre)
  into _nom_cliente
  from cliclien
 where cod_cliente = _cod_pagador;

if _cod_tipo in ('00021','00023') then --Notificaciones de Rechazos TCR/ACH
	let _fecha_rechazo = _fecha_suspension;
	let _doc_electronico = _cod_pagador;
	let _cod_pagador = '';

	if _cod_tipo = '00021' then
		let _no_poliza = sp_sis21(_no_documento);

		select cod_pagador
		  into _cod_pagador
		  from emipomae
		 where no_poliza = _no_poliza;

		select nombre
		  into _nom_cliente
		  from cliclien
		 where cod_cliente = _cod_pagador;
	else
		foreach
			select nombre_pagador
			  into _nom_cliente
			  from cobcutmpre
			 where no_cuenta = _doc_electronico
			   and no_documento = _no_documento
			   and date(date_added) = _fecha_rechazo
			exit foreach;
		end foreach			   
	end if
	
	let _html = replace(trim(_html),'%_pagador%',_nom_cliente);

elif _cod_tipo in ('00040') then
	if _no_remesa = 'T' then
		let _evento = 'TASA DE IMPUESTO';
	else
		let _evento = 'FIANZA';
	end if
	let _html = replace(trim(_html),'%_evento%',_evento);
elif _cod_tipo in ('00039') then
	let _fecha_completa = sp_sis20(_fecha_suspension);
	let _html = replace(trim(_html),'%_fecha_completa%',_fecha_completa);
	let _html = replace(trim(_html),'%_pagador%',_nom_cliente);
	let _html = replace(trim(_html),'%_no_documento%',trim(_no_documento));
	let _html = replace(trim(_html),'%_exigible%',trim(_exigible2));
	
	
elif _cod_tipo in ('00037','00038') then --Notificaciones de Suspensión de Cobertura
 
	if _fecha_suspension is null then
		return '';
	end if

	let _fecha_cancelacion = _fecha_suspension + 60 units day;
	let _fecha_suspension2 = _fecha_suspension;
	let _fecha_cancelacion2 = _fecha_cancelacion;

	let _html = replace(trim(_html),'%_pagador%',_nom_cliente);
	let _html = replace(trim(_html),'%_no_documento%',trim(_no_documento));
	let _html = replace(trim(_html),'%_exigible%',trim(_exigible2));
	let _html = replace(trim(_html),'%_fecha_suspension%',trim(_fecha_suspension2));
	let _html = replace(trim(_html),'%_fecha_cancelacion%',trim(_fecha_cancelacion2));
elif _cod_tipo = '00016' then
	call sp_che126(a_secuencia) returning _nom_cliente, _monto, _fecha;
	
	let _html = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /></head><body style="font-family:Arial; font-size:13.5px; text-align:justify;"><table width="275%"><tr><td><p style="margin:1px; padding:1px;">Panam&aacute;, %_fecha%</p><p></p><p></p></td></tr><tr><td><p style="margin:1px; padding:1px;">Se&ntilde;or(a) (es)</p><p></p></td></tr><tr><td><p style="margin:1px; padding:1px;">%_nombre%</p><p></p></td></tr><tr><td><p style="margin:1px; padding:1px;">Un cordial saludo de parte de Aseguradora Anc&oacute;n, S. A., este correo es para informarle(s) que se le ha acreditado a su cuenta en concepto de pago de reclamo el monto de B/.%_monto% seg&uacute;n el detalle adjunto.</p><p></p></td></tr><tr><td><p style="margin:1px; padding:1px;">Gracias por preferirnos.</p><p></p><tr><td><p>Para cualquier duda o consulta escribirnos a atencionalcliente@asegurancon.com</p></td></tr></td></tr></table>';
	
    let _monto2 = _monto;
	
	let v_monto = sp_html02(_monto);
	
    let _fecha_letra = sp_fecha_letra(_fecha);
	
    --let _html = replace(trim(_html),'%_fecha%',trim(upper(_fecha_letra)));	
    let _html = replace(trim(_html),'%_fecha%',trim(lower(_fecha_letra)));		
    let _html = replace(trim(_html),'%_nombre%',trim(_nom_cliente));	
    let _html = replace(trim(_html),'%_monto%',trim(v_monto));	
	
elif _cod_tipo = '00010' then
 SELECT nombre_cliente	
   INTO _nom_cliente	
   FROM avisocanc
  WHERE no_aviso  = _no_remesa
    AND renglon = _renglon	;
	
   let _fecha_letra = sp_fecha_letra(today);
	
   let _html = replace(trim(_html),'%_fecha%',trim(upper(_fecha_letra)));	
   let _html = replace(trim(_html),'%_nombre%',trim(_nom_cliente));	
elif _cod_tipo = '00041' then --Notificación Eliminación de Coberturas - Sobat    	
	select cod_pagador
	  into _cod_pagador
	  from emipomae
	 where no_poliza = _no_remesa;

	select nombre
	  into _nom_cliente
	  from cliclien
	 where cod_cliente = _cod_pagador;
	
	let _html = replace(trim(_html),'%_nombre%',_nom_cliente);
elif _cod_tipo = '00007' then 
    call sp_pro202c(_no_remesa) returning _nom_cliente,_no_remesa,_usuario_eval,_evaluadora;
	let _fecha2 = today;
    let _html = replace(trim(_html),'%_fecha%',trim(_fecha2));	
	let _html = replace(trim(_html),'%_solicitud%',trim(_no_remesa));
    let _html = replace(trim(_html),'%_nombre%',trim(_nom_cliente));	
	let _html = replace(trim(_html),'%_evaluadora%',trim(_evaluadora));
elif _cod_tipo = '00042' then --Aviso de Vencimiento de las Pólizas de Fianza
	select cod_pagador,
	       prima_bruta,
		   vigencia_inic,
		   vigencia_final,
		   cod_formapag,
		   no_pagos
	  into _cod_pagador,
	       _monto,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_formapag,
		   _no_pagos
	  from emipomae
	 where no_poliza = _no_remesa;
	 
	let _monto2 = _monto;
	let _vigencia_inic2 = _vigencia_inic;
	let _vigencia_final2 = _vigencia_final;
	let _no_pagos2 = _no_pagos;

	select nombre,
		   telefono1,
		   e_mail,
		   celular,
	       direccion_1
	  into _nom_cliente,
	       _telefono1,
		   _e_mail,
		   _celular,
		   _direccion_1
	  from cliclien
	 where cod_cliente = _cod_pagador;
	 	 
	select nombre
	  into _forma_pago
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	 if _telefono1 is null then
		let _telefono1 = "";
	 end if
	 
	 if _e_mail is null then
		let _e_mail = "";
	 end if
	 
	 if _celular is null then
		let _celular = "";
	 end if
	 
	 if _direccion_1 is null then
		let _direccion_1 = "";
	 end if
	 
	let _html = replace(trim(_html),'%_nombre%',trim(_nom_cliente));
    let _html = replace(trim(_html),'%_fianza%',trim(_no_documento));	
    let _html = replace(trim(_html),'%_prima%',trim(_monto2));	
    let _html = replace(trim(_html),'%_vigencia_inic%',trim(_vigencia_inic2));	
    let _html = replace(trim(_html),'%_vigencia_final%',trim(_vigencia_final2));	
    let _html = replace(trim(_html),'%_forma_pago%',trim(_forma_pago));	
    let _html = replace(trim(_html),'%_no_pagos%',_no_pagos2);	
    let _html = replace(trim(_html),'%_nombre%',trim(_nom_cliente));	
    let _html = replace(trim(_html),'%_telefono%',trim(_telefono1));	
    let _html = replace(trim(_html),'%_email%',trim(_e_mail));	
    let _html = replace(trim(_html),'%_celular%',trim(_celular));	
    let _html = replace(trim(_html),'%_direccion%',trim(_direccion_1));	
elif _cod_tipo = '00011' then --Aviso de cancelación – Corredor
	SELECT nombre_agente,
		   cod_agente	
	  INTO _nom_cliente,
		   _cod_agente	
      FROM avisocanc
     WHERE no_aviso  = _no_remesa
       AND renglon = _renglon	;
	
	let _html = replace(trim(_html),'%_nombre%',trim(_nom_cliente));
	let _html = replace(trim(_html),'%cod_corredor%',trim(_cod_agente));

elif _cod_tipo = '00015' then --Estados de Cuentas
	Select nombre
	  into _nom_cliente
	  from cliclien
	 where cod_cliente = _cod_pagador; 

	let _ano			= _no_remesa[1,4];
	let _mes			= _no_remesa[6,7];

	if _mes = '01' then
		let _fecha_char = 'Enero de ' || _ano;
	elif _mes = '02' then
		let _fecha_char = 'Febrero de ' || _ano;
	elif _mes = '03' then
		let _fecha_char = 'Marzo de ' || _ano;
	elif _mes = '04' then
		let _fecha_char = 'Abril de ' || _ano;
	elif _mes = '05' then
		let _fecha_char = 'Mayo de ' || _ano;
	elif _mes = '06' then
		let _fecha_char = 'Junio de ' || _ano;
	elif _mes = '07' then
		let _fecha_char = 'Julio de ' || _ano;
	elif _mes = '08' then
		let _fecha_char = 'Agosto de ' || _ano;
	elif _mes = '09' then
		let _fecha_char = 'Septiembre de ' || _ano;
	elif _mes = '10' then
		let _fecha_char = 'Octubre de ' || _ano;
	elif _mes = '11' then
		let _fecha_char = 'Noviembre de ' || _ano;
	elif _mes = '12' then
		let _fecha_char = 'Diciembre de ' || _ano;
	end if    

	let _html = replace(trim(_html),'%_nombre%',trim(_nom_cliente));
	let _html = replace(trim(_html),'%cod_pagador%',trim(_cod_pagador));
	let _html = replace(trim(_html),'%fecha_char%',trim(_fecha_char));
	
elif _cod_tipo in ('00004','00047') then -- Comprobantes de pagos
		
	select nombre
	  into _nom_cliente
	  from cliclien
	 where cod_cliente = _cod_pagador;

	Select fecha
	  into _periodo 
	  from cobredet  
	 where no_remesa = _no_remesa 
		and renglon	  = _renglon; 

	let _dia            =  day(_periodo);
    let _mes			=  month(_periodo);
	
    if month(_periodo) < 10 then
		let _mes			= '0' || trim(_mes);
	end if
	
	let _ano			= year(_periodo);
	
	if _mes = '01' then
		let _fecha_char = 'enero de ' || _ano;
	elif _mes = '02' then
		let _fecha_char = 'febrero de ' || _ano;
	elif _mes = '03' then
		let _fecha_char = 'marzo de ' || _ano;
	elif _mes = '04' then
		let _fecha_char = 'abril de ' || _ano;
	elif _mes = '05' then
		let _fecha_char = 'mayo de ' || _ano;
	elif _mes = '06' then
		let _fecha_char = 'junio de ' || _ano;
	elif _mes = '07' then
		let _fecha_char = 'julio de ' || _ano;
	elif _mes = '08' then
		let _fecha_char = 'agosto de ' || _ano;
	elif _mes = '09' then
		let _fecha_char = 'septiembre de ' || _ano;
	elif _mes = '10' then
		let _fecha_char = 'octubre de ' || _ano;
	elif _mes = '11' then
		let _fecha_char = 'noviembre de ' || _ano;
	elif _mes = '12' then
		let _fecha_char = 'diciembre de ' || _ano;
	end if  

    let _fecha_char = trim(_dia) || ' de ' || _fecha_char;	
	
	let _html = replace(trim(_html),'%_pagador%',_nom_cliente);
	let _html = replace(trim(_html),'%_fecha_remesa%',_fecha_char);
elif _cod_tipo = '00036' then
    let _html = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /></head><body style="font-family:Arial; font-size:13.5px; text-align:justify;"><table width="275%"><tr><td><p style="margin:1px; padding:1px;">Panam&aacute;, %_fecha%</p><p></p></td></tr><tr><td><p style="margin:1px; padding:1px;">Se&ntilde;or(a) (es)</p></td></tr><tr><td><p style="margin:1px; padding:1px;">%_nombre%</p><p></p></td></tr><tr><td><p style="margin:1px; padding:1px;">Un cordial saludo de parte de Aseguradora Anc&oacute;n, S. A., este correo es para informarle(s) que su reclamo ha sido declinado seg&uacute;n detalle adjunto.</p><p></p></td></tr><tr><td><p style="margin:1px; padding:1px;">Gracias por preferirnos.</p><tr><td><p>Para cualquier duda o consulta escribirnos a atencionalcliente@asegurancon.com</p></td></tr></td></tr></table>';
	call sp_rec741(a_secuencia) returning _nom_cliente;
	
    let _fecha_letra = sp_fecha_letra(today);
	
--    let _html = replace(trim(_html),'%_fecha%',trim(upper(_fecha_letra)));	
	let _html = replace(trim(_html),'%_fecha%',trim(lower(_fecha_letra)));	
    let _html = replace(trim(_html),'%_nombre%',trim(_nom_cliente));	
	
end if

return _html;

end
end procedure;