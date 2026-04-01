-- Procedimiento adiciona tipo: 00037 - Suspensión de Cobertura
-- Creado    : 17/11/2017 -- Henry Giron
-- Execute procedure sp_sis455('0001072447')

drop procedure sp_sis455;
create procedure sp_sis455(a_no_poliza char(10))
returning smallint, varchar(30);

define _html_body			varchar(255);
define _descripcion			varchar(30);
define _email_aseg			char(384);
define _email_agt			char(100);
define _no_documento		char(20);
define _cod_cliente			char(10);
define _cod_agente			char(5);
define _cod_tipo			char(5);
define _cod_ramo			char(3);
define _exigible			dec(10,2);
define _tipo_notif			smallint;
define _ramo_sis			smallint;
define _error				smallint;
define _error_isam			smallint;
define _secuencia			integer;
define _secuencia2			integer;
define _fecha_suspension	date;
define _cod_formapag        char(3);
define _desc_vip			varchar(50);
define _cliente_vip			smallint;

set isolation to dirty read;
begin
on exception set _error, _error_isam, _descripcion
 	return _error, _descripcion;
end exception

--set debug file to "sp_sis455.trc";    BG17111708  
--trace on;

let _error = 0;
let _tipo_notif = 2; --Mensaje de Suspensión de Cobertura en AppMovil
let _descripcion = 'Actualizacion Exitosa ...';

select no_documento,
	   cod_ramo,
	   cod_pagador,
   	   cod_formapag
  into _no_documento,
	   _cod_ramo,
	   _cod_cliente,
   	   _cod_formapag
  from emipomae
 where no_poliza = a_no_poliza;

let _cliente_vip = 0; 
call sp_sis233(_cod_cliente) returning _cliente_vip,_desc_vip; -- HG[JBRITO]14052019 Incumplimiento de Pago 1916-00044-01 
if _cliente_vip = 1 then
	return _error, _descripcion;
end if 

-- Procedure que retorna todos los correos de un cliente
call sp_sis163(_cod_cliente) returning _email_aseg;

Select max(secuencia)
  into _secuencia
  from parmailsend;

if _secuencia is null then
	let _secuencia = 0;
end if

let _secuencia = _secuencia + 1;
let _html_body = '';
let _exigible = 0;

select cod_agente,
	   fecha_suspension,
	   exigible
  into _cod_agente,
	   _fecha_suspension,
	   _exigible
  from emipoliza			  
 where no_documento = _no_documento;  					

call sp_sis163a(_cod_agente,'COB') returning _email_agt;

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;

if _ramo_sis = 1 then --Auto,Soda,Flota
	let _cod_tipo = '00038';
else
	let _cod_tipo = '00037';
end if
if _cod_formapag in('005','003','008') then
	let _email_aseg = _email_agt;
	let _email_agt = "";
end if
insert into parmailsend(
		cod_tipo,
		email,
		enviado,
		adjunto,
		html_body,
		secuencia,
		sender)
values(	_cod_tipo,
		_email_aseg,
		0,
		0,
		_html_body,
		_secuencia,
		_email_agt);

select max(secuencia)
  into _secuencia2
  from parmailcomp;

if _secuencia2 is null then
	let _secuencia2 = 0;
end if

let _secuencia2 = _secuencia2 + 1;

insert into parmailcomp(
		no_remesa,
		asegurado,
		secuencia,
		no_documento,
		renglon,
		mail_secuencia,
		saldo,
		fecha)
values(	a_no_poliza,
		_cod_cliente,
		_secuencia2,
		_no_documento,
		0,
		_secuencia,
		_exigible,
		_fecha_suspension);

call sp_sis458(_cod_cliente,_no_documento,_tipo_notif) returning _error,_descripcion;

return _error, _descripcion;
end
end procedure;