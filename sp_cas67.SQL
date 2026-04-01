-- Retorna el Resumen Historico de Gestiones 
-- Para un rango de fechas
-- 
-- Creado    : 24/04/2003 - Autor:Armando Moreno
-- Modificado: 24/04/2003 - Autor:Armando Moreno
--
-- SIS v.2.0 - d_cobr_sp_cob100_dw1 - DEIVID, S.A.

drop procedure sp_cas67;

create procedure sp_cas67(a_fecha_desde date, a_fecha_hasta date)
returning varchar(50),
          char(3),
          date,
          smallint;

define _nombre			varchar(50);
define _cod_cobrador	char(3);
define _cant_gestor1	smallint;
define _fecha			date;

create temp table tmp_resges(
fecha			date,
cant_gestor1	smallint	default 0,
cod_cobrador	char(3)		default "") with no log;

let _cant_gestor1 = 0;

foreach
	select h.cod_cobrador,
		   date(h.fecha_ini)
	  into _cod_cobrador,
		   _fecha
	  from cobcahis h, cobcobra c
	 where date(h.fecha_ini) >= a_fecha_desde
	   and date(h.fecha_ini) <= a_fecha_hasta
	   and h.cod_gestion is not null
	   and h.cod_cobrador = c.cod_cobrador
	   and c.tipo_cobrador not in (7, 8) 

	insert into tmp_resges(
			fecha,
			cod_cobrador,
			cant_gestor1)
	values(	_fecha,
			_cod_cobrador,
			1);
end foreach

foreach
	select cod_cobrador,
		   fecha,
		   sum(cant_gestor1)
	  into _cod_cobrador,
		   _fecha,
		   _cant_gestor1
	  from tmp_resges   
	 group by 1, 2
	 order by 1, 2

	select nombre
	  into _nombre
	  from	cobcobra
	 where cod_cobrador = _cod_cobrador;

	return _nombre,
		   _cod_cobrador,
		   _fecha,
		   _cant_gestor1
		   with resume;

end foreach
drop table tmp_resges;
end procedure;