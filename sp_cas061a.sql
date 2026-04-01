-- Procedimiento para verificacion de inf. callcenter

-- Creado    : 04/04/2003 - Autor: Armando Moreno M.
-- Modificado: 30/04/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

drop procedure sp_cas061a;

create procedure sp_cas061a(a_compania CHAR(3),a_agencia CHAR(3),a_cobrador CHAR(3))
RETURNING SMALLINT,
		  integer,	
          CHAR(100);

define _cod_cliente		char(10);
define _sucursal_origen	char(3);
define _cod_sucursal	char(3);
define _cod_cobrador	char(3);
define _no_poliza		char(10);
define _no_documento    char(20);
define _nombre_pagador  char(100);
define _cuantas,_van	integer;
define _estatus_poliza  smallint;
define _dia             smallint;
define _fecha_ult_pro   date;
define _error_code      INTEGER;
define _error_desc		char(50);
define _error_isam		integer;

set isolation to dirty read;

BEGIN

ON EXCEPTION SET _error_code, _error_isam, _error_desc 
 	RETURN _error_code, _error_desc, '';
END EXCEPTION

foreach
	select cod_cliente
	  into _cod_cliente
	  from cascliente 
	 where cod_cobrador = a_cobrador

	select nombre
	  into _nombre_pagador
	  from cliclien 
	 where cod_cliente = _cod_cliente;

	let _cuantas = 0;
	let _van     = 0;

	select	count(*)
	  into	_cuantas
	  from	caspoliza
	 where	cod_cliente = _cod_cliente;

  foreach
	select	no_documento
	  into	_no_documento
	  from	caspoliza
	 where	cod_cliente = _cod_cliente

	 let _no_poliza = sp_sis21(_no_documento);

	select estatus_poliza,
		   sucursal_origen
	  into _estatus_poliza,
		   _sucursal_origen
	  from emipomae
	 where no_poliza = _no_poliza;

	   if _estatus_poliza = 1 then

		  let _van = _van + 1;

		  if _cuantas = _van then

			let _cod_cobrador = sp_cas006("001", 1);

			update cascliente
			   set cod_cobrador     = _cod_cobrador
			 where cod_cliente      = _cod_cliente;

			update cobcapen
			   set cod_cobrador = _cod_cobrador
		     where cod_cliente  = _cod_cliente;
			
			exit foreach;

		  end if

	   end if

	end foreach
end foreach
RETURN 0, 0,'Actualizacion Exitosa...';
end
end procedure