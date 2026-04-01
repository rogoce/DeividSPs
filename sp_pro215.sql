
drop procedure sp_pro215;

create procedure "informix".sp_pro215()
returning char(8);

define _usuario 	char(8);
define _cantidad    integer;

create temp table tt_renprt(
usuario char(8),
cantidad	  integer
) with no log;

CREATE INDEX i_tt_renprt1 ON tt_renprt(usuario);
CREATE INDEX i_tt_renprt2 ON tt_renprt(cantidad);

foreach

	select usuario
	  into _usuario
	  from insuser
	 where codigo_perfil = '052'
	   and es_medico = 0
	   and status    = 'A'

	 select count(*)
	   into _cantidad
	   from emievalu
	  WHERE escaneado    = 1
	    AND completado   = 0
	    AND decicion     <> 6
	    AND suspenso     = 0
	    AND usuario_eval = _usuario;

	 if _cantidad is null then
	 	let _cantidad = 0;
	 end if

	 insert into tt_renprt
	 values (_usuario, _cantidad);

end foreach

foreach

 	 select cantidad,
    	    usuario
	   into _cantidad,
	        _usuario
	   from tt_renprt
	  order by 1, 2

	 exit foreach;

end foreach

drop table tt_renprt;

return _usuario;

end procedure;
