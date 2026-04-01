-- Insertando los valores de las cartas de Salud en emicartasal5

-- Creado    : 15/07/2010 - Autor: Amado Perez M.
-- Modificado: 15/07/2010 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

drop procedure sp_pro1119;
create procedure sp_pro1119(a_no_documento char(20))

returning	lvarchar(500),
			smallint;

define v_e_mail			lvarchar(500);
define _e_mail			varchar(50);
define _cod_asegurado	char(10);
define _no_poliza		char(10);
define _cod_agente		char(10);
define _periodo			char(7);
define _enviado_a		smallint;
define _asegurado		smallint;
define _corredor		smallint;
define _error			smallint; 
define _fecha_email		datetime year to second;
define _cod_pagador     char(10);

--set debug file to "sp_pro499.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error    		
 	--RETURN _error, "Error al Actualizar";         
end exception 
 
call sp_sis21(a_no_documento) returning _no_poliza;
 
let v_e_mail = "";  
let _e_mail = "";  
let _asegurado = 0;
let _corredor = 0;

select cod_pagador
  into _cod_pagador
  from emipomae
 where no_poliza = _no_poliza;
 
select trim(e_mail)
  into _e_mail
  from cliclien
 where cod_cliente = _cod_pagador;

if _e_mail is not null and trim(_e_mail) <> "" then
	let v_e_mail = trim(v_e_mail) || trim(_e_mail) || ";";
	let _asegurado = 1;
else
	let _asegurado = 0;
end if

foreach
  select email
	into _e_mail
	from climail
   where cod_cliente = _cod_pagador

  if _e_mail is not null and trim(_e_mail) <> "" then
	let v_e_mail = trim(v_e_mail) || trim(_e_mail) || ";";
	let _asegurado = 1;
  end if
end foreach
 

foreach
	select cod_asegurado 
	  into _cod_asegurado
	  from emipouni
	 where no_poliza = _no_poliza

	let _e_mail = ""; 

	select trim(e_mail)
	  into _e_mail
	  from cliclien
	 where cod_cliente = _cod_asegurado;

	if _e_mail is not null and trim(_e_mail) <> "" then
		let v_e_mail = trim(v_e_mail) || trim(_e_mail) || ";";
		let _asegurado = 1;
	else
		let _asegurado = 0;
	end if
	
	foreach
	  select email
		into _e_mail
		from climail
	   where cod_cliente = _cod_asegurado

	  if _e_mail is not null and trim(_e_mail) <> "" then
		let v_e_mail = trim(v_e_mail) || trim(_e_mail) || ";";
		let _asegurado = 1;
	  end if
	end foreach
end foreach

 
let _e_mail = "";  

  foreach		        	
	  select cod_agente 
	    into _cod_agente
		from emipoagt
	   where no_poliza = _no_poliza

	  select email_personas
	    into _e_mail
		from agtagent
	   where cod_agente = _cod_agente;

      if _e_mail is not null and trim(_e_mail) <> "" then
		let v_e_mail = trim(v_e_mail) || trim(_e_mail) || ";";
		let _corredor = 1;
	  else
		  select e_mail
			into _e_mail
			from agtagent
		   where cod_agente = _cod_agente;
		   
		  if _e_mail is not null and trim(_e_mail) <> "" then
			let v_e_mail = trim(v_e_mail) || trim(_e_mail) || ";";
			let _corredor = 1;
		  else		   
			let _corredor = 0;
		  end if
	  end if
  end foreach
  
let _e_mail = "";  

  foreach		        	
	  select cod_agente 
	    into _cod_agente
		from emipoagt
	   where no_poliza = _no_poliza
	   	   
      foreach
		  select email
			into _e_mail
			from agtmail
		   where cod_agente = _cod_agente
			 and tipo_correo = 'PER'

		  if _e_mail is not null and trim(_e_mail) <> "" then
			let v_e_mail = trim(v_e_mail) || trim(_e_mail) || ";";
			let _corredor = 1;
		  end if
	  end foreach	  
      foreach
		  select email
			into _e_mail
			from agtmail
		   where cod_agente = _cod_agente
			 and tipo_correo = 'COM'

		  if _e_mail is not null and trim(_e_mail) <> "" then
			let v_e_mail = trim(v_e_mail) || trim(_e_mail) || ";";
			let _corredor = 1;
		  end if
	  end foreach
  end foreach
  
end


if _asegurado = 1 and _corredor = 1 then
	let _enviado_a = 1;
elif _asegurado = 1 and _corredor = 0 then  
	let _enviado_a = 2;
elif _asegurado = 0 and _corredor = 1 then  
	let _enviado_a = 3;
else
	let _enviado_a = 0;
end if

--let v_e_mail = "amoreno@asegurancon.com;jeperez@asegurancon.com;";

return trim(v_e_mail), _enviado_a;

end procedure;