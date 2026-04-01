-- Procedimiento que verifica la integridad de la información de pólizas en las remesas de reaseguro 
-- Creado     :	18/04/2016 - Autor: Román Gordón C.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rea073;		

create procedure "informix".sp_rea073(a_no_remesa char(10))
returning	smallint,
			varchar(100);

define _error_desc		varchar(100);
define _cod_coasegur	char(3);
define _cod_contrato	char(2);
define _error_isam		smallint;
define _error			smallint;

--set debug file to "sp_rea073.trc";
--trace on ;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

set isolation to dirty read;

select cod_coasegur,
	   cod_contrato
  into _cod_coasegur,
	   _cod_contrato
  from reatrx1
 where no_remesa = a_no_remesa;

foreach
	select renglon,
		   
end foreach

end procedure;