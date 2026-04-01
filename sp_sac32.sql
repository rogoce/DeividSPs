-- Procedimiento que genera el detalle de las cuentas afectadas en SAC
-- 
-- Creado     : 24/12/2004 - Autor: Marquelda Valdelamar
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sac32;		

CREATE PROCEDURE "informix".sp_sac32(a_comprobante char(10))
returning char(25),
	      char(50),
	      dec(16,2),
	      dec(16,2),
	      dec(16,2),
		  char(1),	
		  integer,
	   	  char(8),
	      date,
	      char(100),
		  char(3);

define _res_notrx		integer;
define _res_noregistro	integer;
define _res_comprobante	char(8);
define _res_fechatrx	date;
define _res_descripcion	char(50);
define _res_cuenta		char(25);
define _res_debito		dec(16,2);
define _res_credito		dec(16,2);
define _res_neto		dec(16,2);
define _res_origen		char(3);

define _cta_auxiliar	char(1);
define _nombre_cuenta	char(100);


foreach
 select res_notrx,
        res_noregistro,
		res_comprobante,
		res_fechatrx,
		res_descripcion,
		res_cuenta,
		res_debito,
		res_credito,
		res_origen
   into	_res_notrx,
        _res_noregistro,
		_res_comprobante,
		_res_fechatrx,
		_res_descripcion,
		_res_cuenta,
		_res_debito,
		_res_credito,
		_res_origen
   from cglresumen
  where res_comprobante = a_comprobante
  order by res_notrx, res_noregistro

	select cta_nombre,
	       cta_auxiliar
	  into _nombre_cuenta,
	       _cta_auxiliar
	  from cglcuentas
	 where cta_cuenta = _res_cuenta;

	let _res_neto = _res_debito - _res_credito;

	return _res_cuenta,
		   _nombre_cuenta,
		   _res_debito,
		   _res_credito,
		   _res_neto,
		   _cta_auxiliar,
		   _res_notrx,
		   _res_comprobante,
		   _res_fechatrx,
		   _res_descripcion,
		   _res_origen
		   with resume;

end foreach

end procedure