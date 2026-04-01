-- Procedimiento que calcula el descuento por: Tipo Auto - Ano - Suma Asegurada

-- Creado:	25/06/2014 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_proe72;
 
create procedure sp_proe72(a_poliza CHAR(10), a_unidad CHAR(5))
returning dec(16,2);

define _no_motor	char(50);
define _ano_tarifa	smallint;
define _cod_modelo	char(5);
define _cod_tipo	char(3);
define _tipo_auto	smallint;
define _suma		dec(16,2);
define _porc_desc	dec(16,2);
define _max_ano		smallint;
define _cod_grupo   char(5);
define _porc_des_grupo decimal(5,2);

--set debug file to "sp_proe72.trc";
--trace on;

set isolation to dirty read;
let _cod_grupo = null;

select cod_grupo
  into _cod_grupo
  from emipomae
 where no_poliza = a_poliza;

let _porc_des_grupo = null;
 
select porc_descuento
  into _porc_des_grupo
  from cligrupo
 where cod_grupo = _cod_grupo;

if _porc_des_grupo is null then
	let _porc_des_grupo = 0;
end if
 
select suma_asegurada
  into _suma
  from emipouni
 where no_poliza = a_poliza
   and no_unidad = a_unidad;
  
select no_motor,
       ano_tarifa
  into _no_motor,
       _ano_tarifa
  from emiauto
 where no_poliza = a_poliza
   and no_unidad = a_unidad;

select cod_modelo
  into _cod_modelo
  from emivehic
 where no_motor = _no_motor;

select cod_tipoauto
  into _cod_tipo
  from emimodel
 where cod_modelo = _cod_modelo;

select tipo_auto
  into _tipo_auto
  from emitiaut
 where cod_tipoauto = _cod_tipo;

select max(ano)
  into _max_ano
  from emitiautdesc
 where tipo_auto = _tipo_auto;

if _ano_tarifa > _max_ano then
	let _ano_tarifa = _max_ano;
end if

if _tipo_auto = 0 then

	let _porc_desc = 0;

else

	select porc_desc
	  into _porc_desc
	  from emitiautdesc
	 where tipo_auto = _tipo_auto
	   and ano       = _ano_tarifa
	   and rango_1  < _suma
	   and rango_2   >= _suma;

	if _porc_desc is null then
		let _porc_desc = 0;
	end if

end if

let _porc_desc = _porc_desc + _porc_des_grupo;

return _porc_desc;

end procedure
