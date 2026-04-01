-- Creacion de una Campaña a Partir de Otra
-- 
-- Creado    : 14/05/2003 - Autor: Roman Gordon
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas109;

create procedure sp_cas109(a_campana_orig char(5)) 
returning integer,
          char(100),
          char(5);

define a_campana_dest 	char(10);
define _error			integer;
define _cantidad		integer;

--set debug file to "sp_cas109.trc";
--trace on;

begin
on exception set _error
	return _error, "Error al Generar la Nueva Campaña", a_campana_dest;
end exception 

let a_campana_dest = sp_sis13("001","COB","02","par_campana"); 

select count(*)
  into _cantidad
  from cascampana
 where cod_campana = a_campana_dest;

if _cantidad <> 0 then
	return 1, "Campaña Ya Existe", a_campana_dest;
end if

-- Informacion de la Campaña

select * 
  from cascampana
 where cod_campana = a_campana_orig
  into temp tmp_temp;

update tmp_temp
   set cod_campana = a_campana_dest,
       estatus	   = 0,
       fecha_desde = today,
	   fecha_hasta = today + 1;

insert into cascampana
select *
  from tmp_temp;

drop table tmp_temp;

-- Filtros de la Campaña

select * 
  from cascampanafil
 where cod_campana = a_campana_orig
  into temp tmp_temp;

update tmp_temp
   set cod_campana = a_campana_dest;

insert into cascampanafil
select *
  from tmp_temp;

drop table tmp_temp;

end

RETURN 0,
       "Actualizacion Exitosa",
       a_campana_dest
       with resume;

end procedure