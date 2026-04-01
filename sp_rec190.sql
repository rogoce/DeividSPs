-- buscar ajustador

-- Creado: 02/09/2011 - Autor: Amado Perez Mendoza

drop procedure sp_rec190;

create procedure "informix".sp_rec190()
returning  char(10),
           char(20), 
           char(20),
           char(10),
           varchar(100),
           date,
		   dec(16,2),
		   dec(16,2);	

define _fecha_comp			date;
define _no_reclamo			char(10);
define _numrecla			char(20);
define _no_documento	    char(20);
define _cod_asegurado		char(10);
define _fecha_reclamo		date;
define _fecha		        date;
define _reserva		        dec(16,2);
define _pagado		        dec(16,2);
define _nombre_aseg         varchar(100);
define _error               integer;

let _error = 0;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rwf86.trc"; 
--trace on;

begin

ON EXCEPTION SET _error 
	RETURN _error, null, null, null, null, null, 0.00, 0.00; 
END EXCEPTION           

let _fecha_comp = '15/11/2011';

foreach
	select no_reclamo,
	       numrecla,
	       no_documento,
		   cod_asegurado,
		   fecha_reclamo
	  into _no_reclamo,
	       _numrecla,
	       _no_documento,
		   _cod_asegurado,
		   _fecha_reclamo
	  from recrcmae
	 where numrecla[1,2] in ('02','20')
	   and fecha_reclamo >=	'01/01/2011'
	   and fecha_reclamo <=	'15/11/2011'

    select max(fecha),
		   sum(variacion)
	  into _fecha,
	       _reserva
	  from rectrmae
	 where no_reclamo = _no_reclamo
	   and actualizado = 1;

    if _fecha_comp - _fecha <= 90 then
		continue foreach;
	end if

    if _reserva = 0 then
		continue foreach;
	end if

    select sum(monto)
	  into _pagado
	  from rectrmae
	 where no_reclamo = _no_reclamo
	   and cod_tipotran = 4
	   and actualizado = 1;

    if _pagado is null then
		let _pagado = 0.00;
	end if

    select nombre
	  into _nombre_aseg
	  from cliclien
	 where cod_cliente = _cod_asegurado; 

	return _no_reclamo,
	       _numrecla,
		   _no_documento,
		   _cod_asegurado,
		   _nombre_aseg,
		   _fecha_reclamo,
		   _pagado,
		   _reserva with resume;

end foreach

end

end procedure