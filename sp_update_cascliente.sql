-- Procedimiento para cargar Cascliente y Caspoliza luego de Activar la Campaña

-- Creado    : 12/10/2010 - Autor:Roman Gordon
-- DEIVID, S.A.

drop procedure sp_update_cas;

create procedure sp_update_cas(a_cod_campana char(10))
returning smallint,
       	  char(100)	     

Define _error			integer;
Define _cont			integer;
Define _no_documento	char(20);
Define _no_poliza		char(10);
Define _cod_cliente		char(10);
Define _cod_pagos		char(3);
Define _dia_cobros1		smallint;
Define _dia_cobros2		smallint;
Define _fecha_ult_pro	date;
Define _corriente		decimal(16,2);
Define _monto_30		decimal(16,2);
Define _monto_60		decimal(16,2);
Define _monto_90		decimal(16,2);
Define _monto_120		decimal(16,2);
Define _monto_150		decimal(16,2);
Define _monto_180		decimal(16,2);
Define _saldo			decimal(16,2);
Define _por_vencer		decimal(16,2);
Define _exigible		decimal(16,2);
Define _a_pagar			decimal(16,2);
	   


on exception set _error,_dia_cobros1,_no_documento
    --rollback work;
	return _error, _no_documento;
end exception

--set debug file to "sp_cas108.trc";
--trace on;

set isolation to dirty read;
foreach
	select cod_cliente
	  into _cod_cliente
	  from cascliente

	update cascliente set cod_campana = '00000' where cod_cliente = _cod_cliente;

end foreach
return 0,'';