-- Procedure que retorna el centro de costo 

-- Creado    : 26/11/2008 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac93;

create procedure sp_sac93(
a_numero char(10),
a_tipo	 smallint
) returning integer,
            char(50),
            char(3);

define _no_poliza		char(10);
define _no_tranrec		char(10);
define _no_reclamo		char(10);

define _cod_enlace		char(10);
define _nombre			char(50);

define _sucursal_origen	char(3);
define _cod_sucursal	char(3);
define _casa_matriz		char(3);
define _administracion	char(3);
define _centro_costo	char(3);
define _cod_ramo		char(3);
define _cod_agente		char(5);
define _cod_vendedor	char(3);
define _nombre_vendedor	char(50);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

--set debug file to "sp_sac93.trc";
--trace on;

set isolation to dirty read;

let _administracion = "000"; -- Administracion
let _casa_matriz    = "001"; -- Casa Matriz

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc, _error_isam;
end exception

if a_tipo = 1 then -- Poliza
	
	let _no_poliza = a_numero;

elif a_tipo = 2 then -- Transaccion de Reclamo

	let _no_tranrec = a_numero;

	select no_reclamo
	  into _no_reclamo
	  from rectrmae
	 where no_tranrec = _no_tranrec;

	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

elif a_tipo = 3 then -- Reclamo

	let _no_reclamo = a_numero;

	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

elif a_tipo = 99 then -- Administracion

	let _cod_sucursal = a_numero;
	
end if

-- Buscar el Centro de Costo

if a_tipo <> 99 then

	select sucursal_origen,
		   cod_ramo	
	  into _sucursal_origen,
	       _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select centro_costo
	  into _cod_sucursal
	  from segv05:insagen
	 where codigo_agencia = _sucursal_origen;
  
end if

if _cod_sucursal = _administracion then

	select cod_centro
	  into _centro_costo
	  from saccenco
	 where tipo_centro = 0
	   and cod_enlace  = _cod_sucursal;

	if _centro_costo is null then
		return 1, "No Existe Centro de Costo para Administracion ", _cod_sucursal;
	end if

elif _cod_sucursal = _casa_matriz then

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza
		exit foreach;			
	end foreach

	select cod_vendedor
	  into _cod_vendedor
	  from parpromo
	 where cod_agente  = _cod_agente
	   and cod_agencia = _casa_matriz
	   and cod_ramo    = _cod_ramo;

	select cod_centro
	  into _centro_costo
	  from saccenco
	 where tipo_centro = 2
	   and cod_enlace  = _cod_vendedor;

	if _centro_costo is null then

		return 1, "No Existe Centro de Costo para Vendedor " || _cod_vendedor, _cod_vendedor;

	end if

else -- Sucursales

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza
		exit foreach;			
	end foreach

	select cod_vendedor
	  into _cod_vendedor
	  from parpromo
	 where cod_agente  = _cod_agente
	   and cod_agencia = _casa_matriz
	   and cod_ramo    = _cod_ramo;

	select cod_centro
	  into _centro_costo
	  from saccenco
	 where tipo_centro = 2
	   and cod_enlace  = _cod_vendedor;

	if _centro_costo is null then

		return 1, "No Existe Centro de Costo para Vendedor " || _cod_vendedor, _cod_vendedor;

	end if

end if

end 

return 0, "Actualizacion Exitosa", _centro_costo;

end procedure