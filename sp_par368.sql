-- Procedimiento que Genera el Html Body 
-- Declinacion de reclamos de Salud de Deivid Gestion
-- Creado : 07/05/2018 - Autor: Amado Perez 
Drop procedure sp_par368; 
CREATE PROCEDURE "informix".sp_par368(  
a_no_tranrec	CHAR(10) 
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

define _cod_cliente         char(10);
define _numrecla            char(20);
define _nombre              varchar(100);
define _descripcion         varchar(255);

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return 0;
end exception

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_par364.trc"; 
--trace on;
drop table if exists temp_carta;

Let  _html_body1 = '';
Let  _html_body2 = '';
--Let  _html_body3 = '';

let _no_solicitud = 0;
let _siguiente = 0;

let _html_body2 = sp_html01();

select cod_cliente,
       numrecla
  into _cod_cliente,
       _numrecla
  from rectrmae
 where no_tranrec = a_no_tranrec;
 
select nombre
  into _nombre
  from cliclien
 where cod_cliente = _cod_cliente;
 
 	  
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
Let  _html_body1 = trim(_html_body1) ||'<td><p style="margin:1px; padding:1px;">SE&Ntilde;OR(A)(ES)</p></td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td><p style="margin:1px; padding:1px;">' || _nombre || '</p></td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td><p style="margin:1px; padding:1px;">UN CORDIAL SALUDO DE PARTE DE ASEGURADORA ANCON, S. A., ESTE CORREO ES';
Let  _html_body1 = trim(_html_body1) ||' PARA INFORMARLE(S) QUE SU RECLAMO ' || _numrecla || ' HA SIDO DECLINADO.</p></td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
--Let  _html_body1 = trim(_html_body1) ||'<tr>';
--Let  _html_body1 = trim(_html_body1) ||'<td align="center">';
--Let  _html_body1 = trim(_html_body1) ||'<table width=" 50%">';
--Let  _html_body1 = trim(_html_body1) ||'<tr>';
--Let  _html_body1 = trim(_html_body1) ||'<td>';
--Let  _html_body1 = trim(_html_body1) ||'<b>Requisici&oacute;n #</b>';
--Let  _html_body1 = trim(_html_body1) ||'</td>';
--Let  _html_body1 = trim(_html_body1) ||'<td align="right">';
--Let  _html_body1 = trim(_html_body1) ||'<b>Monto</b>';
--Let  _html_body1 = trim(_html_body1) ||'</td>';
--Let  _html_body1 = trim(_html_body1) ||'</tr>';
FOREACH
	select descripcion 
	  into _descripcion
	   from blobcobe 
	  where no_tranrec = a_no_tranrec
   order by renglon
   

	Let  _html_body1 = trim(_html_body1) ||'<tr>';
	Let  _html_body1 = trim(_html_body1) ||'<td><b>';
	Let  _html_body1 = trim(_html_body1) ||_descripcion;
	Let  _html_body1 = trim(_html_body1) ||'</b></td>';
	Let  _html_body1 = trim(_html_body1) ||'</tr>';

END FOREACH
Let  _html_body1 = trim(_html_body1) ||'</table>';
Let  _html_body1 = trim(_html_body1) ||'</td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td>';
Let  _html_body1 = trim(_html_body1) ||'<p>';
Let  _html_body1 = trim(_html_body1) ||'GRACIAS POR PREFERIRNOS.';
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
Let  _html_body1 = trim(_html_body1) ||'</table>';
Let  _html_body1 = trim(_html_body1) ||'</body>';
Let  _html_body1 = trim(_html_body1) ||'</html>';
	

return _html_body1;

--trace off;
END PROCEDURE



