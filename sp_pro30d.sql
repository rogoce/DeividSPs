-- Procedure que determina el producto nuevo para los cambios de tarifas

-- Creado    : 07/08/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - sp_pro30c - DEIVID, S.A.

drop procedure sp_pro30d;

create procedure sp_pro30d(
a_no_poliza 	char(10),
a_cod_producto	char(5)
) returning char(5);

define _cod_producto	char(5);
define _producto_nuevo  char(5);
define _tipo_suscrip	smallint;
define _cod_subramo		char(3);
define _fecha_creacion  date;

let _cod_producto = a_cod_producto;

select cod_subramo
  into _cod_subramo
  from emipomae
 where no_poliza = a_no_poliza;

select tipo_suscripcion,
       fecha_creacion
  into _tipo_suscrip,
       _fecha_creacion       
  from prdprod
 where cod_producto = _cod_producto;

{
-- Este cambio es solo por un ano (01/09/2005 al 31/08/2006)

if _vigencia_final <= "31/08/2006" then

	select producto_nuevo
	  into _producto_nuevo
	  from prdnewpro
	 where cod_producto = _cod_producto;

	-- Tarifas Nuevas

	if _producto_nuevo is not null then
		let _cod_producto = _producto_nuevo;
	end if

end if
}

-- Cambio de Tarifas Tercer Aumento	Efectivo 01/09/2006
select producto_nuevo
  into _producto_nuevo
  from prdnewpro
 where cod_producto = _cod_producto
   and desde = '01/09/2006';

-- Tarifas Nuevas

if _producto_nuevo is not null then
	let _cod_producto = _producto_nuevo;
else
	if _fecha_creacion <= "31/08/2006" then	 -- No cambiar los productos creado desde el 01/09/2006 -- Amado Perez M. 17/06/2008
		if _cod_subramo = "008" then -- Plan Panama

			if _tipo_suscrip = 1 then -- Asegurado Solo

				let _cod_producto = "00588";

			elif _tipo_suscrip = 2 then -- Asegurado + 1 

				let _cod_producto = "00589";

			elif _tipo_suscrip = 3 then -- Asegurado + 2

				let _cod_producto = "00590";

			end if
			 
		elif _cod_subramo = "007" then -- Plan Panama Plus

			if _tipo_suscrip = 1 then -- Asegurado Solo

				let _cod_producto = "00591";

			elif _tipo_suscrip = 2 then -- Asegurado + 1 

				let _cod_producto = "00592";

			elif _tipo_suscrip = 3 then -- Asegurado + 2

				let _cod_producto = "00593";

			end if

		end if
	end if
end if

return _cod_producto;

end procedure