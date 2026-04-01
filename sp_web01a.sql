-- Procedure que realiza el ciclo de carga de deivid para deivid_web

-- Creado: 21/02/2021 - Autor: Federico Coronado

drop procedure sp_web01a;

create procedure "informix".sp_web01a()
returning integer,
		  char(5),
          char(100);


define _error				integer;
define _error1				integer;
define _error_isam			integer;
define _error_desc			char(100);
define _error_desc1			char(100);
define _cod_agente          char(5);
define _cnt_agente          integer;
define _nombre_agente       varchar(100);

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, "", trim(_error_desc);
end exception
--begin work; --ya el begin esta iniciado desde powerbuilder; comentar al correrlo manual
delete from errorweb;
commit work; --ya el begin esta iniciado desde powerbuilder hago commit para confirmar el delete
	foreach WITH HOLD
		Select cod_agente
		  into _cod_agente
		  from agtagent
		 where tipo_agente = 'A' --and cod_agente in('00001','00002','00003','00004','00005')
			or cod_agente in('00085','02311')
	  order by cod_agente

		begin work;
			select count(*)
			  into _cnt_agente
			  from deivid_web:web_agente
			  where cod_agente = _cod_agente;

			  if _cnt_agente = 0 then
				update agtagent
				   set flag_web_corr = 0
				 where cod_agente = _cod_agente;
			  end if

			insert into deivid_web:web_agente
			select cod_agente, nombre from agtagent	where cod_agente = _cod_agente and flag_web_corr = 0;

			select nombre
			  into _nombre_agente
			  from agtagent
			 where cod_agente = _cod_agente;

			 update deivid_web:web_agente
				set nombre		= _nombre_agente
			 where cod_agente 	= _cod_agente;
		commit work;

		begin work;
		
		 CALL sp_web01(_cod_agente) returning _error, _error_desc;
			IF _error <> 0 THEN
				rollback work;
				CALL sp_web09(_cod_agente) returning _error1, _error_desc1;
			else
				commit work;
			END IF
		return _error, _cod_agente, _error_desc WITH RESUME;
	end foreach	
--commit work; 
end
end procedure