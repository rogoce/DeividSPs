-- Procedure que busca los reclamos abiertos hace mas de 3 meses que no han tenido movimiento TERCEROS

drop procedure sp_rec286;

create procedure sp_rec286()
returning char(10) as tramite,
          varchar(100) as asegurado,
		  char(20) as poliza,
		  varchar(100) as tercero,
          date as fecha_apertura,
		  date as fecha_siniestro,
		  dec(16,2) as reserva;
		  
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
define _cod_tercero    char(10);
define _cont           integer;
define _asegurado      varchar(100);
define _tercero        varchar(100);
define _date_added     date;
define _cod_asegurado  char(10);
define _no_documento   char(20);
define _fecha_siniestro date;

let _fecha_inicio = MDY(1,1,2008);

set isolation to dirty read;

let _error = 0;
let _cod_abogado   = null;
let _cod_ajustador = null;
let _n_ajustador   = null;

foreach
 select	a.no_tramite,
        a.cod_asegurado,
 		a.no_documento,
        a.fecha_siniestro,
        a.no_reclamo,
		b.cod_tercero,
		b.date_added
   into	_no_tramite,
        _cod_asegurado,
		_no_documento,
		_fecha_siniestro,
        _no_reclamo,
		_cod_tercero,
		_date_added
   from recrcmae a, recterce b
  where a.no_reclamo = b.no_reclamo
    and a.fecha_reclamo  >= _fecha_inicio
	and a.actualizado    = 1
--	and a.estatus_reclamo = 'A'
	and a.estatus_audiencia in (0,8)
	and a.cod_abogado = '001'
order by  a.incidente
	
	let _cont = 0;
	
	select count(*)
	  into _cont
	  from rectrmae
	 where no_reclamo = _no_reclamo
	   and cod_cliente  = _cod_tercero
	   and cod_tipotran = '004'
	   and actualizado = 1;
	   
	select sum(variacion)
	  into _reserva
	  from rectrmae
	 where no_reclamo = _no_reclamo
	   and actualizado = 1;	 
	
    if _cont = 0 then
		select nombre
		  into _asegurado
		  from cliclien
		 where cod_cliente = _cod_asegurado;
	
		select nombre
		  into _tercero
		  from cliclien
		 where cod_cliente = _cod_tercero;
	
		return _no_tramite,
			   _asegurado,
			   _no_documento,
			   _tercero,
			   _date_added,
			   _fecha_siniestro,
			   _reserva
			   with resume;
    end if
end foreach



end procedure