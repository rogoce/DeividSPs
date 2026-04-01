-- Procedimiento que Genera el Html Body 
-- Pago de reclamos por cheques
-- Creado : 07/05/2018 - Autor: Amado Perez 
Drop procedure sp_par374; 
CREATE PROCEDURE "informix".sp_par374(  
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
 
-- let _no_tranrec = '2310716';
 
select no_reclamo,
       cod_cliente,
	   user_added
  into _no_reclamo,
       _cod_cliente,
	   _user_added
  from rectrmae
 where no_tranrec = _no_tranrec;

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
  
 
Let  _html_body1 = trim(_html_body1) ||'<!doctype html>';
Let  _html_body1 = trim(_html_body1) ||'<html>';
Let  _html_body1 = trim(_html_body1) ||'<head>';
--let  _html_body1 = trim(_html_body1) || trim(_html_body2); -- Función formato(num) devuelve el número en fomato currency y separador de miles;
Let  _html_body1 = trim(_html_body1) ||'<meta charset="utf-8">';
Let  _html_body1 = trim(_html_body1) ||'<title>Reclamo</title>';
Let  _html_body1 = trim(_html_body1) ||'</head>';
Let  _html_body1 = trim(_html_body1) ||'<body style="font-family:Arial; text-align:justify;">';  --font-size:14px;
Let  _html_body1 = trim(_html_body1) ||'<table width="800">';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td><p style="margin:1px; padding:1px;">Buen d&iacute;a,</p></td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td><p style="margin:1px; padding:1px;">Se&ntilde;or (a) ' || trim(_nombre) || ', con relaci&oacute;n a la reclamaci&oacute;n presentada bajo el n&uacute;mero de tr&aacute;mite ' || trim(_no_tramite) || ' adjunto le enviamos detalle de pago:</p></td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
FOREACH
	select desc_transaccion
	  into _desc_transaccion
	  from rectrde2
	 where no_tranrec = _no_tranrec
	order by renglon

	Let  _html_body1 = trim(_html_body1) ||'<tr>';
	Let  _html_body1 = trim(_html_body1) ||'<td><p style="margin:1px; padding:1px;"><b>';
	Let  _html_body1 = trim(_html_body1) ||trim(_desc_transaccion);
	Let  _html_body1 = trim(_html_body1) ||'</b></td>';
	Let  _html_body1 = trim(_html_body1) ||'</tr>';

END FOREACH
--Let  _html_body1 = trim(_html_body1) ||'</table>';
--Let  _html_body1 = trim(_html_body1) ||'</td>';
--Let  _html_body1 = trim(_html_body1) ||'</tr>';

Let  _html_body1 = trim(_html_body1) ||'<td align="center">';
Let  _html_body1 = trim(_html_body1) ||'<table width=" 50%">';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td align="center"><p style="margin:1px; padding:1px;"><b>CONCEPTO DE PAGO</b></p></td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';

Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td>';
Let  _html_body1 = trim(_html_body1) ||'<b>Descripci&oacute;n</b>';
Let  _html_body1 = trim(_html_body1) ||'</td>';
Let  _html_body1 = trim(_html_body1) ||'<td align="right">';
Let  _html_body1 = trim(_html_body1) ||'<b>Monto</b>';
Let  _html_body1 = trim(_html_body1) ||'</td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
FOREACH
	select cod_concepto, 
	       monto
	  into _cod_concepto,
	       _monto
	  from rectrcon
	 where no_tranrec = _no_tranrec

	select nombre
	  into _concepto
	  from recconce
	 where cod_concepto = _cod_concepto;
 
    if _monto is null then
		let _monto = 0;
    end if
	
	let v_monto = sp_html02(_monto);

	Let  _html_body1 = trim(_html_body1) ||'<tr>';
	Let  _html_body1 = trim(_html_body1) ||'<td><b>';
	Let  _html_body1 = trim(_html_body1) ||_concepto;
	Let  _html_body1 = trim(_html_body1) ||'</b></td>';
    Let  _html_body1 = trim(_html_body1) ||'<td align="right"><b>';
	Let  _html_body1 = trim(_html_body1) ||'B/.'||v_monto;
	Let  _html_body1 = trim(_html_body1) ||'</b></td>';
	Let  _html_body1 = trim(_html_body1) ||'</tr>';

END FOREACH
Let  _html_body1 = trim(_html_body1) ||'</table>';
Let  _html_body1 = trim(_html_body1) ||'</td>';


Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td>';
Let  _html_body1 = trim(_html_body1) ||'<p>';
--Let  _html_body1 = trim(_html_body1) ||'Favor si est&aacute; de acuerdo agradecemos enviar el finiquito adjunto firmado por esta v&iacute;a a ' || trim(_ajustador) || ' a la direcci&oacute;n ' || trim(_e_mail) || ' junto con copia de su documento de identidad personal y certificado de registro p&uacute;blico vigente (si aplica) para procesar la transferencia.';
Let  _html_body1 = trim(_html_body1) ||'Favor si est&aacute; de acuerdo agradecemos firmar el finiquito adjunto, igual a la c&eacute;dula y entregarlo en la sucursal mas cercana junto con copia de su documento de identidad personal y certificado de registro p&uacute;blico vigente (si aplica) para procesar la transferencia de pago ACH.';
Let  _html_body1 = trim(_html_body1) ||'</p>';
Let  _html_body1 = trim(_html_body1) ||'</td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
--Let  _html_body1 = trim(_html_body1) ||'<tr>';
--Let  _html_body1 = trim(_html_body1) ||'<td>';
--Let  _html_body1 = trim(_html_body1) ||'<p>';
--Let  _html_body1 = trim(_html_body1) ||'Tomar nota que dicho documento, luego de levantadas las restricciones de movilidad, debe ser presentado en f&iacute;sico ante nuestras oficinas.';
--Let  _html_body1 = trim(_html_body1) ||'</p>';
--Let  _html_body1 = trim(_html_body1) ||'</td>';
--Let  _html_body1 = trim(_html_body1) ||'</tr>';
--Let  _html_body1 = trim(_html_body1) ||'<tr>';
--Let  _html_body1 = trim(_html_body1) ||'<td>';
--Let  _html_body1 = trim(_html_body1) ||'<p>';
--Let  _html_body1 = trim(_html_body1) ||'Para lo cual la remisi&oacute;n del finiquito por esta v&iacute;a se entender&aacute; como plena aceptaci&oacute;n y satisfacci&oacute;n de lo aqu&iacute; se&ntilde;alado.';
--Let  _html_body1 = trim(_html_body1) ||'</p>';
--Let  _html_body1 = trim(_html_body1) ||'</td>';
--Let  _html_body1 = trim(_html_body1) ||'</tr>';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td>';
Let  _html_body1 = trim(_html_body1) ||'<p>';
Let  _html_body1 = trim(_html_body1) ||'Atentamente,';
Let  _html_body1 = trim(_html_body1) ||'</p>';
Let  _html_body1 = trim(_html_body1) ||'</td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td>';
Let  _html_body1 = trim(_html_body1) ||'<p>';
Let  _html_body1 = trim(_html_body1) ||'Aseguradora Anc&oacute;n.';
Let  _html_body1 = trim(_html_body1) ||'</p>';
Let  _html_body1 = trim(_html_body1) ||'</td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
Let  _html_body1 = trim(_html_body1) ||'</table>';
Let  _html_body1 = trim(_html_body1) ||'</body>';
Let  _html_body1 = trim(_html_body1) ||'</html>';
	

return _html_body1;

--trace off;
END PROCEDURE



