----------------------------------------------------------
--Saber si un Modelo de auto tiene motor o no, para que se imprima o no en las facturas.
-- 13/08/2018    Armando Moreno M.
----------------------------------------------------------
--drop procedure sp_sis508;
create procedure sp_sis508(a_cod_modelo char(5))
returning	smallint;

define _tiene_motor			smallint;
define _cod_tipoauto        char(3);

--set debug file to "sp_sis508.trc";
--trace on;

let _tiene_motor = 1;
let _cod_tipoauto = null;

select cod_tipoauto
  into _cod_tipoauto
  from emimodel
 where cod_modelo = a_cod_modelo;
 
if _cod_tipoauto is null then
	return 1;
end if 
 
Select tiene_motor
  Into _tiene_motor
  From emitiaut
 Where cod_tipoauto = _cod_tipoauto;
   
Return _tiene_motor;
end procedure;