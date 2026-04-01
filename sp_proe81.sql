-- Procedimiento que calcula el descuento por: Tipo Auto - Ano - Suma Asegurada

-- Creado:	25/06/2014 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_proe81;
 
create procedure sp_proe81(a_marca CHAR(5), a_modelo CHAR(5))
returning dec(16,2);

define _cod_tipo	char(3);
define _tipo_auto	smallint;
define _porc_desc_model decimal(16,2);
define _porc_desc       decimal(16,2);

--set debug file to "sp_proe72.trc";
--trace on;

set isolation to dirty read;
let _porc_desc_model = 0;
let _porc_desc       = 0;


select cod_tipoauto, porc_desc
  into _cod_tipo,_porc_desc_model
  from emimodel
 where cod_marca  = a_marca
   and cod_modelo = a_modelo;

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
