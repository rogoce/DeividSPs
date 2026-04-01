-- Procedimiento traer las direccion del  cliente concatenada
-- Creado     : 07/06/2018 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_par365;

create procedure "informix".sp_par365(a_cod_pagador char(10))
returning varchar(100);

define _direccion12		varchar(100); -- concatenada

--set debug file to "sp_par365.trc";
--trace on;

set isolation to dirty read;

select nvl(trim(upper(direccion_1)),' ')||' '||nvl(trim(upper(direccion_2)),' ')
  into _direccion12
  from cliclien
 where cod_cliente = a_cod_pagador;
 
	if _direccion12 is null then
		let _direccion12 = '';	
	end if	
return _direccion12 with resume;


end procedure