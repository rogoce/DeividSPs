-- para hacer una prueba
-- 
-- Creado    : 10/09/2003 - Autor:Armando Moreno
-- Modificado: 10/09/2003 - Autor:Armando Moreno
--

drop procedure sp_cas80a;

create procedure sp_cas80a(a_cod_gestion char(3))

define _cod_pagador     char(10);
define _nombre_pagador	char(100);
define _no_documento	char(50);
define _desc_formapag	char(50);
define _cod_formapag	char(3);
define _no_poliza		char(10);
define _no_cuenta		char(17);
define _cant,_flag		integer;
define _cant_polizas	integer;

--set debug file to "sp_cas68.trc";
--trace on;

let _flag = 0;

foreach
 select cod_cliente
   into _cod_pagador
   from cascliente
  where cod_gestion = a_cod_gestion

 foreach
	 select no_documento
	   into _no_documento
	   from caspoliza
	  where cod_cliente = _cod_pagador
	  order by no_documento

	 let _no_poliza = sp_sis21(_no_documento);

	 select no_cuenta
	   into _no_cuenta
	   from emipomae
	  where no_poliza = _no_poliza;

	 select count(*)
	   into _cant
	   from cobcutas
	  where no_cuenta = _no_cuenta;

     if _cant > 0 then  --existe en ach

		 select count(*)
		   into _cant_polizas
		   from caspoliza
		  where cod_cliente = _cod_pagador;

		delete from caspoliza
		 where no_documento = _no_documento;

		if _cant_polizas = 1 then	   --solo una poliza
			let _flag = 0;
			delete from cobcapen
			 where cod_cliente = _cod_pagador;

			delete from cascliente
			 where cod_cliente = _cod_pagador;
		end if

	 end if

 end foreach

end foreach

end procedure


				  