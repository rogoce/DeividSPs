-- Procedimiento que calcula el descuento por: Tipo Auto - Ano Vehiculo - Clasificado

-- Creado:	25/06/2014 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rwf143;
 
create procedure sp_rwf143(a_cod_modelo CHAR(5), a_ano_tarifa smallint)
returning dec(16,2);

define _cod_tipo	char(3);
define _tipo_auto	smallint;
define _porc_desc	dec(16,2);
define _max_ano		smallint;
define _grupo       char(5);

--set debug file to "sp_proe72.trc";
--trace on;

let a_cod_modelo = a_cod_modelo; 

set isolation to dirty read;

select grupo
  into _grupo
  from emimodel
 where cod_modelo = a_cod_modelo;
 
if _grupo is null or trim(_grupo) = "" then
	return 0;
end if

select max(ano)
  into _max_ano
  from emivecla1
 where grupo = _grupo;

if a_ano_tarifa > _max_ano then
	let a_ano_tarifa = _max_ano;
end if

select porc_desc
  into _porc_desc
  from emivecla1
 where grupo = _grupo
   and ano   = a_ano_tarifa;

if _porc_desc is null then
	let _porc_desc = 0;
end if


return _porc_desc;

end procedure
