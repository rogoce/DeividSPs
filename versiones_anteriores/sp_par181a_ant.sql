-- Creacion de un Producto de Otro
-- 
-- Creado    : 14/05/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 14/05/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par181a;

create procedure "informix".sp_par181a(
a_producto_orig char(5),
a_ano			integer
) returning integer,
            char(100),
            char(5);

define a_producto_dest 	char(5);
define _error			integer;
define _cantidad		integer;
define _fecha1			date;
define _fecha2			date;

--set debug file to "sp_par80.trc";
--trace on;

begin
on exception set _error
	return _error, "Error al Generar la Nueva Ruta", a_producto_dest;
end exception 

let a_producto_dest = sp_sis13("001", "REA", "02", "par_rutas");

select count(*)
  into _cantidad
  from rearumae
 where cod_ruta = a_producto_dest;

if _cantidad <> 0 then
	return 1, "Ruta Ya Existe", a_producto_dest;
end if

-- Contratos

let _fecha1 = mdy(1,1,a_ano);
let _fecha2 = mdy(12,31,a_ano);

select * 
  from rearumae
 where cod_ruta = a_producto_orig
  into temp tmp_temp;

update tmp_temp
   set cod_ruta   = a_producto_dest,
       nombre = replace(nombre,nombre,a_ano),
	   vig_inic  = _fecha1,
       vig_final = _fecha2,
       serie          = a_ano,
	   user_added = 'DEIVID',
       date_added = today;

insert into rearumae
select *
  from tmp_temp;

drop table tmp_temp;

-- Coberturas por contrato

select * 
  from rearucon
 where cod_ruta = a_producto_orig
  into temp tmp_temp;

update tmp_temp
   set cod_ruta = a_producto_dest;

insert into rearucon
select *
  from tmp_temp;

drop table tmp_temp;
end

RETURN 0,
       "Actualizacion Exitosa",
       a_producto_dest
       with resume;

end procedure;