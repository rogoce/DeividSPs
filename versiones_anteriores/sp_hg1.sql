-- Procedimiento que verifica si la póliza estaba en suspensión de cobertura para una fecha dada.
-- Creado: 17/10/2017 - Autor: Román Gordón
--
drop procedure sp_hg1;
create procedure sp_hg1()
returning	smallint		as cod_error,
			varchar(100)	as poliza,
			date			as cubierto_hasta;

define _mensaje				varchar(100);
define _error_isam			integer;
define _error				integer;

define _no_documento		char(20);
DEFINE _cod_pagador		 	char(10);
define _no_tran integer;

set isolation to dirty read;

--set debug file to "sp_hg1.trc";
--trace on;

--Query para crear la temporal
BEGIN WORK;
begin
on exception set _error,_error_isam,_mensaje
return _error,_mensaje,null;
end exception

foreach
	select no_tran,no_documento
	  into _no_tran,_no_documento
	  from cobcutmp
	  
	    select cod_pagador
		into _cod_pagador
		  from emipoliza
		 where no_documento = _no_documento;
		 
		 update cobcutmp
		    set cod_pagador = _cod_pagador,
			motivo = '',
			periodo = '',
			motivo_rechazo  = ''
		 where no_tran = _no_tran;

	--return 1,_no_documento,_fecha_suspension;
end foreach
COMMIT WORK;
return 0,'Exito',null;

end
end procedure;