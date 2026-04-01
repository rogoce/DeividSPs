-- Creacion de la remesa de Cierre de Caja

-- Creado    : 01/02/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_cob231bk1;

create procedure sp_cob231bk1(a_no_caja char(10))
returning	integer,
			char(100);

define _observacion    	varchar(100);
define _error_desc		char(100);
define _descripcion		char(50);
define _cuenta			char(25);
define _no_recibo    	char(10);
define _no_remesa,_no_rem		char(10);
define _user_cierre		char(8);
define _user_caja		char(8);
define _periodo			char(7);
define _cod_chequera 	char(3);
define _cod_compania	char(3);
define _cod_sucursal	char(3);
define _cod_banco		char(3);
define _tipo_mov		char(1);
define _total_caja		dec(16,2);
define _monto,_mto_rem	dec(16,2);
define _cantidad		smallint;
define _contador		smallint;
define _renglon			smallint;
define _error_isam		integer;
define _diferencia   	integer;
define _recibo1      	integer;
define _recibo2      	integer;
define _error			integer;
define _fecha_cierre	date;
define _fecha,_fecha2 	date;


begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _fecha2 = current;
let _mto_rem = 0;
-- Validaciones para que esten todas las cuentas

foreach
	select renglon
	  into _renglon
	  from cobcieca2
	 where no_caja = a_no_caja
	   and cuenta  is null

	return 1, 'No Existe Cuenta para Renglon ' || _renglon;

end foreach

-- Verificacion para la Secuencia de Recibos

select fecha,
       cod_chequera,
	   total_caja,
	   user_cierre,
	   fecha_cierre,
	   user_caja
  into _fecha,
       _cod_chequera,
	   _total_caja,
	   _user_cierre,
	   _fecha_cierre,
	   _user_caja
  from cobcieca
 where no_caja = a_no_caja;

let _contador = 0;
let _cantidad = 0;
foreach
	select count(*),no_remesa,sum(monto_chequeo)
	  into _cantidad,_no_rem,_mto_rem
	  from cobremae
	 where fecha        = _fecha2
	   and tipo_remesa  = 'F'
	   and cod_chequera = _cod_chequera
	 group by no_remesa
	 order by no_remesa
	 
	exit foreach;
 end foreach
 
 if _cantidad is null then
	let _cantidad = 0;
 end if
 
 if _cantidad > 0 then
	if abs(_mto_rem) = abs(_total_caja) then
		return 1, 'Ya existe la Remesa de Cierre ' || _no_rem || ', Por Favor verifique ...';	
	end if
 end if
 
 return 0, "Actualizacion Exitosa";

end
end procedure 