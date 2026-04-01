-- Procedimiento que Genera el html body y la secuencia del envio de correos masivos 	

-- Creado    : 15/11/2010 - Autor: Roman Gordon

DROP PROCEDURE sp_par336;

CREATE PROCEDURE "informix".sp_par336(
a_cod_tipo	CHAR(5),
a_email		CHAR(384),
a_adjunto	smallint
)returning	integer;

Define _cantidad		smallint;
Define _secuencia		integer;
Define _adjunto			smallint;
Define _html_body		char(512);
Define _secuencia_char	char(10);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(100);

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return 0;
end exception


SET ISOLATION TO DIRTY READ;
--set debug file to "sp_par336.trc"; 
--trace on;


let _adjunto = 0;
let _secuencia = 0;
let _html_body = '';
let _cantidad = 0;

if a_cod_tipo not in ('00029','00049','00050','00051','00052','00053','00054','00055') then --Apertura de reclamo, CASO: 33073 USER: DFERNAND 
	Select count(*)
	  into _cantidad
	  from parmailsend
	 where cod_tipo = a_cod_tipo
	   and email	= a_email
	   and enviado	= 0;
end if

if _cantidad = 0 then
	let _secuencia = sp_sis148();
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
	   
	if a_cod_tipo in ('00035','00036') then -- Amado 17-01-2022 no estaba actualizando los parmailcomp caso
		let _adjunto = a_adjunto;
	else
		let _adjunto = _adjunto + a_adjunto;
	end if
end if

-- [Henry] 7/9/2016. Solicitud de O&M, consultar ubicacion de compartido para colocar PDF Formatos en Blanco.
-- Se anexan a la notificacion 2 paguinas adicionales (1. Instructivo de Reclamo de Auto-ASEGURADO.pdf  2.Poder Legal Transito ) 
--if _adjunto > 0 then
--   let _adjunto = _adjunto + 2;
--end if

let _secuencia_char = cast(_secuencia as varchar(10));
let _secuencia_char = trim(_secuencia_char);

if _adjunto > 4 then
 {	let _html_body = "<html><img src=cid:" ||  _secuencia || ".jpg width=850 height=1100>";
	Update parmailsend 
	   set html_body	= _html_body,
	   	   adjunto		= _adjunto 
	 where secuencia	= _secuencia;}

	let _html_body = "<html><img src=cid:" ||  _secuencia || ".jpg width=850 height=1100>";
	
	Update parmailsend 
	   set html_body	= _html_body,
	   	   adjunto		= _adjunto 
	 where secuencia	= _secuencia; 
			
elif _adjunto > 1 and _adjunto < 5 then
   --	let _html_body = trim(_html_body) || '<br><img src=cid:' ||  _secuencia || '_' || cast(_adjunto as char(1)) || '.jpg width=850 height=1100>';

	let _html_body = "<html><img src=cid:" ||  _secuencia || ".jpg width=850 height=1100>";
	
	Update parmailsend 
	   set html_body	= _html_body,
	   	   adjunto		= _adjunto 
	 where secuencia	= _secuencia; 

else
   {if _adjunto = 1 then
		let _html_body = "<html><img src=cid:" ||  _secuencia || ".jpg width=850 height=1100>" || "<br><img src=cid:" || _secuencia || "_1.jpg width=850 height=1100>";
	else
		let _html_body = "<html><img src=cid:" ||  _secuencia || ".jpg width=850 height=1100>";
	end if}
	
	let _html_body = "<html><img src=cid:" || _secuencia || ".jpg width=850 height=1100>";
	--let _adjunto = _adjunto + 2;  -- suma 2 paguinas mas adjunto
	
	if a_cod_tipo in ('00035','00036') and _cantidad = 0 then -- estos tipos solo tienen un adjunto y al generar el pdf genera uno solo pero con las diferentes transacciones que pueda encontrar
		Insert into parmailsend(cod_tipo, email, enviado, adjunto, html_body, secuencia)
		--Values (a_cod_tipo, a_email, 0, _adjunto, _html_body, _secuencia);	-- [Henry] se adicionara al enviar correo
		Values (a_cod_tipo, a_email, 0, a_adjunto, _html_body, _secuencia);
	elif a_cod_tipo not in ('00035','00036') then	
		Insert into parmailsend(cod_tipo, email, enviado, adjunto, html_body, secuencia)
		--Values (a_cod_tipo, a_email, 0, _adjunto, _html_body, _secuencia);	-- [Henry] se adicionara al enviar correo
		Values (a_cod_tipo, a_email, 0, a_adjunto, _html_body, _secuencia);
    end if
end if 

return _secuencia;

END PROCEDURE
