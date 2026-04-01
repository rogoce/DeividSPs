-- Retorna el Resumen Historico de Rutero(cobruhis)
-- Para un Pagador o un Cobrador
-- 
-- Creado    : 08/09/2003 - Autor: Armando Moreno M.
-- Modificado: 08/09/2003 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - d_cobr_sp_cob100_dw1 - DEIVID, S.A.

drop procedure sp_cas65;

create procedure sp_cas65(a_cod_pagador char(10))
returning char(50),
		  char(50),
          smallint,
          datetime year to fraction(5),
		  decimal(16,2),
		  char(8),
          smallint,
          datetime year to fraction(5),
		  char(8),
		  char(10);

define _cod_cobrador	char(3);
define _cod_motiv		char(3);
define _procedencia		smallint;
define _dia_cobros1		smallint;
define _nombre_cobrador char(50);
define _nombre_motivo   char(50);
define _a_pagar			dec(16,2);
define _user_added	    char(8);
define _user_posteo     char(8);
define _fecha_posteo 	datetime year to fraction(5);
define _fecha			datetime year to fraction(5);

set isolation to dirty read;

foreach 
 select cod_cobrador,
        dia_cobros1,
		fecha,
		cod_motiv,
		a_pagar,
		user_added,
		procedencia,
		fecha_posteo,
		user_posteo
   into _cod_cobrador,
        _dia_cobros1,
		_fecha,
		_cod_motiv,
		_a_pagar,
		_user_added,
		_procedencia,
		_fecha_posteo,
		_user_posteo
   from cobruhis
  where cod_pagador  matches a_cod_pagador

	select nombre
	  into _nombre_cobrador
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;

	select nombre
	  into _nombre_motivo
	  from cobmotiv
	 where cod_motiv = _cod_motiv;

	return _nombre_cobrador,
	       _nombre_motivo,
		   _dia_cobros1,
		   _fecha,
		   _a_pagar,
		   _user_added,
		   _procedencia,
		   _fecha_posteo,
		   _user_posteo,
		   a_cod_pagador
		   with resume;

end foreach
end procedure
