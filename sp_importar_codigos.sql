-- Carga masiva de codigos de color,acreedor y modelo para la creacion de equivalencias
-- Autor: Roman Gordon 

drop procedure sp_importar_codigos;

create procedure "informix".sp_importar_codigos()
returning char(10), char(100),char(10),char(5);

define _descripcion			char(30);
define _nombre_valor_agt	char(30);
define _cod_agt				char(10);
define _cod_ancon			char(5);
define _cod_ancon2			char(5);
define _error_isam			integer;
define _error				integer;
  
begin

{on exception set _error, _error_isam, _descripcion
 	return _error, _descripcion;
end exception}

set isolation to dirty read;


--SET DEBUG FILE TO "sp_importar_codigos.trc"; 
--TRACE ON;
let _nombre_valor_agt = '';

foreach
	select codigo,
		   nombre
	  into _cod_agt,
	  	   _nombre_valor_agt
	  from tmp_importar
	  
	let _nombre_valor_agt = trim(lower(_nombre_valor_agt));
	let _cod_ancon = '';

	foreach	
		select cod_modelo,
			   cod_marca	
		  into _cod_ancon,
			   _cod_ancon2	
		  from emimodel
		 where cod_marca in ('00128','00126')
		   and trim(lower(nombre)) = _nombre_valor_agt
		exit foreach;
	end foreach

	if _cod_ancon is null or _cod_ancon = '' then
		continue foreach;
	end if

	insert into equimodel(
			cod_agente,
			cod_modelo_agt,
			cod_marca_ancon,
			cod_modelo_ancon
			)
	values	('00035',
			_cod_agt,	
			_cod_ancon2,
			_cod_ancon
			);	

	return _cod_agt,_nombre_valor_agt,_cod_ancon,_cod_ancon2 with resume;
end foreach
end
end procedure



