-- Insertando 
-- Creado    : 15/07/2010 - Autor: Amado Perez M.
-- Modificado: 15/07/2010 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

drop procedure sp_pro527;

create procedure sp_pro527(a_correo varchar(150))
returning smallint,
		  char(25);

define _no_poliza char(10);
define _error     integer;
define _cant      integer;
define _html_body			char(512);
define _email_send			varchar(150);
define _error_isam			integer;
define _error_desc			char(100);
define _secuencia			integer;
define _cod_tipo			char(5);


--set debug file to "sp_pro172.trc";

    

on exception set _error, _error_isam, _error_desc
	return _error,_error_desc;
end exception


set isolation to dirty read;
begin

--set debug file to "sp_pro348.trc"; 
--trace on; 

let _email_send = trim(a_correo);

let _secuencia = sp_sis148();
 
let _cod_tipo  = "99999";	
let _html_body = "<html><img src=cid:feliz_dia.jpg width=850 height=1100>";

insert into parmailsend(
cod_tipo,
email,
enviado,
adjunto,
secuencia,
html_body,
sender
)
values(
_cod_tipo,
trim(_email_send),
0,
0,
_secuencia,
_html_body,
null);

end

return 0,'carga de medico exitosa';
end procedure