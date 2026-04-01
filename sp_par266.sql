-- Actualizadion masiva de los datos de promotorias

-- Creado    : 04/09/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 04/09/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_par266;

create procedure "informix".sp_par266()
returning smallint, char(100);

define _cod_agente 		char(5);
define _cod_vendedor	char(3);

foreach
 select	cod_agente
   into _cod_agente
   from agtagent

	select cod_vendedor
	  into _cod_vendedor
	  from parpromo
	 where cod_agente  = _cod_agente
	   and cod_agencia = "001"
	   and cod_ramo    = "001";

	update parpromo
	   set cod_vendedor = _cod_vendedor
	 where cod_agente   = _cod_agente
	   and cod_agencia  = "001"
	   and cod_ramo     = "021";
	  
	update parpromo
	   set cod_vendedor = _cod_vendedor
	 where cod_agente   = _cod_agente
	   and cod_agencia  = "004"
	   and cod_ramo     = "021";

end foreach

return 0, "Actualizacion Exitosa";

end procedure;
