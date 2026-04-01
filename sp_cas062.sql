-- Procedimiento para verificacion de inf. callcenter

-- Creado    : 04/04/2003 - Autor: Armando Moreno M.
-- Modificado: 30/04/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

drop procedure sp_cas062;

create procedure sp_cas062(a_compania CHAR(3),a_agencia CHAR(3),a_cobrador CHAR(3), a_dia smallint)
returning char(10),CHAR(100),CHAR(50);

define _cod_cliente		char(10);
define _sucursal_origen	char(3);
define _cod_cobrador_ant char(3);
define _cod_sucursal	char(3);
define _cod_cobrador	char(3);
define _no_poliza		char(10);
define _no_documento    char(20);
define _nombre_pagador  char(100);
define _nombre_cobrador char(50);
define _cuantas,_van	integer;
define _estatus_poliza  smallint;
define _dia             smallint;
define _fecha_ult_pro   date;

--set debug file to "sp_cob101.trc";

set isolation to dirty read;


foreach
	select cod_cliente,
		   cod_cobrador_ant
	  into _cod_cliente,
		   _cod_cobrador_ant
	  from cascliente 
	 where cod_cobrador = a_cobrador
	   and cod_gestion  = "036"	--cte. sin cierre

	delete from cobcapen
	 where cod_cliente = _cod_cliente;

	select nombre
	  into _nombre_pagador
	  from cliclien 
	 where cod_cliente = _cod_cliente;

	select nombre,
	  	   fecha_ult_pro
	  into _nombre_cobrador,
	 	   _fecha_ult_pro
	  from cobcobra
	 where cod_cobrador = _cod_cobrador_ant;

		let _fecha_ult_pro = _fecha_ult_pro + 1;
		let _dia = day(_fecha_ult_pro);

		{update cascliente
		   set cod_cobrador_ant = null,
		       cod_cobrador     = _cod_cobrador_ant,
			   dia_cobros1      = _dia,
			   dia_cobros2      = _dia,
			   cant_call        = 0
	     where cod_cliente      = _cod_cliente;}


	  RETURN _cod_cliente,
			 _nombre_pagador,
			 _nombre_cobrador
			with resume;

end foreach
end procedure