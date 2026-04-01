-- Procedimiento que retorna el trimestre de reaseguro dado el periodo
 
-- Creado     :	12/11/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rea002b;		

create procedure "informix".sp_rea002b(a_periodo char(7), a_tipo smallint default 1)
returning char(9),
		  smallint;

define _per_ano		char(9);
define _trim		smallint;

select ano,
       trimestre
  into _per_ano,
       _trim
  from reatrim
 where periodo1 = a_periodo
   and tipo     = a_tipo;

if _per_ano is not null then
	return _per_ano, _trim;
end if

select ano,
       trimestre
  into _per_ano,
       _trim
  from reatrim
 where periodo2 = a_periodo
   and tipo     = a_tipo;

if _per_ano is not null then
	return _per_ano, _trim;
end if

select ano,
       trimestre
  into _per_ano,
       _trim
  from reatrim
 where periodo3 = a_periodo
   and tipo     = a_tipo;

if _per_ano is not null then
	return _per_ano, _trim;
end if

end procedure
