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

define 	v_prima_mes	    DEC(16,2); 
define v_cod_perpago    char(3);
define v_periodo_pago   char(20);

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
Let _html_body1 = trim(_html_body1) ||'<p><strong>Estimado(a): '||v_asegurado||' </strong><br><br>';
Let _html_body1 = trim(_html_body1) ||'Aseguradora Anc&oacute;n S.A., le da la m&aacute;s cordial bienvenida y agradecemos la confianza que ha depositado en<br>';
Let _html_body1 = trim(_html_body1) ||'nosotros para ofrecerles el mejor servicio y reiteramos nuestro compromiso de satisfacer sus necesidades<br>'; 
Let _html_body1 = trim(_html_body1) ||'de forma eficiente y oportuna, en base a la p&oacute;liza adquirida.<br><br>';
Let _html_body1 = trim(_html_body1) ||'Hemos emitido su p&oacute;liza de '||v_ramo||'  No. '||v_poliza||' con vigencia desde '||cast(v_vigen_ini as varchar(10))||' hasta '||cast(v_vigen_fin as varchar(10))||'.<br><br>';
Let _html_body1 = trim(_html_body1) ||'Su prima Total a pagar es B/.'||cast(v_prima_total as varchar(10))||', en '||cast(v_n_pagos as varchar(3))||' pagos de B/. '||cast(v_prima_mes as varchar(8))||' '||v_periodo_pago||'.<br><br>';    

Let _html_body2 = trim(_html_body2) ||'Descargue su p&oacute;liza <a target="_blank" href="https://app.asegurancon.com/poliza_web/print_pol.php?'||v_url||'">aqu&iacute;.</a><br><br>';
Let _html_body2 = trim(_html_body2) ||'Favor verifique que sus datos est&eacute;n correctos, de lo contrario puede actualizarlos <a target="_blank" href="https://app.asegurancon.com/webasegurados/">aqu&iacute;</a>.<br><br>';
Let _html_body2 = trim(_html_body2) ||'Su primer pago puede realizarlo accediendo a <a target="_blank" href="https://app.asegurancon.com/pago_online/">pagos online</a>.';
Let _html_body2 = trim(_html_body2) ||'</p>';
Let _html_body2 = trim(_html_body2) ||'</td>';
Let _html_body2 = trim(_html_body2) ||'</tr>';
Let _html_body2 = trim(_html_body2) ||'<tr>';
Let _html_body2 = trim(_html_body2) ||'<td colspan="2">';
Let _html_body2 = trim(_html_body2) ||'<p>';
Let _html_body2 = trim(_html_body2) ||'<br>Nuestra L&iacute;nea de Atenci&oacute;n al Cliente es (+507)210-8700, 210-8787, 305-7500 con un horario de Lunes a Viernes <br>de 8:00 a.m. a 5:00 p.m. y s&aacute;bados de 9:00 a.m. a 12:00 p.m. para cualquier duda o consulta, puede enviar un <br>e-mail a: atencionalcliente@asegurancon.com.';     
Let _html_body2 = trim(_html_body2) ||'</p>';
Let _html_body2 = trim(_html_body2) ||'</td>';
Let _html_body2 = trim(_html_body2) ||'</tr>';
Let _html_body2 = trim(_html_body2) ||'<tr>';
Let _html_body2 = trim(_html_body2) ||'<td colspan="2">';
Let _html_body2 = trim(_html_body2) ||'<p>';
Let _html_body2 = trim(_html_body2) ||'<br>Le invitamos a descargar nuestro App m&oacute;vil y disfrute de tener en las manos acceso 24/7 a sus p&oacute;lizas, reclamos, '; 
Let _html_body2 = trim(_html_body2) ||'consulta de saldos, realizar sus pagos, conocer nuestra red de proveedores, valores agregados e informaci&oacute;n sobre nuestros productos. Encu&eacute;ntrenos en Google Play o App Store como Ancon Clientes.';
Let _html_body2 = trim(_html_body2) ||'</p>';
Let _html_body2 = trim(_html_body2) ||'</td>';
Let _html_body2 = trim(_html_body2) ||'</tr>';
Let _html_body2 = trim(_html_body2) ||'<tr>';
Let _html_body2 = trim(_html_body2) ||'<td colspan="2">';
Let _html_body2 = trim(_html_body2) ||'<p>';

Let _html_body3 = trim(_html_body3) ||'<br>&#161;Valoramos tu opini&oacute;n! Cu&eacute;ntanos que tal fue tu experiencia con nuestros productos y servicios en la siguiente <a target="_blank" href="https://forms.office.com/Pages/ResponsePage.aspx?id=iEoE-rfND0GbV6CST6EclfF01golxm1JhPH2pT-E0AFUOEJLRjMxQktEUzhPNUJYUEI4RzNYVkRTRi4u">encuesta</a> y ay&uacute;danos a seguir mejorando.';
Let _html_body3 = trim(_html_body3) ||'</p>';
Let _html_body3 = trim(_html_body3) ||'</td>';
Let _html_body3 = trim(_html_body3) ||'</tr>';
Let _html_body3 = trim(_html_body3) ||'<tr>';
Let _html_body3 = trim(_html_body3) ||'<td colspan="2">';
Let _html_body3 = trim(_html_body3) ||'<p>';
Let _html_body3 = trim(_html_body3) ||'<br><strong>NOTA:</strong> Es nuestro mayor deseo poder ofrecerles el servicio necesario para su protecci&oacute;n, y que su p&oacute;liza<br>'; 
Let _html_body3 = trim(_html_body3) ||'funcione adecuadamente por lo que gentilmente les recordamos el cumplimiento oportuno del pago total o<br>';
Let _html_body3 = trim(_html_body3) ||'primer pago fraccionado en la emisi&oacute;n de su p&oacute;liza, para garantizar el disfrute pleno de sus beneficios.';
Let _html_body3 = trim(_html_body3) ||'</p>';
Let _html_body3 = trim(_html_body3) ||'</td>';
Let _html_body3 = trim(_html_body3) ||'</tr>';
Let _html_body3 = trim(_html_body3) ||'</table>';
Let _html_body3 = trim(_html_body3) ||'</body>';
Let _html_body3 = trim(_html_body3) ||'</html>';

return _html_body1,_html_body2,_html_body3  with resume;

END FOREACH;
--trace off;
END PROCEDURE

