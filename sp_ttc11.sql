-- Procedure que convierte la tabla de versiones inma de ttcorp en las marcas, modelos y versiones inma en deivid

-- Creado    : 27/08/2014 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_ttc11;

create procedure sp_ttc11(
a_marca_inma	char(10)	default "*",
a_modelo_inma	char(10)	default "*"
) returning integer,
            char(100);

define _civi			char(10);
define _marca			char(100);
define _modelo			char(100);
define _version			char(100);
define _codtrans		smallint;
define _motor			char(50);
define _tipo			smallint;
define _pasajeros		smallint;
define _tamano			smallint;

define _marca_inma		char(3);
define _modelo_inma		char(6);
define _cantidad		smallint;

define _cod_marca		char(5);
define _cod_modelo		char(5);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

--set debug file to "sp_ttc11.trc";
--trace on;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

-- Marcas

foreach
 select civi[1,3],
		marca
   into	_marca_inma,		
		_marca		
   from	version_inma
  where civi[1,3] matches a_marca_inma
  group by 1, 2
  order by 1, 2

	select count(*)
	  into _cantidad
	  from marca_inma
	 where cod_marca = _marca_inma;
	 
	 if _cantidad = 0 then 

	 	insert into marca_inma
	 	values (_marca_inma, _marca); 				

	end if

end foreach

-- Modelos

foreach
 select civi[1,3],
		civi[1,6],
		modelo
   into	_marca_inma,
		_modelo_inma,
		_modelo
   from	version_inma
  where civi[1,3] matches a_marca_inma
    and civi[1,6] matches a_modelo_inma
  group by 1, 2, 3
  order by 1, 2, 3

	select count(*)
	  into _cantidad
	  from modelo_inma
	 where cod_modelo = _modelo_inma;
	 
	 if _cantidad = 0 then 

	 	insert into modelo_inma
	 	values (_modelo_inma, _modelo, _marca_inma); 				

	end if

end foreach

-- Versiones 
--{

delete from emimodelver;

foreach
 select civi,
		marca,
		modelo,
		version,
		codtrans,
		motor,
		tipoveh,
		npasajeros,
		tamano,
		civi[1,3],
		civi[1,6]
   into	_civi,		
		_marca,		
		_modelo,		
		_version,		
		_codtrans,	
		_motor,		
		_tipo,		
		_pasajeros,
		_tamano,
		_marca_inma,
		_modelo_inma		
   from	version_inma
  where civi[1,3] matches a_marca_inma
    and civi[1,6] matches a_modelo_inma

	let _error = 0;

	-- Marcas Deivid

	select cod_marca
	  into _cod_marca
	  from emimarca
	 where marca_inma = _marca_inma;
	 
	if _cod_marca is null then

		let _error = 1;
--	 	return 1, "No Hay Registros en Deivid para la Marca " || _marca_inma || " " || trim(_marca) with resume; 

	end if

	-- Modelos Deivid

	let _cod_modelo = null;

	foreach	
	 select cod_modelo
	   into _cod_modelo
	   from emimodel
	  where modelo_inma = _modelo_inma
	  order by cod_modelo
		exit foreach;
	end foreach	
	 
	 if _cod_modelo is null then 

		let _error = 1;
--	 	return 1, "No Hay Registros en Deivid para el Modelo " || _modelo_inma || " " || trim(_modelo) with resume; 

	end if

	-- Versiones Deivid

	if _error = 0 then
	
		select count(*)
		  into _cantidad
		  from emimodelver
		 where cod_version = _civi;
		 

		 if _cantidad = 0 then 

			let _version = UPPER(_version);
			let _version = REPLACE(trim(_version),"SINCRONICO","MANUAL");
			let _version = REPLACE(trim(_version),"SECUENCIAL","TIPTRONIC");

			insert into emimodelver(
			cod_version,
			cod_modelo,
			nombre,
			cov,
			transmision,
			motor,
			pasajeros,
			tamano,
			tipo
			)
			values(
			_civi,
			_cod_modelo,
			_version,
			null,
			_codtrans,
			_motor,
			_pasajeros,
			_tamano,
			_tipo
			);

		end if

	end if
					
end foreach
--}

end

return 0, "Actualizacion Exitosa";

end procedure
