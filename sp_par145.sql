-- Procedimiento que genera el detalle de las cuentas afectadas en SAC
-- 
-- Creado     : 24/12/2004 - Autor: Marquelda Valdelamar
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par145;		

CREATE PROCEDURE "informix".sp_par145()
returning char(20),
	      dec(16,2),
	      dec(16,2),
	      dec(16,2),
	      dec(16,2),
	      dec(16,2),
	      dec(16,2),
	      dec(16,2),
	      char(3),
	      char(3);

define _no_documento	char(20);
define _saldo1          dec(16,2);
define _facturas        dec(16,2);
define _cobros          dec(16,2);
define _cheques         dec(16,2);
define _saldo2          dec(16,2);
define _calculado       dec(16,2);
define _diferencia      dec(16,2);

define _no_poliza		char(10);
define _cod_ramo		char(3);
define _cod_tipoprod	char(3);

foreach
 select	no_documento,
 		saldo1,      
 		facturas,    
 		cobros,      
 		cheques,     
 		saldo2      
   into _no_documento,
		_saldo1,      
		_facturas,    
		_cobros,      
		_cheques,     
		_saldo2      
   from	cobdifsa

	let _calculado  = _saldo1 + _facturas - _cobros + _cheques;
	let _diferencia = _calculado - _saldo2;

	if _diferencia = 0.00 then
		continue foreach;
	end if

	let _no_poliza = sp_sis21(_no_documento);

	select cod_ramo,
	       cod_tipoprod
	  into _cod_ramo,
	       _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	return _no_documento,
		   _saldo1,
		   _facturas,
		   _cobros,
		   _cheques,
		   _saldo2,
		   _calculado,
		   _diferencia,
		   _cod_ramo,
		   _cod_tipoprod
		   with resume;
		   
end foreach

end procedure
