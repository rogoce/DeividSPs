-- Insertando los valores de las cartas de Salud en emicartasal5

-- Creado    : 15/07/2010 - Autor: Amado Perez M.
-- Modificado: 15/07/2010 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

drop procedure sp_pro1113a;

create procedure sp_pro1113a(a_asegurado varchar(100))
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
  
let v_html = '<!doctype html><html><head><meta charset="utf-8"><title>Reclamo</title></head><body style="font-family:Arial; font-size:14px; text-align:justify;"><table width="800"><td><p style="margin:1px; padding:1px;">Estimada(o) Asegurada (o) %asegurado%</p></td><tr><tr><td><p style="margin:1px; padding:1px;">Adjunto se env&iacute;a carta de renovaci&oacute;n de su p&oacute;liza de salud la cual detalla el incremento aplicado a su prima, as&iacute; como la modificaci&oacute;n a la cobertura de enfermedades catastr&oacute;ficas. </p></td></tr></tr><tr><tr><td><p>Las mismas se han dado a la renovaci&oacute;n en funci&oacute;n de una insuficiencia en la prima por la alta siniestralidad del grupo.  </p></td></tr></tr><tr><td><p>Cualquier consulta a la orden.</p></td></tr><tr><tr><td><p>Departamento de Ramos de Personas.</p></td></tr></tr></table></body></html>';  

let v_html = replace(trim(v_html),'%asegurado%',a_asegurado);

return trim(v_html);
end
end procedure;