-- Procedimiento que calcula el descuento por: Tipo Auto - Ano - Suma Asegurada

-- Creado:	25/06/2014 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_proe80;
 
create procedure sp_proe80(a_poliza CHAR(10), a_unidad CHAR(5))
returning dec(16,2);

define _no_motor	char(50);
define _ano_tarifa	smallint;
define _cod_modelo	char(5);
define _cod_tipo	char(3);
define _tipo_auto	smallint;
define _suma		dec(16,2);
define _max_ano		smallint;
define _porc_desc_model decimal(16,2);
define _porc_desc       decimal(16,2);

--set debug file to "sp_proe72.trc";
--trace on;

set isolation to dirty read;
let _porc_desc_model = 0;
let _porc_desc       = 0;

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

select cod_tipoauto, porc_desc
  into _cod_tipo,_porc_desc_model
  from emimodel
 where cod_modelo = _cod_modelo;

select tipo_auto
  into _tipo_auto
  from emitiaut
 where cod_tipoauto = _cod_tipo;
 
 select porc_desc
   into _porc_desc
   from emiautip
  where tipo_auto = _tipo_auto;
  
if _porc_desc = 0 then
	let _porc_desc = _porc_desc_model;
end if


return _porc_desc;

end procedure
