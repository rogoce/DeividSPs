-- Procedimiento que Devuelve el Cobrador al que se le debe asignar
-- una gestion de acuerdo al grado de saturacion de su cartera
-- 
-- Creado    : 24/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/04/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

-- Tipos de Cobrador
--	1. Gestor
--	7. Investigador

drop procedure sp_cas006;

create procedure sp_cas006(a_cod_sucursal char(3), a_tipo_cobrador smallint)
returning char(3);

define _cod_cobrador	char(3);
define _cantidad		integer;

create temp table tmp_cobra(
cod_cobrador	char(3),
cantidad		integer
) with no log;

let _cod_cobrador = null;

set isolation to dirty read;

foreach
 select	cod_cobrador
   into	_cod_cobrador
   from cobcobra
  where cod_sucursal  = a_cod_sucursal
    and tipo_cobrador = a_tipo_cobrador
    and activo        = 1

	select count(*)
	  into _cantidad
	  from cascliente
	 where cod_cobrador = _cod_cobrador;

	if _cantidad is null then
		let _cantidad = 0;
	end if

	insert into tmp_cobra
	values (_cod_cobrador, _cantidad);

end foreach

if _cod_cobrador is null then

	foreach
	 select	cod_cobrador
	   into	_cod_cobrador
	   from cobcobra
	  where cod_sucursal  = "001"
	    and tipo_cobrador = a_tipo_cobrador
	    and activo        = 1

		select count(*)
		  into _cantidad
		  from cascliente
		 where cod_cobrador = _cod_cobrador;

		if _cantidad is null then
			let _cantidad = 0;
		end if

		insert into tmp_cobra
		values (_cod_cobrador, _cantidad);

	end foreach
end if

foreach
 select cantidad,
        cod_cobrador
   into _cantidad,
        _cod_cobrador
   from tmp_cobra
  order by 1, 2

	exit foreach;

end foreach

drop table tmp_cobra;
return _cod_cobrador;

end procedure
