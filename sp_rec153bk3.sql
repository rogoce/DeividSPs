-- Procedure que cierra los reclamos abiertos hace mas de 3 meses que no han tenido movimiento

drop procedure sp_rec153bk3;
create procedure sp_rec153bk3()
returning char(20),
          date,
		  date,
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
define _n_ajustador     char(50);
define _fecha_max_tran  date;

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
   from recrcmae a, emipomae b
  where a.no_poliza = b.no_poliza
    and a.fecha_reclamo  >= _fecha_inicio
	and a.actualizado    = 1
	--and today - a.fecha_reclamo > 90
	and b.cod_ramo in ("002", "020", "023")		 --se incluye 023 01/10/2014 Armando

	--	De acuerdo a Instrucciones del Sr. Wilson del 25/08/2009
	-- 	Modificado por Demetrio Hurtado

	if _perd_total = 1 then
		continue foreach;
	end if
 -- Verificando si el reclamo tiene terceros si es asi no se cierra automatico
   { let _cont_tercero = 0;

    select count(*)
	  into _cont_tercero
	  from recterce
	 where no_reclamo = _no_reclamo;

    if _cont_tercero > 0 then
		continue foreach;
	end if}
    if _cod_abogado is null Or _cod_abogado = '' then
	
		select max(fecha)
		  into _fecha_max_tran
		  from rectrmae
		 where no_reclamo = _no_reclamo
		   and actualizado  = 1;
		   
		if (today -_fecha_max_tran) > 90 then
		else
			continue foreach;
		end if	

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

		select nombre
		  into _n_ajustador
		  from recajust
		 where cod_ajustador = _cod_ajustador;
				
		return _numrecla,
			   _fecha_reclamo,
			   _fecha_max_tran,
			   today - _fecha_reclamo,
			   _reserva,
			   _n_ajustador,
			   _n_ajustador
			   with resume;
	end if
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