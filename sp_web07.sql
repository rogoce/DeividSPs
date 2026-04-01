-- Procedimiento que verifica que exista un cliente para las emisiones de polizas web suntracs

-- Creado    : 06/06/2008 - Autor: Demetrio Hurtado Almanza 

--Modificado : 09/08/2011 - Federico Coronado

-- modificado para la creacion de clientes que estan registrados con la misma cedula pero con distinto tipo de persona 

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_web07;

create procedure sp_web07(
a_cedula	char(30),
a_tipo		smallint,
a_tipo_persona char(1)
) returning smallint,
            char(10);

define _cantidad	smallint;
define _cod_cliente	char(10);

if a_tipo = 1 then -- Cedula

	select count(*)
	  into _cantidad
	  from cliclien
	 where cedula = a_cedula
     and tipo_persona = a_tipo_persona;

	if _cantidad = 0 then

		let _cod_cliente = sp_sis13("001", "PAR", "02", "par_cliente");

		let _cod_cliente = trim(_cod_cliente);

		return 0, _cod_cliente;

	else

		foreach
		 select cod_cliente
		   into _cod_cliente
		   from cliclien
		  where cedula = a_cedula
          and tipo_persona = a_tipo_persona
			exit foreach;
		end foreach

		return 1, _cod_cliente;

	end if

elif a_tipo = 0 then -- Pasaporte

	select count(*)
	  into _cantidad
	  from cliclien
	 where cedula  = a_cedula
       and tipo_persona = a_tipo_persona
	   and pasaporte = 1;

	if _cantidad = 0 then

		let _cod_cliente = sp_sis13("001", "PAR", "02", "par_cliente");

		let _cod_cliente = trim(_cod_cliente);
		return 0, _cod_cliente;

	else

		foreach
		 select cod_cliente
		   into _cod_cliente
		   from cliclien
		  where cedula  = a_cedula
	        and pasaporte = 1
                and tipo_persona = a_tipo_persona
			exit foreach;
		end foreach

		return 1, _cod_cliente;

	end if

end if

end procedure
