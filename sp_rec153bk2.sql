-- Procedure que cierra los reclamos abiertos hace mas de 3 meses que no han tenido movimiento

drop procedure sp_rec153bk2;
create procedure sp_rec153bk2()
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

let _fecha_inicio = MDY(1,1,2008);

set isolation to dirty read;

let _error = 0;
let _cod_abogado   = null;
let _cod_ajustador = null;
let _n_ajustador   = null;



-- Solicitud 24/03/2014 Analisa Stanziola

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
		_cod_ramo
   from bb t,recrcmae a, emipomae b
  where t.numrecla = a.numrecla
    and t.procesado = 0
    and a.no_poliza = b.no_poliza
	and a.actualizado    = 1
	and b.cod_ramo in ("002", "020", "023")		 --se incluye 023 01/10/2014 Armando

	--	De acuerdo a Instrucciones del Sr. Wilson del 25/08/2009
	-- 	Modificado por Demetrio Hurtado

	-- Verificando la reserva
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
 	   and cod_tipotran NOT IN ("001","003"); --reserva inicial, disminucion

	-- Proceso que cierra las reservas

	call sp_rec158(_no_reclamo, _reserva) returning _error, _error_desc;

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	-- Inserta info en wfcieres para abortar los incidentes del mapa de control reclamos poliza.	Armando 19/10/2010
	insert into wfcieres (no_reclamo,no_tramite,incidente,user_added)
	values(_no_reclamo,_no_tramite,_incidente,_user_added);

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