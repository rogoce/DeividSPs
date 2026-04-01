-- Procedure para validar el periodo de reacomp vs rectrmae

drop procedure sp_rea054;

create procedure sp_rea054()
returning smallint,
		  char(50);

define _tipo_registro		smallint;
define _no_poliza			char(10);
define _no_endoso			char(5);
define _no_remesa			char(10);
define _renglon				smallint;
define _no_tranrec			char(10);
define _transaccion			char(10);
define _fecha_anulado		date;
define _periodo				char(7);

define _periodo2			char(7);
define _numrecla			char(20);
define _cantidad			smallint;
define _no_registro			char(10);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

return 0, "Actualizacion Exitosa";

foreach
 select tipo_registro,
	    no_poliza,	
	    no_endoso,	
	    no_remesa,	
	    renglon,		
	    no_tranrec,
	    fecha,	
	    periodo,
		no_registro
   into _tipo_registro,
	    _no_poliza,	
	    _no_endoso,	
	    _no_remesa,	
	    _renglon,		
	    _no_tranrec,
	    _fecha_anulado,	
	    _periodo,
		_no_registro
   from sac999:reacomp
  where sac_asientos  = 0
    and tipo_registro = 3

	select periodo,
		   numrecla,
		   transaccion
	  into _periodo2,
	       _numrecla,
		   _transaccion
	  from rectrmae
	 where no_tranrec = _no_tranrec;

	if _periodo <> _periodo2 then

		update sac999:reacomp
		   set periodo     = _periodo2
		 where no_registro = _no_registro;

	end if

end foreach

end

return 0, "Actualizacion Exitosa";

end procedure
