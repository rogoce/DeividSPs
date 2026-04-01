-- Procedimiento que busca si la transacción de la requisición es de pago de subrogacion
--
-- Creado    : 18/03/2021 - Autor: Amado Perez
-- Modificado: 18/03/2021 - Autor: Amado Perez	
-- sis v.2.0 - deivid, s.a.

drop procedure sp_rec315;
create procedure "informix".sp_rec315(a_no_requis char(10))
returning   integer;   

define _cantidad        integer;
define _transaccion     char(10); 
define _error_desc		char(50);
define _error_isam		smallint;
define _error			integer;
define _renglon         smallint;

set isolation to dirty read;

--set debug file to "sp_pro369.trc";      
--trace on;

-- Buscando pago a subrogaciones

let _cantidad = 0;

foreach
	select transaccion
	  into _transaccion
	  from chqchrec 
	 where no_requis = a_no_requis 
	 
	let _cantidad = 0;
	
	select count(*)
	  into _cantidad
	  from rectrmae a, rectrcon b
	 where a.no_tranrec = b.no_tranrec
	   and a.transaccion = _transaccion
	   and b.cod_concepto = '063';
	   
	if _cantidad is null then
		let _cantidad = 0;
	end if			
	   
	if _cantidad = 0 then
		exit foreach;
	end if
end foreach
return _cantidad;
end procedure
