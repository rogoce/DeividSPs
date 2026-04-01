-- Procedure que Determina Cuando se Cambio un Registro en Agentes

-- Creado    : 18/09/2013 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_para_agentes - DEIVID, S.A.

drop procedure sp_par340;

create procedure "informix".sp_par340(
a_tipo	smallint,
a_valor	char(20)
) returning	char(5),
            char(50),
			char(20),
			char(20),
			datetime year to fraction;

define _cod_agente		char(5);
define _cod_vendedor	char(3);
define _nombre			char(50);
define _fecha_modif		datetime year to fraction;

define _flag			smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc, "", "", null;
end exception

if a_tipo = 1 then -- Cambios en Zona

	foreach
	 select cod_agente
	   into	_cod_agente
	   from agtbitacora
	  where cod_vendedor = a_valor
	  group by cod_agente
	  order by cod_agente

		select nombre
		  into _nombre
		  from agtagent
		 where cod_agente = _cod_agente;

		let _flag = 0;

		foreach 
		 select	cod_vendedor,
				fecha_modif
		   into _cod_vendedor,
		        _fecha_modif
		   from agtbitacora
		  where cod_agente = _cod_agente
--		    and tipo_mov   = "M"
--			and year(fecha_modif) = 2013
--			and month(fecha_modif) = 9
		  order by fecha_modif

			if _cod_vendedor = a_valor then
				let _flag = 1;
			end if

			if _flag         = 1        and 				
			   _cod_vendedor <> a_valor then

				let _flag = 0;

				return _cod_agente,
				       _nombre,
					   a_valor,
					   _cod_vendedor,
					   _fecha_modif
					   with resume;
				
---				exit foreach;

			end if

		end foreach

	end foreach

end if

end 

return "0", "Actualizacion Exitosa", "", "", null;

end procedure
