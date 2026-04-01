-- Actualizacion de Registros Segun el Tipo de Gestion

-- Creado    : 08/05/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 08/05/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 14/10/2010 - Autor: Roman Gordon

-- SIS v.2.0 - w_m_detalle_detalle - DEIVID, S.A.

drop procedure sp_cant_call;

create procedure sp_cant_call()
returning integer,char(10);

define _cod_cliente	char(10);
--set debug file to "sp_cas014bk.trc";
--trace on;
set isolation to dirty read;

foreach
	select cod_cliente
	  into _cod_cliente
	  from cascliente
	 where cant_call > 2

	update cascliente 
	   set cant_call = 0 
	 where cod_cliente = _cod_cliente;

	return 0,_cod_cliente with resume;
end foreach
return 0,'';
end procedure
