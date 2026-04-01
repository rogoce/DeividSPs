-- Procedure que retorna la lista de correos en cadena

-- AmadoPerez 27/07/2011


drop procedure sp_par322;

create procedure sp_par322(a_tipo char(3))
RETURNING VARCHAR(255),varchar(100);

define _email_parcocue	varchar(100);
define _email_unido  	varchar(255);
define _asunto          varchar(100);

set isolation to dirty read;

let _email_unido = "";

foreach	with hold

	select email
	  into _email_parcocue
	  from parcocue
	 where cod_correo = a_tipo
	   and activo = 1

	let _email_unido = trim(_email_unido) || trim(_email_parcocue) || ";";

end foreach

select nombre
  into _asunto
  from parcodes
 where cod_correo = a_tipo;
				  
RETURN _email_unido, _asunto WITH RESUME;

end procedure