-- Procedimiento para procesar los valores en las tablas de DEIVID y emitir las polizas de ducruet
-- Creado    : 17/05/2019 - Autor: Federico Coronado

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_emite13;

create procedure "informix".sp_emite13(a_poliza char(10), a_endoso char(5), a_idpoliza integer, a_idendoso integer) 
returning	smallint,varchar(200);


define _error           smallint;
define _error_desc		varchar(200);
define _error_isam		smallint;
define _nombre    varchar(200);
define _cod_cliente    char(10);
define _no_documento    varchar(20);

	begin
	on exception set _error,_error_isam,_error_desc
		return _error,_error_desc;         
	end exception

	set isolation to dirty read;
	--set debug file to "sp_emite01.trc"; 
	--trace on;
	foreach
		select cod_cliente,nombre
		  into _cod_cliente,_nombre
		  from deivid_tmp:tmp_act_clte

		update cliclien
		   set nombre = _nombre
		 where cod_cliente = _cod_cliente
	
	end foreach
 	
	
	return 0,"Actualización Exitosa";
	end
end procedure