-- para hacer una prueba
-- 
-- Creado    : 10/09/2003 - Autor:Armando Moreno
-- Modificado: 10/09/2003 - Autor:Armando Moreno
--

drop procedure sp_cas80;

create procedure sp_cas80(a_cod_gestion char(3))
returning char(50),
		  char(10),
          char(3),
		  char(50),
		  char(20),
		  char(17),
		  char(3);

define _cod_pagador     char(10);
define _nombre_pagador	char(100);
define _no_documento	char(50);
define _desc_formapag	char(50);
define _cod_formapag	char(3);
define _no_poliza		char(10);
define _no_cuenta		char(17);
define _cant			integer;
define _cod_cobrador    char(3);

--set debug file to "sp_cas68.trc";
--trace on;

foreach
 select cod_cliente,
        cod_cobrador
   into _cod_pagador,
		_cod_cobrador
   from cascliente
  where cod_gestion = a_cod_gestion

 select nombre
   into _nombre_pagador
   from cliclien
  where cod_cliente = _cod_pagador;

 foreach
	 select no_documento
	   into _no_documento
	   from caspoliza
	  where cod_cliente = _cod_pagador
	  order by no_documento

	 let _no_poliza = sp_sis21(_no_documento);

	 select cod_formapag,
	        no_cuenta
	   into _cod_formapag,
			_no_cuenta
	   from emipomae
	  where no_poliza = _no_poliza;

	 select count(*)
	   into _cant
	   from cobcutas
	  where no_documento = _no_documento;

	 if _cant > 0 then
		 select no_cuenta
		   into _no_cuenta
		   from cobcutas
		  where no_documento = _no_documento;
	 end if

 	 select nombre
	   into _desc_formapag
	   from cobforpa
	  where cod_formapag = _cod_formapag;

	return _nombre_pagador,
		   _cod_pagador,
		   _cod_formapag,
		   _desc_formapag,
		   _no_documento,
		   _no_cuenta,
		   _cod_cobrador
		   with resume;
 end foreach
end foreach

end procedure


				  