-- Procedimiento que Genera el Html Body para las notificaciones de reclamos 
-- Reclamos no abiertos de cobertura completa
-- Creado : 13/09/2023 - Autor: Federico Coronado
Drop procedure sp_par381; 
CREATE PROCEDURE "informix".sp_par381(  
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
define v_no_asiges			char(20);
define 	_no_solicitud		CHAR(50);
define v_placa              char(10);
define v_no_poliza          char(10);

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return 0,0,0;
end exception

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_par381.trc"; 
--trace on;
drop table if exists temp_carta;

Let  _html_body1 = '';
Let  _html_body2 = '';
Let  _html_body3 = '';

let v_no_poliza = 0;
let _siguiente = 0;

     create temp table temp_carta(
			asegurado	varchar(50), 
			no_documento	char(13),
			fecha_siniestro	date,
			no_unidad	char(5),
			no_asiges	char(20),
			placa       char(10)
			) with no log;															 
	create index idx1_temp_carta on temp_carta(no_documento);
    create index idx2_temp_carta on temp_carta(no_unidad);		
	create index idx3_temp_carta on temp_carta(no_asiges);		

foreach
	Select no_remesa, asegurado
	  into v_no_poliza, v_no_asiges
	  from parmailcomp
	 where mail_secuencia = a_secuencia  
	 exit foreach;
end foreach
	 
	 FOREACH 
		select c.nombre,
		       b.no_documento, 
			   b.fecha_siniestro,
			   b.no_unidad,
			   b.no_asiges,
			   e.placa
		  into v_asegurado,
			   v_no_documento,
			   v_fecha_siniestro,
			   v_no_unidad,
			   v_no_asiges,
			   v_placa
		  from emipomae a inner join recpanasi b on a.no_documento = b.no_documento
		  inner join cliclien c on a.cod_contratante = c.cod_cliente
		  inner join emiauto d on a.no_poliza = d.no_poliza
		  inner join emivehic e on e.no_motor = d.no_motor
		  where a.no_poliza = v_no_poliza and b.no_asiges = v_no_asiges
			INSERT INTO temp_carta 
			VALUES  (v_asegurado,
					v_no_documento,
					v_fecha_siniestro,
					v_no_unidad,
					v_no_asiges,
					v_placa
					);				
	END FOREACH;

FOREACH 
      select NVL(asegurado,''),
			NVL(no_documento,''),
			fecha_siniestro,
			NVL(no_unidad,''),
			NVL(no_asiges,''),
			NVL(placa,'')
	   into v_asegurado,
			v_no_documento,
			v_fecha_siniestro,
			v_no_unidad,
			v_no_asiges,
			v_placa
       from temp_carta
	  --order by no_documento
	  
Let  _html_body1 = trim(_html_body1) ||'<!doctype html>';
Let  _html_body1 = trim(_html_body1) ||'<html>';
Let  _html_body1 = trim(_html_body1) ||'<head>';
Let  _html_body1 = trim(_html_body1) ||'<meta charset="utf-8">';
Let  _html_body1 = trim(_html_body1) ||'<title>Notificaci&oacute;n</title>';
Let  _html_body1 = trim(_html_body1) ||'</head>';
Let  _html_body1 = trim(_html_body1) ||'<body style="font-family:Arial; font-size:14px; text-align:justify;">';
Let  _html_body1 = trim(_html_body1) ||'<table width="800">';
Let  _html_body1 = trim(_html_body1) ||'	<tr>';

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
Let  _html_body1 = trim(_html_body1) ||'        	Estimado asegurado, le informamos que hemos recibido notificaci&oacute;n de un reclamo. Su n&uacute;mero';
Let  _html_body1 = trim(_html_body1) ||'            de Asistencia es: <b>'||trim(v_no_asiges)||'.</b><br>';
Let  _html_body1 = trim(_html_body1) ||' 			Adjunto encontrar&aacute; los requisitos para presentar su reclamo; y este sea atendido de forma expedita seg&uacute;n la cobertura afectada.';  

Let  _html_body2 = trim(_html_body2) ||'            </p><br>';
Let  _html_body2 = trim(_html_body2) ||'        </td>';
Let  _html_body2 = trim(_html_body2) ||'    </tr>';
Let  _html_body2 = trim(_html_body2) ||'    <tr>';
Let  _html_body2 = trim(_html_body2) ||'    	<td colspan="2">';
--Let  _html_body2 = trim(_html_body2) ||'        	<p style=" text-align: justify;">';
--Let  _html_body2 = trim(_html_body2) ||'        		Adjunto encontrar&aacute; una gu&iacute;a para conocer los documentos necesarios para el tr&aacute;mite de su reclamo sea m&aacute;s expedito seg&uacute;n la cobertura afectada.';
--Let  _html_body2 = trim(_html_body2) ||'            </p>';
Let  _html_body2 = trim(_html_body2) ||'            <p style=" text-align: justify;">';
Let  _html_body2 = trim(_html_body2) ||'				En caso que aplique pago a deducible, Ud. podr&aacute; realizarlo a trav&eacute;s de nuestras sucursales';
Let  _html_body2 = trim(_html_body2) ||'				a nivel nacional, as&iacute; como tambi&eacute;n en Banca en L&iacute;nea de Banco General, con su n&uacute;mero de tr&aacute;mite una vez haya formalizado su reclamo ante nuestras oficinas.';
Let  _html_body2 = trim(_html_body2) ||'			</p>';
Let  _html_body2 = trim(_html_body2) ||'            <p style=" text-align: justify;">';
Let  _html_body2 = trim(_html_body2) ||'               Si usted desea solicitar el servicio de Asistencia Legal es necesario completar y firmar en original el Poder Legal ';
Let  _html_body2 = trim(_html_body2) ||'               adjunto, el mismo debe ser impreso en hoja tama&ntilde;o Legal (8 &frac12; x 14), en dos ejemplares los que podr&aacute;  enviarlos ';
Let  _html_body2 = trim(_html_body2) ||'               a trav&eacute;s de su corredor de seguros o entregarlo en nuestras  sucursales a nivel nacional en horario de lunes a viernes de 8:00 a.m. a 5:00 p.m. y los '; 
Let  _html_body2 = trim(_html_body2) ||' 			   d&iacute;as s&aacute;bados  de 9:00 a.m. a 12:00 p.m., adjuntando copia de c&eacute;dula o pasaporte del conductor, copia de licencia del ';
Let  _html_body2 = trim(_html_body2) ||' 			   conductor y copia de la boleta (colilla) de  tr&aacute;nsito.';
Let  _html_body2 = trim(_html_body2) ||'               Estos documentos deben presentarse en la aseguradora, al menos  &nbsp;tres (3) d&iacute;as h&aacute;biles antes de la fecha de la audiencia.';
Let  _html_body2 = trim(_html_body2) ||'			</p>';

Let  _html_body3 = trim(_html_body3) ||'            <p style=" text-align: justify;">';
Let  _html_body3 = trim(_html_body3) ||'               Le invitamos a ingresar a nuestros <a href="https://linktr.ee/asegurancon">Canales de atenci&oacute;n</a> donde podr&aacute; acceder a nuestra p&aacute;gina web, redes ';
Let  _html_body3 = trim(_html_body3) ||'               sociales, ubicaci&oacute;n de sucursales, n&uacute;meros de contacto, afiliarse al Portal de Consultas de Asegurados y ';
Let  _html_body3 = trim(_html_body3) ||'               descargar nuestro App M&oacute;vil "Anc&oacute;n Clientes" disponible para iOS y Android.<br>';
Let  _html_body3 = trim(_html_body3) ||'               Ay&uacute;denos a mejorar nuestro servicio; es por ello por lo que agradecemos favor complete la siguiente encuesta:';
Let  _html_body3 = trim(_html_body3) ||'             <a href="https://forms.office.com/Pages/ResponsePage.aspx?id=iEoE-rfND0GbV6CST6EclTaBzullj6dEm8AYjUcOw_1UMFRGWTc1VzM3U0dNMkxaWDRDODdUUDlaVi4u">Haz Click Aqu&iacute;</a></p>';

Let  _html_body3 = trim(_html_body3) ||'            <p>&nbsp;</p>';
Let  _html_body3 = trim(_html_body3) ||'            <p>&iexcl;Gracias por preferirnos!<br>';
Let  _html_body3 = trim(_html_body3) ||'            Nota: Este correo es generado de forma autom&aacute;tica por la Intranet Corporativa. Por favor no responder al remitente.';
Let  _html_body3 = trim(_html_body3) ||'            </p>';
Let  _html_body3 = trim(_html_body3) ||'            ';
Let  _html_body3 = trim(_html_body3) ||'        </td>';
Let  _html_body3 = trim(_html_body3) ||'    </tr>';
Let  _html_body3 = trim(_html_body3) ||'	<tr>';

Let  _html_body3 = trim(_html_body3) ||'    </tr>';
Let  _html_body3 = trim(_html_body3) ||'</table>';
Let  _html_body3 = trim(_html_body3) ||'</body>';
Let  _html_body3 = trim(_html_body3) ||'</html>'; 

return _html_body1,_html_body2,_html_body3  with resume;

END FOREACH;
--trace off;
END PROCEDURE
