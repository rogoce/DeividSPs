-- Procedimiento que crea los diferentes valores para
-- las promotorias de los corredores
-- Por Agencia y Ramo

-- Creado    : 29/08/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 29/08/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_para_agentes - DEIVID, S.A.

--drop procedure sp_par82bk;
create procedure "informix".sp_par82bk()
returning smallint, char(100);

define _cod_ramo		char(3);
define _cod_agencia		char(3);
define _cod_vendedor	char(3);
define _cod_agente 	    char(10);

define _vida			smallint;
define _general			smallint;
define _ramo_afecta		smallint;

define _error			integer;
define _cantidad		smallint;

set isolation to dirty read;

--set debug file to "sp_par82.trc";
--trace on;

begin
on exception set _error
	return _error, "Error al Actualizar las Promotorias ...";
end exception

--let _vend_fianzas  = "024";	-- Zona 8 se pone en comentario Armando 05/12/2018, debido a que Fianzas debe llevar el vendedor que tiene asignado el corredor.


foreach
	select cod_agente,
		   cod_vendedor
	  into _cod_agente,
	       _cod_vendedor
	  from promobk
	 order by 1
	 
	update agtagent
       set cod_vendedor = _cod_vendedor
     where cod_agente   = _cod_agente;

    update parpromo
       set cod_vendedor = _cod_vendedor
	 where cod_agente   = _cod_agente;  

end foreach
end
return 0, "Actualizacion Exitosa";
end procedure;