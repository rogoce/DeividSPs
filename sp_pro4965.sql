-- Procedimiento valida endoso, cambio de corredor comision cero no permitir
-- Creado    : 04/09/2018 - Autor: Henry Girón

drop procedure sp_pro4965;

create procedure sp_pro4965(a_no_poliza char(10),a_no_endoso char(5))
returning	smallint,
			char(50);

define _error_desc		char(50);
define _porc_comis		dec(16,2);
define _error_isam		integer;
define _error			integer;
define _cod_endomov		char(3);
define _cod_agente		char(5);
define _tipo_agente	    char(1);

--set debug file to "sp_pro4965.trc";
--trace on;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

select cod_endomov
  into _cod_endomov
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _cod_endomov  = "012"  then -- Movimiento de Cambio de Corredor

		FOREACH
		 SELECT	rtrim(cod_agente), 
				porc_comis_agt
		   INTO	_cod_agente, 
				_porc_comis
		   FROM	endmoage
		  WHERE	no_poliza = a_no_poliza
		    AND no_endoso = a_no_endoso

				select tipo_agente
				  into _tipo_agente
				  from agtagent  
				 where cod_agente = _cod_agente;

				if _porc_comis > 0 and _tipo_agente = 'O' then
					Return 1, "Porcentaje comision del corredor "||_cod_agente||" invalida.";
				end if

		END FOREACH

end if

end
return 0,'validacion exitosa';

end procedure 