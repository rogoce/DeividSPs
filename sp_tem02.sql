-- Procedimiento que busca si hay registro en recrcmae antes de crear el reclamo

-- Creado    : 07/10/2011 - Autor: Amado Perez  

drop procedure sp_tem02;

create procedure sp_tem02(a_numrecla varchar(20)) 
returning varchar(10),
          varchar(3),
		  varchar(3),
		  varchar(10),
		  varchar(10),
		  dec(16,2),
		  varchar(3);

define _no_reclamo		varchar(10);
define _cod_compania	varchar(3);
define _cod_sucursal	varchar(3);
define _cod_cliente		varchar(10);
define _no_poliza		varchar(10);
define _reserva_actual	dec(16,2);
define _cod_ramo		varchar(3);

--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;
set isolation to dirty read;

let _no_reclamo = null;

select cod_compania,
       cod_sucursal,
	   no_reclamo,
	   cod_asegurado,
	   no_poliza,
	   reserva_actual
  into _cod_compania,
       _cod_sucursal,
	   _no_reclamo,
	   _cod_cliente,
	   _no_poliza,
	   _reserva_actual
  from recrcmae
 where numrecla = trim(a_numrecla);
 
select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = _no_poliza;

return _no_reclamo,
       _cod_compania,
	   _cod_sucursal,
	   _cod_cliente,
	   _no_poliza,
	   _reserva_actual,
	   _cod_ramo;

end procedure