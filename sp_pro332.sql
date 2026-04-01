--- Renovacion Automatica.
--- Creado 14/07/2009 por Armando Moreno

drop procedure sp_pro332;

create procedure "informix".sp_pro332(a_centro_costo char(3), a_tipo_ramo char(1))
returning char(8);

define _usuario 	char(8);
define _cntt 		integer;
define _cantidad    integer;

create temp table t_ren(
usuario		char(8),
cantidad	integer
) with no log;

create index i_t_ren1 on t_ren(usuario);
create index i_t_ren2 on t_ren(cantidad);

foreach
	select usuario
	  into _usuario
	  from emiredis
	 where cod_sucursal = a_centro_costo
	   and tipo_ramo    = a_tipo_ramo
	 group by usuario

	insert into t_ren
	values (_usuario, 0);
end foreach

select count(*)
  into _cntt
  from t_ren;

if _cntt = 1 then
	drop table t_ren;
	return _usuario;
end if

if _cntt > 1 then
	foreach
		select usuario
		  into _usuario
		  from emiredis
		 where cod_sucursal = a_centro_costo
		   and tipo_ramo    = a_tipo_ramo
		   group by usuario

		select count(*)
		  into _cantidad
		  from emirepo
		 where user_added = _usuario;

		if _cantidad is null then
			let _cantidad = 0;
		end if

		update t_ren
		   set cantidad = _cantidad
		 where usuario  = _usuario;
	end foreach

	foreach
		select cantidad,
			   usuario
		  into _cantidad,
			   _usuario
		  from t_ren
		order by 1, 2
		 exit foreach;
	end foreach

	drop table t_ren;
	return _usuario;
end if

drop table t_ren;
end procedure;
