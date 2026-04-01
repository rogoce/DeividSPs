-- Creacion de un Producto de Otro
-- 
-- Creado    : 14/05/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 14/05/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par80;

create procedure sp_par80(a_producto_orig char(5)) 
returning integer,
          char(100),
          char(5);

define _valor_parametro	char(15);
define _valor_int		integer;
define _valor_char		char(10);
define a_producto_dest 	char(5);
define _error			integer;
define _cantidad		integer;

--set debug file to "sp_par80.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error
	return _error, "Error al Generar el Nuevo Producto", a_producto_dest;
end exception 

select valor_parametro
  into _valor_parametro
  from parcont
 where cod_compania  = '001'
   and aplicacion    = 'PAR'
   and version       = '02'
   and cod_parametro = 'par_productos';

let _valor_int  = _valor_parametro;
let _valor_int  = _valor_int + 1;
let _valor_char = '00000';

IF _valor_int > 9999  THEN
	LET _valor_char       = _valor_int;
ELIF _valor_int > 999 THEN
	LET _valor_char[2,5] = _valor_int;
ELIF _valor_int > 99  THEN
	LET _valor_char[3,5] = _valor_int;
ELIF _valor_int > 9   THEN
	LET _valor_char[4,5] = _valor_int;
ELSE
	LET _valor_char[5,5] = _valor_int;
END IF

let a_producto_dest = _valor_char;

select count(*)
  into _cantidad
  from prdprod
 where cod_producto = a_producto_dest;

if _cantidad <> 0 then
	return 1, "Producto Ya Existe", a_producto_dest;
end if

-- Productos

select * 
  from prdprod
 where cod_producto = a_producto_orig
  into temp tmp_temp;

update tmp_temp
   set cod_producto   = a_producto_dest,
       fecha_creacion = today;

insert into prdprod
select *
  from tmp_temp;

drop table tmp_temp;

-- Exceso de Perdida

select * 
  from prdpriex
 where cod_producto = a_producto_orig
  into temp tmp_temp;

update tmp_temp
   set cod_producto = a_producto_dest;

insert into prdpriex
select *
  from tmp_temp;

drop table tmp_temp;

-- Comision por Producto

select * 
  from prdcoprd
 where cod_producto = a_producto_orig
  into temp tmp_temp;

update tmp_temp
   set cod_producto = a_producto_dest;

insert into prdcoprd
select *
  from tmp_temp;

drop table tmp_temp;

-- Tarifas por Monto

select * 
  from prdtamon
 where cod_producto = a_producto_orig
  into temp tmp_temp;

update tmp_temp
   set cod_producto = a_producto_dest;

insert into prdtamon
select *
  from tmp_temp;

drop table tmp_temp;

-- Coberturas por Producto

select * 
  from prdcobpd
 where cod_producto = a_producto_orig
  into temp tmp_temp;

update tmp_temp
   set cod_producto = a_producto_dest;

insert into prdcobpd
select *
  from tmp_temp;

drop table tmp_temp;

-- Deducibles por Rango

select * 
  from prdcobrd
 where cod_producto = a_producto_orig
  into temp tmp_temp;

update tmp_temp
   set cod_producto = a_producto_dest;

insert into prdcobrd
select *
  from tmp_temp;

drop table tmp_temp;

-- Tipos para Salud

select * 
  from prdcobsa
 where cod_producto = a_producto_orig
  into temp tmp_temp;

update tmp_temp
   set cod_producto = a_producto_dest;

insert into prdcobsa
select *
  from tmp_temp;

drop table tmp_temp;

-- Tarifas por Edad

select * 
  from prdtaeda
 where cod_producto = a_producto_orig
  into temp tmp_temp;

update tmp_temp
   set cod_producto = a_producto_dest;

insert into prdtaeda
select *
  from tmp_temp;

drop table tmp_temp;

-- Beneficio Maximo

select * 
  from prdbemax
 where cod_producto = a_producto_orig
  into temp tmp_temp;

update tmp_temp
   set cod_producto = a_producto_dest;

insert into prdbemax
select *
  from tmp_temp;

drop table tmp_temp;

-- Tarifas Secuenciales

select * 
  from prdtasec
 where cod_producto = a_producto_orig
  into temp tmp_temp;

update tmp_temp
   set cod_producto = a_producto_dest;

insert into prdtasec
select *
  from tmp_temp;

drop table tmp_temp;

-- Tarifas por Edad - Sexo - Fumador

select * 
  from prdtavid
 where cod_producto = a_producto_orig
  into temp tmp_temp;

update tmp_temp
   set cod_producto = a_producto_dest;

insert into prdtavid
select *
  from tmp_temp;

drop table tmp_temp;

-- Actualizacion del Contador

update parcont
   set valor_parametro = a_producto_dest
 where cod_compania    = '001'
   and aplicacion      = 'PAR'
   and version         = '02'
   and cod_parametro   = 'par_productos';

end

RETURN 0,
       "Actualizacion Exitosa",
       a_producto_dest
       with resume;

end procedure