-- Procedimiento adiciona la información de Notificación de Pagos al proceso de correos masivos jango.
-- Creado    : 26/01/2018 -- Román Gordón
-- Execute procedure sp_sis455('0001072447')

drop procedure sp_sis456a;
create procedure sp_sis456a()
returning smallint, varchar(30);

define _email_agt			char(384);
define _descripcion			varchar(30);
define _cod_agente			char(5);
define _cod_tipo_p			char(5);
define _cod_tipo			char(3);
define _error_isam			smallint;
define _cnt_existe			smallint;
define _error				smallint;


set isolation to dirty read;
begin
on exception set _error, _error_isam, _descripcion
 	return _error, _descripcion;
end exception

--set debug file to "sp_sis456a.trc";    BG17111708  
--trace on;

let _error       = 0;
let _descripcion = 'Actualizacion Exitosa ...';
let _cod_tipo_p = '00040';
let _cod_tipo = 'COM';

foreach
	{select cod_agente
	  into _cod_agente
	  from agtagent
	 where estatus_licencia not in ('P')} --Suspensión Permanente
	
	select distinct cod_agente
	  into _cod_agente
	  from agtnotas
	 where date(fecha_nota) = '30/05/2018'
	   and desc_nota = 'SUSPENDIDO POR MOROSIDAD, SEGUN INFORME DE SUPERINTENDEDNCIA.-TASA'

	let _email_agt = sp_sis163a(_cod_agente,_cod_tipo);

	if _email_agt is null then
		let _email_agt = '';
	end if
	
	if _email_agt <> '' then

		select count(*)
		  into _cnt_existe
		  from parmailsend
		 where cod_tipo = _cod_tipo_p
		   and email = _email_agt
		   and enviado = 0;

		if _cnt_existe is null then
			let _cnt_existe = 0;
		end if

		if _cnt_existe = 0 then
			call sp_sis455a(_cod_tipo_p,_email_agt,'','','T',0,'','',0.00,0.00,0.00,null) returning _error,_descripcion;
		end if
	end if
end foreach
end

return _error,_descripcion;
end procedure;