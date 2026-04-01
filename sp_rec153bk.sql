-- Procedure que cierra los reclamos abiertos hace mas de 3 meses que no han tenido movimiento

drop procedure sp_rec153bk;

create procedure sp_rec153bk()
returning char(20),
          date,
		  smallint,
		  smallint,
		  dec(16,2),
		  char(50),
		  smallint;

define _fecha_inicio	date;
define _fecha_reclamo	date;
define _cantidad		smallint;
define _cantidad2       smallint;
define _no_reclamo		char(10);
define _numrecla		char(20);
define _reserva			dec(16,2);
define _no_poliza		char(10);
define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _nombre_ramo		char(50);
define _perd_total		smallint;
define _dias            integer;         

define _no_tramite      char(10);
define _incidente		integer;
define _user_added      char(10);

define _error			integer;
define _error_desc		char(50);
define _ult_fecha       date;

let _fecha_inicio = MDY(1,1,2008);

set isolation to dirty read;

let _error = 0;

foreach
 select	fecha_reclamo,
        no_reclamo,
		numrecla,
		no_poliza,
		perd_total,
		no_tramite,
		incidente,
		user_added
   into	_fecha_reclamo,
        _no_reclamo,
		_numrecla,
		_no_poliza,
		_perd_total,
		_no_tramite,
		_incidente,
		_user_added
   from recrcmae
  where fecha_reclamo  >= _fecha_inicio
	and actualizado    = 1
	and today - fecha_reclamo > 90

	select cod_ramo,
	       cod_subramo
	  into _cod_ramo,
	       _cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo <> "018" then
		continue foreach;
	end if

	select sum(variacion)
	  into _reserva
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and actualizado  = 1;

	if _reserva is null then
		let _reserva = 0.00;
	end if

	if _reserva <= 0.00 then
		continue foreach;
	end if

	select count(*)
	  into _cantidad
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and actualizado  = 1
	   and cod_tipotran <> "001"; --reserva inicial

    let _cantidad2 = 0;
	let _dias = 0;

	if _cantidad <> 0 then

		--Ampliacion cierre automatico para salud cuya ultima transaccion haya sido hace 3 meses Alejandra Marquez
		if _cod_ramo = "018" then	--SALUD

				select max(fecha)
				  into _ult_fecha
				  from rectrmae
				 where no_reclamo   = _no_reclamo
				   and actualizado  = 1;

                if today - _ult_fecha > 90 then

					select nombre
					  into _nombre_ramo
					  from prdramo
					 where cod_ramo = _cod_ramo;

					return _numrecla,
					       _fecha_reclamo,
						   _error,
						   today - _fecha_reclamo,
						   _reserva,
						   _nombre_ramo,
						   today - _ult_fecha
						   with resume;

				else
					continue foreach;
				end if
		else
			continue foreach;
		end if

	end if
end foreach

return "",
       "",
	   0,
	   0,
	   0.00,
	   "",
	   0
	   with resume;

end procedure