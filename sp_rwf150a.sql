-- Procedimiento que calcula el descuento por: Cobertura y Suma Asegurada, vehículos de alta gama

-- Creado:	25/09/2018 - Autor: Amado Perez Mendoza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rwf150a;
 
create procedure sp_rwf150a(a_cobertura CHAR(5), a_suma DEC(16,2), a_cod_producto char(5))
returning dec(16,2),
          dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _desc_ded_a  decimal(16,2);
define _desc_ded_b  decimal(16,2);
define _desc_ded_c  decimal(16,2);
define _reca_pri_a  decimal(16,2);
define _reca_pri_b  decimal(16,2);
define _reca_pri_c  decimal(16,2);
define _opcion      char(1);
define _porc_ded    decimal(16,2);
define _porc_prima  decimal(16,2);

--set debug file to "sp_rwf150.trc";
--trace on;

set isolation to dirty read;

let _desc_ded_a       = 0;
let _desc_ded_b       = 0;
let _desc_ded_c       = 0;
let _reca_pri_a       = 0;
let _reca_pri_b       = 0;
let _reca_pri_c       = 0;
let _porc_ded         = 0;
let _porc_prima       = 0;

if a_cod_producto = '07627' then
	return 0.00,0.00,0.00,0.00,0.00,0.00;
end if

foreach
 select opcion,
        porc_ded,
		porc_prima
   into _opcion,
        _porc_ded,
		_porc_prima
   from prdcores1
  where cod_cobertura = a_cobertura
    and rango1 <= a_suma
	and rango2 > a_suma
	
  if _opcion = 'A' then
	let _desc_ded_a = _porc_ded;
	let _reca_pri_a = _porc_prima;
  elif _opcion = 'B' then
	let _desc_ded_b = _porc_ded;
	let _reca_pri_b = _porc_prima;
  elif _opcion = 'C' then
	let _desc_ded_c = _porc_ded;
	let _reca_pri_c = _porc_prima;
  end if  
end foreach

return _desc_ded_a,
       _reca_pri_a,
	   _desc_ded_b,
	   _reca_pri_b,
	   _desc_ded_c,
	   _reca_pri_c;

end procedure
