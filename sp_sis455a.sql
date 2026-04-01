-- Procedimiento adiciona la información de parmailsend y parmailcomp para los procesos de correos masivos
-- Creado    : 26/01/2018 -- Román Gordón
-- Execute procedure sp_sis455('0001072447')

drop procedure sp_sis455a;
create procedure sp_sis455a(
a_cod_tipo		char(5),
a_email			char(384),
a_html_body		char(512),
a_email_cc		char(100),
a_no_remesa		char(10),
a_renglon		integer,
a_no_documento	char(20),
a_asegurado		char(100),
a_saldo			dec(16,2),
a_saldo61		dec(16,2),
a_prima_mensual	dec(16,2),
a_fecha			date,
a_adjunto		smallint	default 0)
returning smallint, varchar(30);

define _descripcion			varchar(30);
define _email_aseg			char(384);
define _no_documento		char(20);
define _cod_cliente			char(10);
define _no_poliza			char(10);
define _cod_agente			char(5);
define _cod_tipo			char(5);
define _cod_ramo			char(3);
define _exigible			dec(10,2);
define _ramo_sis			smallint;
define _error				smallint;
define _error_isam			smallint;
define _secuencia			integer;
define _secuencia2			integer;
define _fecha_suspension	date;

set isolation to dirty read;
begin
on exception set _error, _error_isam, _descripcion
 	return _error, _descripcion;
end exception

--set debug file to "sp_sis455.trc";    BG17111708  
--trace on;

let _error       = 0;
let _descripcion = 'Actualizacion Exitosa ...';

select max(secuencia)
  into _secuencia
  from parmailsend;

if _secuencia is null then
	let _secuencia = 0;
end if

let _secuencia = _secuencia + 1;
  
insert into parmailsend(
		cod_tipo,
		email,
		enviado,
		adjunto,
		html_body,
		secuencia,
		sender)
values(	a_cod_tipo,
		a_email,
		0,
		a_adjunto,
		a_html_body,
		_secuencia,
		a_email_cc);

select max(secuencia)
  into _secuencia2
  from parmailcomp;

if _secuencia2 is null then
	let _secuencia2 = 0;
end if

let _secuencia2 = _secuencia2 + 1;

insert into parmailcomp(
		secuencia,
		mail_secuencia,
		no_remesa,
		renglon,
		asegurado,
		no_documento,
		saldo,
		saldo61,
		prima_mensual,
		fecha)
values(	_secuencia2,
		_secuencia,
		a_no_remesa,
		a_renglon,
		a_asegurado,
		a_no_documento,
		a_saldo,
		a_saldo61,
		a_prima_mensual,
		a_fecha);

return _error, _descripcion;
end
end procedure;