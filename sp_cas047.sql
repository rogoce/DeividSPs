-- Pasar Polizas que Cobra el Corredor con Modrosidad a 90 Dias
-- 
-- Creado    : 23/06/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 23/06/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas047;

create procedure sp_cas047()

define _cod_cliente	char(10);
define _cantidad	smallint;

foreach with hold
 select cod_cliente
   into _cod_cliente
   from cascliente
--  where cod_cliente = "42729"

	select count(*)
	  into _cantidad
	  from caspoliza
	 where cod_cliente = _cod_cliente;

	if _cantidad = 0 then

		delete from cascliente
		 where cod_cliente = _cod_cliente;

		delete from cobcapen
		 where cod_cliente = _cod_cliente;

	end if

end foreach

end procedure