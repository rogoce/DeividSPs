-- Genera Cheque ACH
-- Creado    : 08/06/2010 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_che123('2',0)

DROP PROCEDURE ap_corr_forma_pago;
CREATE PROCEDURE ap_corr_forma_pago() 
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
define  _cod_formapag       char(3);


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
	       cod_formapag
	  into _no_poliza,
	       _cod_formapag
	  from deivid_tmp:corr_forma_pag
	  
	update emipomae
	   set cod_formapag = _cod_formapag
	 where no_poliza = _no_poliza;
	  
end foreach
end

--commit work;
return 0, 'Actualizacion exitosa';
END PROCEDURE	  