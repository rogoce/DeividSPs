-- Procedimiento que Devuelve la cantidad de reg.pendientes, (tabla cobcapen)
-- para cada gestor
-- 
-- Creado    : 07/10/2003 - Autor:Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

-- Tipos de Cobrador
--	1. Gestor
--	7. Investigador

drop procedure sp_cas060;

create procedure sp_cas060()
returning char(3),char(50),integer;

define _cod_cobrador	char(3);
define _nombre_cobrador char(50);
define _cantidad		integer;

create temp table tmp_cobra(
cod_cobrador	char(3),
cantidad		integer
) with no log;

foreach
 select	cod_cobrador
   into	_cod_cobrador
   from cobcobra
  where tipo_cobrador = 1
    and activo        = 1

	select count(*)
	  into _cantidad
	  from cobcapen
	 where cod_cobrador = _cod_cobrador;

	if _cantidad is null then
		let _cantidad = 0;
	end if

	insert into tmp_cobra
	values (_cod_cobrador, _cantidad);

end foreach

foreach
 select cantidad,
        cod_cobrador
   into _cantidad,
        _cod_cobrador
   from tmp_cobra
  order by 1, 2

	select nombre
	  into _nombre_cobrador
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;

	return _cod_cobrador,
		   _nombre_cobrador,
		   _cantidad
			with resume;
end foreach

drop table tmp_cobra;

end procedure
