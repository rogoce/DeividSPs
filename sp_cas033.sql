-- Chequear Areas del Rutero Vs Areas de Clientes

-- Creado    : 19/06/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 19/06/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas033;	  

create procedure sp_cas033()
returning char(10),
          char(5),
		  char(5),
		  char(3),
		  char(3);

define _cod_pagador		char(10);
define _cod_cobrador	char(3);
define _cod_cobrador_cl char(3);
define _code_pais	    char(3);
define _code_provincia	char(2);
define _code_ciudad	    char(2);
define _code_distrito	char(2);
define _code_correg1	char(5);
define _code_correg2	char(5);

foreach
 select code_correg,
        cod_pagador,
		cod_cobrador
   into _code_correg1,
        _cod_pagador,
		_cod_cobrador_cl
   from cobruter1

	select code_correg,
		   code_pais,	  
		   code_provincia,
		   code_ciudad,	  
		   code_distrito	
	  into _code_correg2,
		   _code_pais,	  
		   _code_provincia,
		   _code_ciudad,	  
		   _code_distrito	
	  from cliclien
	 where cod_cliente = _cod_pagador;

	select cod_cobrador
	  into _cod_cobrador
	  from gencorr
	 where code_pais	  = _code_pais
	   and code_provincia = _code_provincia
	   and code_ciudad	  = _code_ciudad
	   and code_distrito  =	_code_distrito
	   and code_correg	  = _code_correg2;

	if _code_correg1 <> _code_correg2 then
		--update cobruter1
		--   set code_correg = _code_correg2,
		       

		return _cod_pagador,
		       _code_correg1,
			   _code_correg2,
			   _cod_cobrador,
			   _cod_cobrador_cl
			   with resume;

	end if

end foreach

end procedure
