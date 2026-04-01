-- Procedimiento que Genera el Html Body - Renovacion
-- Creado : 14/09/2016 - Autor: Henry Giron 
-- Creado : 22/02/21- Autor: Henry Giron Lo conversado solo para Cartas de renovaciones, solo cambios menores AUTOMOVIL.
-- Modificado : 24/02/2022

Drop procedure sp_par357; 
CREATE PROCEDURE "informix".sp_par357(  
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
define  v_url           CHAR(500);
define 	v_prima_mes	    DEC(16,2); 
define v_cod_perpago    char(3);
define v_periodo_pago   char(20);
--define  v_url = 'https://app.asegurancon.com/poliza_web/print_pol.php?940160211511101411830840160301011501511790101801830840050840160111901790411590001111990830940840840840840160001790001501011711590111011830050350840750450350940160790221501801111211590111011';

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return 0,0,0;
end exception

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_par357.trc"; 
--trace on;
drop table if exists temp_carta;

Let  _html_body1 = '';
Let  _html_body2 = '';
Let  _html_body3 = '';
let v_cod_perpago = '';
let v_periodo_pago = '';
let v_prima_mes = 0;
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
 where cod_tipo = '00031';
 
 if v_sender is null then
    let v_sender = 'atencionalcliente@asegurancon.com';
 end if

FOREACH 
      select ramo,
			poliza,
			NVL(prima_total,0),
			NVL(codformapag,''),
			vigen_ini, -- NVL(vigen_ini, to_date('19000101','YYYYMMDD')),  -- vigen_ini,
			vigen_fin, -- NVL(vigen_fin, to_date('19000101','YYYYMMDD')),  -- vigen_fin,
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

foreach
select cod_perpago
  into v_cod_perpago
  from emipomae
 where no_documento = v_poliza
 order by serie desc
  exit foreach;
   end foreach

 
select upper(nombre)
  into v_periodo_pago
  from cobperpa
 where cod_perpago = v_cod_perpago;	  
 
 let v_prima_mes = round((v_prima_total / v_n_pagos),4);

 
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
--Let _html_body1 = trim(_html_body1) ||'<p><strong>Estimado Asegurado:</strong><br>';
Let _html_body1 = trim(_html_body1) ||'<p><strong>Estimado(a) '||v_asegurado||'</strong><br>';
Let _html_body1 = trim(_html_body1) ||'Hemos renovado su p&oacute;liza de '||v_ramo||' No. '||v_poliza||' con vigencia desde '||cast(v_vigen_ini as varchar(10))||' hasta '||cast(v_vigen_fin as varchar(10))||'.<br>'; 
Let _html_body1 = trim(_html_body1) ||'Su prima Total a pagar es B/.'||cast(v_prima_total as varchar(10))||', en '||cast(v_n_pagos as varchar(3))||' pagos de B/. '||cast(v_prima_mes as varchar(8))||' '||v_periodo_pago||'.<br>'; 
Let _html_body1 = trim(_html_body1) ||'<br>Descargue su p&oacute;liza <a target="_blank" href="https://app.asegurancon.com/poliza_web/print_pol.php?'||v_url||'">aqu&iacute;.</a><br>';

{
Let _html_body1 = trim(_html_body1) ||'Aseguradora Anc&oacute;n S.A., le da la m&aacute;s cordial bienvenida, le agradecemos la confianza que ha depositado en<br>'; 
Let _html_body1 = trim(_html_body1) ||'nosotros para ofrecerles el mejor servicio y reiteramos nuestro compromiso de atender sus necesidades de<br>'; 
Let _html_body1 = trim(_html_body1) ||'forma eficiente y oportuna en base a la p&oacute;liza contratada.';
}
--Let _html_body1 = trim(_html_body1) ||'Aseguradora Anc&oacute;n S.A., le da la m&aacute;s cordial bienvenida, le agradecemos la confianza que ha depositado en<br>'; 
--Let _html_body1 = trim(_html_body1) ||'nosotros para ofrecerles el mejor servicio y reiteramos nuestro compromiso de servirle y atenderle sus necesidades de<br>'; 
--Let _html_body1 = trim(_html_body1) ||'forma eficiente y oportuna en base a la p&oacute;liza contratada.';

{
Let _html_body1 = trim(_html_body1) ||'</p>';
Let _html_body1 = trim(_html_body1) ||'</td>';
Let _html_body1 = trim(_html_body1) ||'</tr>';
Let _html_body1 = trim(_html_body1) ||'<tr>';
Let _html_body1 = trim(_html_body1) ||'<td colspan="2">';
Let _html_body1 = trim(_html_body1) ||'<p>';
Let _html_body1 = trim(_html_body1) ||'<strong>Hemos renovado la(s) siguiente(s) p&oacute;liza(s):</strong>';
Let _html_body1 = trim(_html_body1) ||'</p>';
Let _html_body1 = trim(_html_body1) ||'</td>';
Let _html_body1 = trim(_html_body1) ||'</tr>';
Let _html_body1 = trim(_html_body1) ||'<tr>';
Let _html_body1 = trim(_html_body1) ||'<td>';
Let _html_body1 = trim(_html_body1) ||'<p>';
Let _html_body1 = trim(_html_body1) ||'Ramo: '||v_ramo||' <br>';
Let _html_body1 = trim(_html_body1) ||'Prima Total: B/. '||cast(v_prima_total as varchar(10))||'<br>';
Let _html_body1 = trim(_html_body1) ||'Vigencia inicial: '||cast(v_vigen_ini as varchar(10))||'';
Let _html_body1 = trim(_html_body1) ||'</p>';
Let _html_body1 = trim(_html_body1) ||'</td>';
Let _html_body1 = trim(_html_body1) ||'<td>';
Let _html_body1 = trim(_html_body1) ||'<p>';
Let _html_body1 = trim(_html_body1) ||'No. De P&oacute;liza:'||v_poliza||' <br>';
Let _html_body1 = trim(_html_body1) ||'Forma de Pago: '||cast(v_n_pagos as varchar(3))||',pagos '||v_codformapag||' <br>';
Let _html_body1 = trim(_html_body1) ||'Vigencia Final: '||cast(v_vigen_fin as varchar(10))||'';                    
Let _html_body1 = trim(_html_body1) ||'</p>';
Let _html_body1 = trim(_html_body1) ||'</td>';
Let _html_body1 = trim(_html_body1) ||'</tr>';
Let _html_body1 = trim(_html_body1) ||'<tr>';
Let _html_body1 = trim(_html_body1) ||'<td colspan="2">';
}
Let _html_body1 = trim(_html_body1) ||'<p>';
--Let _html_body1 = trim(_html_body1) ||'<strong>Datos Generales:</strong>';
Let _html_body1 = trim(_html_body1) ||'<strong>Datos de Contacto:</strong>';
Let _html_body1 = trim(_html_body1) ||'</p>';
Let _html_body1 = trim(_html_body1) ||'</td>';
Let _html_body1 = trim(_html_body1) ||'</tr>';
Let _html_body1 = trim(_html_body1) ||'<tr>';
Let _html_body1 = trim(_html_body1) ||'<td>';
Let _html_body1 = trim(_html_body1) ||'<p>';
--Let _html_body1 = trim(_html_body1) ||'Asegurado: '||v_asegurado||' <br>';
Let _html_body1 = trim(_html_body1) ||'Tel&eacute;fono: '||v_telefono1||' <br>';
--Let _html_body1 = trim(_html_body1) ||'Tel&aacute;fono: '||v_telefono1||' <br>';
Let _html_body1 = trim(_html_body1) ||'Correo electr&oacute;nico: '||v_email||' '; 
Let _html_body1 = trim(_html_body1) ||'</p>';
Let _html_body1 = trim(_html_body1) ||'</td>';
Let _html_body1 = trim(_html_body1) ||'<td>';
Let _html_body1 = trim(_html_body1) ||'<p>';
--Let _html_body1 = trim(_html_body1) ||'Contratante: '||v_contratante||' <br>';
Let _html_body1 = trim(_html_body1) ||'Celular: '||v_telefono2||' <br>';
Let _html_body1 = trim(_html_body1) ||'Direcci&oacute;n: '||v_dir_cobro||'';                   
Let _html_body1 = trim(_html_body1) ||'</p>';
Let _html_body1 = trim(_html_body1) ||'</td>';
Let _html_body1 = trim(_html_body1) ||'</tr>';
Let _html_body1 = trim(_html_body1) ||'<tr>';
Let _html_body1 = trim(_html_body1) ||'<td colspan="2">';
Let _html_body1 = trim(_html_body1) ||'<p>';

Let _html_body2 = trim(_html_body2) ||'<br>Favor verifique que sus datos est&eacute;n correctos, de lo contrario puede actualizarlos <a href="https://app.asegurancon.com/webasegurados/">aqu&iacute;.</a><br>';
Let _html_body2 = trim(_html_body2) ||'<tr>';
Let _html_body2 = trim(_html_body2) ||'<td colspan="2">';
Let _html_body2 = trim(_html_body2) ||'<p>';
Let _html_body2 = trim(_html_body2) ||'<br>Su primer pago puede realizarlo accediendo a <a target="_blank" href="https://app.asegurancon.com/pago_online/">pagos online</a>.';
Let _html_body2 = trim(_html_body2) ||'</p>';
--Let _html_body2 = trim(_html_body2) ||'</td>';
--Let _html_body2 = trim(_html_body2) ||'</tr>';

Let _html_body2 = trim(_html_body2) ||'Si usted no est&aacute; de acuerdo con la p&oacute;liza renovada, o tiene alguna duda o consulta; puede escribirnos a<br>';
Let _html_body2 = trim(_html_body2) ||'conservacioncliente@asegurancon.com, o llamarnos al 210-8745, 210-8793, 210-8785. <br>';
Let _html_body2 = trim(_html_body2) ||'<br>Le invitamos a descargar nuestro App m&oacute;vil y disfrute de tener en las manos acceso 24/7 a sus p&oacute;lizas, reclamos, consulta de saldos,<br>'; 
Let _html_body2 = trim(_html_body2) ||'realizar sus pagos, conocer nuestra red de proveedores, valores agregados e informaci&oacute;n sobre nuestros productos. <br>';
Let _html_body2 = trim(_html_body2) ||'Encu&eacute;ntrenos en Google Play o App Store como Ancon Clientes.<br>';

Let _html_body2 = trim(_html_body2) ||'<p>';
Let _html_body2 = trim(_html_body2) ||'<br>&iexcl;Valoramos tu opini&oacute;n! Cu&eacute;ntanos que tal fue tu experiencia con nuestros productos y servicios en la siguiente <a target="_blank" href="https://forms.office.com/Pages/ResponsePage.aspx?id=iEoE-rfND0GbV6CST6EclUWEk2UOYpBPux2RK6IxZwJUMldSOVZKSlc1TU81Q1pCWEowVURRVUZPTS4u">encuesta</a> y<br>';  
Let _html_body2 = trim(_html_body2) ||'ay&uacute;danos a seguir mejorando. ';
Let _html_body2 = trim(_html_body2) ||'</p>';


Let _html_body3 = trim(_html_body3) ||'</p>';
Let _html_body3 = trim(_html_body3) ||'</td>';
Let _html_body3 = trim(_html_body3) ||'</tr>';
Let _html_body3 = trim(_html_body3) ||'<tr>';
Let _html_body3 = trim(_html_body3) ||'<td colspan="2">';
Let _html_body3 = trim(_html_body3) ||'<p>';
Let _html_body3 = trim(_html_body3) ||'<br><strong>NOTA:</strong> Es nuestro mayor deseo poder ofrecerles el servicio necesario para su protecci&oacute;n, y que su p&oacute;liza<br>'; 
Let _html_body3 = trim(_html_body3) ||'funcione adecuadamente por lo que gentilmente les recordamos el cumplimiento oportuno del pago total o<br>'; 
Let _html_body3 = trim(_html_body3) ||'primer pago fraccionado en la emisi&oacute;n de su p&oacute;liza, para garantizar el disfrute pleno de sus beneficios<br>'; 
Let _html_body3 = trim(_html_body3) ||'</p>';
Let _html_body3 = trim(_html_body3) ||'</td>';
Let _html_body3 = trim(_html_body3) ||'</tr>';
Let _html_body3 = trim(_html_body3) ||'<tr>';
Let _html_body3 = trim(_html_body3) ||'<td colspan="2">';
Let _html_body3 = trim(_html_body3) ||'<p>';





{
Let _html_body2 = trim(_html_body2) ||'<br>Para descargar su p&oacute;liza presione <a target="_blank" href="https://app.asegurancon.com/poliza_web/print_pol.php?'||v_url||'">aqu&iacute;.</a><br>';
Let _html_body2 = trim(_html_body2) ||'Si usted no est&aacute; de acuerdo con la renovaci&oacute;n de su p&oacute;liza, debe enviar un correo a:<br>';
Let _html_body2 = trim(_html_body2) ||'conservacioncliente@asegurancon.com indicando el motivo, para proceder con la anulaci&oacute;n de la p&oacute;liza.<br>';
Let _html_body2 = trim(_html_body2) ||'Si tiene alguna duda o consulta sobre su renovaci&oacute;n puede llamar a nuestras l&iacute;neas 210-8745, 210-8793, 210-8785<br>'; 
Let _html_body2 = trim(_html_body2) ||'Recuerde verificar que sus datos generales est&aacute;n correctos, de lo contrario puede actualizarlos en el siguiente <a href="https://app.asegurancon.com/webasegurados/">link</a><br>';
}
--Let _html_body2 = trim(_html_body2) ||'Nuestra L&iacute;nea de Atenci&oacute;n al Cliente es <strong>(+507)210-8700, 210-8787, 305-7500</strong> para cualquier duda o consulta,<br>'; 
--Let _html_body2 = trim(_html_body2) ||'o puede enviar un e-mail a: atencionalcliente@asegurancon.com'; 
{
Let _html_body2 = trim(_html_body2) ||'</p>'; 
Let _html_body2 = trim(_html_body2) ||'</td>';
Let _html_body2 = trim(_html_body2) ||'</tr>';
Let _html_body2 = trim(_html_body2) ||'<tr>';
Let _html_body2 = trim(_html_body2) ||'<td colspan="2">';
Let _html_body2 = trim(_html_body2) ||'<p>';
Let _html_body2 = trim(_html_body2) ||'<br>Le invitamos acceder a nuestros canales de atenci&oacute;n:';
Let _html_body2 = trim(_html_body2) ||'<br>&nbsp;&nbsp;&nbsp;&nbsp;a.	<a target="_blank" href="https://app.asegurancon.com/">www.asegurancon.com</a> conozca nuestros productos, Valores Agregados, Talleres Autorizados, Red M&eacute;dica y <a target="_blank" href="https://www.asegurancon.com/formularios-y-solicitudes/">formularios</a><br> &nbsp;&nbsp;&nbsp;&nbsp;de Afiliaci&oacute;n a Pago electr&oacute;nico por ACH o Tarjeta de Cr&eacute;dito.';
Let _html_body2 = trim(_html_body2) ||'<br>&nbsp;&nbsp;&nbsp;&nbsp;b.	S&iacute;ganos en nuestras redes sociales <a target="_blank" href="https://linktr.ee/asegurancon">@asegurancon</a>  y conozca nuestros productos, beneficios y promociones.';
Let _html_body2 = trim(_html_body2) ||'<br>&nbsp;&nbsp;&nbsp;&nbsp;c.	Af&iacute;liese al <a target="_blank" href="https://app.asegurancon.com/webasegurados/">portal de asegurados</a>, donde podr&aacute; realizar consultas sobre sus p&oacute;lizas.';
Let _html_body2 = trim(_html_body2) ||'<br>&nbsp;&nbsp;&nbsp;&nbsp;d.	Descargue nuestra aplicaci&oacute;n m&oacute;vil Anc&oacute;n Clientes disponible para <a target="_blank" href="https://apps.apple.com/us/app/ancon-clientes/id1363630649">iOS</a> y <a target="_blank" href="https://play.google.com/store/apps/details?id=com.smartreport.anconclientes">Android</a>.';
Let _html_body2 = trim(_html_body2) ||'</p>';
Let _html_body2 = trim(_html_body2) ||'</td>';
Let _html_body2 = trim(_html_body2) ||'</tr>';
Let _html_body2 = trim(_html_body2) ||'<tr>';
Let _html_body2 = trim(_html_body2) ||'<td colspan="2">';
Let _html_body2 = trim(_html_body2) ||'<p>';
}
--Let _html_body2 = trim(_html_body2) ||'<br>Para nosotros su opini&oacute;n es importante, por lo que le invitamos a realizar la siguiente <a target="_blank" href="https://forms.office.com/Pages/DesignPage.aspx?fragment=FormId%3DiEoE-rfND0GbV6CST6EclUWEk2UOYpBPux2RK6IxZwJUMldSOVZKSlc1TU81Q1pCWEowVURRVUZPTS4u">encuesta</a> que nos<br>';  
{
Let _html_body2 = trim(_html_body2) ||'<br>Para nosotros su opini&oacute;n es importante, por lo que le invitamos a realizar la siguiente <a target="_blank" href="https://forms.office.com/Pages/ResponsePage.aspx?id=iEoE-rfND0GbV6CST6EclUWEk2UOYpBPux2RK6IxZwJUMldSOVZKSlc1TU81Q1pCWEowVURRVUZPTS4u">encuesta</a> que nos<br>';  
Let _html_body2 = trim(_html_body2) ||'permitir&aacute; mejorar nuestro servicio.';
Let _html_body2 = trim(_html_body2) ||'</p>';
Let _html_body2 = trim(_html_body2) ||'</td>';
Let _html_body2 = trim(_html_body2) ||'</tr>';
Let _html_body2 = trim(_html_body2) ||'<tr>';
Let _html_body2 = trim(_html_body2) ||'<td colspan="2">';
Let _html_body2 = trim(_html_body2) ||'<p>';

Let _html_body3 = trim(_html_body3) ||'<br><strong>NOTA:</strong> Es nuestro mayor deseo poder ofrecerles el servicio necesario para su protecci&oacute;n, y que su p&oacute;liza<br>'; 
Let _html_body3 = trim(_html_body3) ||'funcione adecuadamente por lo que gentilmente les recordamos el cumplimiento oportuno del pago total o<br>'; 
Let _html_body3 = trim(_html_body3) ||'primer pago fraccionado en la emisi&oacute;n de su p&oacute;liza, para garantizar el disfrute pleno de sus beneficios<br>'; 
Let _html_body3 = trim(_html_body3) ||'(Art&iacute;culo 154 y 156 Ley 12 de 03 de abril del 2012).'; 
Let _html_body3 = trim(_html_body3) ||'</p>';
Let _html_body3 = trim(_html_body3) ||'</td>';
Let _html_body3 = trim(_html_body3) ||'</tr>';
Let _html_body3 = trim(_html_body3) ||'<tr>';
Let _html_body3 = trim(_html_body3) ||'<td colspan="2">';
Let _html_body3 = trim(_html_body3) ||'<p>';
Let _html_body3 = trim(_html_body3) ||'<br>Para realizar su primer pago puede ingresar a nuestros <a target="_blank" href="https://app.asegurancon.com/pago_online/">pagos online</a>, con su tarjeta Visa, MasterCard y Clave.';
Let _html_body3 = trim(_html_body3) ||'</p>';
Let _html_body3 = trim(_html_body3) ||'</td>';
Let _html_body3 = trim(_html_body3) ||'</tr>';
}
Let _html_body3 = trim(_html_body3) ||'</table>';
Let _html_body3 = trim(_html_body3) ||'</body>';
Let _html_body3 = trim(_html_body3) ||'</html>';
  
	

return _html_body1,_html_body2,_html_body3  with resume;

END FOREACH;
--trace off;
END PROCEDURE

-- 2048 = N : - 0 ----- N------------- 32739 max
--1421 -- <!doctype html><html><head><meta charset="utf-8"><title>Renovaci&oacute;n</title></head><body style="font-family:Arial; font-size:14px; text-align:justify;"><table width="800">	<tr>    	<td colspan="2"><img src="https:app.asegurancon.com/imagen/cintillo1.jpg" width="800"></td>    </tr>    <tr>        <td colspan="2">            <p>Estimado Asegurado:<br>           	   Aseguradora Anc&oacute;n S.A., tiene el honor de dirigirse a usted para agradecer la confianza y preferencia hacia nuestra			   empresa y los servicios que brindamos, manteni&eacute;ndonos como su compa&ntilde;&iacute;a de seguros.            </p>        </td>    </tr>    <tr>        <td colspan="2">            <p style="text-decoration:underline;">            Hemos renovado la(s) siguiente(s) p&oacute;liza(s):            </p>        </td>    </tr>    <tr>    	<td width="400">        	<p>Ramo: SODA                                              </p>        </td>        <td width="400">       		<p>No. de P&oacute;liza: 2014-01002-01       </p>        </td>    </tr>    <tr>    	<td width="400">        	<p>Prima total: 106.00</p>        </td>        <td width="400">       		<p>Forma de pago: ANC - ANCON                                       </p>        </td>    </tr>    <tr>    	<td width="400">        	<p>Vigencia Incial: 28/04/2016</p>	</td>        <td width="400">       		<p>Vigencia Final: 28/04/2017</p>        </td>    </tr>	<tr>    	
--1229 -- <td colspan="2"><p style="text-decoration:underline;">Datos Generales</p></td>    </tr>    <tr>    	<td width="400">        	<p>Asegurado: ORLANDO OSCAR MARTINEZ RODRIGUEZ                                                                    </p>        </td>        <td width="400">       		<p>Contratante: ORLANDO OSCAR MARTINEZ RODRIGUEZ                                                                    </p>        </td>    </tr>    <tr>    	<td width="400">        	<p>Tel&eacute;fono: 270-1370  </p>        </td>        <td width="400">       		<p>Celular: 6781-6364 </p>        </td>    </tr>    <tr>    	<td width="400">        	<p>Correo electr&oacute;nico: mpspanama@ymail.com                               </p>        </td>        <td width="400">       		<p>Direcci&oacute;n: ARRAIJAN, SECTOR 08, CASA 239 BDA LA PAZ          </p>        </td>    </tr>    <tr>    	<td colspan="2">        	<p><b>IMPORTANTE:</b><br>        	Favor verificar que sus datos generales est&eacute;n correctos, de lo contrario, puede dirigirse a nuestra p&aacute;gina web para la actualizaci&oacute;n			de sus datos o contactar a nuestros agentes de servicio al cliente al 210-8787 o escribanos a info@asegurancon.com.            </p>        
--3416 -- </td>    </tr>    <tr>        <td colspan="2">            <p style="text-decoration:underline;">            Hemos renovado la(s) siguiente(s) p&oacute;liza(s):            </p>        </td>    </tr>    <tr>    	<td width="400">        	<p>Ramo: SODA                                              </p>        </td>        <td width="400">       		<p>No. de P&oacute;liza: 2014-01002-01       </p>        </td>    </tr>    <tr>    	<td width="400">        	<p>Prima total: 106.00</p>        </td>        <td width="400">       		<p>Forma de pago: ANC - ANCON                                       </p>        </td>    </tr>    <tr>    	<td width="400">        	<p>Vigencia Incial: 28/04/2016</p>	</td>        <td width="400">       		<p>Vigencia Final: 28/04/2017</p>        </td>    </tr>	<tr>    	<td colspan="2"><p style="text-decoration:underline;">Datos Generales</p></td>    </tr>    <tr>    	<td width="400">        	<p>Asegurado: ORLANDO OSCAR MARTINEZ RODRIGUEZ                                                                    </p>        </td>        <td width="400">       		<p>Contratante: ORLANDO OSCAR MARTINEZ RODRIGUEZ                                                                    </p>        </td>    </tr>    <tr>    	<td width="400">        	<p>Tel&eacute;fono: 270-1370  </p>        </td>        <td width="400">       		<p>Celular: 6781-6364 </p>        </td>    </tr>    <tr>    	<td width="400">        	<p>Correo electr&oacute;nico: mpspanama@ymail.com                               </p>        </td>        <td width="400">       		<p>Direcci&oacute;n: ARRAIJAN, SECTOR 08, CASA 239 BDA LA PAZ          </p>        </td>    </tr>    <tr>    	<td colspan="2">        	<p><b>IMPORTANTE:</b><br>        	Favor verificar que sus datos generales est&eacute;n correctos, de lo contrario, puede dirigirse a nuestra p&aacute;gina web para la actualizaci&oacute;n			de sus datos o contactar a nuestros agentes de servicio al cliente al 210-8787 o escribanos a info@asegurancon.com.            </p>        </td>    </tr>    <tr>		<td colspan="2">        	<p><b>NOTA:</b><br>        	Se les recuerda el cumplimiento oportuno del pago total o primer pago fraccionado en la renovaci&oacute;n de su p&oacute;liza, de lo            contrario el contrato de seguro podr&aacute; ser anulado. As&iacute; como los pagos subsiguientes conforme al calendario de pago            pactado, y as&iacute; evitar consecuencias de suspensi&oacute;n de cobertura e inhabilitaci&oacute;n de sus beneficios. (Art&iacute;culo 154 y 156,            De acuerdo a la Ley 12 de 03 de abril del 2012).            </p>            <p>            Para brindarle un mejor servicio, le invitamos a afiliarse a â€œAncon Online/Consulta de Aseguradosâ€ en nuestra p&aacute;gina            web: www.asegurancon.com donde podr&aacute; realizar consultas sobre sus p&oacute;lizas tales como: estados de cuenta,            renovaciones, estatus de reclamo, actualizaci&oacute;n de datos, etc.            </p>            <p>Agradeciendo su preferencia, le saluda muy cordialmente, Aseguradora Anc&oacute;n, S.A.</p>            <p>&nbsp;</p>            <p>Nota: Este correo es generado de forma autom&aacute;tica por la Intranet Corporativa. Por favor no responder al remitente.</p>        </td>    </tr>	<tr>    	<td colspan="2"><img src="https:app.asegurancon.com/imagen/cintillo2.jpg" width="800"></td>    </tr></table></body></html>	





