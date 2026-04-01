-- Insertando los valores de las cartas de Salud en emicartasal5

-- Creado    : 15/07/2010 - Autor: Amado Perez M.
-- Modificado: 15/07/2010 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

drop procedure sp_pro1122;

create procedure sp_pro1122(a_asegurado varchar(100))
returning	lvarchar(3000);

define v_html			lvarchar(3000);
define _e_mail			varchar(50);
define _cod_asegurado	char(10);
define _no_poliza		char(10);
define _cod_agente		char(10);
define _periodo			char(7);
define _enviado_a		smallint;
define _asegurado		smallint;
define _corredor		smallint;
define _error			smallint; 
define _fecha_email		datetime year to second;
define _cod_pagador     char(10);
define _cod_vendedor    char(3);
define _usuario         char(8);

--set debug file to "sp_pro499.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error    		
 	--RETURN _error, "Error al Actualizar";         
end exception 
  
let v_html = '<!doctype html><html><head><meta charset="utf-8"><title>Carta</title></head><body style="font-family:Arial; font-size:14px; text-align:justify;"><table width="800"><tr><td><img src="https://app.asegurancon.com/imagen/mem_carta.png"></td></tr><tr><td><p style="margin:1px; padding:1px;">Estimado Asegurado(a) %asegurado%</p></td></tr><tr><td><p style="margin:1px; padding:1px;">Adjunto se env&iacute;a notificaci&oacute;n de ajuste de prima de su p&oacute;liza de salud y anuncio del nuevo servicio de Telemedicina 24/7.</p></td></tr><tr><td><p>Nos reiteramos a la orden para cualquier consulta.</p></td></tr><tr><td><img src="https://app.asegurancon.com/imagen/mem_pie_carta.jpg" width="800"></td></tr></table></body></html>';  

let v_html = replace(trim(v_html),'%asegurado%',a_asegurado);

return trim(v_html);
end
end procedure;