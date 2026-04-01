-- Creacion de un Producto de Otro
-- 
-- Creado    : 14/05/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 14/05/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par181a;

create procedure "informix".sp_par181a(
a_producto_orig char(5),
a_ano			integer,
a_usuario       CHAR(8)
) returning integer,
            char(100),
            char(5);

define a_producto_dest 	char(5);
define _error			integer;
define _cantidad		integer;
define _anio_new        integer;
define _fecha1			date;
define _fecha2			date;
define _periodo1        char(5);
define _periodo2        char(5);
define _periodo_actual  char(4);

--set debug file to "sp_par80.trc";
--trace on;

begin
on exception set _error
	return _error, "Error al Generar la Nueva Ruta", a_producto_dest;
end exception 

let a_producto_dest = sp_sis13("001", "REA", "02", "par_rutas");
--	set debug file to "sp_par181a.trc";
--	trace on;
select count(*)
  into _cantidad
  from rearumae
 where cod_ruta = a_producto_dest;

if _cantidad <> 0 then
	return 1, "Ruta Ya Existe", a_producto_dest;
end if

-- Contratos
{
let _fecha1 = mdy(1,1,a_ano);
let _fecha2 = mdy(12,31,a_ano);
}

select * 
  from rearumae
 where cod_ruta = a_producto_orig
  into temp tmp_temp;
  
select vig_inic  + 1 units year,
       vig_final + 1 units year,
	   serie,
	   serie + 1
  into _fecha1,
       _fecha2,
	   _periodo_actual,
	   _anio_new	   
  from tmp_temp
 where cod_ruta = a_producto_orig;  
 
call sp_sis39(_fecha1) RETURNING _periodo1; 
call sp_sis39(_fecha2) RETURNING _periodo2;   

update tmp_temp
   set cod_ruta   = a_producto_dest,
       nombre = replace(nombre,_periodo_actual,_periodo1[1,4]),	
	   vig_inic  = _fecha1,
       vig_final = _fecha2,
       serie     = _anio_new,
	   user_added = a_usuario, ---'DEIVID',SOLICITA AMORENO
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