-- Procedimiento que retorna el descuento por siniestralidad

-- Tarifas Agosto 2015

drop procedure sp_pro549;

create procedure "informix".sp_pro549(
a_no_siniestro		smallint,
a_no_promedio		dec(5,2),
a_siniestralidad	dec(16,2)
) returning dec(5,2), smallint;

define _porc_descuento	dec(5,2);
define _tipo       smallint;

let _porc_descuento = 0;
let _tipo = 0;

if a_no_siniestro < 0 then
	let a_no_siniestro = 0;
end if

if a_no_promedio < 0 then
	let a_no_promedio = 0;
end if

if a_siniestralidad < 0 then
	let a_siniestralidad = 0;
end if
if a_siniestralidad > 999.99 then
	let a_siniestralidad = 999.99;
end if
foreach
 select porc_descuento,
        tipo				--Tipo = 0 es descuento; 1 es recargo
   into _porc_descuento,
        _tipo
   from emidescsini
  where a_no_siniestro	>=	no_siniestro_desde
    and a_no_siniestro		<=	no_siniestro_hasta
	and a_no_promedio		>=	no_promedio_desde
	and a_no_promedio		<=	no_promedio_hasta
	and a_siniestralidad	>=	siniestralidad_desde
	and a_siniestralidad	<=	siniestralidad_hasta
  order by condicion
	exit foreach;
end foreach

return _porc_descuento, _tipo;

end procedure

