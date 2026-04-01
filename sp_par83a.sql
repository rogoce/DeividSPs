-- Procedimiento que Actualiza los diferentes valores para
-- las promotorias de los corredores
-- Por Agencia y Ramo

-- Creado    : 01/09/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 01/09/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_para_agentes_promotoria_parametros - DEIVID, S.A.

drop procedure sp_par83a;
create procedure "informix".sp_par83a(
a_cod_agente 	char(5),
a_vend_vida		char(3),
a_vend_general	char(3),
a_vend_fianzas	char(3)
) returning smallint, char(100);

define _cod_ramo		char(3);
define _cod_vendedor	char(3);
define _cod_tiporamo	char(3);

foreach
	select cod_ramo
	  into _cod_ramo
	  from parpromo
	 where cod_agente   = a_cod_agente

	select cod_tiporamo
	  into _cod_tiporamo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	if _cod_tiporamo = "001" then -- Vida
		let _cod_vendedor = a_vend_vida;
	elif _cod_tiporamo = "002" then -- General
		let _cod_vendedor = a_vend_general;
	elif _cod_tiporamo = "003" then -- Fianzas
		let _cod_vendedor = a_vend_fianzas;
	end if

	update parpromo
	   set cod_vendedor = _cod_vendedor
     where cod_agente   = a_cod_agente
       and cod_ramo     = _cod_ramo;
end foreach

return 0, "Actualizacion Exitosa";
end procedure;