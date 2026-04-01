
--drop procedure sp_rec492;

create procedure "informix".sp_rec492()
returning char(3);

define _cntt 		integer;
define _usuario 	char(8);
define _cantidad    integer;
define _cod_ajustador  char(3);

create temp table tt_renaut(
cod_ajustador char(3),
cantidad	  integer
) with no log;

CREATE INDEX i_t_renaut1 ON tt_renaut(cod_ajustador);
CREATE INDEX i_t_renaut2 ON tt_renaut(cantidad);

foreach

	select cod_ajustador
	  into _cod_ajustador
	  from recajust
	 where activo = 1
	   and analista_salud = 1

	 select count(*)
	   into _cantidad
	   from atcdocde				  
	  where cod_ajustador = _cod_ajustador
	    and completado    = 0;

	 if _cantidad is null then
	 	let _cantidad = 0;
	 end if

	 insert into tt_renaut
	 values (_cod_ajustador, _cantidad);

end foreach

foreach

 	 select cantidad,
    	    cod_ajustador
	   into _cantidad,
	        _cod_ajustador
	   from tt_renaut
	  order by 1, 2

	 exit foreach;

end foreach

drop table tt_renaut;

return _cod_ajustador;

end procedure;
