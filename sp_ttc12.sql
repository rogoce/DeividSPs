-- Procedure que Actualiza los valores de las marcas y los modelos

-- Creado    : 02/09/2014 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_ttc12;

create procedure sp_ttc12() 
returning char(10),
		  char(10),
		  char(50),
		  char(50);

define _cod_marca			char(10);
define _cod_inma			char(10);
define _cod_modelo			char(10);
define _cod_modelo_inma		char(10);

define _nombre_marca		char(50);
define _nombre_inma			char(50);
define _nombre_modelo		char(50);
define _nombre_modelo_inma	char(50);

define _match				smallint;

{
foreach
 select m.cod_marca, i.cod_inma, m.nombre, i.nombre_inma
   into _cod_marca, _cod_inma, _nombre_marca, _nombre_inma
   from emimarca m, (select trim(nombre) as nombre_inma, cod_marca as cod_inma from marca_inma) i
  where m.marca_inma is null
    and trim(m.nombre) = i.nombre_inma
  order by m.nombre

	update emimarca
	   set marca_inma = _cod_inma
	 where cod_marca  = _cod_marca;

	return _cod_marca, _cod_inma, _nombre_marca, _nombre_inma with resume;

end foreach
}

foreach
 select cod_marca,
        nombre
   into _cod_inma,
        _nombre_inma
   from marca_inma
--  where cod_marca = "074"
  order by nombre

	select cod_marca
	  into _cod_marca
	  from emimarca
	 where marca_inma = _cod_inma;

	if _cod_marca is null then
		continue foreach;
	end if

	foreach 
	 select cod_modelo,
	        trim(nombre)
	   into _cod_modelo_inma,
			_nombre_modelo_inma
	   from modelo_inma
	  where cod_marca = _cod_inma
	  order by nombre

		foreach
		 select cod_modelo,
		        nombre
		   into	_cod_modelo,
		        _nombre_modelo
		   from emimodel
		  where cod_marca   = _cod_marca
		    and modelo_inma is null
		  order by nombre  

			let _match = sp_ttc13(_nombre_modelo, _nombre_modelo_inma);
			
			if _match = 1 then

				update emimodel
				   set modelo_inma = _cod_modelo_inma
				 where cod_modelo  = _cod_modelo;

				return _cod_modelo_inma, _cod_modelo, _nombre_modelo_inma, _nombre_modelo with resume;

			end if
			
		end foreach
	
	end foreach

end foreach

return "", "", "", "";

end procedure
