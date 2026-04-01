-- Procedimiento que actualiza las zonas para el presupuesto de ventas 
-- Creado    : 19/03/2010 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par299_ajuste;

create procedure sp_par299_ajuste()
returning integer, 
          char(50);

define _cod_agente		char(5);
define _cod_vendedor	char(3);
define _cod_ramo		char(3);
define _cod_area		char(1);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _periodo         char(7);
define _cod_subramo     char(3);

let _cod_agente = "";
--set debug file to "sp_par299_ajuste.trc";
--trace on;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _cod_agente || " " || _error_desc;
end exception

-- Actualizar Presupuesto de Ventas
{
	foreach
		SELECT cod_agente, cod_vendedor, cod_ramo
		  into _cod_agente, _cod_vendedor, _cod_ramo
		  FROM excel_actuario
		 WHERE cod_agente IN (
			SELECT cod_agente
			FROM excel_actuario
			GROUP BY cod_agente
			HAVING COUNT(DISTINCT cod_vendedor) > 1
		)
		group by 1,2,3
		ORDER BY cod_agente, cod_vendedor, cod_ramo
		
		update deivid_bo:preventas
		   set cod_vendedor = _cod_vendedor
		 where cod_agente   = _cod_agente
		   and cod_ramo     = _cod_ramo
		   and periodo[1,4] = '2025';
	end foreach
}
{
	foreach
		SELECT cod_vendedor, cod_agente
		  into _cod_vendedor, _cod_agente 
		FROM deivid_bo:excel_actuario
		where cod_ramo not in('018','019','016','004')
		group by 1,2
		ORDER BY cod_agente, cod_vendedor
		
		update preventas
		   set cod_vendedor = _cod_vendedor
		 where cod_agente   = _cod_agente
		   and periodo[1,4] = 2025;
	end foreach
}
{
	foreach
		SELECT cod_agente, cod_vendedor, cod_ramo
		  into _cod_agente, _cod_vendedor, _cod_ramo
		  FROM deivid_bo:excel_actuario
	  group by 1,2,3
	  ORDER BY cod_agente, cod_vendedor
		
		update deivid_bo:preventas
		   set cod_vendedor = _cod_vendedor
		 where cod_agente   = _cod_agente
		   and cod_ramo     = _cod_ramo
		   and periodo[1,4] = '2025';
	end foreach
}	
	
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
--	on exception in(-268, -239)
--		return 0, _cod_vendedor||" "||_cod_agente||" "||_cod_ramo with resume;
--	end exception
		update deivid_bo:preventas
		   set cod_vendedor = _cod_vendedor
		 where cod_agente   = _cod_agente
		   and periodo[1,4] =  year(today)
		   and cod_ramo = _cod_ramo;

 --  END  
end foreach

end 

return 0, "Actualizacion Exitosa" with resume;

end procedure