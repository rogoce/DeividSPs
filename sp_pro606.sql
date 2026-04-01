-- No Aprobacion de de uno de los aspirantes

-- Creado    : 28/12/2010 - Autor: Armando Moreno.

DROP PROCEDURE sp_pro606;

CREATE PROCEDURE "informix".sp_pro606(a_cod_producto char(5))
returning smallint;


define _descuento_b	smallint;
define _recargo_b  	smallint;
define _opcion_b    smallint;
define _descuento_c	smallint;
define _recargo_c   smallint;
define _opcion_c    smallint;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro202b.trc";
--trace on;

BEGIN

let _descuento_b = 0;
let _recargo_b = 0;
let _opcion_b = 0;
let _descuento_c = 0;
let _recargo_c = 0;
let _opcion_c = 0;

select descuento_b,
	   recargo_b,
	   descuento_c,
	   recargo_c
  into _descuento_b,
	   _recargo_b,
	   _descuento_c,
	   _recargo_c
  from prdprod
 where cod_producto = a_cod_producto;

if _descuento_b is null then
	let _descuento_b = 0;
end if
	
if _recargo_b is null then
	let _recargo_b = 0;
end if

if _descuento_c is null then
	let _descuento_c = 0;
end if
	
if _recargo_c is null then
	let _recargo_c = 0;
end if

let _opcion_b = _descuento_b + _recargo_b;
let _opcion_c = _descuento_c + _recargo_c;

if _opcion_b + _opcion_c <> 0 then
	return 1;
else
	return 0;
end if

END
END PROCEDURE
