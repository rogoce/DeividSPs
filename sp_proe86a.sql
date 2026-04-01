-- Procedimiento que calcula el descuento por: Edad del Asegurado

-- Creado:	12/01/2017 - Autor: Amado Perez M

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_proe86a;
 
create procedure sp_proe86a(a_poliza CHAR(10), a_unidad CHAR(5))
returning dec(16,2);

define _porc_desc	  		dec(16,2);
define _edad          		smallint;
define _vigencia_inic 		date;
define _cod_asegurado 		char(10);
define _tipo_persona  		char(1);
define _fecha_aniversario 	date;

--set debug file to "sp_proe72.trc";
--trace on;

set isolation to dirty read;

let _porc_desc = 0.00;

select cod_asegurado,
       vigencia_inic
  into _cod_asegurado,
       _vigencia_inic
  from emipouni
 where no_poliza = a_poliza
   and no_unidad = a_unidad;
   
 let _vigencia_inic = _vigencia_inic + 1 units year;
   
 select tipo_persona,
        fecha_aniversario
   into _tipo_persona,
        _fecha_aniversario
   from cliclien
  where cod_cliente = _cod_asegurado;
  
 if _tipo_persona = 'N' then
	if _fecha_aniversario is null or _fecha_aniversario = "00/00/0000" then
		let _porc_desc = 0.00;
	else
		let _edad = sp_sis78(_fecha_aniversario, _vigencia_inic);
		if _edad >= 55 and _edad <= 85 then
			let _porc_desc = 7.00;
		end if
	end if
 else
	let _porc_desc = 0.00;
 end if
   

return _porc_desc;

end procedure
