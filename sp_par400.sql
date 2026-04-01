-- Procedimiento que Genera el Html Body 
-- Pago de reclamos por cheques
-- Creado : 07/05/2018 - Autor: Amado Perez 
Drop procedure sp_par400; 
CREATE PROCEDURE "informix".sp_par400(  
a_secuencia	INTEGER 
)returning	Lvarchar(max); 

Define _html_body1	 Lvarchar(max); -- char(512); 
Define _html_body2	 Lvarchar(max); -- char(512); 
--Define _html_body3	 Lvarchar(max); -- char(512); 

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
define _no_tranrec          char(10);
define _monto               dec(16,2);
define _monto2              money(16,2);
define v_monto              varchar(25);
define _nombre              varchar(100);
define _no_reclamo          char(10);
define _cod_cliente         char(10);
define _no_tramite          char(10);
define _user_added          char(8);
define _desc_transaccion    varchar(60);
define _ajustador           varchar(50);
define _e_mail              varchar(50);
define _cod_concepto        char(3);
define _concepto            varchar(50);
define _no_factura          char(10);
define _cod_tipopago        char(3);

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return 0;
end exception

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_par374.trc"; 
--trace on;
drop table if exists temp_carta;

Let  _html_body1 = '';
Let  _html_body2 = '';
--Let  _html_body3 = '';

let _no_solicitud = 0;
let _siguiente = 0;

--let _html_body2 = sp_html01();

select no_remesa
  into _no_tranrec
  from parmailcomp
 where mail_secuencia = a_secuencia;
 
 let _no_tranrec = '2310716';
 
select no_reclamo,
       cod_cliente,
	   user_added,
	   no_factura,
	   cod_tipopago
  into _no_reclamo,
       _cod_cliente,
	   _user_added,
	   _no_factura,
	   _cod_tipopago
  from rectrmae
 where no_tranrec = _no_tranrec;

if _no_factura is null then
	let _no_factura = 'PRUEBA';
end if

 select no_tramite
   into _no_tramite
   from recrcmae
  where no_reclamo = _no_reclamo;
  
 select nombre
   into _nombre
   from cliclien
  where cod_cliente = _cod_cliente;
  
 select descripcion,
        e_mail
   into _ajustador,
        _e_mail
   from insuser
  where usuario = _user_added;
  
if _cod_tipopago = '001'  then
	 
	Let  _html_body1 = trim(_html_body1) ||'<!doctype html>';
	Let  _html_body1 = trim(_html_body1) ||'<html>';
	Let  _html_body1 = trim(_html_body1) ||'<head>';
	Let  _html_body1 = trim(_html_body1) ||'<meta charset="utf-8">';
	Let  _html_body1 = trim(_html_body1) ||'<title>Reclamo</title>';
	Let  _html_body1 = trim(_html_body1) ||'</head>';
	Let  _html_body1 = trim(_html_body1) ||'<body style="font-family:Arial; text-align:justify;">';  --font-size:14px;
	Let  _html_body1 = trim(_html_body1) ||'<table width="800">';
	Let  _html_body1 = trim(_html_body1) ||'<tr>';
	Let  _html_body1 = trim(_html_body1) ||'<td><p style="margin:1px; padding:1px;">Por este medio les informamos que el pago correspondiente a la <b>Factura Nro: ' || trim(_no_factura) || '</b> ha sido aprobado, y el mismo se estar&aacute; ';
	Let  _html_body1 = trim(_html_body1) ||' realizando en un plazo m&aacute;ximo de cinco (05) d&iacute;as h&aacute;biles. Por tal motivo, les agradecemos se sirvan confirmarnos la recepci&oacute;n del pago a nuestro buz&oacute;n de correo electr&oacute;nico: reclamospatrimoniales@asegurancon.com.</p></td>';
	Let  _html_body1 = trim(_html_body1) ||'</tr>';

	Let  _html_body1 = trim(_html_body1) ||'<tr>';
	Let  _html_body1 = trim(_html_body1) ||'<td>';
	Let  _html_body1 = trim(_html_body1) ||'<p>';
	Let  _html_body1 = trim(_html_body1) ||'Quedamos a la espera de lo solicitado y muchas gracias de antemano.';
	Let  _html_body1 = trim(_html_body1) ||'</p>';
	Let  _html_body1 = trim(_html_body1) ||'</td>';
	Let  _html_body1 = trim(_html_body1) ||'</tr>';
	Let  _html_body1 = trim(_html_body1) ||'<tr>';
	Let  _html_body1 = trim(_html_body1) ||'<td>';
	Let  _html_body1 = trim(_html_body1) ||'<p>';
	Let  _html_body1 = trim(_html_body1) ||'Saludos,';
	Let  _html_body1 = trim(_html_body1) ||'</p>';
	Let  _html_body1 = trim(_html_body1) ||'</td>';
	Let  _html_body1 = trim(_html_body1) ||'</tr>';
	Let  _html_body1 = trim(_html_body1) ||'<tr>';
	Let  _html_body1 = trim(_html_body1) ||'<td>';
	Let  _html_body1 = trim(_html_body1) ||'<p>';
	Let  _html_body1 = trim(_html_body1) ||'Gerencia de Ramos Patrimoniales.';
	Let  _html_body1 = trim(_html_body1) ||'</p>';
	Let  _html_body1 = trim(_html_body1) ||'</td>';
	Let  _html_body1 = trim(_html_body1) ||'</tr>';
	Let  _html_body1 = trim(_html_body1) ||'</table>';
	Let  _html_body1 = trim(_html_body1) ||'</body>';
	Let  _html_body1 = trim(_html_body1) ||'</html>';
