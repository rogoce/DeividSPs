-- Procedimiento que actualiza las zonas para el presupuesto de ventas 
-- Creado    : 19/03/2010 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par301;

create procedure sp_par301()
returning integer, 
          char(50);

define _cod_agente		char(5);
define _cod_vendedor	char(3);
define _cod_ramo		char(3);
define _cod_area		char(1);
define _user_changed	char(8);
define _user_added 		char(8);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

let _cod_agente = "";
--set debug file to "sp_par301.trc";
--trace on;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _cod_agente || " " || _error_desc;
end exception

-- Actualizar Presupuesto de Ventas

foreach
 select pre.cod_agente,ram.cod_area,ram.cod_ramo
   into _cod_agente,_cod_area,_cod_ramo
   from deivid_bo:preventas pre
  inner join deivid:prdramo ram on ram.cod_ramo = pre.cod_ramo
   where periodo[1,4] =  year(today)
  group by pre.cod_agente,ram.cod_area,ram.cod_ramo
  order by 1

	if _cod_area = '2' then -- PERSONAS
		select cod_vendedor2
		  into _cod_vendedor
		  from deivid:agtagent
		 where cod_agente = _cod_agente;
	else
		select cod_vendedor
		  into _cod_vendedor
		  from deivid:agtagent
		 where cod_agente = _cod_agente;
	end if
	
	if trim(_cod_vendedor) = '' or _cod_vendedor is null then
		continue foreach;
	end if
--	begin 
--		on exception in(-268, -239)
--		end exception	
			update deivid_bo:preventas
			   set cod_vendedor = _cod_vendedor
			 where cod_agente   = _cod_agente
			   and periodo[1,4] =  year(today)
			   and cod_ramo = _cod_ramo;
--	END    
end foreach

{
foreach
 select cod_agente
   into _cod_agente
   from deivid_bo:preventas
  group by cod_agente

	select cod_vendedor
	  into _cod_vendedor
	  from agtagent
	 where cod_agente = _cod_agente;

	update deivid_bo:preventas
	   set cod_vendedor = _cod_vendedor
	 where cod_agente   = _cod_agente;

end foreach
}

-- Polizas Nuevas en el Presupuesto de Acuerdo a los Indicadores

call sp_par331() returning _error, _error_desc;

if _error <> 0 then 
	return _error, _cod_agente || " " || _error_desc;
end if

-- Actualizar tabla de enlace (parpromo)
--puesto en comentario por AMM 06/06/2025
{foreach
 select p.cod_agente
   into _cod_agente
   from parpromo p, agtagent a
  where p.cod_agente   = a.cod_agente
    and p.cod_vendedor <> a.cod_vendedor
    and p.cod_ramo     <> "008"
  group by 1
  order by 1

	select user_changed,
	       user_added
	  into _user_changed,
	       _user_added
	  from agtagent
	 where cod_agente = _cod_agente; 
	
	if _user_changed is null then
		let _user_changed = _user_added;
	end if

	call sp_par82(_cod_agente, _user_changed) returning _error, _error_desc;
	
	if _error <> 0 then 
		return _error, _cod_agente || " " || _error_desc;
	end if

end foreach}

end 

return 0, "Actualizacion Exitosa";

end procedure
