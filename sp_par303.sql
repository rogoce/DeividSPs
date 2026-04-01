-- Procedimiento que cambia la forma de pago a "Cuentas Malas (082)"
-- 
-- Creado     : 25/09/2010 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_par303;

create procedure "informix".sp_par303() returning integer,
            char(100);

define _no_documento	char(20);
define _no_poliza		char(10); 

define _cod_pagador		char(10);
define _nombre			varchar(100);
define _razon			varchar(100);

foreach
 select poliza,
        obs
   into _no_documento,
        _razon
   from deivid_tmp:cobinc201010

	let _no_poliza = sp_sis21(_no_documento);

	select cod_pagador
	  into _cod_pagador
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nombre
	  from cliclien
	 where cod_cliente = _cod_pagador;

	insert into cobcuema(
	no_documento,
	cod_cliente,
	nombre,
	user_added,
	date_added,
	cancelar,
	actualizado,
	user_cancelo,
	date_cancelo,
	razon
	)
	values(
	_no_documento,
	_cod_pagador,
	_nombre,
	"ANARANJO",
	"24/09/2010",
	1,
	0,
	null,
	null,
	_razon
	);

end foreach

return 0, "Actualizacion Exitosa";

end procedure