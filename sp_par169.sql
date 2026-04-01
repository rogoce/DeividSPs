-- Procedure que Actualiza los saldos de los corredores a octubre del 2005

-- Creado: 31/10/2005 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par169;

create procedure "informix".sp_par169()
returning integer,
          char(50);

define _cod_agente	char(5);
define _cod_ramo    char(3);
define _monto       dec(16,2);

define _error		integer;
define _cantidad	smallint;
define _descripcion	char(50);

begin work;
	
begin
on exception set _error
	rollback work;
	return _error, _descripcion;	
end exception

foreach 
 select	agente,
		ramo,
		monto
   into _cod_agente,
        _cod_ramo,
		_monto
   from agtsal1005

	let _cod_agente = trim(_cod_agente);
	let _cod_ramo   = trim(_cod_ramo);

	let _descripcion = "Procesando Agente " || _cod_agente || " Ramo " || _cod_ramo;

	select count(*)
	  into _cantidad
	  from agtsalra
	 where cod_agente = _cod_agente
	   and cod_ramo	  = _cod_ramo;

	if _cantidad = 0 then

		insert into agtsalra
		values (_cod_agente, _cod_ramo, _monto);

	else
		
		update agtsalra
		   set monto      = monto + _monto
		 where cod_agente = _cod_agente
		   and cod_ramo	  = _cod_ramo;

	end if

	update agtagent
	   set saldo      = saldo + _monto
	 where cod_agente = _cod_agente;

end foreach
   
end

--rollback work;
commit work;

return 0, "Actualizacion Exitosa";

end procedure