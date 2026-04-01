-- Genera Cheque ACH
-- Creado    : 08/06/2010 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_che123('2',0)

DROP PROCEDURE ap_camb_tcrach;
CREATE PROCEDURE ap_camb_tcrach() 
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
define  _monto_visa         dec(16,2);
define  _tipo_tarjeta       char(1);


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
	       cod_formapag,
		   monto_visa,
		   tipo_tarjeta
	  into _no_poliza,
	       _cod_formapag,
		   _monto_visa,
		   _tipo_tarjeta
	  from deivid_tmp:camb_TCRACH
	  
	select no_documento
      into _no_documento
      from emipomae
	 where no_poliza = _no_poliza;
	  
	update emipomae
	   set cod_formapag = _cod_formapag,
	       monto_visa = _monto_visa,
		   tipo_tarjeta = _tipo_tarjeta,
		   no_cuenta = null,
		   tipo_cuenta = null
	 where no_poliza = _no_poliza;

	update cobtacre
	   set monto  = _monto_visa
	 where no_documento = _no_documento;
	  
end foreach
end

--commit work;
return 0, 'Actualizacion exitosa';
END PROCEDURE	  