-- Procedimiento que calcula el descuento por: Tipo Auto - Ano - Suma Asegurada - RENOVACION DE POLIZAS

-- Creado:	23/07/2014 - Autor: Amado Perez M

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_proe75;
 
create procedure sp_proe75(a_poliza CHAR(10), a_unidad CHAR(5)) returning SMALLINT;

DEFINE _no_motor	        CHAR(50);
DEFINE _cod_modelo			CHAR(5);
DEFINE _cod_tipo			CHAR(3);
DEFINE _tipo_auto			SMALLINT;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_proe74.trc"; 
--trace on;

let _tipo_auto = 0;
-- Buscando informacion del tipo de vehiculo 1 Sedan, 2 Suv, 3 Pick Up
select no_motor
  into _no_motor
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

if _tipo_auto is null then
	let _tipo_auto = 0;
end if

return _tipo_auto;

end procedure
