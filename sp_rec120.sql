-- Procedure que retorna las transacciones para la consulta de reclamos de salud

drop procedure sp_rec120;

create procedure "informix".sp_rec120(a_no_documento char(20), a_cod_cliente char(10)) 
returning char(20),
            char(10),
			date,
			date,
			char(100),
			char(10),
			integer,
			char(100),
			char(50),
			char(10),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			char(10),
			char(10),
			char(10),
			char(8),
			date;

define _numrecla		char(20);
define _no_reclamo		char(10);
define _cod_icd			char(10);
define _nombre_icd		char(100);

define _transaccion		char(10);
define _fecha_factura	date;
define _fecha			date;
define _no_factura		char(10);
define _cod_tipotran	char(3);
define _nombre_tipotran	char(50);
define _no_requis		char(10);
define _no_cheque		integer;
define _cod_pagado		char(10);
define _nombre_pagado	char(100);
define _no_tranrec		char(10);

define _facturado		dec(16,2);
define _pagado			dec(16,2);
define _a_deducible		dec(16,2);
define _co_pago			dec(16,2);
define _coaseguro		dec(16,2);
define _ahorro			dec(16,2);
define _no_cubierto		dec(16,2);

define _anular_nt		char(10);
define _user_anulo		char(8);
define _fecha_anulo		date;			

foreach
 select numrecla,
        no_reclamo,
		cod_icd
   into _numrecla,
        _no_reclamo,
		_cod_icd
   from recrcmae
  where no_documento   = a_no_documento
    and cod_reclamante = a_cod_cliente
	and actualizado    = 1

	select nombre
	  into _nombre_icd
	  from recicd
	 where cod_icd = _cod_icd;

	foreach
	 select transaccion,
	        fecha_factura,
			fecha,
			no_factura,
			cod_tipotran,
			no_requis,
			cod_cliente,
			no_tranrec,
			anular_nt,
			user_anulo,
			fecha_anulo
	   into	_transaccion,
	        _fecha_factura,
			_fecha,
			_no_factura,
			_cod_tipotran,
			_no_requis,
			_cod_pagado,
			_no_tranrec,
			_anular_nt,
			_user_anulo,
		   _fecha_anulo
	   from rectrmae
	  where no_reclamo  = _no_reclamo
	    and actualizado = 1

		select nombre
		  into _nombre_tipotran
		  from rectitra
		 where cod_tipotran = _cod_tipotran;
		
		select no_cheque
		  into _no_cheque
		  from chqchmae
		 where no_requis = _no_requis;

		select nombre
		  into _nombre_pagado
		  from cliclien
		 where cod_cliente = _cod_pagado;

		select sum(facturado),
		       sum(monto),
		       sum(a_deducible),
		       sum(co_pago),
		       sum(coaseguro),
		       sum(ahorro),
		       sum(monto_no_cubierto)
		  into _facturado,
		       _pagado,
		       _a_deducible,
		       _co_pago,
		       _coaseguro,
		       _ahorro,
		       _no_cubierto
		  from rectrcob
		 where no_tranrec = _no_tranrec;

		return _numrecla,
		       _transaccion,
			   _fecha_factura,
			   _fecha,
			   _nombre_icd,
			   _no_factura,
			   _no_cheque,
			   _nombre_pagado,
			   _nombre_tipotran,
			   _no_factura,
			   _pagado,
			   _a_deducible,
			   _co_pago,
			   _coaseguro,
			   _ahorro,
			   _no_cubierto,
			   _no_reclamo,
			   _no_tranrec,
			   _anular_nt,	
			   _user_anulo,	
			   _fecha_anulo
			   with resume;


	end foreach

end foreach

end procedure


