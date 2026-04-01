--- Renovacion Automatica. Proceso de excepciones
--- Creado 02/03/2009 por Armando Moreno

drop procedure sp_pro322;

create procedure "informix".sp_pro322(a_centro_costo char(3), a_tipo_ramo char(1), a_renglon smallint)
returning char(8);

define _cntt 		integer;
define _usuario 	char(8);
define _cantidad    integer;

create temp table t_renaut(
usuario		char(8),
cantidad	integer
) with no log;

CREATE INDEX i_t_renaut1 ON t_renaut(usuario);
CREATE INDEX i_t_renaut2 ON t_renaut(cantidad);

select count(*)
  into _cntt
  from emiredis
 where cod_sucursal = a_centro_costo
   and tipo_ramo    = a_tipo_ramo
   and renglon      = a_renglon;

if _cntt = 1 then
	select usuario
	  into _usuario
	  from emiredis
	 where cod_sucursal = a_centro_costo
	   and tipo_ramo    = a_tipo_ramo
	   and renglon      = a_renglon;

	drop table t_renaut;
	return _usuario;

end if

if _cntt > 1 then

	foreach
		select usuario
		  into _usuario
		  from emiredis
		 where cod_sucursal = a_centro_costo
		   and tipo_ramo    = a_tipo_ramo
		   and renglon      = a_renglon

		 select count(*)
		   into _cantidad
		   from tmp_reaut
		  where usuario = _usuario;

		 if _cantidad is null then
		 	let _cantidad = 0;
		 end if

		 insert into t_renaut
		 values (_usuario, _cantidad);

	end foreach

	foreach
	 	 select cantidad,
	    	    usuario
		   into _cantidad,
		        _usuario
		   from t_renaut
		  order by 1, 2

		 exit foreach;

	end foreach

	drop table t_renaut;
	return _usuario;

end if
drop table t_renaut;

end procedure;
