-- Procedimiento que crea el auxiliar para la cuenta de gastos

-- Creado    : 18/01/2012 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac202;

create procedure "informix".sp_sac202()
returning char(10),
          char(5);

define _cod_cliente		char(10);
define _ter_codigo		char(5);
define _lenght			integer;
define _cuenta			char(25);

define _error			integer;
define _error_desc		char(50);

begin work;

let _ter_codigo = null;

foreach
 select m.cod_cliente
   into _cod_cliente
   from chqchmae m, chqchcta c
  where m.no_requis = c.no_requis
    and c.cuenta like "6000%"
    and (m.cod_cliente is not null or
         m.cod_cliente <> "")
--	and cod_cliente = "100925"
  group by 1
  order by 1

	let _lenght = length(_cod_cliente);

	if _lenght = 0 then
		continue foreach;
	end if

	let _ter_codigo = sp_sac203(_cod_cliente);
			
	foreach
	 select c.cuenta
	   into _cuenta
	   from chqchmae m, chqchcta c
	  where m.no_requis = c.no_requis
	    and c.cuenta    like "6000%"
		and cod_cliente = _cod_cliente
	  group by 1
	  order by 1

		call sp_sac136(_cuenta, _ter_codigo) returning _error, _error_desc;
		call sp_sac136(_cuenta, "G0001")     returning _error, _error_desc;

	end foreach

	return _cod_cliente, 
		   _ter_codigo	
		   with resume;

end foreach

update cglcuentas
   set cta_auxiliar = "S"
 where cta_cuenta   like "600%"
   and cta_recibe   = "S";

foreach
 select cta_cuenta
   into _cuenta
   from cglcuentas
  where cta_cuenta   like "600%"
    and cta_recibe   = "S"

	call sp_sac136(_cuenta, "G0001")     returning _error, _error_desc;

end foreach

--rollback work;
commit work;

end procedure