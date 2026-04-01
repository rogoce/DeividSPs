-- Retorna la Gestion de un Pagador o de Una Poliza
-- 
-- Creado    : 24/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/04/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas008;

create procedure sp_cas008(a_cod_pagador char(10), a_no_documento char(20))
returning char(20),
          datetime year to second,
		  char(250),
		  char(50),
		  char(8);

define _no_documento  	char(20);
define _fecha_gestion 	datetime year to second;
define _descripcion   	char(250);
define _user_added	  	char(8);
define _cod_gestion	  	char(3);
define _nombre_gestion	char(50);

set isolation to dirty read;

foreach
 select g.no_documento,
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
  where g.cod_pagador  matches a_cod_pagador
    and g.no_documento matches a_no_documento
  order by fecha_gestion desc

	if _cod_gestion is null then
		let _cod_gestion = '';
	end if
	
	let _nombre_gestion = '';	


	select nombre
	  into _nombre_gestion
	  from cobcages
	 where cod_gestion = _cod_gestion;

	return _no_documento,
	       _fecha_gestion,
		   _descripcion,
		   _nombre_gestion,
		   _user_added
		   with resume;

end foreach

end procedure
