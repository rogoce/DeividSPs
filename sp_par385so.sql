-- Procedimiento que Genera el Html Body 
-- Creado : 21/06/2024 - Autor: Amado Perez - Asegurado solo, los buenos
Drop procedure sp_par385so; 
CREATE PROCEDURE "informix".sp_par385so(  
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
define v_vigenciainicial	date;
define v_aumento            dec(5,2);
define v_montoaumento       dec(16,2);
define v_prima_actual       dec(16,2);
define v_prima_nueva        dec(16,2);
define v_porcbandaedad      dec(5,2);
define v_montobandaedad     dec(16,2);
define v_porcsiniest        dec(5,2);
define v_montosiniest       dec(16,2);
define v_corredor           varchar(200);
define v_contratante        varchar(100);

define a_no_documento      char(20);
define a_cod_asegurado      char(10);


define v_no_unidad			char(5);
define v_no_tramite			char(10);
define 	_no_solicitud		CHAR(50);
define v_placa              char(10);

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return 0,0,0;
end exception

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_par385.trc"; 
--trace on;
drop table if exists temp_carta;

Let  _html_body1 = '';
Let  _html_body2 = '';
Let  _html_body3 = '';

	Select no_remesa,
	       no_documento
	  into a_cod_asegurado,
	       a_no_documento
	  from parmailcomp
	 where mail_secuencia = a_secuencia; 

FOREACH 
      select NVL(asegurado,''),
			NVL(poliza,''),
			vigenciainicial,
			NVL(aumento,''),
			NVL(montoaumento,''),
			NVL(prima_actual,''),
			prima_nueva,
			porcbandaedad,
			montobandaedad,
			porcsiniest,
			montosiniest,
			corredor,
			contratante
	   into v_asegurado,
			v_no_documento,
			v_vigenciainicial,
			v_aumento,
			v_montoaumento,
			v_prima_actual,
			v_prima_nueva,
			v_porcbandaedad,
			v_montobandaedad,
			v_porcsiniest,
			v_montosiniest,
			v_corredor,
			v_contratante			
       from deivid_tmp:carta84
	  where poliza = a_no_documento
	    and codasegurado = a_cod_asegurado
	  --order by no_documento
	  
let v_porcbandaedad = v_porcbandaedad * 100;	
let v_porcsiniest = v_porcsiniest * 100;  
let v_aumento = v_aumento * 100;
		
if v_contratante is null or trim(v_contratante) = "" then
	let v_contratante = v_asegurado;
end if
	  
Let  _html_body1 = trim(_html_body1) || '<!doctype html>';
Let  _html_body1 = trim(_html_body1) ||'<html>';
Let  _html_body1 = trim(_html_body1) ||'<head>';
Let  _html_body1 = trim(_html_body1) ||'<meta charset="utf-8">';
Let  _html_body1 = trim(_html_body1) ||'<title>Reclamo</title>';
Let  _html_body1 = trim(_html_body1) ||'</head>';

Let  _html_body1 = trim(_html_body1) ||'<body style="font-family:Arial; font-size:14px; text-align:justify;">';
Let  _html_body1 = trim(_html_body1) ||'<table width="800">';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
--Let  _html_body1 = trim(_html_body1) ||'<td colspan="2" align="center"><img src="https://img.mailinblue.com/5827580/images/content_library/original/6438571f2d9c7d48ae0b12a2.png"';
--Let  _html_body1 = trim(_html_body1) ||'width="200" border="0" style="display: block; width: 50%;"></td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td width="600">';
Let  _html_body1 = trim(_html_body1) ||'        	Panama, 24 de junio de 2024.';

Let  _html_body1 = trim(_html_body1) ||'<p>&nbsp;</p>';

Let  _html_body1 = trim(_html_body1) ||'</td>';

Let  _html_body1 = trim(_html_body1) ||'</tr>';

Let  _html_body1 = trim(_html_body1) ||'<tr>';

Let  _html_body1 = trim(_html_body1) ||'<td width="600">';

Let  _html_body1 = trim(_html_body1) ||'        	Sr./Sra.';

Let  _html_body1 = trim(_html_body1) ||'</td>';

Let  _html_body1 = trim(_html_body1) ||'</tr>';

Let  _html_body1 = trim(_html_body1) ||'<tr>';

Let  _html_body1 = trim(_html_body1) ||'<td width="600">';

Let  _html_body1 = trim(_html_body1) ||'        	'||v_contratante;

Let  _html_body1 = trim(_html_body1) ||'</td>';

Let  _html_body1 = trim(_html_body1) ||'</tr>';

Let  _html_body1 = trim(_html_body1) ||'<tr>';

Let  _html_body1 = trim(_html_body1) ||'<td width="600">';

Let  _html_body1 = trim(_html_body1) ||'        	Ciudad';

Let  _html_body1 = trim(_html_body1) ||'<p>&nbsp;</p>';

Let  _html_body1 = trim(_html_body1) ||'</td>';

Let  _html_body1 = trim(_html_body1) ||'</tr>';

Let  _html_body1 = trim(_html_body1) ||'<tr>';

Let  _html_body1 = trim(_html_body1) ||'<td width="600">';

Let  _html_body1 = trim(_html_body1) ||'        	Ref.: Su p&oacute;liza de Salud Nro. '||v_no_documento||' - '||v_asegurado;

Let  _html_body1 = trim(_html_body1) ||'</td>';

Let  _html_body1 = trim(_html_body1) ||'</tr>';	

Let  _html_body1 = trim(_html_body1) ||'<tr>';

Let  _html_body1 = trim(_html_body1) ||'<td width="600">';

 Let  _html_body1 = trim(_html_body1) ||'       	Estimado Sr./Sra. '||v_contratante;

Let  _html_body1 = trim(_html_body1) ||'<p>&nbsp;</p>';

Let  _html_body1 = trim(_html_body1) ||'</td>';

Let  _html_body1 = trim(_html_body1) ||'</tr>';
 
Let  _html_body1 = trim(_html_body1) ||'    <tr>';

Let  _html_body1 = trim(_html_body1) ||'<td colspan="2">';

Let  _html_body1 = trim(_html_body1) ||'<p>';

Let  _html_body1 = trim(_html_body1) ||'			Nos dirigimos a usted con relaci&oacute;n a su p&oacute;liza de salud Nro. '||v_no_documento||', la cual ha estado en vigencia desde '||v_vigenciainicial||' hasta la fecha actual.';

Let  _html_body1 = trim(_html_body1) ||'</p>';
 
Let  _html_body1 = trim(_html_body1) ||'        	<p>';

Let  _html_body1 = trim(_html_body1) ||'				Durante este tiempo, nos ha complacido brindarle nuestros servicios y asegurarle la protecci&oacute;n que garantiza su ';

Let  _html_body1 = trim(_html_body1) ||'				p&oacute;liza. Cabe destacar, que Aseguradora Anc&oacute;n ha trabajado de manera incansable desde el a&ntilde;o 2019 para sostener ';

Let  _html_body1 = trim(_html_body1) ||'				y no desmejorar los precios de todos sus programas de seguros de salud y brindarle el servicio relacionado a los ';

Let  _html_body1 = trim(_html_body1) ||'				mismos con la excelent&iacute;sima calidad que usted merece. Sin embargo, una inflaci&oacute;n m&eacute;dica anual galopante en el ';

Let  _html_body2 = trim(_html_body2) ||'				pa&iacute;s que ronda el 15% promedio por a&ntilde;o y que desde el 2019 a la fecha ha Acumulado un 75.00% de incremento en ';

Let  _html_body2 = trim(_html_body2) ||'				los precios, hace insostenible el mantenimiento de su prima actual, y por lo cual nos vemos obligados a aumentar ';

Let  _html_body2 = trim(_html_body2) ||'				la misma, <span style="text-decoration: underline;">lo cual ha sido autorizado por la Superintendencia de Seguros y Reaseguros de Panam&aacute; mediante la ';

Let  _html_body2 = trim(_html_body2) ||'				Resoluci&oacute;n Nro. DRLA-043 de 27 de mayo de 2024.</span> ';

Let  _html_body2 = trim(_html_body2) ||'</p>';

Let  _html_body2 = trim(_html_body2) ||'<p>';

Let  _html_body2 = trim(_html_body2) ||'				Por lo tanto, a partir del 01 de agosto del presente a&ntilde;o, la prima mensual de su p&oacute;liza experimentar&aacute; un aumento del ';

Let  _html_body2 = trim(_html_body2) ||'				'||v_aumento||'%,  equivalente a B/. '||v_montoaumento||',  pasando de B/. '||v_prima_actual||' a B/. '||v_prima_nueva||', sin impuesto incluido. ';

Let  _html_body2 = trim(_html_body2) ||'</p>';

Let  _html_body2 = trim(_html_body2) ||'<p>';

Let  _html_body2 = trim(_html_body2) ||' 				Adicionalmente, le informamos que a partir de agosto aplicara la nueva Red de proveedores Red Ancón Premier Care a su plan de seguro actual, '; 

Let  _html_body2 = trim(_html_body2) ||'				por lo que durante el mes de julio le haremos llegar el nuevo carnet de salud actualizado con la Red Premier Care a través de su corredor de seguros. ';

Let  _html_body2 = trim(_html_body2) ||'				La Red Ancón Premier Care es una red premium de alcance nacional en todas las especialidades médicas y clínicas de donde podrá elegir entre las ';

Let  _html_body2 = trim(_html_body2) ||'				alternativas que considere se adaptan a sus necesidades, y estará disponible a partir del 28 de junio en nuestra página web con la lista de ';

Let  _html_body2 = trim(_html_body2) ||'				proveedores participantes, a través del siguiente link: <a href="https://app.asegurancon.com/documentos/proveedores_medicos/proovedores_care.php?pid=1"> .:Red de Salud - Premier Care:. (asegurancon.com). ';

Let  _html_body2 = trim(_html_body2) ||'</p>';

Let  _html_body2 = trim(_html_body2) ||'<p>';

Let  _html_body2 = trim(_html_body2) ||'				Reconocemos que este cambio puede resultar inesperado, pero resulta necesario para as&iacute; mantener la calidad y la ';

Let  _html_body2 = trim(_html_body2) ||'				efectividad de las coberturas contenidas en su programa de seguro.  Queremos asegurarle que su ';

Let  _html_body2 = trim(_html_body2) ||'				lealtad y confianza son de gran valor para nosotros y en este caso, su corredor de confianza o nuestro departamento ';

Let  _html_body2 = trim(_html_body2) ||'				de comercializaci&oacute;n con todo gusto le ampliara estas opciones. ';

Let  _html_body2 = trim(_html_body2) ||'</p>';

Let  _html_body2 = trim(_html_body2) ||'<p>';

Let  _html_body2 = trim(_html_body2) ||'				Agradecemos sinceramente su comprensi&oacute;n y su continua confianza en nuestra empresa. Esperamos seguir ';

Let  _html_body3 = trim(_html_body3) ||'				siendo su socio de confianza en materia de seguros de salud durante muchos a&ntilde;os m&aacute;s. ';

Let  _html_body3 = trim(_html_body3) ||'</p>';

Let  _html_body3 = trim(_html_body3) ||'<p>Para cualquier consulta adicional quedamos a sus &oacute;rdenes en los siguientes contactos: </p>';

Let  _html_body2 = trim(_html_body2) ||'<p>';

Let  _html_body3 = trim(_html_body3) ||'				Tel&eacute;fono 210-8700';

Let  _html_body3 = trim(_html_body3) ||'</p>';

Let  _html_body2 = trim(_html_body2) ||'<p>';

Let  _html_body3 = trim(_html_body3) ||'				Correo electr&oacute;nico: <a href="mailto:atencionalcliente@asegurancon.com">atencionalcliente@asegurancon.com</a>.';

Let  _html_body3 = trim(_html_body3) ||'</p>';

Let  _html_body3 = trim(_html_body3) ||'<p>Los datos de contacto de la Superintendencia de Seguros y Reaseguros de Panam&aacute; son los siguientes: tel&eacute;fono 524-5817 / 16 / 25 / 32 / 72 / 55; correo electr&oacute;nico: <a href="mailto:proteccion@superseguros.gob.pa"> proteccion@superseguros.gob.pa</a>.</p>';

Let  _html_body3 = trim(_html_body3) ||'<p>Sin otro particular, quedamos de Usted. <br>';

Let  _html_body3 = trim(_html_body3) ||'</p>';

Let  _html_body3 = trim(_html_body3) ||'<p>Atentamente,</p>';

Let  _html_body3 = trim(_html_body3) ||'<p>';

Let  _html_body3 = trim(_html_body3) ||'				Aseguradora Ancon, S.A.';

Let  _html_body3 = trim(_html_body3) ||'</p>';
Let  _html_body3 = trim(_html_body3) ||'<p>';

Let  _html_body3 = trim(_html_body3) ||'				CC: '||v_corredor;

Let  _html_body3 = trim(_html_body3) ||'</p>';
Let  _html_body3 = trim(_html_body3) ||'</td>';

Let  _html_body3 = trim(_html_body3) ||'</tr>';

Let  _html_body3 = trim(_html_body3) ||'</table>';

Let  _html_body3 = trim(_html_body3) ||'</body>';

Let  _html_body3 = trim(_html_body3) ||'</html>	  ';
	  

return _html_body1,_html_body2,_html_body3  with resume;

END FOREACH;
--trace off;
END PROCEDURE


--1154 -- <!doctype html><html><head><meta charset="utf-8"><title>Reclamo</title></head><body style="font-family:Arial; font-size:14px; text-align:justify;"><table width="800">	<tr>    	<td colspan="2"><img src="https:app.asegurancon.com/imagen/cintillo1.jpg" width="800"></td>    </tr>    <tr>    	<td width="200">        	Nombre del Asegurado:        </td>        <td width="400">       		ARYS ABDIEL RANGEL CAÑIZALES        </td>    </tr>    <tr>    	<td width="200">       		P&oacute;liza:        </td>        <td width="400">       		0215-00242-12        </td>    </tr>    <tr>    	<td width="200">        	Fecha del Siniestro:        </td>        <td width="400">       		15/09/2016        </td>    </tr>    <tr>    	<td width="200">        	No. de Unidad:        </td>        <td width="400">       		00003        </td>    </tr>    <tr>    	<td colspan="2">        	<p>        	Estimado cliente, Aseguradora Anc&oacute;n le informa que su reclamo ha sido recibido e            ingresado en nuestro sistema. Su n&uacute;mero de Tramite es: 75438     . Muy pronto ser&aacute;            atendido por personal del Departamento de Reclamos de Autom&oacute;vil.	
--1842 -- </p>        </td>    </tr>    <tr>    	<td colspan="2">        	<p>        	 	Adjunto encontrar&aacute; una gu&iacute;a para conocer los documentos necesarios para el tr&aacute;mite             	de su reclamo sea m&aacute;s expedito seg&uacute;n la cobertura afectada.            </p>            <p>            	En caso que aplique pago a deducible Ud. podr&aacute; realizarlo a trav&eacute;s de nuestras oficinas				a nivel nacional, as&iacute; como tambi&eacute;n en los diferentes centros de pago, recuerde            	presentar el slip al momento de presentarse en algunas de nuestras oficinas.            </p>            <p>               Si usted desea solicitar el servicio de Asistencia Legal es necesario completar y firmar               en original el Poder Legal que encontrar&aacute; adunto, el mismo podr&aacute; enviarlo a trav&eacute;s de su               corredor de seguros o dejarlo en algunas de nuestras oficinas a nivel nacional.			</p>            <p>            	Si desea informaci&oacute;n referente a sus p&oacute;lizas, reclamos, actualizaci&oacute;n de datos u				otras consultas puede realizarlas a trav&eacute;s de nuestra Web: www.asegurancon.com,                opci&oacute;n SERVICIO EN LINEA/ANCON ONLINE o llamarnos a nuestra central telef&oacute;nica                210-8787 o escribanos a info@asegurancon.com que con gusto nuestros agentes                le estar&aacute;n atendiendo.            </p>            <p>&nbsp;</p>            <p>&nbsp;</p>            <p>&iexcl;Gracias por preferirnos!<br>            Nota: Este correo es generado de forma autom&aacute;tica por la Intranet Corporativa. Por favor no responder al remitente.            </p>        </td>    </tr>	<tr>    	<td colspan="2"><img src="https:app.asegurancon.com/imagen/cintillo2.jpg" width="800"></td>    </tr></table></body></html>		
