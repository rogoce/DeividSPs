-- Carga masiva de codigos de color,acreedor y modelo para la creacion de equivalencias
-- Autor: Roman Gordon 

drop procedure sp_importar_codigos_col;

create procedure "informix".sp_importar_codigos_col()
returning char(10), char(100),char(10),char(5);

define _descripcion			char(30);
define _nombre_valor_agt	char(30);
define _cod_agt				char(10);
define _cod_ancon			char(5);
define _cod_ancon2			char(5);
define _error_isam			integer;
define _error				integer;
define _cnt_existe			smallint;
  
begin

{on exception set _error, _error_isam, _descripcion
 	return _error, _descripcion;
end exception}

set isolation to dirty read;


--SET DEBUG FILE TO "sp_importar_codigos.trc"; 
--TRACE ON;
let _nombre_valor_agt = '';
let _cod_ancon2 = '';

foreach
	select cod_color,
		   nombre
	  into _cod_agt,
	  	   _nombre_valor_agt
	  from tmp_colores
	
	let _cnt_existe = 0;

	select count(*)
	  into _cnt_existe
	  from equicolor
	 where cod_color_agt = _cod_agt;

	if _cnt_existe <> 0 then
		continue foreach;
	end if		
	  
	let _nombre_valor_agt = trim(lower(_nombre_valor_agt));
	let _cod_ancon = '';

	foreach	
		select cod_color	
		  into _cod_ancon
		  from emicolor
		 where trim(lower(nombre)) = _nombre_valor_agt
		exit foreach;
	end foreach

	if _cod_ancon is null or _cod_ancon = '' then
		continue foreach;
	end if

	insert into equicolor(
			cod_agente,
			cod_color_agt,
			cod_color_ancon
			)
	values	('00035',
			_cod_agt,	
			_cod_ancon
			);	

	return _cod_agt,_nombre_valor_agt,_cod_ancon,_cod_ancon2 with resume;
end foreach
end
end procedure



