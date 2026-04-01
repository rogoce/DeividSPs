-- Consulta de Abogados - Cobranzas Legales
-- Creado por: Amado Perez M - 28/02/2013
 													   
drop procedure sp_cob323;

create procedure sp_cob323(a_documento char(20), a_abogado char(3))
returning integer,
          varchar(50);

define _cd_abogado	       char(3);
define _nombre_abogado     varchar(50);
define _renglon            smallint;

define _error		integer;

begin
on exception set _error
	return _error, "Error al Actualizar Cobros Legales";
end exception

if a_abogado is not null and trim(a_abogado) <> "" then

UPDATE coboutleg
   SET cod_abogado = a_abogado
 WHERE no_documento = a_documento;

end if

end

return 0, "Actualizacion Exitosa";


end procedure