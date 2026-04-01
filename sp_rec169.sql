-- Arreglar las Transacciones de pago con numero de requisicion

-- Creado    : 30/01/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 04/02/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec169;

create procedure sp_rec169()
returning char(10), 
          char(10),
		  smallint,
		  smallint;

define _transaccion	char(10);
define _no_tranrec	char(10);
define _no_requis	char(10);
define _pagado		smallint;
define _anulado		smallint;
define _fecha		date;

foreach
 select no_requis,
        transaccion,
		no_tranrec
   into _no_requis,
        _transaccion,
		_no_tranrec
   from rectrmae
  where periodo[1,4] = 2009
    and pagado       = 0
    and cod_tipotran = "004"
    and actualizado  = 1
    and no_requis    is not null

	select pagado,
	       anulado,
		   fecha_impresion
	  into _pagado,
	       _anulado,
		   _fecha
	  from chqchmae
	 where no_requis = _no_requis;

	if _pagado  = 1 and 
	   _anulado = 0 then

{
		update rectrmae
		   set pagado       = 1,
		       fecha_pagado = _fecha
		 where no_tranrec   = _no_tranrec;
}

		return _transaccion, 
		       _no_requis,
			   _pagado,
			   _anulado
			   with resume;
	end if

end foreach

return "",
       "", 
	   0,
	   0;

end procedure