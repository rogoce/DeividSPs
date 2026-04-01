--Detalle de transacciones de Reserva de reclamos generadas en 2011 y aprobadas en el 2012


drop procedure sp_rec195b;

create procedure "informix".sp_rec195b()
returning char(18),
          char(20),
		  dec(16,2),
		  date,
		  char(7),
		  char(10);

define _periodo		char(7);
define _monto		dec(16,2);
define _variacion	dec(16,2);
define _anio        char(4);
define _no_documento char(20);
define _numrecla     char(18);
define _fecha       date;
define _no_reclamo  char(10);
define _transaccion char(10);


set isolation to dirty read;

foreach
 select	periodo,
        monto,
		variacion,
		no_reclamo,
		fecha,
		transaccion
   into _periodo,
        _monto,
		_variacion,
		_no_reclamo,
		_fecha,
		_transaccion
   from rectrmae
  where year(fecha)  = 2011
	and actualizado  = 1
	and cod_tipotran in ("001", "002", "003")

   let _anio = _periodo[1,4];

   if _anio = '2012' then

		select no_documento,numrecla
		  into _no_documento,_numrecla
		  from recrcmae
		 where no_reclamo = _no_reclamo;

		return _numrecla,
			   _no_documento,
			   _variacion,
			   _fecha,
	           _periodo,
			   _transaccion
		   with resume;
   else
		continue foreach;
   end if

end foreach

end procedure