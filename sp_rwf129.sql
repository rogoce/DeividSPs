-- Procedimiento que calcula el descuento por: Tipo Auto - Ano - Suma Asegurada

-- Creado:	25/06/2014 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rwf129;
 
create procedure sp_rwf129(a_cod_modelo CHAR(5), a_suma DEC(16,2), a_ano_tarifa smallint)
returning dec(16,2);

define _cod_tipo	char(3);
define _tipo_auto	smallint;
define _porc_desc	dec(16,2);
define _max_ano		smallint;

--set debug file to "sp_proe72.trc";
--trace on;

let a_cod_modelo = a_cod_modelo; 

set isolation to dirty read;

select cod_tipoauto
  into _cod_tipo
  from emimodel
 where cod_modelo = a_cod_modelo;

select tipo_auto
  into _tipo_auto
  from emitiaut
 where cod_tipoauto = _cod_tipo;

select max(ano)
  into _max_ano
  from emitiautdesc
 where tipo_auto = _tipo_auto;

if a_ano_tarifa > _max_ano then
	let a_ano_tarifa = _max_ano;
end if

if _tipo_auto = 0 then

	let _porc_desc = 0;

else

	select porc_desc
	  into _porc_desc
	  from emitiautdesc
	 where tipo_auto = _tipo_auto
	   and ano       = a_ano_tarifa
	   and rango_1  < a_suma
	   and rango_2   >= a_suma;

	if _porc_desc is null then
		let _porc_desc = 0;
	end if

end if

return _porc_desc;

end procedure
