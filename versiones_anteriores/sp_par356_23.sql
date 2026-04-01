-- Procedimiento que Genera el Html Body - Bienvenida
-- Creado : 14/09/2016 - Autor: Henry Giron 
Drop procedure sp_par356ee; 
CREATE PROCEDURE "informix".sp_par356ee(  
a_secuencia	INTEGER,
a_url CHAR(500)  
)returning	Lvarchar(3500), --max),
            Lvarchar(3500), --max),
            Lvarchar(3500); --max); 

Define _html_body1	 Lvarchar(3500); --max); -- char(512); 
Define _html_body2	 Lvarchar(3500); --max); -- char(512); 
Define _html_body3	 Lvarchar(3500); --max); -- char(512); 


define _error			integer; 
define _siguiente		integer; 
define _error_isam		integer; 
define _error_desc		char(100); 

define 	v_ramo		    CHAR(50); 
define 	v_poliza		CHAR(20); 
define 	v_prima_total	DEC(16,2); 
define 	v_codformapag	CHAR(50); 
define 	v_vigen_ini		DATE; 
define 	v_vigen_fin		DATE;
define 	v_asegurado		CHAR(100);
define 	v_contratante	CHAR(100);
define 	v_telefono1		CHAR(10);
define 	v_telefono2		CHAR(10);
define 	v_email		    CHAR(50);
define 	v_dir_cobro		CHAR(50);
define 	v_n_pagos		INTEGER;
define 	_no_solicitud	CHAR(50);
define  v_sender        CHAR(50);
define  v_url       CHAR(500);
--define  v_url = 'https://app.asegurancon.com/poliza_web/print_pol.php?940160211511101411830840160301011501511790101801830840050840160111901790411590001111990830940840840840840160001790001501011711590111011830050350840750450350940160790221501801111211590111011';

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return 0,0,0;
end exception

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_par356.trc"; 
--trace on;
drop table if exists temp_carta;

Let  _html_body1 = '';
Let  _html_body2 = '';
Let  _html_body3 = '';
--let  v_url = '940160211511101411830840160301011501511790101801830840050840160111901790411590001111990830940840840840840160001790001501011711590111011830050350840750450350940160790221501801111211590111011';
let v_url = trim(a_url);
let _no_solicitud = 0;
let _siguiente = 0;

     create temp table temp_carta(
			ramo		    CHAR(50),
			poliza		    CHAR(20),
			prima_total		DEC(16,2),
			codformapag		CHAR(50),
			vigen_ini		DATE,
			vigen_fin		DATE,
			asegurado		CHAR(100),
			contratante		CHAR(100),
			telefono1		CHAR(10),
			telefono2		CHAR(10),
			email		    CHAR(50),
			dir_cobro		CHAR(50),
			n_pagos		    INTEGER
			) with no log;															 
	create index idx1_temp_carta on temp_carta(poliza);
    create index idx2_temp_carta on temp_carta(ramo);		

	Select no_remesa
	  into _no_solicitud
	  from parmailcomp
	 where mail_secuencia = a_secuencia; 
 
 FOREACH EXECUTE PROCEDURE sp_pro402(_no_solicitud,'00000') 
           INTO v_ramo,
				v_poliza,
				v_prima_total,
				v_codformapag,
				v_vigen_ini,
				v_vigen_fin,
				v_asegurado,
				v_contratante,
				v_telefono1,
				v_telefono2,
				v_email,
				v_dir_cobro,
				v_n_pagos	
		INSERT INTO temp_carta 
		VALUES (v_ramo,
		        v_poliza,
				v_prima_total,
				v_codformapag,
				v_vigen_ini,
				v_vigen_fin,
				v_asegurado,
				v_contratante,
				v_telefono1,
				v_telefono2,
				v_email,
				v_dir_cobro,
				v_n_pagos);
				
END FOREACH;

select nvl(sender,'') 
  into v_sender
  from parmailtipo 
 where cod_tipo = '00030';
 
 if v_sender is null then
    let v_sender = 'info@asegurancon.com';
 end if
			
