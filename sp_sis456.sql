-- Procedimiento adiciona la información de Notificación de Pagos al proceso de correos masivos jango.
-- Creado    : 26/01/2018 -- Román Gordón
-- Execute procedure sp_sis455('0001072447')

drop procedure sp_sis456;
create procedure sp_sis456()
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

foreach
	select distinct c.e_mail
	  into _email_aseg
	  from cliclien c, emipoliza e
	 where c.cod_cliente = e.cod_pagador
	   and (e.cod_status = 1 or (e.cod_status = 3 and e.vigencia_fin >= '01/12/2017'))
	   and c.e_mail is not null
	   and e_mail not like '%/%'
	   and e_mail <> ''
	   and e_mail like '%@%'
	   and e_mail like '%.%'
	   and e_mail not like '@%'
	   and e_mail not like '%@'
	   and e_mail not like '% %'
	   and e_mail not like '%,%'
	   and lower(e_mail) not like '%asegurancon%'
	   and lower(e_mail) not like '%aseguancon%'
	   and lower(e_mail) not like '%asegurncon%'
	   and lower(e_mail) not like '%sincorreo%'
	   and lower(e_mail) not like '%notiene%'
	   and lower(e_mail) not like '%no_tiene%'
	 order by e_mail

	call sp_sis455a('99999',_email_aseg,'','','',0,'','',0.00,0.00,0.00,null) returning _error,_descripcion;
end foreach
end
end procedure;