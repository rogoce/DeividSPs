-- Procedimiento que calcula el descuento por: Tipo Auto - Ano - Suma Asegurada

-- Creado:	25/06/2014 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rwf130;
 
create procedure sp_rwf130(a_cod_modelo CHAR(5))
returning smallint;

define _cod_tipo	char(3);
define _tipo_auto	smallint;
define _porc_desc	dec(16,2);
define _max_ano		smallint;

--set debug file to "sp_proe72.trc";
--trace on;

set isolation to dirty read;

select cod_tipoauto
  into _cod_tipo
  from emimodel
 where cod_modelo = a_cod_modelo;

select tipo_auto
  into _tipo_auto
  from emitiaut
 where cod_tipoauto = _cod_tipo;


return _tipo_auto;

end procedure
