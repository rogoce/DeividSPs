-- Verifica si la ruta aplica para la Distribución de Reaseguro por plenos.
-- Creado    : 13/01/2012 - Autor: Roman Gordon
-- SIS v.2.0 - - DEIVID, S.A.


drop procedure sp_cob301;

create procedure sp_cob301(a_compania char (3),a_periodo char(10))
returning char(100),
		  char(20),
		  date,
		  date,
		  smallint,
		  char(5),
		  char(10),
		  date,
		  char(50),
		  smallint,
		  date,
		  char(50),
		  dec(16,2);

define _cnt_reversar		smallint;
define _no_pagos			smallint;
define _monto_descontado	dec(16,2);
define _nom_pagador			char(100);
define _nom_formapag		char(50);
define v_compania_nombre	char(50);
define _no_documento		char(20);
define _cod_pagador			char(10);
define _no_factura			char(10);
define _no_poliza			char(10);
define _no_endoso			char(5);
define _cod_formapag		char(3);
define _vigencia_inic_pol	date;
define _vigencia_final_pol	date;
define _fecha_impresion		date;
define _fecha_impresion_rev date;

--set debug file to "sp_cob301.trc";
--trace on;

set isolation to dirty read;

let _fecha_impresion_rev	= '01/01/1900';
let _fecha_impresion 		= '01/01/1900';
let _cnt_reversar			= 0;
let v_compania_nombre 		= sp_sis01(a_compania); 

foreach
	select no_documento,
		   no_endoso,
		   cod_formapag,
		   vigencia_inic_pol,
		   vigencia_final_pol,
		   no_factura,
		   no_pagos,
		   fecha_impresion,
		   no_poliza,
		   prima_bruta
	  into _no_documento,
		   _no_endoso,
		   _cod_formapag,
		   _vigencia_inic_pol,
		   _vigencia_final_pol,
		   _no_factura,
		   _no_pagos,
		   _fecha_impresion,
		   _no_poliza,
		   _monto_descontado
	  from endedmae
	 where cod_endomov = '024'
	   and periodo = a_periodo
	   and actualizado = 1
	   and cod_formapag in ('003','005')
	
	select cod_pagador
	  into _cod_pagador
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nom_pagador
	  from cliclien
	 where cod_cliente = _cod_pagador;

	select count(*)
	  into _cnt_reversar
	  from endedmae
	 where no_poliza = _no_poliza
	   and cod_endomov = '025';


	if _cnt_reversar > 0 then
		let _cnt_reversar = 1;

		select max(fecha_impresion)
		  into _fecha_impresion_rev
		  from endedmae
		 where no_poliza = _no_poliza
		   and cod_endomov = '025';
	end if
	
	select nombre
	  into _nom_formapag
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	return _nom_pagador,
		   _no_documento,
		   _vigencia_inic_pol,
		   _vigencia_final_pol,
		   _no_pagos,
		   _no_endoso,
		   _no_factura,
		   _fecha_impresion,
		   _nom_formapag,
		   _cnt_reversar,
		   _fecha_impresion_rev,
		   v_compania_nombre,
		   _monto_descontado with resume;

end foreach
end procedure
	  