FOREACH 
      select ramo,
			poliza,
			NVL(prima_total,0),
			NVL(codformapag,''),
			vigen_ini, --NVL(vigen_ini, to_date('19000101','YYYYMMDD')),  --vigen_ini,
			vigen_fin, --NVL(vigen_fin, to_date('19000101','YYYYMMDD')),  --vigen_fin,
			NVL(asegurado,''),
			NVL(contratante,''),
			NVL(telefono1,''),
			NVL(telefono2,''),
			NVL(email,''),
			NVL(dir_cobro,''),
			NVL(n_pagos,0)	
	   into v_ramo,
			v_poliza,
			v_prima_total,
			v_codformapag,
			v_vigen_ini,
			v_vigen_fin,
			v_asegurado,
			v_contratante,
			v_telefono1,
			v_telefono2,
			v_email,
			v_dir_cobro,
			v_n_pagos	
       from temp_carta
	  --order by poliza
	  
Let _html_body1 = trim(_html_body1) ||'<!doctype html>';
Let _html_body1 = trim(_html_body1) ||'<html>';
Let _html_body1 = trim(_html_body1) ||'<head>';
Let _html_body1 = trim(_html_body1) ||'<meta charset="utf-8">';
Let _html_body1 = trim(_html_body1) ||'<title></title>';
Let _html_body1 = trim(_html_body1) ||'</head>';
Let _html_body1 = trim(_html_body1) ||'<body style="font-family:Arial; font-size:14px; text-align:justify;">';
Let _html_body1 = trim(_html_body1) ||'<table width="800">';
Let _html_body1 = trim(_html_body1) ||'<tr>';
Let _html_body1 = trim(_html_body1) ||'<td colspan="2">';
Let _html_body1 = trim(_html_body1) ||'<p><strong>Estimado Asegurado:</strong><br>';
Let _html_body1 = trim(_html_body1) ||'Aseguradora Anc&oacute;n S.A., le da la m&aacute;s cordial bienvenida y agradecemos la confianza que ha depositado en<br>'; 
Let _html_body1 = trim(_html_body1) ||'nosotros para ofrecerles el mejor servicio y reiteramos nuestro compromiso de satisfacer sus necesidades<br>'; 
Let _html_body1 = trim(_html_body1) ||'de forma eficiente y oportuna en base a la p&oacute;liza adquirida.';
Let _html_body1 = trim(_html_body1) ||'</p>';
Let _html_body1 = trim(_html_body1) ||'</td>';
Let _html_body1 = trim(_html_body1) ||'</tr>';
Let _html_body1 = trim(_html_body1) ||'<tr>';
Let _html_body1 = trim(_html_body1) ||'<td colspan="2">';
Let _html_body1 = trim(_html_body1) ||'<p>';
Let _html_body1 = trim(_html_body1) ||'1. Nuestra L&iacute;nea de Atenci&oacute;n al Cliente es <strong>(+507)210-8700, 210-8787, 305-7500</strong> para cualquier duda o<br>';  
Let _html_body1 = trim(_html_body1) ||'consulta, o puede enviar un e-mail a: atencionalcliente@asegurancon.com.';     
Let _html_body1 = trim(_html_body1) ||'</p>';
Let _html_body1 = trim(_html_body1) ||'</td>';
Let _html_body1 = trim(_html_body1) ||'</tr>';
Let _html_body1 = trim(_html_body1) ||'<tr>';
Let _html_body1 = trim(_html_body1) ||'<td colspan="2">';
Let _html_body1 = trim(_html_body1) ||'<p>';
Let _html_body1 = trim(_html_body1) ||'<br>2. Horario de atenci&oacute;n: lunes a viernes de 8:00 a.m. a 5: 00 p.m. y s&aacute;bados de 9:00 a.m. a 12:00 p.m.<br>'; 
Let _html_body1 = trim(_html_body1) ||'Sucursales: Casa Matriz - Costa del Este, Trans&iacute;stmica, Col&oacute;n, La Chorrera, Chitr&eacute;, Santiago y David.';
Let _html_body1 = trim(_html_body1) ||'</p>';
Let _html_body1 = trim(_html_body1) ||'</td>';
Let _html_body1 = trim(_html_body1) ||'</tr>';
Let _html_body1 = trim(_html_body1) ||'<tr>';
Let _html_body1 = trim(_html_body1) ||'<td colspan="2">';
Let _html_body1 = trim(_html_body1) ||'<p>';
Let _html_body1 = trim(_html_body1) ||'<br>3. Le invitamos acceder a nuestros canales de atenci&oacute;n:';
Let _html_body1 = trim(_html_body1) ||'<br>&nbsp;&nbsp;&nbsp;&nbsp;a.	<a target="_blank" href="https://app.asegurancon.com/">www.asegurancon.com</a> conozca nuestros productos, Valores Agregados, Talleres Autorizados, Red M&eacute;dica <br>y <a target="_blank" href="https://www.asegurancon.com/formularios-y-solicitudes/">formularios</a> de &nbsp;&nbsp;&nbsp;&nbsp;Afiliaci&oacute;n a Pago electr&oacute;nico por ACH o Tarjeta de Cr&eacute;dito.';
Let _html_body1 = trim(_html_body1) ||'<br>&nbsp;&nbsp;&nbsp;&nbsp;b.	S&iacute;ganos en nuestras redes sociales <a target="_blank" href="https://linktr.ee/asegurancon">@asegurancon</a>  y conozca nuestros productos, beneficios y promociones.';
Let _html_body1 = trim(_html_body1) ||'<br>&nbsp;&nbsp;&nbsp;&nbsp;c.	Af&iacute;liese al <a target="_blank" href="https://app.asegurancon.com/webasegurados/">portal de asegurados</a>, donde podr&aacute; realizar consultas sobre sus p&oacute;lizas.';
Let _html_body1 = trim(_html_body1) ||'<br>&nbsp;&nbsp;&nbsp;&nbsp;d.	Descargue nuestra aplicaci&oacute;n m&oacute;vil Anc&oacute;n Clientes disponible para <a target="_blank" href="https://apps.apple.com/us/app/ancon-clientes/id1363630649">iOS</a> y <a target="_blank" href="https://play.google.com/store/apps/details?id=com.smartreport.anconclientes">Android</a>.';
Let _html_body1 = trim(_html_body1) ||'</p>';
Let _html_body1 = trim(_html_body1) ||'</td>';
Let _html_body1 = trim(_html_body1) ||'</tr>';
Let _html_body1 = trim(_html_body1) ||'<tr>';
Let _html_body1 = trim(_html_body1) ||'<td colspan="2">';
Let _html_body1 = trim(_html_body1) ||'<p>';
Let _html_body1 = trim(_html_body1) ||'<br>4. Si los datos generales que brind&oacute; al momento de adquirir su p&oacute;liza var&iacute;an o no est&aacute;n correctos, podr&aacute;<br>';  
Let _html_body1 = trim(_html_body1) ||'actualizar sus datos en el APP Ancon Clientes o puede llamar a nuestras l&iacute;neas de Atenci&oacute;n al Cliente.';
Let _html_body1 = trim(_html_body1) ||'</p>';
Let _html_body1 = trim(_html_body1) ||'</td>';
Let _html_body1 = trim(_html_body1) ||'</tr>';
Let _html_body1 = trim(_html_body1) ||'<tr>';
Let _html_body1 = trim(_html_body1) ||'<td colspan="2">';
Let _html_body1 = trim(_html_body1) ||'<p>';
Let _html_body1 = trim(_html_body1) ||'<br>5. Contamos con un programa de Asistencia Vial 24 horas:<br>'; 
Let _html_body1 = trim(_html_body1) ||'<strong>(+507) 303-2444 / 302-2444 / WhatsApp (+507) 6233-3882</strong>';
Let _html_body1 = trim(_html_body1) ||'</p>';
Let _html_body1 = trim(_html_body1) ||'</td>';
Let _html_body1 = trim(_html_body1) ||'</tr>';
Let _html_body1 = trim(_html_body1) ||'<tr>';
Let _html_body1 = trim(_html_body1) ||'<td colspan="2">';
Let _html_body1 = trim(_html_body1) ||'<p>';
Let _html_body1 = trim(_html_body1) ||'<br>6. Brindamos atenci&oacute;n permanente, para orientar y dar respuesta a sus consultas de Salud y<br>';  
Let _html_body1 = trim(_html_body1) ||'Preautorizaciones las 24 horas. <strong>(+507)210-8777 / 305-7565</strong> preautorizaciones@asegurancon.com';
Let _html_body1 = trim(_html_body1) ||'</p>';
Let _html_body1 = trim(_html_body1) ||'</td>';
Let _html_body1 = trim(_html_body1) ||'</tr>';
Let _html_body1 = trim(_html_body1) ||'<tr>';
Let _html_body1 = trim(_html_body1) ||'<td colspan="2">';
Let _html_body1 = trim(_html_body1) ||'<p>';
Let _html_body1 = trim(_html_body1) ||'<br>7. Si al momento de su renovaci&oacute;n tiene alguna duda o consulta, puede escribir al correo<br> conservacioncliente@asegurancon.com';
Let _html_body1 = trim(_html_body1) ||'</p>';
Let _html_body1 = trim(_html_body1) ||'</td>';
Let _html_body1 = trim(_html_body1) ||'</tr>';
Let _html_body1 = trim(_html_body1) ||'<tr>';
Let _html_body1 = trim(_html_body1) ||'<td colspan="2">';
Let _html_body1 = trim(_html_body1) ||'<p>';


