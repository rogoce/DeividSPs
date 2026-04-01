-- Insertando los valores de las cartas de Salud en emicartasal5

-- Creado    : 15/07/2010 - Autor: Amado Perez M.
-- Modificado: 15/07/2010 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

drop procedure sp_pro1112a;

create procedure sp_pro1112a(a_no_documento char(20))
returning	lvarchar(500);

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
define _cod_vendedor    char(3);
define _usuario         char(8);

--set debug file to "sp_pro499.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error    		
 	--RETURN _error, "Error al Actualizar";         
end exception 
 let v_e_mail = "";  
 {
call sp_sis21(a_no_documento) returning _no_poliza;

let _e_mail = "";  
let _asegurado = 0;
let _corredor = 0;

 
let _e_mail = "";  

  foreach		        	
	  select cod_agente 
	    into _cod_agente
		from emipoagt
	   where no_poliza = _no_poliza

	  select cod_vendedor
	    into _cod_vendedor
		from agtagent
	   where cod_agente = _cod_agente;
	   
	  select usuario
        into _usuario
        from agtvende
       where cod_vendedor = _cod_vendedor;	

      select e_mail	   
	    into _e_mail
		from insuser
	   where usuario = _usuario;

      if _e_mail is not null and trim(_e_mail) <> "" then
		let v_e_mail = trim(v_e_mail) || trim(_e_mail) || ";";
	  end if
  end foreach
  
  let v_e_mail = trim(v_e_mail) || "vhenriquez@asegurancon.com;fasprilla@asegurancon.com;movalle@asegurancon.com;mlouis@asegurancon.com;";
}
  return trim(v_e_mail);
  end
end procedure;