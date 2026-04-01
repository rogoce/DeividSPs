-- 
-- Creado    : 23/01/2004 - Autor: Armando Moreno M.

-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

--drop procedure sp_averiguar;

create procedure sp_averiguar()
returning char(10),
          char(100),
		  smallint,
		  date,
          char(100),
          char(20),
		  smallint,
		  char(6);

define _cod_cliente		char(10);
define _nombre	        char(50);
define _no_documento      char(20);
define _ultima_gestion	char(100);
define _nombre_pagador	char(100);
define _dia_cobros3     smallint;
define _estatus_poliza  smallint;
define _cod_gestion     char(3);
define _no_poliza	    char(10);
define _cantidad,_existe smallint;
define _fecha_ult_pro	date;
define _tipo            char(6);

--set debug file to "sp_cob101.trc";

set isolation to dirty read;

let _tipo = '';
begin

foreach
	select cod_cliente,
		   dia_cobros3,
		   fecha_ult_pro,
		   ultima_gestion
	  into _cod_cliente,
	       _dia_cobros3,
		   _fecha_ult_pro,
		   _ultima_gestion
 	  from cascliente
	 where cod_cobrador = '092'

	select count(*)
      into _cantidad
      from cobcapen
     where cod_cliente = _cod_cliente;

	select nombre
	  into _nombre_pagador
	  from cliclien
	 where cod_cliente = _cod_cliente;

	select count(*)
	  into _existe
	  from cobruter1
	 where cod_pagador = _cod_cliente;

	if _existe = 1 then
		let _tipo = 'RUTERO';
	else
		let _tipo = '';
	end if
	if _cantidad = 0 then

		foreach

			select no_documento
		      into _no_documento
		      from caspoliza
		     where cod_cliente = _cod_cliente

			let _no_poliza = sp_sis21(_no_documento);

			select estatus_poliza
		      into _estatus_poliza
		      from emipomae
		     where no_poliza = _no_poliza;

		     return _cod_cliente,
					_nombre_pagador,
				    _dia_cobros3,
			        _fecha_ult_pro,
			        _ultima_gestion,
				    _no_documento,
				    _estatus_poliza,
				    _tipo WITH RESUME;
			           
		end foreach
	end if
end foreach

end

end procedure