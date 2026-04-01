-- Sacar descuento para las primas y recargo para los deducibles por opción seleccionada por el asegurado
--
-- creado    : 24/03/2013 - Autor: Armando Moreno
-- sis v.2.0

drop procedure sp_pro603;
create procedure "informix".sp_pro603(a_no_poliza char(10), a_cod_producto char(5), a_opcion CHAR(1) DEFAULT NULL)
returning dec(16,2),
		  dec(16,2);

define _descuento	      decimal(16,2);
define _recargo           decimal(16,2);
define _cod_ramo          char(3);
define _cod_subramo       char(3);

begin

set isolation to dirty read;

--set debug file to "sp_niif01.trc"; 
--trace on;

select cod_ramo,
       cod_subramo
  into _cod_ramo,
       _cod_subramo
  from emipomae
 where no_poliza = a_no_poliza; 
 
if _cod_ramo <> '002' then
	return 0,0;
end if

if _cod_ramo = '002' and _cod_subramo <> '001' then
	return 0,0;
end if

let _descuento = 0;
let _recargo  = 0;

if a_opcion = 'A' or a_opcion is null or trim(a_opcion) = "" then
	let _descuento = 0;
	let _recargo = 0;
elif a_opcion = 'B' then
	select descuento_b,
	       recargo_b
	  into _descuento,
	       _recargo
	  from prdprod  
     where cod_producto = a_cod_producto;
elif a_opcion = 'C' then
	select descuento_c,
	       recargo_c
	  into _descuento,
	       _recargo
	  from prdprod  
     where cod_producto = a_cod_producto;
end if 

if _descuento is null then
	let _descuento = 0;
end if

if _recargo is null then
	let _recargo = 0;
end if

return _descuento, _recargo;

end
end procedure
