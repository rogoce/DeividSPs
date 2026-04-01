-- Retorna el Resumen Historico de Rutero(cobruhis)
-- Para un Pagador o un Cobrador
-- 
-- Creado    : 08/09/2003 - Autor: Armando Moreno M.
-- Modificado: 08/09/2003 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - d_cobr_sp_cob100_dw1 - DEIVID, S.A.

drop procedure sp_cas65a;

create procedure sp_cas65a()
returning char(30),
          smallint,
          char(10);

define _cod_cobrador	char(3);
DEFINE _descripcion     CHAR(30);
define _cod_pagador		char(10);
define _cod_motiv		char(3);
define _procedencia		smallint;
define _dia_cobros1		smallint;
define _codigo			smallint;
define _nombre_cobrador char(50);
define _nombre_motivo   char(50);
define _a_pagar			dec(16,2);
define _user_added	    char(8);
define _user_posteo     char(8);
define _fecha_posteo 	datetime year to fraction(5);
define _fecha			datetime year to fraction(5);
define _code_pais		    char(3);
define _code_provincia	    char(2);
define _code_ciudad  	    char(2);
define _code_distrito	    char(2);
define _code_correg  	    char(5);

ON EXCEPTION SET _codigo
 	RETURN 'Error al Realizar actualizacion',_codigo,_cod_pagador;
END EXCEPTION

SET ISOLATION TO DIRTY READ;

LET _codigo      = 0;
LET _descripcion = 'Actualizacion Exitosa ...';

foreach 
 select cod_cobrador,
        dia_cobros1,
		fecha,
		cod_motiv,
		a_pagar,
		user_added,
		procedencia,
		fecha_posteo,
		user_posteo,
		cod_pagador
   into _cod_cobrador,
        _dia_cobros1,
		_fecha,
		_cod_motiv,
		_a_pagar,
		_user_added,
		_procedencia,
		_fecha_posteo,
		_user_posteo,
		_cod_pagador
   from cobruhis
  where procedencia = 0

	select code_pais,
		   code_provincia,
		   code_ciudad,
		   code_distrito,
		   code_correg,
		   cod_cobrador,
		   procedencia
	  into _code_pais,
		   _code_provincia,
		   _code_ciudad,
		   _code_distrito,
		   _code_correg,
		   _cod_cobrador,
		   _procedencia
	  from cobruter1
	 where cod_pagador = _cod_pagador;

	if _cod_cobrador is null then
		delete from cobruhis
		 where fecha       = _fecha
		   and dia_cobros1 = _dia_cobros1
		   and procedencia = 0
		   and cod_cobrador = "";

		continue foreach;
	end if

    update cobruhis
	   set cod_cobrador   = _cod_cobrador,
		   code_pais      =	_code_pais,
		   code_provincia =	_code_provincia,
		   code_ciudad    =	_code_ciudad,
		   code_distrito  =	_code_distrito,
	       code_correg	  = _code_correg,
		   procedencia	  = _procedencia
	 where cod_pagador    =	_cod_pagador
	   and fecha          = _fecha
	   and dia_cobros1    = _dia_cobros1;

	return _descripcion,
		   _codigo,
		   _cod_pagador
		   with resume;

end foreach
end procedure
