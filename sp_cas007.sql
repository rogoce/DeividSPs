-- Procedimiento para actualizar los gestores
-- 
-- Creado    : 24/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/04/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas007;

create procedure sp_cas007()

define _cod_pagador		char(10);
define _cod_cobrador	char(3);
define _code_pais		char(3);
define _code_provincia	char(2);
define _code_ciudad		char(2);
define _code_distrito	char(2);
define _code_correg		char(5);
define _cod_sucursal    char(3);

define _no_documento	char(20);
define _no_poliza		char(10);
define _sucursal_origen	char(3);

--set debug file to "sp_cas007.sql";
--trace on;

{foreach
 select cod_cliente
   into _cod_pagador
   from cascliente
  where cod_cobrador is null
  order by 1

	 select code_pais,	  
			code_provincia,
			code_ciudad,	  
			code_distrito, 
			code_correg
	   into _code_pais,	  
			_code_provincia,
			_code_ciudad,	  
			_code_distrito, 
			_code_correg	  
	   from cliclien
	  where cod_cliente = _cod_pagador;

	select cod_sucursal
	  into _cod_sucursal
	  from gencorr
	 where code_pais	  =	_code_pais	  
	   and code_provincia =	_code_provincia
	   and code_ciudad	  =	_code_ciudad	
	   and code_distrito  =	_code_distrito
	   and code_correg    = _code_correg;

	if _cod_sucursal is null then

		select cod_sucursal,
		       code_pais,	  
			   code_provincia,
			   code_ciudad,	  
			   code_distrito
		  into _cod_sucursal,
		       _code_pais,	  
			   _code_provincia,
			   _code_ciudad,	  
			   _code_distrito
		  from gencorr
		 where code_correg = _code_correg;

		if _cod_sucursal is not null then

			update cliclien
			   set code_pais	  = _code_pais,
		           code_provincia = _code_provincia,
		           code_ciudad	  = _code_ciudad,
		           code_distrito  = _code_distrito
			 where cod_cliente    = _cod_pagador;

		else

			let _code_correg = "01";

		end if

	end if

	if _code_correg = "01" then

		update cliclien
		   set code_pais      = "001",
		       code_provincia = "01",
			   code_ciudad    = "01",
			   code_distrito  = "01",
			   code_correg    = "01"
	     where cod_cliente    = _cod_pagador;

		foreach
		 select no_documento
		   into _no_documento
		   from caspoliza
		  where cod_cliente = _cod_pagador

			let _no_poliza = sp_sis21(_no_documento);
			
			select sucursal_origen
			  into _sucursal_origen
			  from emipomae
			 where no_poliza = _no_poliza;

			if _sucursal_origen = "002" then
				let _cod_sucursal = _sucursal_origen;
			elif _sucursal_origen = "003" then
				let _cod_sucursal = _sucursal_origen;
			else
				let _cod_sucursal = "001";
			end if

			exit foreach;

		end foreach
			
	end if

	let _cod_cobrador = sp_cas006(_cod_sucursal, 1);

	update cascliente
	   set cod_cobrador = _cod_cobrador
	 where cod_cliente  = _cod_pagador;
	
end foreach		  }

end procedure