else
	Let  _html_body1 = trim(_html_body1) ||'<!doctype html>';
	Let  _html_body1 = trim(_html_body1) ||'<html>';
	Let  _html_body1 = trim(_html_body1) ||'<head>';
	Let  _html_body1 = trim(_html_body1) ||'<meta charset="utf-8">';
	Let  _html_body1 = trim(_html_body1) ||'<title>Reclamo</title>';
	Let  _html_body1 = trim(_html_body1) ||'</head>';
	Let  _html_body1 = trim(_html_body1) ||'<body style="font-family:Arial; text-align:justify;">';  --font-size:14px;
	Let  _html_body1 = trim(_html_body1) ||'<table width="800">';
	Let  _html_body1 = trim(_html_body1) ||'<tr>';
	Let  _html_body1 = trim(_html_body1) ||'<td><p style="margin:1px; padding:1px;">Por este medio les informamos que el pago correspondiente al reclamo en referencia ha sido aprobado. Por tal motivo, para proceder con la transferencia ';
	Let  _html_body1 = trim(_html_body1) ||' agradecemos se sirvan hacernos llegar al buz&oacute;n de correo electr&oacute;nico: reclamospatrimoniales@asegurancon.com, la siguiente documentaci&oacute;n:</p></td>';
	Let  _html_body1 = trim(_html_body1) ||'</tr>';
	Let  _html_body1 = trim(_html_body1) ||'<table width=" 80%">';
	Let  _html_body1 = trim(_html_body1) ||'<tr>';
	Let  _html_body1 = trim(_html_body1) ||'<th colspan="2"></th>';
	Let  _html_body1 = trim(_html_body1) ||'</tr>';
	Let  _html_body1 = trim(_html_body1) ||'<td></td>';	
	Let  _html_body1 = trim(_html_body1) ||'<td><b>- Si usted es Persona Natural:</b>';
	Let  _html_body1 = trim(_html_body1) ||'<br>&middot; Finiquito original firmado (adjuntamos finiquito).';
	Let  _html_body1 = trim(_html_body1) ||'<br>&middot; Copia de la c&eacute;dula de identidad.';
	Let  _html_body1 = trim(_html_body1) ||'<br><b>- Si usted es Persona Jur&iacute;dica:</b>';
	Let  _html_body1 = trim(_html_body1) ||'<br>&middot; Finiquito original firmado por el Representante Legal de la empresa (adjuntamos finiquito).';
	Let  _html_body1 = trim(_html_body1) ||'<br>&middot; Copia de la c&eacute;dula del Representante Legal.';
	Let  _html_body1 = trim(_html_body1) ||'<br>&middot; Copia del Registro P&uacute;blico de la empresa en el cual se evidencie el firmante como representante legal.';
	Let  _html_body1 = trim(_html_body1) ||'</td>';
	Let  _html_body1 = trim(_html_body1) ||'</tr>';
	Let  _html_body1 = trim(_html_body1) ||'</table>';

	Let  _html_body1 = trim(_html_body1) ||'<tr>';
	Let  _html_body1 = trim(_html_body1) ||'<td>';
	Let  _html_body1 = trim(_html_body1) ||'<p>';
	Let  _html_body1 = trim(_html_body1) ||'Quedamos a la espera de lo solicitado y muchas gracias de antemano.';
	Let  _html_body1 = trim(_html_body1) ||'</p>';
	Let  _html_body1 = trim(_html_body1) ||'</td>';
	Let  _html_body1 = trim(_html_body1) ||'</tr>';
	Let  _html_body1 = trim(_html_body1) ||'<tr>';
	Let  _html_body1 = trim(_html_body1) ||'<td>';
	Let  _html_body1 = trim(_html_body1) ||'<p>';
	Let  _html_body1 = trim(_html_body1) ||'Saludos,';
	Let  _html_body1 = trim(_html_body1) ||'</p>';
	Let  _html_body1 = trim(_html_body1) ||'</td>';
	Let  _html_body1 = trim(_html_body1) ||'</tr>';
	Let  _html_body1 = trim(_html_body1) ||'<tr>';
	Let  _html_body1 = trim(_html_body1) ||'<td>';
	Let  _html_body1 = trim(_html_body1) ||'<p>';
	Let  _html_body1 = trim(_html_body1) ||'Gerencia de Ramos Patrimoniales.';
	Let  _html_body1 = trim(_html_body1) ||'</p>';
	Let  _html_body1 = trim(_html_body1) ||'</td>';
	Let  _html_body1 = trim(_html_body1) ||'</tr>';
	Let  _html_body1 = trim(_html_body1) ||'</table>';
	Let  _html_body1 = trim(_html_body1) ||'</body>';
	Let  _html_body1 = trim(_html_body1) ||'</html>';
end if	

return _html_body1;

--trace off;
END PROCEDURE



