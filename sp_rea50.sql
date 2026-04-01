--- Insercion de endosos especiales desde produccion para ser impresos por logistica
--- Creado 06/09/2011 por Henry 
drop procedure sp_rea50;
create procedure "informix".sp_rea50(a_contrato char(2), a_reasegurador char(3), a_anio char(10),a_trimestre smallint,a_saldo_inicial decimal(16,2) default 0)
returning integer,varchar(100);
begin
define _cantidad	  	smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		varchar(100);

on exception set _error, _error_isam, _error_desc
   return _error, _error_desc;
end exception

set isolation to dirty read;

select count(*)
  into _cantidad
  from reaestct1
 WHERE ( contrato = a_contrato ) 
   AND ( reasegurador = a_reasegurador)
   AND ( ano = a_anio) 
   AND ( trimestre = a_trimestre ) 
   AND ( saldo_inicial <> 0 );

if _cantidad <> 0 then	
	 update reaestct1 
	    set saldo_inicial = a_saldo_inicial
	  WHERE ( contrato = a_contrato ) 
		AND ( reasegurador = a_reasegurador)
		AND  ( ano = a_anio) 
		AND ( trimestre = a_trimestre ) 
		AND ( saldo_inicial <> 0 );
end if

end
return 0,'Realizado con Exito';
end procedure;
