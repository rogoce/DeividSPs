-- Procedimiento para verificacion de inf. callcenter

-- Creado    : 04/04/2003 - Autor: Armando Moreno M.
-- Modificado: 30/04/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

--drop procedure sp_cas061;

create procedure sp_cas061(a_compania CHAR(3),a_agencia CHAR(3),a_cobrador CHAR(3), a_dia smallint)
returning char(10),CHAR(20),CHAR(100),date;

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
define _fecha_suscripcion date;

--set debug file to "sp_cob101.trc";

set isolation to dirty read;


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
		   sucursal_origen,
		   fecha_suscripcion
	  into _estatus_poliza,
		   _sucursal_origen,
		   _fecha_suscripcion
	  from emipomae
	 where no_poliza = _no_poliza;

	   if _estatus_poliza = 1 then

		  let _van = _van + 1;

		  if _cuantas = _van then

			{if _sucursal_origen = "002" then
				let _cod_sucursal = _sucursal_origen;
			elif _sucursal_origen = "003" then
				let _cod_sucursal = _sucursal_origen;
			else
				let _cod_sucursal = "001";
			end if

			let _cod_cobrador = sp_cas006(_cod_sucursal, 1);

			select fecha_ult_pro
			  into _fecha_ult_pro
			  from cobcobra
			 where cod_cobrador = _cod_cobrador;

			let _fecha_ult_pro = _fecha_ult_pro + 1;
			let _dia = day(_fecha_ult_pro);

			update cascliente
			   set cod_cobrador_ant = null,
			       cod_cobrador     = _cod_cobrador,
				   dia_cobros1      = _dia,
				   dia_cobros2      = _dia
		     where cod_cliente      = _cod_cliente;}

			  foreach
				select	no_documento
				  into	_no_documento
				  from	caspoliza
				 where	cod_cliente = _cod_cliente

				  RETURN _cod_cliente,
						 _no_documento,
						 _nombre_pagador,
						 _fecha_suscripcion
						with resume;
			  end foreach

		  end if
	   end if

	end foreach
end foreach
end procedure