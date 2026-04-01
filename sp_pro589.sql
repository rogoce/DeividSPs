-- Procedimiento que genera el endoso de traspaso de cartera
-- Creado: 20/07/2021 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.
-- execute procedure sp_pro589('','',5,20000,'SED0')

drop procedure sp_pro589;
create procedure sp_pro589(a_cod_producto char(5),a_cod_cobertura char(5),a_anio smallint,a_suma_asegurada dec(16,2),a_grupo varchar(10))
returning	integer		as err,
			varchar(200)	as err_desc,
			dec(16,2)		as tarifa;

define _descripcion		varchar(200);
define _error_desc		varchar(50);
define _tarifa	dec(16,2);
define _error_isam		integer;
define _error			integer;

--set debug file to "sp_pro589.trc";
--trace on;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc,-1;
end exception

select tarifa
  into _tarifa
  from prdtarnvl
 where cod_producto = a_cod_producto
   and cod_cobertura = a_cod_cobertura
   and grupo = a_grupo
   and anio = a_anio
   and desde < a_suma_asegurada
   and hasta >= a_suma_asegurada;
   
return 0,'Tarifa:',_tarifa;

end
end procedure;