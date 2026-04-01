-- Procedimiento que trae todos los correos de cobros,reclamos y comercializacion de un corredor.
-- Creado    : 26/10/2012 - Autor: Roman Gordon

-- SIS v.2.0 - d_para_agentes - DEIVID, S.A.

drop procedure sp_par318;

create procedure "informix".sp_par318(a_cod_agente 	char(5))
returning	char(385),
			char(385),
			char(385);

define _email_com		varchar(50);
define _email_cob		varchar(50);
define _email_rec		varchar(50);
define _correo_cob		char(385);
define _correo_rec		char(385);
define _correo_com		char(385);
define _email			char(50);
define _cod_vendedor	char(3);
define _vend_fianzas	char(3);
define _tipo_correo		char(3);
define _cod_agencia		char(3);
define _ramo_afecta		smallint;
define _cantidad		smallint;
define _general			smallint;
define _vida			smallint;
define _error			integer;

set isolation to dirty read;

let _correo_cob	= '';
let	_correo_rec	= '';
let	_correo_com	= '';
let	_email_com	= '';
let	_email_cob	= '';
let	_email_rec	= '';

select e_mail,
	   email_cobros,
	   email_reclamo
  into _email_com,
  	   _email_cob,
  	   _email_rec
  from agtagent
 where cod_agente = a_cod_agente;

let _email_cob	= trim(_email_cob);
let	_email_rec	= trim(_email_rec);
let	_email_com	= trim(_email_com);
let _correo_cob	= _email_cob;
let	_correo_rec	= _email_rec;
let	_correo_com	= _email_com;

if _email_cob is null then
	let _email_cob = '';
end if

if _email_rec is null then
	let _email_rec = '';
end if


if _correo_com is null then
	let _correo_com = '';
end if

if _correo_com <> '' then
	let _correo_com = trim(_correo_com) || ';';
end if

if _email_rec <> '' then
	let _email_rec = trim(_email_rec) || ';';
end if

if _correo_cob <> '' then
	let _correo_cob = trim(_correo_cob) || ';';
end if

foreach
	select email,
		   tipo_correo
	  into _email,
	  	   _tipo_correo
	  from agtmail
	 where cod_agente = a_cod_agente
	   and trim(email) not like '%[^a-z,0-9,@,.]%' and trim(email) like '%_@_%_.__%'
	
	if _tipo_correo = 'COM' then
		if _email = _email_com then
			continue foreach;
		end if

		let _correo_com = trim(_correo_com) || trim(_email) || ';';  
	elif _tipo_correo = 'REC' then
		if _email = _email_rec then
			continue foreach;
		end if

		let _correo_rec = trim(_correo_rec) || trim(_email) || ';';
	elif _tipo_correo = 'COB' then
		if _email = _email_cob then
			continue foreach;
		end if

		let _correo_cob = trim(_correo_cob) || trim(_email) || ';';
	end if
end foreach

return _correo_cob,
	   _correo_rec,
	   _correo_com;

end procedure;