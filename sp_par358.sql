-- Procedimiento que Genera el Html Body 
-- Creado : 14/09/2016 - Autor: Henry Giron 
Drop procedure sp_par358; 
CREATE PROCEDURE "informix".sp_par358(  
a_secuencia	INTEGER 
)returning	Lvarchar(max),
            Lvarchar(max),
            Lvarchar(max); 

Define _html_body1	 Lvarchar(max); -- char(512); 
Define _html_body2	 Lvarchar(max); -- char(512); 
Define _html_body3	 Lvarchar(max); -- char(512); 

define _error				integer; 
define _siguiente			integer; 
define _error_isam			integer; 
define _error_desc			char(100); 

define v_asegurado	    	varchar(50); 
define v_no_documento		char(13);
define v_fecha_siniestro	date;
define v_no_unidad			char(5);
define v_no_tramite			char(10);
define 	_no_solicitud		CHAR(50);
define v_placa              char(10);

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return 0,0,0;
end exception

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_par358.trc"; 
--trace on;
drop table if exists temp_carta;

Let  _html_body1 = '';
Let  _html_body2 = '';
Let  _html_body3 = '';

let _no_solicitud = 0;
let _siguiente = 0;

     create temp table temp_carta(
			asegurado	varchar(50), 
			no_documento	char(13),
			fecha_siniestro	date,
			no_unidad	char(5),
			no_tramite	char(10),
			placa       char(10)
			) with no log;															 
	create index idx1_temp_carta on temp_carta(no_documento);
    create index idx2_temp_carta on temp_carta(no_unidad);		
	create index idx3_temp_carta on temp_carta(no_tramite);		

foreach
	Select no_remesa
	  into _no_solicitud
	  from parmailcomp
	 where mail_secuencia = a_secuencia  
	 exit foreach;
end foreach
	 
 
	 FOREACH EXECUTE PROCEDURE sp_rec211(_no_solicitud) 
			   INTO v_asegurado,
					v_no_documento,
					v_fecha_siniestro,
					v_no_unidad,
					v_no_tramite,
					v_placa
			INSERT INTO temp_carta 
			VALUES  (v_asegurado,
					v_no_documento,
					v_fecha_siniestro,
					v_no_unidad,
					v_no_tramite,
					v_placa
					);				
	END FOREACH;

FOREACH 
      select NVL(asegurado,''),
			NVL(no_documento,''),
			fecha_siniestro,
			NVL(no_unidad,''),
			NVL(no_tramite,''),
			NVL(placa,'')
	   into v_asegurado,
			v_no_documento,
			v_fecha_siniestro,
			v_no_unidad,
			v_no_tramite,
			v_placa
       from temp_carta
	  --order by no_documento
	  
