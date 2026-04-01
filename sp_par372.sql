-- Procedimiento que Genera el Html Body 
-- Pago de reclamos por cheques
-- Creado : 07/05/2018 - Autor: Amado Perez 
Drop procedure sp_par372; 
CREATE PROCEDURE "informix".sp_par372(  
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
define _fecha_letra         varchar(25); 
define _nombre              varchar(100);
define _a_nombre_de         varchar(100);
define _ano_cal             integer;
define _monto_tot           dec(16,2);

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return _error || _error_isam || _error_desc;
end exception

     create temp table temp_carta(
		nombre varchar(100),
		agno integer,
		deducible dec(16,2)) with no log;															 
	create index idx1_temp_carta on temp_carta(nombre);
    create index idx2_temp_carta on temp_carta(agno);		


SET ISOLATION TO DIRTY READ;
--set debug file to "sp_par364.trc"; 
--trace on;
--drop table if exists temp_carta;

 FOREACH EXECUTE PROCEDURE sp_rec741b(a_secuencia) 
           INTO _monto_tot, 
		        _ano_cal, 
		        _a_nombre_de	
		INSERT INTO temp_carta 
		VALUES (_a_nombre_de,
		        _ano_cal,
				_monto_tot);
				
 END FOREACH;


Let  _html_body1 = '';
Let  _html_body2 = '';
--Let  _html_body3 = '';

let _no_solicitud = 0;
let _siguiente = 0;

let _fecha_letra = sp_fecha_letra(today);
let _nombre = sp_rec741(a_secuencia);


let _html_body2 = sp_html01();
	  
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
--Let  _html_body1 = trim(_html_body1) ||'<td><p style="margin:1px; padding:1px;">PANAMA, '|| _fecha_letra || '</p></td>';
Let  _html_body1 = trim(_html_body1) ||'<td><p style="margin:1px; padding:1px;">Panam&aacute;, '|| _fecha_letra || '</p></td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
--Let  _html_body1 = trim(_html_body1) ||'<td><p style="margin:1px; padding:1px;">SE&Ntilde;OR(A)(ES)</p></td>';
Let  _html_body1 = trim(_html_body1) ||'<td><p style="margin:1px; padding:1px;">Se&ntilde;or(a) (es)</p></td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
--Let  _html_body1 = trim(_html_body1) ||'<td><p style="margin:1px; padding:1px;"> ' || _nombre || '</p></td>';
Let  _html_body1 = trim(_html_body1) ||'<td><p style="margin:1px; padding:1px;"><strong>' || _nombre || '</strong></p></td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
--Let  _html_body1 = trim(_html_body1) ||'<td><p style="margin:1px; padding:1px;">UN CORDIAL SALUDO DE PARTE DE ASEGURADORA ANCON, S. A., ESTE CORREO ES PARA INFORMARLE(S) QUE SU RECLAMO APLIC&Oacute; A DEDUCIBLE SEGUN EL DETALLE ADJUNTO.</p></td>';
Let  _html_body1 = trim(_html_body1) ||'<td><p style="margin:1px; padding:1px;">Un cordial saludo de parte de Aseguradora Ancon, S. A., este correo es para informarle(s) que su reclamo aplic&oacute; a deducible seg&uacute;n el detalle adjunto.</p></td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td align="center">';
Let  _html_body1 = trim(_html_body1) ||'<table width=" 50%">';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td>';
--Let  _html_body1 = trim(_html_body1) ||'<b>A&ntilde;o</b>';
Let  _html_body1 = trim(_html_body1) ||'<b><strong>A&ntilde;o</strong></b>';
Let  _html_body1 = trim(_html_body1) ||'</td>';
Let  _html_body1 = trim(_html_body1) ||'<td align="right">';
--Let  _html_body1 = trim(_html_body1) ||'<b>Deducible</b>';
Let  _html_body1 = trim(_html_body1) ||'<b><strong>Deducible</strong></b>';
Let  _html_body1 = trim(_html_body1) ||'</td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';

let _monto = 0; 

FOREACH
	select nombre,
	       agno,
		   deducible
	  into _a_nombre_de,
	       _ano_cal,
		   _monto_tot
	  from temp_carta
	
	let _monto = _monto + _monto_tot;
	
	let v_monto = sp_html02(_monto_tot);

	Let  _html_body1 = trim(_html_body1) ||'<tr>';
	Let  _html_body1 = trim(_html_body1) ||'<td><b>';
--	Let  _html_body1 = trim(_html_body1) ||_a_nombre_de;
    Let  _html_body1 = trim(_html_body1) ||'<strong>'||_a_nombre_de||'</strong>';
	Let  _html_body1 = trim(_html_body1) ||'</b></td>';
	Let  _html_body1 = trim(_html_body1) ||'</tr>';

	Let  _html_body1 = trim(_html_body1) ||'<tr>';
	Let  _html_body1 = trim(_html_body1) ||'<td><b>';
--	Let  _html_body1 = trim(_html_body1) ||_ano_cal;
	Let  _html_body1 = trim(_html_body1) ||'<strong>'||_ano_cal||'</strong>';
	Let  _html_body1 = trim(_html_body1) ||'</b></td>';
    Let  _html_body1 = trim(_html_body1) ||'<td align="right"><b>';
--	Let  _html_body1 = trim(_html_body1) ||'B/.'||v_monto;
	Let  _html_body1 = trim(_html_body1) ||'B/.<strong>'||v_monto||'</strong>';
	Let  _html_body1 = trim(_html_body1) ||'</b></td>';
	Let  _html_body1 = trim(_html_body1) ||'</tr>';

END FOREACH

let v_monto = sp_html02(_monto);

Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td><b>';
--Let  _html_body1 = trim(_html_body1) ||'TOTAL:';
Let  _html_body1 = trim(_html_body1) ||'<strong>Total:</strong>';
Let  _html_body1 = trim(_html_body1) ||'</b></td>';
Let  _html_body1 = trim(_html_body1) ||'<td align="right"><b>';
--Let  _html_body1 = trim(_html_body1) ||'B/.'||v_monto;
Let  _html_body1 = trim(_html_body1) ||'B/.<strong>'||v_monto||'</strong>';
Let  _html_body1 = trim(_html_body1) ||'</b></td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';

Let  _html_body1 = trim(_html_body1) ||'</table>';
Let  _html_body1 = trim(_html_body1) ||'</td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td>';
Let  _html_body1 = trim(_html_body1) ||'<p>';
--Let  _html_body1 = trim(_html_body1) ||'GRACIAS POR PREFERIRNOS.';
Let  _html_body1 = trim(_html_body1) ||'Gracias por preferirnos.';
Let  _html_body1 = trim(_html_body1) ||'</p>';
Let  _html_body1 = trim(_html_body1) ||'</td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td>';
Let  _html_body1 = trim(_html_body1) ||'<p>';
Let  _html_body1 = trim(_html_body1) ||'Atte,';
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
--nuevo
Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td>';
Let  _html_body1 = trim(_html_body1) ||'<p>';
Let  _html_body1 = trim(_html_body1) ||'Para cualquier duda o consulta escribirnos a atencionalcliente@asegurancon.com';
Let  _html_body1 = trim(_html_body1) ||'</p>';
Let  _html_body1 = trim(_html_body1) ||'</td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
--hasta qui
Let  _html_body1 = trim(_html_body1) ||'</table>';
Let  _html_body1 = trim(_html_body1) ||'</body>';
Let  _html_body1 = trim(_html_body1) ||'</html>';
	
drop table if exists temp_carta;

return _html_body1;

--trace off;
END PROCEDURE



