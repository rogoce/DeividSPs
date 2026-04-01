-- Actualizar el Rutero dependiendo de las areas
-- 
-- Creado    : 08/03/2004 - Autor: Demetrio Hurtado Almanza
-- Modificado: 08/03/2004 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_cas071;

CREATE PROCEDURE "informix".sp_cas071()

define _cod_correg		char(5);
define _cod_cobrador	char(3);

foreach 
 select code_correg,
		cod_cobrador
   into _cod_correg,
        _cod_cobrador
   from gencorr

	update cobruter
	   set cod_cobrador = _cod_cobrador
	 where code_correg  = _cod_correg;
	
	update cobruter1
	   set cod_cobrador = _cod_cobrador
	 where code_correg  = _cod_correg;

	update cobruter2
	   set cod_cobrador = _cod_cobrador
	 where code_correg  = _cod_correg;

end foreach

end procedure
