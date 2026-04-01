-- Reclamos con reserva inicial en cero y que no generaron transaccion inicial
-- 
-- Creado    : 04/05/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_rec86;

CREATE PROCEDURE "informix".sp_rec86()
returning char(20),
	      char(7),
	      char(15),
	      char(10),
	      date;

define _no_reclamo		char(10);
define _numrecla		char(20);
define _periodo			char(7);
define _fecha			date;
define _no_documento	char(20);
define _cantidad		smallint;

define _error			integer;
define _descripcion		char(100);
define _return3			char(10);
define _return4			char(10);

begin work;

begin
on exception set _error
	rollback work;
	return "Error",
	       _error,
		   "",
		   "",
		   null
		   with resume;
end exception

foreach with hold
 select	no_reclamo,
        numrecla,
		periodo,
		fecha_reclamo,
		no_documento
   into	_no_reclamo,
        _numrecla,
		_periodo,
		_fecha,
		_no_documento
   from	recrcmae
  where actualizado   = 1
	and numrecla[1,2] = "02"
--  and periodo[1,4]  = 2004
--  and periodo       >= "2004-01"
--	and no_reclamo    = "41167"
  order by fecha_reclamo

	select count(*)
	  into _cantidad
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and cod_tipotran = "001";

	if _cantidad = 0 then

--		call sp_rwf12(_no_reclamo) returning _error, _descripcion, _return3, _return4;
		
		return _numrecla,
		       _periodo,
			   _no_documento,
			   _no_reclamo,
			   _fecha
			   with resume;

	end if

end foreach

end 

commit work;

return "Exito",
       "0",
	   "",
	   "",
	   null
	   with resume;

end procedure
