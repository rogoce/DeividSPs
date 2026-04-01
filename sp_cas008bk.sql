-- Retorna la Gestion de un Pagador o de Una Poliza
-- 
-- Creado    : 24/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/04/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas008bk;

create procedure sp_cas008bk(a_cod_pagador char(10), a_no_documento char(20), a_cod_campana char(10))
returning char(20),
          datetime year to second,
		  char(512),
		  char(50),
		  char(8);

define _no_documento  	char(20);
define _fecha_gestion 	datetime year to second;
define _descripcion   	char(512);
define _user_added	  	char(8);
define _cod_gestion	  	char(3);
define _nombre_gestion	char(50);
define _cont			integer;

set isolation to dirty read;

--set debug file to "sp_cas008bk.trc";
--trace on;

let _cont = 0;

CREATE TEMP TABLE temp_gestion
             (no_documento		char(20),
              fecha_gestion		datetime year to second,
              descripcion		char(512),
              nombre_gestion	char(50),
              user_added		char(8))
              WITH NO LOG;


foreach
	select distinct no_documento
	  into _no_documento
	  from caspoliza
	 where cod_cliente = a_cod_pagador

	foreach
	 
	 select distinct g.no_documento,
	        g.fecha_gestion,
			g.desc_gestion,
			g.user_added,
			g.cod_gestion
	   into _no_documento,
	        _fecha_gestion,
			_descripcion,
			_user_added,
			_cod_gestion
	   from cobgesti g
	  where g.no_documento = _no_documento
	  order by fecha_gestion desc

		if _cod_gestion is null then
		let _cod_gestion = '';
		end if
		let _cont = _cont + 1;

		let _nombre_gestion = '';	

		select nombre
		  into _nombre_gestion
		  from cobcages
		 where cod_gestion = _cod_gestion;

		insert into temp_gestion(no_documento,
								 fecha_gestion,
								 descripcion,
								 nombre_gestion,
								 user_added)
						  values (_no_documento,
								  _fecha_gestion,
								  _descripcion,
								  _nombre_gestion,
								  _user_added);
	end foreach
end foreach

foreach
	select no_documento,
		   fecha_gestion,
		   descripcion,
		   nombre_gestion,
		   user_added
	  into _no_documento,
		   _fecha_gestion,
		   _descripcion,
		   _nombre_gestion,
		   _user_added
	  from temp_gestion
	 order by fecha_gestion desc

	return _no_documento,
		   _fecha_gestion,
		   _descripcion,
		   _nombre_gestion,
		   _user_added
		   with resume;
end foreach

drop table temp_gestion;

end procedure
