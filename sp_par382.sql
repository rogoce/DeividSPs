-- Procedimiento que Genera el Html Body 
-- Pago de reclamos por cheques
-- Creado : 07/05/2018 - Autor: Amado Perez 
Drop procedure sp_par382; 
CREATE PROCEDURE "informix".sp_par382(  
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
define _no_requis           char(10);
define _monto               dec(16,2);
define _monto2              money(16,2);
define v_monto              varchar(25);
define v_desc_cheque         varchar(100);

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return 0;
end exception

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_par364.trc"; 
--trace on;
--drop table if exists temp_carta;

Let  _html_body1 = '';
--Let  _html_body2 = '';
--Let  _html_body3 = '';

let _no_solicitud = 0;
let _siguiente = 0;

--let _html_body2 = sp_html01();

select no_remesa
  into _no_requis
  from parmailcomp
 where mail_secuencia = a_secuencia;

select monto
  into _monto
  from chqchmae
 where no_requis = _no_requis;

if _monto is null then
	let _monto = 0;
end if

let v_monto = sp_html02(_monto);

	  
Let  _html_body1 = trim(_html_body1) ||'<!doctype html>';
Let  _html_body1 = trim(_html_body1) ||'<html>';
Let  _html_body1 = trim(_html_body1) ||'<head>';
--let  _html_body1 = trim(_html_body1) || trim(_html_body2); -- Función formato(num) devuelve el número en fomato currency y separador de miles;
Let  _html_body1 = trim(_html_body1) ||'<meta charset="utf-8">';
Let  _html_body1 = trim(_html_body1) ||'<title>Reclamo</title>';
Let  _html_body1 = trim(_html_body1) ||'</head>';
Let  _html_body1 = trim(_html_body1) ||'<body style="font-family:Arial; font-size:14px; text-align:justify;">';
Let  _html_body1 = trim(_html_body1) ||'<table width="800">';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td><p style="margin:1px; padding:1px;">Estimado cliente, por este medio le notificamos que se le ha acreditado a su cuenta el monto de B/.';
Let  _html_body1 = trim(_html_body1) ||v_monto;
Let  _html_body1 = trim(_html_body1) ||'  en concepto de:</p></td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td align="center">';
Let  _html_body1 = trim(_html_body1) ||'<table width=" 50%">';
FOREACH
    SELECT desc_cheque
	  INTO v_desc_cheque
	  FROM chqchdes
	 WHERE no_requis = _no_requis 
	 
	Let  _html_body1 = trim(_html_body1) ||'<tr>';
	Let  _html_body1 = trim(_html_body1) ||'<td>';
	Let  _html_body1 = trim(_html_body1) ||v_desc_cheque;
	Let  _html_body1 = trim(_html_body1) ||'</td>';
	Let  _html_body1 = trim(_html_body1) ||'</tr>';

END FOREACH
Let  _html_body1 = trim(_html_body1) ||'</table>';
Let  _html_body1 = trim(_html_body1) ||'</td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td>';
Let  _html_body1 = trim(_html_body1) ||'<p>';
Let  _html_body1 = trim(_html_body1) ||'Gracias por preferirnos.';
Let  _html_body1 = trim(_html_body1) ||'</p>';
Let  _html_body1 = trim(_html_body1) ||'</td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td>';
Let  _html_body1 = trim(_html_body1) ||'<p>';
Let  _html_body1 = trim(_html_body1) ||'Para cualquier duda o consulta escribirnos a atencionalcliente@asegurancon.com';
Let  _html_body1 = trim(_html_body1) ||'</p>';
Let  _html_body1 = trim(_html_body1) ||'</td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
Let  _html_body1 = trim(_html_body1) ||'</table>';
Let  _html_body1 = trim(_html_body1) ||'</body>';
Let  _html_body1 = trim(_html_body1) ||'</html>';
	

return _html_body1;

--trace off;
END PROCEDURE



