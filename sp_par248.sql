-- Reversar el cambio de corredores

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_par248;

create procedure "informix".sp_par248()
returning integer,
          char(50);

define _cod_documento	char(20);
define _renglon			integer;
define _cod_agente_v	char(5);
define _cod_agente_n	char(5);

foreach
 select cod_documento,
        renglon,
		cod_agente_v,
		cod_agente_n
   into _cod_documento,
        _renglon,
		_cod_agente_v,
		_cod_agente_n
   from agthisun
  where fecha    = "19/06/2007"
    and tipo_doc = 2

	update cobreagt
	   set cod_agente = _cod_agente_v
	 where no_remesa  = _cod_documento
	   and renglon    = _renglon
	   and cod_agente = _cod_agente_n;
	   
end foreach

return 0, "Actualizacion Exitosa";

end procedure