Let  _html_body1 = trim(_html_body1) ||'<!doctype html>';
Let  _html_body1 = trim(_html_body1) ||'<html>';
Let  _html_body1 = trim(_html_body1) ||'<head>';
Let  _html_body1 = trim(_html_body1) ||'<meta charset="utf-8">';
Let  _html_body1 = trim(_html_body1) ||'<title>Reclamo</title>';
Let  _html_body1 = trim(_html_body1) ||'</head>';
Let  _html_body1 = trim(_html_body1) ||'<body style="font-family:Arial; font-size:14px; text-align:justify;">';
Let  _html_body1 = trim(_html_body1) ||'<table width="800">';
Let  _html_body1 = trim(_html_body1) ||'	<tr>';
--Let  _html_body1 = trim(_html_body1) ||'    	<td colspan="2"><img src="https:app.asegurancon.com/imagen/cintillo1.jpg" width="800"></td>';
Let  _html_body1 = trim(_html_body1) ||'    </tr>';
Let  _html_body1 = trim(_html_body1) ||'    <tr>';
Let  _html_body1 = trim(_html_body1) ||'    	<td width="200">';
Let  _html_body1 = trim(_html_body1) ||'        	Nombre del Asegurado:';
Let  _html_body1 = trim(_html_body1) ||'        </td>';
Let  _html_body1 = trim(_html_body1) ||'        <td width="400">';
Let  _html_body1 = trim(_html_body1) ||'       		'||v_asegurado||'';
Let  _html_body1 = trim(_html_body1) ||'        </td>';
Let  _html_body1 = trim(_html_body1) ||'    </tr>';
Let  _html_body1 = trim(_html_body1) ||'    <tr>';
Let  _html_body1 = trim(_html_body1) ||'    	<td width="200">';
Let  _html_body1 = trim(_html_body1) ||'       		P&oacute;liza: ';
Let  _html_body1 = trim(_html_body1) ||'        </td>';
Let  _html_body1 = trim(_html_body1) ||'        <td width="400">';
Let  _html_body1 = trim(_html_body1) ||'       		'||v_no_documento||'';
Let  _html_body1 = trim(_html_body1) ||'        </td>';
Let  _html_body1 = trim(_html_body1) ||'    </tr>';
Let  _html_body1 = trim(_html_body1) ||'    <tr>';
Let  _html_body1 = trim(_html_body1) ||'    	<td width="200">';
Let  _html_body1 = trim(_html_body1) ||'        	Fecha del Siniestro:';
Let  _html_body1 = trim(_html_body1) ||'        </td>';
Let  _html_body1 = trim(_html_body1) ||'        <td width="400">';
Let  _html_body1 = trim(_html_body1) ||'       		'||cast(v_fecha_siniestro as varchar(10))||''; 
Let  _html_body1 = trim(_html_body1) ||'        </td>';
Let  _html_body1 = trim(_html_body1) ||'    </tr> ';
Let  _html_body1 = trim(_html_body1) ||'    <tr>';
Let  _html_body1 = trim(_html_body1) ||'    	<td width="200">';
Let  _html_body1 = trim(_html_body1) ||'        	No. de Unidad:';
Let  _html_body1 = trim(_html_body1) ||'        </td>';
Let  _html_body1 = trim(_html_body1) ||'        <td width="400">';
Let  _html_body1 = trim(_html_body1) ||'       		'||v_no_unidad||'';
Let  _html_body1 = trim(_html_body1) ||'        </td>';
Let  _html_body1 = trim(_html_body1) ||'    </tr>';
Let  _html_body1 = trim(_html_body1) ||'    <tr>';
Let  _html_body1 = trim(_html_body1) ||'    	<td width="200">';
Let  _html_body1 = trim(_html_body1) ||'        	Placa:';
Let  _html_body1 = trim(_html_body1) ||'        </td>';
Let  _html_body1 = trim(_html_body1) ||'        <td width="400">';
Let  _html_body1 = trim(_html_body1) ||'       		'||v_placa||'';
Let  _html_body1 = trim(_html_body1) ||'        </td>';
Let  _html_body1 = trim(_html_body1) ||'    </tr>';
Let  _html_body1 = trim(_html_body1) ||'    <tr>';
Let  _html_body1 = trim(_html_body1) ||'    	<td colspan="2">';
Let  _html_body1 = trim(_html_body1) ||'        	<p style=" text-align: justify;"><br><br>';
Let  _html_body1 = trim(_html_body1) ||'        	Estimado  asegurado,  le  informamos  que  su  reclamo  ha  sido  recibido e ingresado en nuestro sistema. Su n&uacute;mero';
Let  _html_body1 = trim(_html_body1) ||'            de Tramite es: <b>'||trim(v_no_tramite)||'.</b>';  
Let  _html_body2 = trim(_html_body2) ||'            </p><br>';
Let  _html_body2 = trim(_html_body2) ||'        </td>';
Let  _html_body2 = trim(_html_body2) ||'    </tr>';
Let  _html_body2 = trim(_html_body2) ||'    <tr>';
Let  _html_body2 = trim(_html_body2) ||'    	<td colspan="2">';
Let  _html_body2 = trim(_html_body2) ||'        	<p style=" text-align: justify;">';
Let  _html_body2 = trim(_html_body2) ||'        	 	Adjunto encontrar&aacute; los requisitos para presentar su reclamo; y este sea atendido de forma expedita seg&uacute;n la ';
Let  _html_body2 = trim(_html_body2) ||'             	cobertura afectada.';
Let  _html_body2 = trim(_html_body2) ||'            </p>';
Let  _html_body2 = trim(_html_body2) ||'            <p style=" text-align: justify;">';
Let  _html_body2 = trim(_html_body2) ||'            	En caso de que aplique pago a deducible, Ud. podr&aacute; realizarlo a trav&eacute;s de nuestras sucursales a nivel nacional, as&iacute; ';
Let  _html_body2 = trim(_html_body2) ||'				como tambi&eacute;n en Banca en L&iacute;nea de Banco General, con su n&uacute;mero de tr&aacute;mite.';
Let  _html_body2 = trim(_html_body2) ||'            </p>';
Let  _html_body2 = trim(_html_body2) ||'            <p style=" text-align: justify;">';
Let  _html_body2 = trim(_html_body2) ||'               Si Ud. requiere de nuestros servicios de Asistencia Legal es necesario nos facilite un poder legal, firmado 8 d&iacute;as h&aacute;biles ';
Let  _html_body2 = trim(_html_body2) ||'               antes de la fecha de audiencia, el cual puede encontrar en nuestra p&aacute;gina web, a trav&eacute;s del siguiente link: ';
Let  _html_body2 = trim(_html_body2) ||'               <a href="https://www.asegurancon.com/formularios-y-solicitudes/">https://www.asegurancon.com/formularios-y-solicitudes/</a> ';
Let  _html_body2 = trim(_html_body2) ||'			</p>';

