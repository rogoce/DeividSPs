-- Procedimiento que Genera el Html Body 
-- Creado : 19/10/2016 - Autor: Amado Perez 
Drop procedure sp_par359; 
CREATE PROCEDURE "informix".sp_par359(  
a_secuencia	INTEGER 
)returning	Lvarchar(3500); --max),
         --   Lvarchar(3500), --max),
        --    Lvarchar(3500); --max); 

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

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return 0;
end exception

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_par356.trc"; 
--trace on;

Let  _html_body1 = '';
Let  _html_body2 = '';
Let  _html_body3 = '';

let _no_solicitud = 0;

Let  _html_body1 = trim(_html_body1) ||' <!doctype html>';
Let  _html_body1 = trim(_html_body1) ||'<html>';
Let  _html_body1 = trim(_html_body1) ||'<body>';
Let  _html_body1 = trim(_html_body1) ||'<table width="800">';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td colspan="2"><img src="https:app.asegurancon.com/imagen/cintillo1.jpg" width="800"></td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td>';
Let  _html_body1 = trim(_html_body1) ||'<p style="font-family:Arial; font-size:14px; text-align:justify;">Estimado cliente, el presente es para notificarle que cuenta con un pago disponible en nuestras oficinas. Le agradecemos contactar a nuestro servicio al cliente al No. 210-8787 para m&aacute;s detalles.</p>';
Let  _html_body1 = trim(_html_body1) ||'<p style="font-family:Arial; font-size:14px; text-align:justify;">Atte,';
Let  _html_body1 = trim(_html_body1) ||'<br><br>';
Let  _html_body1 = trim(_html_body1) ||'Aseguradora Anc&oacute;n.';
Let  _html_body1 = trim(_html_body1) ||'</p>';
Let  _html_body1 = trim(_html_body1) ||'</td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
Let  _html_body1 = trim(_html_body1) ||'<tr>';
Let  _html_body1 = trim(_html_body1) ||'<td colspan="2"><img src="https:app.asegurancon.com/imagen/cintillo2.jpg" width="800"></td>';
Let  _html_body1 = trim(_html_body1) ||'</tr>';
Let  _html_body1 = trim(_html_body1) ||'</table>';
Let  _html_body1 = trim(_html_body1) ||'</body>';
Let  _html_body1 = trim(_html_body1) ||'</html>';


return _html_body1  with resume;

--trace off;
END PROCEDURE

