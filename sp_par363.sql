-- Procedimiento que Genera el Html Body - Pago de Reclamos Cheque
-- Creado : 23/04/2018 - Autor: Amado Perez
Drop procedure sp_par363; 
CREATE PROCEDURE "informix".sp_par363(  
a_secuencia	INTEGER 
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

Let  _html_body1 = trim(_html_body1) ||' <!doctype html>';
Let  _html_body1 = trim(_html_body1) ||' <html>';
Let  _html_body1 = trim(_html_body1) ||' <head>';
Let  _html_body1 = trim(_html_body1) ||' <meta charset="utf-8">';
Let  _html_body1 = trim(_html_body1) ||' <title>Emisi&oacute;n</title>';
Let  _html_body1 = trim(_html_body1) ||' </head>';
Let  _html_body1 = trim(_html_body1) ||' ';
Let  _html_body1 = trim(_html_body1) ||' <body style="font-family:Arial; font-size:14px; text-align:justify;">';
--Let  _html_body1 = trim(_html_body1) ||'<style>p {	font-family:Arial; 	font-size:14px; 	text-align:justify;} </style> ';
Let  _html_body1 = trim(_html_body1) ||' <table width="800">';
--Let  _html_body1 = trim(_html_body1) ||' 	<tr>';
--Let  _html_body1 = trim(_html_body1) ||'     	<td colspan="2"><img src="https:app.asegurancon.com/imagen/cintillo1.jpg" width="800"></td>';
--Let  _html_body1 = trim(_html_body1) ||'     </tr>';
Let  _html_body1 = trim(_html_body1) ||'     <tr>';
Let  _html_body1 = trim(_html_body1) ||'         <td colspan="2">';
Let  _html_body1 = trim(_html_body1) ||'             <p>Estimado Asegurado:<br>';
Let  _html_body1 = trim(_html_body1) ||'             Aseguradora Anc&oacute;n S.A., le da la m&aacute;s cordial bienvenida y agradecemos la confianza que ha depositado en nosotros en';
Let  _html_body1 = trim(_html_body1) ||'             ofrecerles el mejor servicio y reiteramos nuestro compromiso de satisfacer sus necesidades de forma eficiente y oportuna,';
Let  _html_body1 = trim(_html_body1) ||'             en base a la p&oacute;liza adquirida.';
Let  _html_body1 = trim(_html_body1) ||'             </p>';
Let  _html_body1 = trim(_html_body1) ||'         </td>';
Let  _html_body1 = trim(_html_body1) ||'     </tr>';
Let  _html_body1 = trim(_html_body1) ||'     <tr>';
Let  _html_body1 = trim(_html_body1) ||'         <td colspan="2">';
Let  _html_body1 = trim(_html_body1) ||'             <p style="text-decoration:underline;">';
Let  _html_body1 = trim(_html_body1) ||'             Usted ha emitido con nosotros la(s) siguiente(s) p&oacute;liza(s):';
Let  _html_body1 = trim(_html_body1) ||'             </p>';
Let  _html_body1 = trim(_html_body1) ||'         </td>';
Let  _html_body1 = trim(_html_body1) ||'     </tr>';
Let  _html_body1 = trim(_html_body1) ||'     <tr>';
Let  _html_body1 = trim(_html_body1) ||'     	<td width="400">';
Let  _html_body1 = trim(_html_body1) ||'         	<p>Ramo: '||v_ramo||'</p>';
Let  _html_body1 = trim(_html_body1) ||'         </td>';
Let  _html_body1 = trim(_html_body1) ||'         <td width="400">';
Let  _html_body1 = trim(_html_body1) ||'        		<p>No. de P&oacute;liza: '||v_poliza||'</p>';
Let  _html_body1 = trim(_html_body1) ||'         </td>';
Let  _html_body1 = trim(_html_body1) ||'     </tr>';
Let  _html_body1 = trim(_html_body1) ||'     <tr>';
Let  _html_body1 = trim(_html_body1) ||'     	<td width="400">';
Let  _html_body1 = trim(_html_body1) ||'         	<p>Prima total: '||cast(v_prima_total as varchar(10))||'</p>';
Let  _html_body1 = trim(_html_body1) ||'         </td>';
Let  _html_body1 = trim(_html_body1) ||'         <td width="400">';
Let  _html_body1 = trim(_html_body1) ||'        		<p>Forma de pago: '||cast(v_n_pagos as varchar(3))||',pagos '||v_codformapag||'</p>';
Let  _html_body1 = trim(_html_body1) ||'         </td>';
Let  _html_body1 = trim(_html_body1) ||'     </tr>';
Let  _html_body1 = trim(_html_body1) ||'     <tr>';
Let  _html_body1 = trim(_html_body1) ||'     	<td width="400">';
Let  _html_body1 = trim(_html_body1) ||'         	<p>Vigencia Inicial: '||cast(v_vigen_ini as varchar(10))||'</p>';

Let  _html_body1 = trim(_html_body1) ||'         </td>';
Let  _html_body1 = trim(_html_body1) ||'         <td width="400">';
Let  _html_body1 = trim(_html_body1) ||'        		<p>Vigencia Final: '||cast(v_vigen_fin as varchar(10))||'</p>';
Let  _html_body1 = trim(_html_body1) ||'         </td>';
Let  _html_body1 = trim(_html_body1) ||'     </tr> ';
Let  _html_body1 = trim(_html_body1) ||' 	<tr>';
Let  _html_body1 = trim(_html_body1) ||'     	<td colspan="2"><p style="text-decoration:underline;">Datos Generales</p></td>';
Let  _html_body1 = trim(_html_body1) ||'     </tr> ';
Let  _html_body1 = trim(_html_body1) ||'     <tr>';
Let  _html_body1 = trim(_html_body1) ||'     	<td width="400">';
Let  _html_body1 = trim(_html_body1) ||'         	<p>Asegurado: '||v_asegurado||'</p>';
Let  _html_body1 = trim(_html_body1) ||'         </td>';
Let  _html_body1 = trim(_html_body1) ||'         <td width="400">';
Let  _html_body1 = trim(_html_body1) ||'        		<p>Contratante: '||v_contratante||'</p>';
Let  _html_body1 = trim(_html_body1) ||'         </td>';
Let  _html_body1 = trim(_html_body1) ||'     </tr>';
Let  _html_body1 = trim(_html_body1) ||'     <tr>';
Let  _html_body1 = trim(_html_body1) ||'     	<td width="400">';
Let  _html_body1 = trim(_html_body1) ||'         	<p>Tel&eacute;fono: '||v_telefono1||'</p>';
Let  _html_body1 = trim(_html_body1) ||'         </td>';
Let  _html_body1 = trim(_html_body1) ||'         <td width="400">';
Let  _html_body1 = trim(_html_body1) ||'        		<p>Celular: '||v_telefono2||'</p>';

Let  _html_body2 = trim(_html_body2) ||'         </td>';
Let  _html_body2 = trim(_html_body2) ||'     </tr>';
Let  _html_body2 = trim(_html_body2) ||'     <tr>';
Let  _html_body2 = trim(_html_body2) ||'     	<td width="400">';
Let  _html_body2 = trim(_html_body2) ||'         	<p>Correo electronico: '||v_email||'</p>';
Let  _html_body2 = trim(_html_body2) ||'         </td>';
Let  _html_body2 = trim(_html_body2) ||'         <td width="400">';
Let  _html_body2 = trim(_html_body2) ||'        		<p>Direcci&oacute;n: '||v_dir_cobro||'</p>';
Let  _html_body2 = trim(_html_body2) ||'         </td>';
Let  _html_body2 = trim(_html_body2) ||'     </tr>';
Let  _html_body2 = trim(_html_body2) ||'     <tr>';
Let  _html_body2 = trim(_html_body2) ||'     	<td colspan="2">';
Let  _html_body2 = trim(_html_body2) ||'         	<p><b>IMPORTANTE:</b><br>';
Let  _html_body2 = trim(_html_body2) ||'         	Favor verificar que sus datos generales est&eacute;n correctos, de lo contrario, puede dirigirse a nuestra p&aacute;gina web para la actualizaci&oacute;n';
Let  _html_body2 = trim(_html_body2) ||' 			de sus datos o contactar a nuestros agentes de servicio al cliente al 210-8787 o escribanos a '||v_sender||' .';
Let  _html_body2 = trim(_html_body2) ||'             </p>';

Let  _html_body2 = trim(_html_body2) ||'         </td>';
Let  _html_body2 = trim(_html_body2) ||'     </tr>';
Let  _html_body2 = trim(_html_body2) ||'     <tr>';
Let  _html_body2 = trim(_html_body2) ||'     	<td colspan="2">';
--Let  _html_body2 = trim(_html_body2) ||'         	<p><b>NOTA:</b><br>';
--Let  _html_body2 = trim(_html_body2) ||'         	Se les recuerda el cumplimiento oportuno del pago total o primer pago fraccionado en la renovaci&oacute;n de su p&oacute;liza, de lo';
--Let  _html_body2 = trim(_html_body2) ||'             contrario el contrato de seguro podr&aacute; ser anulado. As&iacute; como los pagos subsiguientes conforme al calendario de pago';
--Let  _html_body2 = trim(_html_body2) ||'             pactado, y as&iacute; evitar consecuencias de suspensi&oacute;n de cobertura e inhabilitaci&oacute;n de sus beneficios. (Art&iacute;culo 154 y 156,';
--Let  _html_body2 = trim(_html_body2) ||'             De acuerdo a la Ley 12 de 03 de abril del 2012).';
Let  _html_body2 = trim(_html_body2) ||'         	<p><b> </b><br>';
Let  _html_body2 = trim(_html_body2) ||'             Se les recuerda el cumplimiento oportuno del pago total o primer pago fraccionado en la emisi&oacute;n de su p&oacute;liza, ';
Let  _html_body2 = trim(_html_body2) ||'             y as&iacute; evitar consecuencias de suspensi&oacute;n de cobertura e inhabilitaci&oacute;n de sus beneficios de lo';
Let  _html_body2 = trim(_html_body2) ||'             contrario el contrato de seguro podr&aacute; ser anulado (Art&iacute;culo 154 y 156 Ley 12 de 03 de abril del 2012).';
Let  _html_body3 = trim(_html_body3) ||'             </p>';
Let  _html_body3 = trim(_html_body3) ||'             <p>';
Let  _html_body3 = trim(_html_body3) ||'             Para brindarle un mejor servicio, le invitamos a afiliarse a "Ancon Online/Consulta de Asegurados" en nuestra p&aacute;gina';
Let  _html_body3 = trim(_html_body3) ||'             web: www.asegurancon.com donde podr&aacute; realizar consultas sobre sus p&oacute;lizas tales como: estados de cuenta,';
Let  _html_body3 = trim(_html_body3) ||'             renovaciones, estatus de reclamo, actualizaci&oacute;n de datos, etc.';
Let  _html_body3 = trim(_html_body3) ||'             </p>';
Let  _html_body3 = trim(_html_body3) ||'             <p>Agradeciendo su preferencia, le saluda muy cordialmente, Aseguradora Anc&oacute;n, S.A.</p>';
Let  _html_body3 = trim(_html_body3) ||'             <p>&nbsp;</p>';
Let  _html_body3 = trim(_html_body3) ||'             <p>Nota: Este correo es generado de forma autom&aacute;tica por la Intranet Corporativa. Por favor no responder al remitente.</p>';
Let  _html_body3 = trim(_html_body3) ||'         </td>';
Let  _html_body3 = trim(_html_body3) ||'     </tr>';
Let  _html_body3 = trim(_html_body3) ||' 	<tr>';
Let  _html_body3 = trim(_html_body3) ||'     	<td colspan="2"><img src="https:app.asegurancon.com/imagen/cintillo2.jpg" width="800"></td>';
Let  _html_body3 = trim(_html_body3) ||'     </tr>';
Let  _html_body3 = trim(_html_body3) ||' </table>';
Let  _html_body3 = trim(_html_body3) ||' </body>';
Let  _html_body3 = trim(_html_body3) ||' </html>'; 
	
  {
	Update parmailsend 
	   set html_body	= _html_body1
	 where secuencia	= a_secuencia;
  }	 

return _html_body1,_html_body2,_html_body3  with resume;

END FOREACH;
--trace off;
END PROCEDURE