--Let  _html_body2 = trim(_html_body2) ||'            <p style=" text-align: justify;">';
--Let  _html_body2 = trim(_html_body2) ||'                Adicionalmente, les solicitamos para la Asistencia Legal copia de c&eacute;dula legible, copia de licencia y copia de la ';
--Let  _html_body2 = trim(_html_body2) ||'                boleta de tr&aacute;nsito, de haberlos aportado a nuestro servicio de Asistencia Vial favor omitir esta indicaci&oacute;n. ';
--Let  _html_body2 = trim(_html_body2) ||'			</p>';
--Let  _html_body3 = trim(_html_body3) ||'            <p>&nbsp;</p>';
Let  _html_body3 = trim(_html_body3) ||'            <p style=" text-align: justify;">';
Let  _html_body3 = trim(_html_body3) ||'               Le invitamos a ingresar a nuestros <a href="https://linktr.ee/asegurancon">Canales de atenci&oacute;n</a> donde podr&aacute; acceder a nuestra p&aacute;gina web, redes ';
Let  _html_body3 = trim(_html_body3) ||'               sociales, ubicaci&oacute;n de sucursales, n&uacute;meros de contacto, afiliarse al Portal de Consultas de Asegurados y ';
Let  _html_body3 = trim(_html_body3) ||'               descargar nuestro App M&oacute;vil "Anc&oacute;n Clientes" disponible para iOS y Android.';
Let  _html_body3 = trim(_html_body3) ||'			</p>';

Let  _html_body3 = trim(_html_body3) ||'             <p style=" text-align: justify;">';
Let  _html_body3 = trim(_html_body3) ||'             Ay&uacute;denos a mejorar nuestro servicio; es por ello por lo que agradecemos favor complete la siguiente encuesta:';
Let  _html_body3 = trim(_html_body3) ||'             <a href="https://forms.office.com/Pages/ResponsePage.aspx?id=iEoE-rfND0GbV6CST6EclTaBzullj6dEm8AYjUcOw_1UMFRGWTc1VzM3U0dNMkxaWDRDODdUUDlaVi4u">Haz Click Aqu&iacute;</a></p>';


--Let  _html_body3 = trim(_html_body3) ||'            <p>';
--Let  _html_body3 = trim(_html_body3) ||'            	Si desea informaci&oacute;n referente a sus p&oacute;lizas, reclamos, actualizaci&oacute;n de datos u';
--Let  _html_body3 = trim(_html_body3) ||'				otras consultas puede realizarlas a trav&eacute;s de nuestra Web: www.asegurancon.com,';
--Let  _html_body3 = trim(_html_body3) ||'                opci&oacute;n SERVICIO EN LINEA/ANCON ONLINE o llamarnos a nuestra central telef&oacute;nica';
--Let  _html_body3 = trim(_html_body3) ||'                210-8787 o escribanos a info@asegurancon.com que con gusto nuestros agentes';
--Let  _html_body3 = trim(_html_body3) ||'                le estar&aacute;n atendiendo.';
--Let  _html_body3 = trim(_html_body3) ||'            </p>';
Let  _html_body3 = trim(_html_body3) ||'            <p>&nbsp;</p>';
Let  _html_body3 = trim(_html_body3) ||'            <p>&nbsp;</p>';
Let  _html_body3 = trim(_html_body3) ||'            <p>&iexcl;Gracias por preferirnos!<br>';
Let  _html_body3 = trim(_html_body3) ||'            Nota: Este correo es generado de forma autom&aacute;tica por la Intranet Corporativa. Por favor no responder al remitente.';
Let  _html_body3 = trim(_html_body3) ||'            </p>';
Let  _html_body3 = trim(_html_body3) ||'            ';
Let  _html_body3 = trim(_html_body3) ||'        </td>';
Let  _html_body3 = trim(_html_body3) ||'    </tr>';
Let  _html_body3 = trim(_html_body3) ||'	<tr>';
--Let  _html_body3 = trim(_html_body3) ||'    	<td colspan="2"><img src="https:app.asegurancon.com/imagen/cintillo2.jpg" width="800"></td>';
Let  _html_body3 = trim(_html_body3) ||'    </tr>';
Let  _html_body3 = trim(_html_body3) ||'</table>';
Let  _html_body3 = trim(_html_body3) ||'</body>';
Let  _html_body3 = trim(_html_body3) ||'</html>';
  {
	Update parmailsend 
	   set html_body	= _html_body1
	 where secuencia	= a_secuencia;
  }	 

