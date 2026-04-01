-- Genera Cheque ACH
-- Creado    : 08/06/2010 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_che123('2',0)

DROP PROCEDURE ap_corrige_pagos;
CREATE PROCEDURE ap_corrige_pagos() 
RETURNING  smallint,				--Salud
		   char(20);

DEFINE 	_no_poliza		    char(10);
DEFINE 	_no_unidad			char(5);
DEFINE 	_opcion				char(1);
DEFINE 	_no_documento		char(20);
DEFINE  _error              integer;
DEFINE  _notrx              integer;
DEFINE  _error_desc         varchar(50);
DEFINE  _no_pagos           smallint;


SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;

--begin work;

begin
on exception set _error
--    rollback work;
	return _error, "Error al Cambiar Tarifas...";
end exception


foreach 
	select no_poliza,
	       no_pagos
	  into _no_poliza,
	       _no_pagos
	  from deivid_tmp:corrige_pagos
	  
	update emipomae
	   set no_pagos = _no_pagos
	 where no_poliza = _no_poliza;

	update endedmae
	   set no_pagos = _no_pagos
	 where no_poliza = _no_poliza;

	update endedhis
	   set no_pagos = _no_pagos
	 where no_poliza = _no_poliza;
	  
end foreach
end

--commit work;
return 0, 'Actualizacion exitosa';
END PROCEDURE	  