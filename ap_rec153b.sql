-- Procedure que cierra los reclamos abiertos que están la tabla tmp_cierra_rec segun caso 3836

drop procedure ap_rec153b;

create procedure ap_rec153b()
returning char(20) as reclamo,
          date as fecha_reclamo,
		  date as fecha_siniestro,
		  int as dias_abierto,
		  decimal as anos_abierto,
		  dec(16,2) as variacion_res,
		  char(50) as ramo,
		  date as fecha_ult_tra,
		  int as dias_ult_tra,
		  char(1) as estatus_reclamo,
		  integer as operacion,
		  integer as error,
		  varchar(50) as desc_error;

define _fecha_inicio	date;
define _fecha_reclamo	date;
define _fecha_siniestro date;
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
define _dias_tran       integer; 
define _fecha_tran   	date;
define _anos_tran       decimal;    
define _estatus_reclamo char(1);    

define _no_tramite      char(10);
define _incidente		integer;
define _user_added      char(10);

define _error			integer;
define _error_desc		char(50);
define _ult_fecha       date;
define _cod_abogado     char(3);
define _cont_tercero    integer;

define _procesado       smallint;
define _cnt             integer;

let _fecha_inicio = MDY(1,1,2008);

set isolation to dirty read;

let _error = 0;
let _error_desc = "";
let _cnt = 0;

let _cod_abogado = null;

-- Solicitud 24/03/2014 Analisa Stanziola

foreach
-- select numrecla    --first 2500 
--   into _numrecla
--   from tmp_cierra_rec
 -- where procesado = 0
--  order by numrecla
  
 select	a.numrecla,
        a.fecha_reclamo,
        a.no_reclamo,
		a.no_poliza,
		a.perd_total,
		a.no_tramite,
		a.incidente,
		a.user_added,
		a.cod_abogado,
		a.fecha_siniestro,
		a.estatus_reclamo,
		b.cod_ramo,
		c.procesado
   into	_numrecla,
        _fecha_reclamo,
        _no_reclamo,
		_no_poliza,
		_perd_total,
		_no_tramite,
		_incidente,
		_user_added,
		_cod_abogado,
		_fecha_siniestro,
		_estatus_reclamo,
		_cod_ramo,
		_procesado
   from recrcmae a, emipomae b, tmp_cierra_rec c
  where c.numrecla = a.numrecla
    and a.no_poliza = b.no_poliza
 	and c.procesado = 1
order by a.numrecla
	
	select sum(variacion)
	  into _reserva
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and actualizado  = 1;

    select max(fecha)
	  into _fecha_tran
	  from rectrmae
	 where no_reclamo = _no_reclamo
	   and actualizado = 1;

	let _dias_tran = 0;
	let _dias_tran = today - _fecha_tran;
	let _anos_tran = (today - _fecha_siniestro) / 365.24;
	
	if _anos_tran <= 2.00 then
	--	continue foreach;
	end if	

	if _reserva is null then
		let _reserva = 0.00;
	end if

	if _reserva = 0.00 and _estatus_reclamo <> 'A' then
	--	continue foreach;
    end if	
	
	-- Proceso que cierra las reservas

	-- call ap_rec158(_no_reclamo, _reserva) returning _error, _error_desc;

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;
				
	return _numrecla,
	       _fecha_reclamo,
		   _fecha_siniestro,
		   today - _fecha_reclamo,
		   _anos_tran,
		   _reserva,
		   _nombre_ramo,
		   _fecha_tran,
		   _dias_tran,
		   _estatus_reclamo,
		   today - _fecha_siniestro,
		   _error,
		   _error_desc
		   with resume;
	
--    let _cnt = _cnt + 1;

--    if _cnt = 1000 then
--       exit foreach;
--    end if	   

end foreach


end procedure

