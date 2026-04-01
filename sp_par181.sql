-- Creacion de un Producto de Otro
-- 
-- Creado    : 14/05/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 14/05/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par181;

create procedure "informix".sp_par181(
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
	return _error, "Error al Generar el Nuevo Contrato", a_producto_dest;
end exception 
--	set debug file to "sp_par181.trc";
--	trace on;
let a_producto_dest = sp_sis13("001", "REA", "02", "par_cont_reas");

select count(*)
  into _cantidad
  from reacomae
 where cod_contrato = a_producto_dest;

if _cantidad <> 0 then
	return 1, "Contrato Ya Existe", a_producto_dest;
end if

-- Contratos

select * 
  from reacomae
 where cod_contrato = a_producto_orig
  into temp tmp_temp;
  
select vigencia_inic + 1 units year,
       vigencia_final + 1 units year,
	   serie,
	   serie + 1
  into _fecha1,
       _fecha2,
	   _periodo_actual,
	   _anio_new	   
  from tmp_temp
 where cod_contrato = a_producto_orig;  
 
call sp_sis39(_fecha1) RETURNING _periodo1; 
call sp_sis39(_fecha2) RETURNING _periodo2; 

update tmp_temp
   set cod_contrato   = a_producto_dest,
       nombre = replace(nombre,_periodo_actual,_periodo1[1,4]),	   
	   vigencia_inic  = _fecha1,
       vigencia_final = _fecha2,
       serie          = _anio_new,
	   cod_traspaso   = null,
       user_actualizo = a_usuario, ---'DEIVID',SOLICITA AMORENO
       fecha_actualizo = today,
	   actualizado = 0;

insert into reacomae
select *
  from tmp_temp;

drop table tmp_temp;

-- Coberturas por contrato

select * 
  from reacocob
 where cod_contrato = a_producto_orig
  into temp tmp_temp;

update tmp_temp
   set cod_contrato = a_producto_dest;

insert into reacocob
select *
  from tmp_temp;

drop table tmp_temp;

-- Reaseguradores por contrato

select * 
  from reacoase
 where cod_contrato = a_producto_orig
  into temp tmp_temp;

update tmp_temp
   set cod_contrato = a_producto_dest;

insert into reacoase
select *
  from tmp_temp;

drop table tmp_temp;


end

RETURN 0,
       "Actualizacion Exitosa",
       a_producto_dest
       with resume;

end procedure