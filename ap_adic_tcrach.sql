-- Genera Cheque ACH
-- Creado    : 08/06/2010 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_che123('2',0)

DROP PROCEDURE ap_adic_tcrach;
CREATE PROCEDURE ap_adic_tcrach() 
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
define	_no_tarjeta			char(19);
define	_fecha_exp			char(7);
define	_cod_banco			char(3);
define	_no_cuenta			char(17);
define	_tipo_cuenta		char(1);	
define	_tipo_adicion		smallint;


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
		   no_tarjeta,
		   fecha_exp,
		   cod_banco,
		   monto_visa,
		   tipo_tarjeta,
		   no_cuenta,
		   tipo_cuenta,
		   tipo_adicion
	  into _no_poliza,
		   _no_tarjeta,
		   _fecha_exp,
		   _cod_banco,
		   _monto_visa,
		   _tipo_tarjeta,
		   _no_cuenta,
		   _tipo_cuenta,
		   _tipo_adicion
	  from deivid_tmp:adic_TCRACH
	  
	select no_documento
      into _no_documento
      from emipomae
	 where no_poliza = _no_poliza;
	 
	if _tipo_adicion = 1 then 	  
		update emipomae
		   set no_tarjeta = _no_tarjeta,
			   fecha_exp = _fecha_exp,
			   cod_banco = _cod_banco,
			   monto_visa = _monto_visa,
			   tipo_tarjeta = _tipo_tarjeta
		 where no_poliza = _no_poliza;

		update cobtacre
		   set monto  = _monto_visa
		 where no_documento = _no_documento;
	else
		update emipomae
		   set cod_banco = _cod_banco,
		       monto_visa = _monto_visa,
			   no_cuenta = _no_cuenta,
			   tipo_cuenta = _tipo_cuenta
		 where no_poliza = _no_poliza;

		update cobcutas
		   set monto  = _monto_visa
		 where no_documento = _no_documento;
	end if
	  
end foreach
end

--commit work;
return 0, 'Actualizacion exitosa';
END PROCEDURE	  