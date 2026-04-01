-- Procedure que cierra los reclamos abiertos hace mas de 3 meses que no han tenido movimiento -- Deivid Gestion

drop procedure sp_rec153;

create procedure sp_rec153()
returning char(20),
          date,
		  smallint,
		  smallint,
		  dec(16,2),
		  char(50),
		  char(50);

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
define _cod_abogado     char(3);
define _cont_tercero    smallint;
define _cod_ajustador   char(3);
define _n_ajustador   char(50);

let _fecha_inicio = MDY(4,1,2019);

set isolation to dirty read;

let _error = 0;
let _cod_abogado   = null;
let _cod_ajustador = null;
let _n_ajustador   = null;

foreach
 select	fecha_reclamo,
        no_reclamo,
		numrecla,
		no_poliza,
		perd_total,
		no_tramite,
		incidente,
		cod_abogado,
		user_added,
		ajust_interno
   into	_fecha_reclamo,
        _no_reclamo,
		_numrecla,
		_no_poliza,
		_perd_total,
		_no_tramite,
		_incidente,
		_cod_abogado,
		_user_added,
		_cod_ajustador
   from recrcmae
  where fecha_reclamo  >= _fecha_inicio
	and actualizado    = 1
	--and today - fecha_reclamo > 90  Se pone en comentario por instr. sr Armando Moreno Escobar segun correo del 03/05/2016 y se usa la ultima fecha de la transaccion
	
	select max(fecha)
	  into _ult_fecha
	  from rectrmae
	 where no_reclamo = _no_reclamo
	   and actualizado  = 1;
		   
	if (today - _ult_fecha) > 60 then	
	else
		continue foreach;
	end if

	select cod_ramo,
	       cod_subramo
	  into _cod_ramo,
	       _cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	-- Solicitud de Katherine Cesar 27/03/2014
    if _cod_abogado is not null and _cod_abogado <> '001' then
		continue foreach;
	end if

	if _cod_ramo = "018" then				--Ramo de Salud y Acc. Personales, se extiende a 120 dias Sol. Katherin Cesar 27/03/2017
		if (today - _ult_fecha) > 60 then
		else
			continue foreach;
		end if
	else 
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

	if _cantidad <> 0 then
		continue foreach;
	end if
			
	-- Proceso que cierra las reservas

	call sp_rec158(_no_reclamo, _reserva) returning _error, _error_desc;

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre
	  into _n_ajustador
	  from recajust
	 where cod_ajustador = _cod_ajustador;

	return _numrecla,
	       _fecha_reclamo,
		   _error,
		   today - _fecha_reclamo,
		   _reserva,
		   _n_ajustador,
		   _n_ajustador
		   with resume;

end foreach


return "",
       "",
	   0,
	   0,
	   0.00,
	   "",
	   ""
	   with resume;

end procedure