--Let _html_body2 = trim(_html_body2) ||'<br>8. Para descargar su p&oacute;liza presione aqu&iacute;.';
Let _html_body2 = trim(_html_body2) ||'<br>8. Para descargar su p&oacute;liza presione <a target="_blank" href="https://app.asegurancon.com/poliza_web/print_pol.php?'||v_url||'">aqu&iacute;.</a>';
Let _html_body2 = trim(_html_body2) ||'</p>';
Let _html_body2 = trim(_html_body2) ||'</td>';
Let _html_body2 = trim(_html_body2) ||'</tr>';
Let _html_body2 = trim(_html_body2) ||'<tr>';
Let _html_body2 = trim(_html_body2) ||'<td colspan="2">';
Let _html_body2 = trim(_html_body2) ||'<p>';
--Let _html_body2 = trim(_html_body2) ||'<br>Para nosotros su opini&oacute;n es importante, por lo que le invitamos a realizar la siguiente <a target="_blank" href="https://forms.office.com/Pages/DesignPage.aspx?fragment=FormId%3DiEoE-rfND0GbV6CST6EclUWEk2UOYpBPux2RK6IxZwJUMldSOVZKSlc1TU81Q1pCWEowVURRVUZPTS4u">encuesta</a> que nos<br>';  
Let _html_body2 = trim(_html_body2) ||'<br>Para nosotros su opini&oacute;n es importante, por lo que le invitamos a realizar la siguiente <a target="_blank" href="https://forms.office.com/Pages/ResponsePage.aspx?id=iEoE-rfND0GbV6CST6EclfF01golxm1JhPH2pT-E0AFUOEJLRjMxQktEUzhPNUJYUEI4RzNYVkRTRi4u">encuesta</a> que nos<br>';  
Let _html_body2 = trim(_html_body2) ||'permitir&aacute; mejorar nuestro servicio.';
Let _html_body2 = trim(_html_body2) ||'</p>';
Let _html_body2 = trim(_html_body2) ||'</td>';
Let _html_body2 = trim(_html_body2) ||'</tr>';
Let _html_body2 = trim(_html_body2) ||'<tr>';
Let _html_body2 = trim(_html_body2) ||'<td colspan="2">';
Let _html_body2 = trim(_html_body2) ||'<p>';
Let _html_body2 = trim(_html_body2) ||'<br><strong>NOTA:</strong> Es nuestro mayor deseo poder ofrecerles el servicio necesario para su protecci&oacute;n, y que su p&oacute;liza<br>'; 
Let _html_body2 = trim(_html_body2) ||'funcione adecuadamente por lo que gentilmente les recordamos el cumplimiento oportuno del pago total o<br>'; 
Let _html_body2 = trim(_html_body2) ||'primer pago fraccionado en la emisi&oacute;n de su p&oacute;liza, para garantizar el disfrute pleno de sus beneficios<br>'; 
Let _html_body2 = trim(_html_body2) ||'(Art&iacute;culo 154 y 156 Ley 12 de 03 de abril del 2012).'; 
Let _html_body2 = trim(_html_body2) ||'</p>';
Let _html_body2 = trim(_html_body2) ||'</td>';
Let _html_body2 = trim(_html_body2) ||'</tr>';
Let _html_body2 = trim(_html_body2) ||'<tr>';
Let _html_body2 = trim(_html_body2) ||'<td colspan="2">';
Let _html_body2 = trim(_html_body2) ||'<p>';
Let _html_body2 = trim(_html_body2) ||'<br>Para realizar su primer pago puede ingresar a nuestros <a target="_blank" href="https://app.asegurancon.com/pago_online/">pagos online</a>, con su tarjeta Visa, MasterCard y Clave.';
Let _html_body2 = trim(_html_body2) ||'</p>';
Let _html_body2 = trim(_html_body2) ||'</td>';
Let _html_body2 = trim(_html_body2) ||'</tr>';
Let _html_body2 = trim(_html_body2) ||'</table>';
Let _html_body2 = trim(_html_body2) ||'</body>';
Let _html_body2 = trim(_html_body2) ||'</html>';

return _html_body1,_html_body2,_html_body3  with resume;

END FOREACH;
--trace off;
END PROCEDURE

