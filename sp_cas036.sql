-- Pasar Gestiones Telefono Equivocado al Call Center
-- 
-- Creado    : 20/06/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 20/06/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas036;

create procedure sp_cas036()
returning smallint,
          char(50);

define _cod_cobrador	char(3);
define _fecha			date;
define _dia				smallint;
define _cod_cliente		char(10);
define _cantidad		smallint;

let _cantidad = 0;

begin work;

foreach
 select	cod_cobrador_ant,
		cod_cliente
   into	_cod_cobrador,
   		_cod_cliente
   from	cascliente
  where	cod_gestion      = "014"
    and cod_cobrador_ant is not null
--	and cod_cliente = "09944"

	let _cantidad = _cantidad + 1;

	select fecha_ult_pro
	  into _fecha
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;

	let _fecha = _fecha + 2;
	let _dia   = day(_fecha);

	update cascliente
	   set cod_cobrador     = cod_cobrador_ant,
	       cod_cobrador_ant = null,
		   dia_cobros3      = _dia
	 where cod_cliente      = _cod_cliente;

end foreach

--rollback work;
commit work;
 
return _cantidad,
       "Registros Procesados ...";

end procedure