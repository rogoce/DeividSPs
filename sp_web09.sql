-- Procedure que inserta en tabla errorweb por si hay error con el corredor para luego volover a intentarlo

-- Creado: 02/11/2011 - Autor: Armando Moreno

--drop procedure sp_web09;

create procedure "informix".sp_web09(a_cod_agente char(5))
returning integer,
          char(100);


define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, trim(_error_desc);
end exception

--SET DEBUG FILE TO "sp_web09.trc";
--TRACE ON ;


insert into errorweb(
cod_agente
)
values(
a_cod_agente
);


end

return 0, "Exito";

end procedure