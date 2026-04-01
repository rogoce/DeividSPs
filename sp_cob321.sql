-- Consulta de Abogados - Cobranzas Legales
-- Creado por: Amado Perez M - 28/02/2013
 													   
drop procedure sp_cob321;

create procedure sp_cob321()
returning char(3),
          varchar(50);

define _cd_abogado	       char(3);
define _nombre_abogado     varchar(50);
define _renglon            smallint;

define _error		integer;

begin
on exception set _error
	return _error, "Error de bloqueo";
end exception

let _renglon = 1;

foreach
 select cod_abogado,
		nombre_abogado
   into _cd_abogado,
        _nombre_abogado
   from recaboga
  where status = "A" and de_cobros = 1
order by nombre_abogado

if _renglon = 1 then
	return "%", "TODOS" with resume;
end if

let _renglon = _renglon + 1;	

return _cd_abogado, _nombre_abogado with resume;

end foreach

end


end procedure