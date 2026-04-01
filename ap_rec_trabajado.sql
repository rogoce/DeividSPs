-- Procedure que cierra los reclamos abiertos hace mas de 3 meses que no han tenido movimiento

drop procedure ap_rec_trabajado;

create procedure ap_rec_trabajado()
returning char(20),
          date,
		  smallint,
		  smallint,
		  dec(16,2),
		  char(50),
		  smallint,
		  char(10);

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
define _n_estatus     char(10);
define _estatus_reclamo char(1);

let _fecha_inicio = MDY(1,1,2008);

set isolation to dirty read;

let _error = 0;
let _cod_abogado   = null;
let _cod_ajustador = null;
let _n_ajustador   = null;

foreach
 select	a.fecha_reclamo,
        a.no_reclamo,
		a.numrecla,
		a.no_poliza,
		a.perd_total,
		a.no_tramite,
		a.incidente,
		a.user_added,
		a.cod_abogado,
		a.ajust_interno,
		a.estatus_reclamo,
		b.cod_ramo
   into	_fecha_reclamo,
        _no_reclamo,
		_numrecla,
		_no_poliza,
		_perd_total,
		_no_tramite,
		_incidente,
		_user_added,
		_cod_abogado,
		_cod_ajustador,
		_estatus_reclamo,
		_cod_ramo
   from recrcmae a, emipomae b
  where a.no_poliza = b.no_poliza
    and a.fecha_reclamo  >= '01-08-2017'
    and a.fecha_reclamo  <= '31-01-2018'
	and a.cod_sucursal = '005'
	and a.actualizado    = 1
	--and today - a.fecha_reclamo > 90
	and b.cod_ramo in ("002", "020", "023")		 --se incluye 023 01/10/2014 Armando
	
	select nombre
	  into _n_ajustador
	  from recajust
	 where cod_ajustador = _cod_ajustador;

	-- Verificando la reserva
	select sum(variacion)
	  into _reserva
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and actualizado  = 1;

	if _reserva is null then
		let _reserva = 0.00;
	end if
	 
	select count(*)
	  into _cantidad
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and actualizado  = 1
 	   and cod_tipotran NOT IN ("001","003"); --reserva inicial, disminucion

    let _cantidad2 = 0;
	let _dias = 0;
	let _error = 0;

	if _cantidad <> 0 then
	    -- Hay reclamos que fueron cerrados el mismo dia lo que hace que la variable _cantidad no de cero y no inserte en wfcieres
	    let _dias = today - _fecha_reclamo;
		select count(*)
		  into _cantidad2
		  from rectrmae
		 where no_reclamo   = _no_reclamo
		   and actualizado  = 1
		   and cod_tipotran NOT IN ("001","003","011");  --reserva inicial, disminucion, cierre del reclamo

		if _cantidad2 > 0 then
			let _error = 1;
		end if

	end if
	
	if _estatus_reclamo = 'A' then
		let _n_estatus = 'ABIERTO';
	elif _estatus_reclamo = 'C' then
		let _n_estatus = 'CERRADO';
	elif _estatus_reclamo = 'D' then
		let _n_estatus = 'DECLINADO';
	elif _estatus_reclamo = 'N' then
		let _n_estatus = 'NO APLICA';
	else
		let _n_estatus = _estatus_reclamo;
	end if 
			
	return _numrecla,
		   _fecha_reclamo,
		   _error,
		   today - _fecha_reclamo,
		   _reserva,
		   _n_ajustador,
		   _perd_total,
		   _n_estatus
		   with resume;

end foreach


end procedure