-- Procedimiento que Genera el html body y la secuencia del envio de correos masivos 	

-- Creado    : 15/11/2010 - Autor: Roman Gordon

DROP PROCEDURE sp_par310;

CREATE PROCEDURE "informix".sp_par310(
a_cod_tipo	CHAR(5),
a_email		CHAR(50),
a_adjunto	smallint
)returning	integer;

Define _cantidad		smallint;
Define _secuencia		integer;
Define _adjunto			smallint;
Define _html_body		char(512);
Define _secuencia_char	char(5);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(100);

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return 0;
end exception


SET ISOLATION TO DIRTY READ;
--set debug file to "sp_par310.trc"; 
--trace on;


let _adjunto = 0;
let _secuencia = 0;
let _html_body = '';

Select count(*)
  into _cantidad
  from parmailsend
 where cod_tipo = a_cod_tipo
   and email	= a_email
   and enviado	= 0;

if _cantidad = 0 then
	Select max(secuencia)
	  into _secuencia
	  from parmailsend;

	if _secuencia is null then
		let _secuencia = 0;
	end if
	
	let _secuencia = _secuencia + 1;
	let _adjunto = _adjunto + a_adjunto;
else    
	Select secuencia,
		   html_body,
		   adjunto
	  into _secuencia,
		   _html_body,
		   _adjunto
	  from parmailsend
	 where cod_tipo = a_cod_tipo
	   and email	= a_email
	   and enviado	= 0;
	
	let _adjunto = _adjunto + a_adjunto;
	
end if

let _secuencia_char = cast(_secuencia as varchar(5));
let _secuencia_char = trim(_secuencia_char);

if _adjunto > 4 then

	let _html_body = "<html><img src=cid:" ||  _secuencia || ".jpg width=850 height=1100>";
	Update parmailsend 
	   set html_body	= _html_body,
	   	   adjunto		= _adjunto 
	 where secuencia	= _secuencia;
			
elif _adjunto > 1 and _adjunto < 5 then
	let _html_body = trim(_html_body) || '<br><img src=cid:' ||  _secuencia || '_' || cast(_adjunto as char(1)) || '.jpg width=850 height=1100>';
	
	Update parmailsend 
	   set html_body	= _html_body,
	   	   adjunto		= _adjunto 
	 where secuencia	= _secuencia;
else
	if _adjunto = 1 then
		let _html_body = "<html><img src=cid:" ||  _secuencia || ".jpg width=850 height=1100>" || "<br><img src=cid:" || _secuencia || "_1.jpg width=850 height=1100>";
	else
		let _html_body = "<html><img src=cid:" ||  _secuencia || ".jpg width=850 height=1100>";
	end if
	
	Insert into parmailsend(cod_tipo, email, enviado, adjunto, html_body, secuencia)
	Values (a_cod_tipo, a_email, 0, a_adjunto, _html_body, _secuencia);
end if 

return _secuencia;

END PROCEDURE
