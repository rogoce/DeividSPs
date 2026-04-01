-- Polizas del Call Center sin Direccion del Cliente
-- 
-- Creado    : 26/06/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 26/06/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas040;

create procedure sp_cas040()
returning char(10),
		  char(50);

define _cod_cliente		char(10);
define _direccion_cob	char(200);
define _direccion_1		char(50);
define _direccion_2		char(50);
define _cantidad		integer;

let _cantidad = 0;

foreach
 select cod_cliente
   into _cod_cliente
   from cascliente
--  where cod_cliente = "26586"
  								
	select direccion_cob,
	       direccion_1,
		   direccion_2
	  into _direccion_cob,
	       _direccion_1,
		   _direccion_2
	  from cliclien
	 where cod_cliente = _cod_cliente;

	if _direccion_cob is null or
	   _direccion_cob = ""    then
		
		let _cantidad = _cantidad + 1;

		if _direccion_2 is null then
			let _direccion_2 = "";
		end if

{
		update cliclien
		   set direccion_cob  = trim(_direccion_1) || " " || trim(_direccion_2)
	     where cod_cliente    = _cod_cliente;
--}

--{
		return _cod_cliente,
		       _direccion_1
		       with resume;
--}

	end if

end foreach

let _cod_cliente = _cantidad;

return _cod_cliente, " Registros Procesados";

end procedure