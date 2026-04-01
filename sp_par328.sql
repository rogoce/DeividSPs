-- Insercion de las tarifas de asiento del producto 01752 a otro producto, cobertura muerte accidental 00123
-- 
-- Creado    : 21/06/2012 - Autor: Armando Moreno
-- Modificado: 21/06/2012 - Autor: Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par328;

create procedure sp_par328(a_producto_orig char(5),a_producto_otro char(5))
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

begin
on exception set _error
	return _error, "Error al Insertar las tarifas", a_producto_otro;
end exception 


-- Productos
-- borrar la tarifa del producto a insertar si es que existia de la cobertura de Muerte Acc. 00123

Delete from prdtasec
 where cod_producto  = a_producto_otro
   and cod_cobertura = '00123';


select * 
  from prdtasec
 where cod_producto  = a_producto_orig
   and cod_cobertura = '00123'
  into temp tmp_temp;

update tmp_temp
   set cod_producto = a_producto_otro;


insert into prdtasec
select *
  from tmp_temp;

drop table tmp_temp;

update prdcobpd
   set busqueda = '6',
       porc_suma = 0,
       valor_asignar = 'L',
       factor_division = 1
 where cod_producto  = a_producto_otro
   and cod_cobertura = '00123';

{
Delete from prdtasec
 where cod_producto  = a_producto_otro
   and cod_cobertura = '01073';


select * 
  from prdtasec
 where cod_producto  = a_producto_orig
   and cod_cobertura = '00123'
  into temp tmp_temp;

update tmp_temp
   set cod_producto  = a_producto_otro,
       cod_cobertura = '01073';


insert into prdtasec
select *
  from tmp_temp;

drop table tmp_temp;

update prdcobpd
   set busqueda = '6',
       porc_suma = 0,
       valor_asignar = 'L',
       factor_division = 1
 where cod_producto  = a_producto_otro
   and cod_cobertura = '01073';
}
end

RETURN 0,
       "Actualizacion Exitosa",
       a_producto_otro;

end procedure