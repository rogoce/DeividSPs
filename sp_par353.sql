-- Procedure que devuelve la informacion solicitada para la actualizacion de datos.

-- Creado    : 27/08/2014 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par353;

create procedure "informix".sp_par353()
returning  smallint,
	       char(100);

{
returning  char(10),
	       char(100),
		   char(10),
		   char(10),
		   char(30),
		   char(30),
		   char(20),
		   char(5),
		   char(50),
		   char(20),
		   char(100),
		   char(100);
}
define _cod_cliente		char(10);
define _telefono		char(10);
define _celular			char(10);
define _e_mail			char(30);
define _nombre			char(100);
define _cedula			char(30);
define _direccion_1		char(100);
define _direccion_2		char(100);

define _cantidad		smallint;
define _no_poliza		char(10);
define _no_poliza2		char(10);

define _tipo_cliente	char(20);
define _cod_corredor	char(5);
define _nombre_corredor	char(50);
define _tipo_corredor	char(20);

set isolation to dirty read;

foreach
 select cod_cliente,
        telefono1,
        celular,
		e_mail,
		nombre,
		cedula,
		direccion_1,
		direccion_2
   into _cod_cliente,
        _telefono,
        _celular,
		_e_mail,
		_nombre,
		_cedula,
		_direccion_1,
		_direccion_2
   from cliclien
--  where cedula[1,1] = '9'
  order by nombre

	-- Si alguna tuvo Polizas 

	select count(*),
	       max(no_poliza)
	  into _cantidad,
	       _no_poliza2
	  from emipomae
	 where (cod_contratante = _cod_cliente or
	        cod_pagador     = _cod_cliente)
	   and actualizado    = 1;

	if _cantidad <> 0 then -- Alguna Vez Cliente
		
		select count(*),
		       max(no_poliza)
		  into _cantidad,
		       _no_poliza
		  from emipomae
		 where (cod_contratante = _cod_cliente or
		        cod_pagador     = _cod_cliente)
		   and actualizado    = 1
		   and estatus_poliza = 1;

		if _cantidad <> 0 then -- Asegurado

			let _tipo_cliente = "ASEGURADO";
				
			foreach
			 select cod_agente
			   into _cod_corredor
			   from emipoagt
			  where no_poliza = _no_poliza
				exit foreach;
			end foreach

			select tipo_agente,
			       nombre
			  into _tipo_corredor,
			       _nombre_corredor
			  from agtagent
			 where cod_agente = _cod_corredor;

			if _tipo_corredor = "O" then
				let _tipo_corredor = "OFICINA";
			else
				let _tipo_corredor = "AGENTE";
			end if			

		else -- Cancelado

			let _no_poliza = _no_poliza2;

			let _tipo_cliente = "CANCELADO";
				
			foreach
			 select cod_agente
			   into _cod_corredor
			   from emipoagt
			  where no_poliza = _no_poliza
				exit foreach;
			end foreach

			select tipo_agente,
			       nombre
			  into _tipo_corredor,
			       _nombre_corredor
			  from agtagent
			 where cod_agente = _cod_corredor;

			if _tipo_corredor = "O" then
				let _tipo_corredor = "OFICINA";
			else
				let _tipo_corredor = "AGENTE";
			end if			

		end if
		
	else -- No Es Cliente
		
		let _tipo_corredor   = "NO APLICA";
		let _cod_corredor    = null;
		let _nombre_corredor = null;

		select count(*)
		  into _cantidad
		  from recterce
		 where cod_tercero = _cod_cliente;

		if _cantidad <> 0 then -- Terceros

			let _tipo_cliente    = "TERCERO";

		else -- Proveedor
	
			select count(*)
			  into _cantidad
			  from emipouni
			 where cod_asegurado  = _cod_cliente;

			if _cantidad <> 0 then -- Colectivo

				let _tipo_cliente    = "COLECTIVO";			
			
			else

				let _tipo_cliente    = "PROVEEDOR";

			end if

		end if


	end if

--	if _tipo_cliente = "PROVEEDOR" then

		insert into deivid_tmp:actdatos
		values (_cod_cliente, _nombre, _telefono, _celular, _e_mail, _cedula, _tipo_cliente, _cod_corredor, _nombre_corredor, _tipo_corredor, _direccion_1, _direccion_2);

		{
		return _cod_cliente,
		       _nombre,
			   _telefono,
			   _celular,
			   _e_mail,
			   _cedula,
			   _tipo_cliente,
			   _cod_corredor,
			   _nombre_corredor,
			   _tipo_corredor,
			   _direccion_1,
			   _direccion_2
			   with resume;
		}
--	end if

end foreach

return 0, "Actualizacion Exitosa";

end procedure