-- Retorna el Resumen Historico de Gestiones 
-- Para un Pagador o un Cobrador
-- 
-- Creado    : 24/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/04/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cobr_sp_cob100_dw1 - DEIVID, S.A.

drop procedure sp_cas005;

create procedure sp_cas005(a_cod_pagador char(10), a_cod_cobrador char(3))
returning char(50),
          smallint,
          smallint;

define _cod_gestion		char(3);
define _cantidad		smallint;
define _nombre			char(50);
define _tipo_contacto	smallint;

set isolation to dirty read;

foreach 
 select cod_gestion,
        count(*)
   into _cod_gestion,
        _cantidad	
   from cobcahis
  where cod_pagador  matches a_cod_pagador
    and cod_cobrador matches a_cod_cobrador
    and cod_pagador  is not null
  group by 1
  order by 1

	select nombre,
	       tipo_contacto
	  into _nombre,
		   _tipo_contacto	
	  from cobcages
	 where cod_gestion = _cod_gestion;

	return _nombre,
	       _cantidad,
		   _tipo_contacto
		   with resume;

end foreach

end procedure