return _html_body1,_html_body2,_html_body3  with resume;

END FOREACH;
--trace off;
END PROCEDURE


--1154 -- <!doctype html><html><head><meta charset="utf-8"><title>Reclamo</title></head><body style="font-family:Arial; font-size:14px; text-align:justify;"><table width="800">	<tr>    	<td colspan="2"><img src="https:app.asegurancon.com/imagen/cintillo1.jpg" width="800"></td>    </tr>    <tr>    	<td width="200">        	Nombre del Asegurado:        </td>        <td width="400">       		ARYS ABDIEL RANGEL CAÑIZALES        </td>    </tr>    <tr>    	<td width="200">       		P&oacute;liza:        </td>        <td width="400">       		0215-00242-12        </td>    </tr>    <tr>    	<td width="200">        	Fecha del Siniestro:        </td>        <td width="400">       		15/09/2016        </td>    </tr>    <tr>    	<td width="200">        	No. de Unidad:        </td>        <td width="400">       		00003        </td>    </tr>    <tr>    	<td colspan="2">        	<p>        	Estimado cliente, Aseguradora Anc&oacute;n le informa que su reclamo ha sido recibido e            ingresado en nuestro sistema. Su n&uacute;mero de Tramite es: 75438     . Muy pronto ser&aacute;            atendido por personal del Departamento de Reclamos de Autom&oacute;vil.	
--1842 -- </p>        </td>    </tr>    <tr>    	<td colspan="2">        	<p>        	 	Adjunto encontrar&aacute; una gu&iacute;a para conocer los documentos necesarios para el tr&aacute;mite             	de su reclamo sea m&aacute;s expedito seg&uacute;n la cobertura afectada.            </p>            <p>            	En caso que aplique pago a deducible Ud. podr&aacute; realizarlo a trav&eacute;s de nuestras oficinas				a nivel nacional, as&iacute; como tambi&eacute;n en los diferentes centros de pago, recuerde            	presentar el slip al momento de presentarse en algunas de nuestras oficinas.            </p>            <p>               Si usted desea solicitar el servicio de Asistencia Legal es necesario completar y firmar               en original el Poder Legal que encontrar&aacute; adunto, el mismo podr&aacute; enviarlo a trav&eacute;s de su               corredor de seguros o dejarlo en algunas de nuestras oficinas a nivel nacional.			</p>            <p>            	Si desea informaci&oacute;n referente a sus p&oacute;lizas, reclamos, actualizaci&oacute;n de datos u				otras consultas puede realizarlas a trav&eacute;s de nuestra Web: www.asegurancon.com,                opci&oacute;n SERVICIO EN LINEA/ANCON ONLINE o llamarnos a nuestra central telef&oacute;nica                210-8787 o escribanos a info@asegurancon.com que con gusto nuestros agentes                le estar&aacute;n atendiendo.            </p>            <p>&nbsp;</p>            <p>&nbsp;</p>            <p>&iexcl;Gracias por preferirnos!<br>            Nota: Este correo es generado de forma autom&aacute;tica por la Intranet Corporativa. Por favor no responder al remitente.            </p>        </td>    </tr>	<tr>    	<td colspan="2"><img src="https:app.asegurancon.com/imagen/cintillo2.jpg" width="800"></td>    </tr></table></body></html>		
