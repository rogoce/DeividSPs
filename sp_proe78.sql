-- Procedimiento que calcula el descuento por: Tipo Auto - Ano - Suma Asegurada - RENOVACION DE POLIZAS
-- Creado:	23/07/2014 - Autor: Amado Perez M
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_proe78; 
create procedure sp_proe78(
a_poliza	char(10),
a_unidad	char(5),
a_producto	char(5),
a_cobertura	char(5))
returning	dec(5,2);


define _no_motor	        char(50);
define _no_documento        char(20); 
define _no_poliza			char(10);
define _cod_modelo			char(5);
define _cod_tipo			char(3);
define _cod_ramo          	char(3);
define _descuento_max		dec(5,2);
define _tipo_descuento      smallint;
define _cant_g              smallint;
define _cant_p              smallint;
define _cant_s 				smallint;
define _tipo_auto			smallint;

set isolation to dirty read;

--SET DEBUG FILE TO "sp_proe74.trc"; 
--trace on;

let _descuento_max = 0;
let _tipo_descuento = 0;

select no_documento,
	   cod_ramo
  into _no_documento,
	   _cod_ramo
  from emipomae
 where no_poliza = a_poliza;

if _cod_ramo not in ("002", "023") then
   return 0.00;
end if 

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

if _tipo_auto = 0 then
   return 0.00;
end if


-- Busqueda de los descuentos 
select descuento_max, 
	   tipo_descuento
  into _descuento_max, 
       _tipo_descuento 
  from prdcobpd
 where prdcobpd.cod_producto  = a_producto
   and prdcobpd.cod_cobertura = a_cobertura;


if _tipo_descuento = 1 then	--> Descuento RC igual para Sedan, Suv, Pick Up
elif _tipo_descuento = 2 then --> Descuento Combinado Casco
	if _tipo_auto in (1, 2, 3) then
		let	_descuento_max = 50;
	else
		let _descuento_max = sp_proe72(a_poliza,a_unidad);
	end if
else
	let _descuento_max = 0;
end if

return _descuento_max;

end procedure;