-- Retorna el Resumen Historico de Gestiones 
-- Para un rango de fechas
-- 
-- Creado    : 24/04/2003 - Autor:Armando Moreno
-- Modificado: 24/04/2003 - Autor:Armando Moreno
--
-- SIS v.2.0 - d_cobr_sp_cob100_dw1 - DEIVID, S.A.

drop procedure sp_cas67;

create procedure sp_cas67(a_fecha_desde date, a_fecha_hasta date)
returning char(50),
          char(3),
          date,
          smallint;

define _cod_cobrador    char(3);
define _nombre			char(50);
define _cant_gestor1	smallint;
define _fecha			date;

create temp table tmp_resges(
fecha			date,
cant_gestor1	smallint default 0,
cod_cobrador    char(3)  default ""
) with no log;

let _cant_gestor1 = 0;

foreach
 select h.cod_cobrador
   into _cod_cobrador
   from cobcahis h, cobcobra c
  where date(h.fecha_ini) >= a_fecha_desde
    and date(h.fecha_ini) <= a_fecha_hasta
	and h.cod_gestion is not null
	and h.cod_cobrador = c.cod_cobrador
	and c.tipo_cobrador not in (7, 8) 
  group by 1
  order by 1

	foreach
	 select date(fecha_ini)
	   into _fecha
	   from cobcahis
	  where cod_cobrador = _cod_cobrador
	    and cod_gestion  is not null
   		and date(fecha_ini) >= a_fecha_desde
    	and date(fecha_ini) <= a_fecha_hasta

		BEGIN
	          ON EXCEPTION IN(-239)
	             UPDATE tmp_resges
	                SET cant_gestor1 = cant_gestor1 + 1
	              WHERE fecha        = _fecha
	                AND cod_cobrador = _cod_cobrador;

	          END EXCEPTION
	          INSERT
	            INTO tmp_resges(
					 fecha,
					 cod_cobrador,
					 cant_gestor1)		
	          VALUES(_fecha,
	                 _cod_cobrador,
	                 1);
	    END


	end foreach

end foreach

foreach
 select cod_cobrador,
		cant_gestor1,
		fecha
   into _cod_cobrador,
		_cant_gestor1,
		_fecha
   from tmp_resges   

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

end procedure
