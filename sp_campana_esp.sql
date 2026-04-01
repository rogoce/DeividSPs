-- Procedimiento que Genera el html body y la secuencia del envio de correos masivos 	

-- Creado    : 15/11/2010 - Autor: Roman Gordon

drop procedure sp_campana_esp;

create procedure "informix".sp_campana_esp() returning	integer,char(256);

define _secuencia		integer;
define _secuencia_comp	integer;
define _error			integer;
define _error_isam		integer;
define _adjunto			smallint;
define _rechazo			smallint;
define _html_body		char(512);
define _error_desc		char(100);
define _email_cliente	char(50);
define _email			char(200);
define _cod_agente		char(5);
define _cod_tipo		char(5);
define _nombre_agt		char(50);
define _email_cc		char(200);
define _no_documento	char(20);
define _cod_cliente		char(10);
define _no_poliza		char(10);
define _no_lote			char(5);
define _renglon			smallint;
define _user_added		char(8);
define _tipo_tran		char(1);

on exception set _error, _error_isam, _error_desc
	--rollback work;
	return _error,_error_desc;
end exception

set isolation to dirty read;

foreach
	select nombre,
		   cod_agente
	  into _nombre_agt,
		   _cod_agente
	  from agtagent
	 where cod_agente not in ('00200','00283','00474','00521','00596','00708',
	 '00731','00863','00953','01009','01068','01159','01572','01653','01654',
	 '01655','01656','01657','01658','01659','01660','01661','01662','01663',
	 '01664','01727')

	insert into cascampanafil(cod_campana,tipo_filtro,cod_filtro,descripcion)
	values ('00082',5,_cod_agente,_nombre_agt);
end foreach

update cascampana set filt_agente = 1 where cod_campana = '00082';

return 0,'insercion exitosa';

end procedure