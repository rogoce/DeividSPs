-- Creacion Inicial de Datos para los Cobros Automaticos
-- 
-- Creado    : 07/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 07/04/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob104;

create procedure sp_cob104()
returning smallint;

define _cod_cliente		char(10);
define _no_documento	char(20);
define _no_poliza		char(10);
define _cant_pol		smallint;
define _cant_vida		smallint;
define _cant_clientes	smallint;
define _cod_ramo		char(3);

let _cant_clientes = 0;

foreach
 select	cod_cliente
   into	_cod_cliente
   from	cascliente

	let _cant_pol  = 0;
	let _cant_vida = 0;

	foreach
	 select no_documento
	   into _no_documento
	   from caspoliza
	  where cod_cliente = _cod_cliente

		let _cant_pol  = _cant_pol + 1;
		let _no_poliza = sp_sis21(_no_documento);

		select cod_ramo
		  into _cod_ramo
		  from emipomae
		 where no_poliza = _no_poliza;

		if _cod_ramo = "016" or
		   _cod_ramo = "018" or
		   _cod_ramo = "019" then
			let _cant_vida = _cant_vida + 1;
		end if

	end foreach

--	if _cant_pol <> _cant_vida then
		if _cant_vida <> 0 then
			let _cant_clientes = _cant_clientes + 1;
		end if
--	end if
		
end foreach

return _cant_clientes;

end procedure




















