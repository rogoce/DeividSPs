-- Procedimiento que Genera el Html Body 
-- Creado : 14/09/2016 - Autor: Henry Giron 
Drop procedure sp_par386b; 
CREATE PROCEDURE "informix".sp_par386b(  
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

define v_anosreclamos       smallint;
define v_siniest_acumulada  dec(16,2);
define _fecha_letra         varchar(25); 
define v_opcion             smallint;

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return 0,0,0;
end exception

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_par385.trc"; 
--trace on;


Let  _html_body1 = '';
Let  _html_body2 = '';
Let  _html_body3 = '';

--	Select no_remesa,
--	       no_documento
--	  into a_cod_asegurado,
--	       a_no_documento
--	  from parmailcomp
--	 where mail_secuencia = a_secuencia; 

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
			anosreclamos,
			siniest_acumulada,
			contratante,
			opcion
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
			v_anosreclamos,
			v_siniest_acumulada,
			v_contratante,
			v_opcion
       from deivid_tmp:carta16dep
	  where secuencia = a_secuencia
	  --  and codasegurado = a_cod_asegurado
	  --order by no_documento
	  
let v_aumento = v_aumento * 100;	  
let v_porcbandaedad = v_porcbandaedad * 100;	  
let v_porcsiniest = v_porcsiniest * 100;	
let v_siniest_acumulada = v_siniest_acumulada * 100;  
let _fecha_letra = sp_fecha_letra(today);	  

Let  _html_body1 = trim(_html_body1) || '<!doctype html>';

Let  _html_body1 = trim(_html_body1) || '<html>';

Let  _html_body1 = trim(_html_body1) || '<head>';

Let  _html_body1 = trim(_html_body1) || '<meta charset="utf-8">';

Let  _html_body1 = trim(_html_body1) || '<title>Reclamo</title>';

Let  _html_body1 = trim(_html_body1) || '</head>';

Let  _html_body1 = trim(_html_body1) || '<body style="font-family:Arial; font-size:14px; text-align:justify;">';

Let  _html_body1 = trim(_html_body1) || '<table width="800">';

Let  _html_body1 = trim(_html_body1) || '<tr>';

--Let  _html_body1 = trim(_html_body1) ||'<td colspan="2" align="center"><img src="https://img.mailinblue.com/5827580/images/content_library/original/6438571f2d9c7d48ae0b12a2.png"';
--Let  _html_body1 = trim(_html_body1) ||'width="200" border="0" style="display: block; width: 50%;"></td>';

Let  _html_body1 = trim(_html_body1) || '</tr>';

Let  _html_body1 = trim(_html_body1) || '<tr>';

Let  _html_body1 = trim(_html_body1) || '<td width="600">';

Let  _html_body1 = trim(_html_body1) || '        	Panama, '|| trim(lower(_fecha_letra)) ||'.';

Let  _html_body1 = trim(_html_body1) || '<p>&nbsp;</p>';

Let  _html_body1 = trim(_html_body1) || '</td>';

Let  _html_body1 = trim(_html_body1) || '</tr>';

Let  _html_body1 = trim(_html_body1) || '<tr>';

Let  _html_body1 = trim(_html_body1) || '<td width="600">';

Let  _html_body1 = trim(_html_body1) || '        	Sr./Sra.';

Let  _html_body1 = trim(_html_body1) || '</td>';

Let  _html_body1 = trim(_html_body1) || '</tr>';

Let  _html_body1 = trim(_html_body1) || '<tr>';

Let  _html_body1 = trim(_html_body1) || '<td width="600">';

Let  _html_body1 = trim(_html_body1) || '        	'||v_contratante;

Let  _html_body1 = trim(_html_body1) || '</td>';

Let  _html_body1 = trim(_html_body1) || '</tr>';

Let  _html_body1 = trim(_html_body1) || '<tr>';

Let  _html_body1 = trim(_html_body1) || '<td width="600">';

 Let  _html_body1 = trim(_html_body1) || '       	Ciudad';

Let  _html_body1 = trim(_html_body1) || '<p>&nbsp;</p>';

Let  _html_body1 = trim(_html_body1) || '</td>';

Let  _html_body1 = trim(_html_body1) || '</tr>';

Let  _html_body1 = trim(_html_body1) || '<tr>';

Let  _html_body1 = trim(_html_body1) || '<td width="600">';

Let  _html_body1 = trim(_html_body1) || '        	Ref.: Su p&oacute;liza de Salud Nro. '||v_no_documento;

Let  _html_body1 = trim(_html_body1) || '</td>';

Let  _html_body1 = trim(_html_body1) || '</tr>';	

Let  _html_body1 = trim(_html_body1) || '<tr>';

Let  _html_body1 = trim(_html_body1) || '<td width="600">';

--Let  _html_body1 = trim(_html_body1) || '        	Estimado Sr./Sra. '||v_asegurado;

Let  _html_body1 = trim(_html_body1) || '<p>&nbsp;</p>';

Let  _html_body1 = trim(_html_body1) || '</td>';

Let  _html_body1 = trim(_html_body1) || '</tr>';

Let  _html_body1 = trim(_html_body1) || '    <tr>';

Let  _html_body1 = trim(_html_body1) || '<td colspan="2">';

Let  _html_body1 = trim(_html_body1) || '<p>';

Let  _html_body1 = trim(_html_body1) || '			Nos dirigimos a usted muy respetuosamente en la oportunidad de hacer menci&oacute;n a su p&oacute;liza de salud Nro. '||v_no_documento||', vigente desde el '||v_vigenciainicial||' hasta la fecha actual. ';

Let  _html_body1 = trim(_html_body1) || '</p>';

Let  _html_body1 = trim(_html_body1) || '        	<p>';

Let  _html_body1 = trim(_html_body1) || '				En seguimiento a nuestra carta previa del 28/06/2024, por este medio sometemos a su consideraci&oacute;n la P&oacute;liza de Conversi&oacute;n Opci&oacute;n ' || v_opcion || ' a partir del 01 de agosto 2024 ';

Let  _html_body1 = trim(_html_body1) || '               para usted y su familia, una alternativa que consideramos atiende a su presupuesto, sin desmejorar la calidad y protecci&oacute;n de las coberturas que se les ofrece en su plan de seguro previo, brind&aacute;ndoles la continuidad de cobertura necesaria durante su permanencia o per&iacute;odo de vigencia con nosotros, con un incremento en la prima actual mensual de 9.5%. ';				

Let  _html_body1 = trim(_html_body1) || '</p>';

Let  _html_body1 = trim(_html_body1) || '<p>';

Let  _html_body1 = trim(_html_body1) || '				Incluimos en esta comunicaci&oacute;n el Cuadro de Beneficios detallado y el Cuadro de Primas de su grupo familiar con el 9.5% de incremento al asegurado o asegurados ';

Let  _html_body2 = trim(_html_body2) || '				de su grupo familiar que tengan un porcentaje (%) de siniestralidad hist&oacute;rica (2018-2023) menor al 55.00% y cuyos planes actuales sean Global, Panam&aacute; Plus, Panam&aacute;, Salud Plus, Salud Vital, ';

Let  _html_body2 = trim(_html_body2) || '				Hospitalizaci&oacute;n Plus, Complementario y Complementario Plus. Esta opci&oacute;n se apoya exclusivamente en la Red Anc&oacute;n Premier Care, que nos garantiza un servicio &oacute;ptimo de primer nivel y con ventajas notables para las partes. ';

Let  _html_body2 = trim(_html_body2) || '</p>';

Let  _html_body3 = trim(_html_body3) || '<p>';

Let  _html_body3 = trim(_html_body3) || '				De usted preferirlo, su corredor y/o nuestro dpto. de comercializaci&oacute;n, con todo gusto le ampliara la informaci&oacute;n de esta opci&oacute;n. ';

Let  _html_body3 = trim(_html_body3) || '</p>';

Let  _html_body3 = trim(_html_body3) || '<p>';

Let  _html_body3 = trim(_html_body3) || '				Estamos a la disposici&oacute;n y agradecemos el continuo compromiso con nuestra empresa y, esperamos continuar siendo su aseguradora de confianza en materia de seguros de salud durante muchos a&ntilde;os m&aacute;s. ';

Let  _html_body3 = trim(_html_body3) || '</p>';

Let  _html_body3 = trim(_html_body3) || '<p>			Para cualquier consulta adicional quedamos a sus &oacute;rdenes en los siguientes contactos: ';

Let  _html_body3 = trim(_html_body3) || '				tel&eacute;fono 210-8700 o por correo electr&oacute;nico: <a href="mailto:atencionalcliente@asegurancon.com">atencionalcliente@asegurancon.com</a>.';

Let  _html_body3 = trim(_html_body3) || '</p>';

Let  _html_body3 = trim(_html_body3) || '<p>			Sin otro particular, quedamos de Usted. <br>';

Let  _html_body3 = trim(_html_body3) || '</p>';

Let  _html_body3 = trim(_html_body3) || '<p>Atentamente,</p>';

Let  _html_body3 = trim(_html_body3) || '<p>';

Let  _html_body3 = trim(_html_body3) || '				Aseguradora Ancon, S.A.';

Let  _html_body3 = trim(_html_body3) || '</p>';
Let  _html_body3 = trim(_html_body3) || '<p>';

Let  _html_body3 = trim(_html_body3) || '				CC: '||v_corredor;

Let  _html_body3 = trim(_html_body3) || '</p>';

Let  _html_body3 = trim(_html_body3) || '</td>';

Let  _html_body3 = trim(_html_body3) || '</tr>';

Let  _html_body3 = trim(_html_body3) || '</table>';

Let  _html_body3 = trim(_html_body3) || '</body>';

Let  _html_body3 = trim(_html_body3) || '</html>';
	  	  

return _html_body1,_html_body2,_html_body3  with resume;

END FOREACH;
--trace off;
END PROCEDURE


--1154 -- <!doctype html><html><head><meta charset="utf-8"><title>Reclamo</title></head><body style="font-family:Arial; font-size:14px; text-align:justify;"><table width="800">	<tr>    	<td colspan="2"><img src="https:app.asegurancon.com/imagen/cintillo1.jpg" width="800"></td>    </tr>    <tr>    	<td width="200">        	Nombre del Asegurado:        </td>        <td width="400">       		ARYS ABDIEL RANGEL CAÑIZALES        </td>    </tr>    <tr>    	<td width="200">       		P&oacute;liza:        </td>        <td width="400">       		0215-00242-12        </td>    </tr>    <tr>    	<td width="200">        	Fecha del Siniestro:        </td>        <td width="400">       		15/09/2016        </td>    </tr>    <tr>    	<td width="200">        	No. de Unidad:        </td>        <td width="400">       		00003        </td>    </tr>    <tr>    	<td colspan="2">        	<p>        	Estimado cliente, Aseguradora Anc&oacute;n le informa que su reclamo ha sido recibido e            ingresado en nuestro sistema. Su n&uacute;mero de Tramite es: 75438     . Muy pronto ser&aacute;            atendido por personal del Departamento de Reclamos de Autom&oacute;vil.	
--1842 -- </p>        </td>    </tr>    <tr>    	<td colspan="2">        	<p>        	 	Adjunto encontrar&aacute; una gu&iacute;a para conocer los documentos necesarios para el tr&aacute;mite             	de su reclamo sea m&aacute;s expedito seg&uacute;n la cobertura afectada.            </p>            <p>            	En caso que aplique pago a deducible Ud. podr&aacute; realizarlo a trav&eacute;s de nuestras oficinas				a nivel nacional, as&iacute; como tambi&eacute;n en los diferentes centros de pago, recuerde            	presentar el slip al momento de presentarse en algunas de nuestras oficinas.            </p>            <p>               Si usted desea solicitar el servicio de Asistencia Legal es necesario completar y firmar               en original el Poder Legal que encontrar&aacute; adunto, el mismo podr&aacute; enviarlo a trav&eacute;s de su               corredor de seguros o dejarlo en algunas de nuestras oficinas a nivel nacional.			</p>            <p>            	Si desea informaci&oacute;n referente a sus p&oacute;lizas, reclamos, actualizaci&oacute;n de datos u				otras consultas puede realizarlas a trav&eacute;s de nuestra Web: www.asegurancon.com,                opci&oacute;n SERVICIO EN LINEA/ANCON ONLINE o llamarnos a nuestra central telef&oacute;nica                210-8787 o escribanos a info@asegurancon.com que con gusto nuestros agentes                le estar&aacute;n atendiendo.            </p>            <p>&nbsp;</p>            <p>&nbsp;</p>            <p>&iexcl;Gracias por preferirnos!<br>            Nota: Este correo es generado de forma autom&aacute;tica por la Intranet Corporativa. Por favor no responder al remitente.            </p>        </td>    </tr>	<tr>    	<td colspan="2"><img src="https:app.asegurancon.com/imagen/cintillo2.jpg" width="800"></td>    </tr></table></body></html>		
