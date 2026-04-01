-- Procedimiento que busca si la transacción está en algun ajuste antes de ser anulada
--
-- creado    : 18/02/2021 - Autor: Amado Perez
-- Modificado: 18/02/2021 - Autor: Amado Perez	- CASO: 36618 USER: ICASTILL 
-- sis v.2.0 - deivid, s.a.

drop procedure sp_rec314;
create procedure sp_rec314(a_transaccion char(10))
returning   smallint,
			varchar(100);   -- _sentencia

define _no_orden	    char(5);
define _cantidad        smallint;
define _no_ajus_orden   char(10); 
define _error_desc		char(50);
define _error_isam		smallint;
define _error			smallint;
define _renglon         smallint;


on exception set _error,_error_isam,_error_desc 
 	return _error,_error_desc;         
end exception

set isolation to dirty read;

--set debug file to "sp_pro369.trc";      
--trace on;

let _cantidad = 0;

select count(*)
  into _cantidad
  from recordma
 where transaccion = a_transaccion;
 
if _cantidad is null then
	let _cantidad = 0;
end if

if _cantidad > 0 then
	let _cantidad = 0;
	
	select no_orden
	  into _no_orden
	  from recordma
     where transaccion = a_transaccion;
	
	select count(*)
	  into _cantidad
	  from recordad a, recordam b
	 where a.no_ajus_orden = b.no_ajus_orden
	   and a.no_orden = _no_orden
	   and b.actualizado = 0;
	 
	if _cantidad is null then
		let _cantidad = 0;
	end if
	
	if _cantidad > 0 then
		foreach
			select a.no_ajus_orden,
			       a.renglon
			  into _no_ajus_orden,
			       _renglon
			  from recordad a, recordam b
			 where a.no_ajus_orden = b.no_ajus_orden
			   and a.no_orden = _no_orden
			   and b.actualizado = 0
			exit foreach;
		end foreach
	  
		return 1, "Esta Tr. está en proceso de pago, orden " || trim(_no_orden) || " del ajuste " || trim(_no_ajus_orden) || " renglon " || _renglon;
	end if
end if

select count(*)
  into _cantidad
  from recordad a, recordam b
 where a.no_ajus_orden = b.no_ajus_orden
   and a.transaccion_alq = a_transaccion
   and b.actualizado = 0;
 
if _cantidad is null then
	let _cantidad = 0;
end if

if _cantidad > 0 then
	foreach
		select a.no_ajus_orden,
			   a.renglon
		  into _no_ajus_orden,
			   _renglon
		  from recordad a, recordam b
		 where a.no_ajus_orden = b.no_ajus_orden
		   and a.transaccion_alq = a_transaccion
           and b.actualizado = 0
		exit foreach;
	end foreach
  
	return 1, "Esta Tr. está en proceso de pago, ajuste " || trim(_no_ajus_orden) || " renglon " || _renglon;
end if
return 0, "";
end procedure
