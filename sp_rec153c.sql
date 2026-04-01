-- Procedure que cierra los reclamos abiertos hace mas de 3 meses que no han tenido movimiento

drop procedure sp_rec153c;

create procedure sp_rec153c(a_dias integer, a_dias2 integer, a_ajustador varchar(20) default '%')
returning char(18),
          char(5),
          char(20),
		  char(100),
          date,
		  char(50),
		  integer,
		  char(50),
		  char(30),
		  CHAR(10),
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
define _n_ajustador     char(50);
define _no_unidad		char(5);
define _cod_asegurado	char(10);
define _cod_evento		char(3);
define _no_documento    char(20);
define _n_asegurado     char(100);
define _n_evento        char(50);
define _cnt_dias        integer;
define _e_mail          char(30);
define _usuario         char(8);
define _incidente_ter   integer;
define _origen          char(10);

let _fecha_inicio = MDY(1,1,2018);

set isolation to dirty read;

let _error = 0;
let _cod_abogado   = null;
let _cod_ajustador = null;
let _n_ajustador   = null;
let _cnt_dias      = 0;
let	_no_unidad	   = null;
let	_cod_asegurado = null;
let	_cod_evento	   = null;
let _no_documento  = null;
let _n_asegurado   = null;
let _n_evento      = null;
let _e_mail        = null;

let _cnt_dias = 0;

foreach
 select	c.date_added,
        a.no_reclamo,
		a.numrecla,
		a.no_poliza,
		a.perd_total,
		a.no_tramite,
		a.incidente,
		a.user_added,
		a.cod_abogado,
		a.ajust_interno,
		b.cod_ramo,
		today - c.date_added,
		a.no_unidad,
		c.cod_tercero,
		a.cod_evento,
		b.no_documento,
		c.no_incidente,
		UPPER(d.fullname)
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
		_cod_ramo,
		_cnt_dias,
	    _no_unidad,
	    _cod_asegurado,
	    _cod_evento,
		_no_documento,
		_incidente_ter,
		_n_ajustador
   from recrcmae a, emipomae b, recterce c, tmp_crp_cdr d
  where a.no_poliza = b.no_poliza
    and a.no_reclamo = c.no_reclamo
	and c.no_incidente = d.incident
    and c.date_added  >= _fecha_inicio
	and a.actualizado    = 1
	and today - c.date_added in (4, 6) 
	and b.cod_ramo in ("002", "020", "023")
	and UPPER(d.assignedtouser) like UPPER(a_ajustador)
	order by a.no_reclamo

	--	De acuerdo a Instrucciones del Sr. Wilson del 25/08/2009
	-- 	Modificado por Demetrio Hurtado

	if _perd_total = 1 then
		continue foreach;
	end if

    -- Solicitud de Analisa Stanziola 24/03/2014
	-- Modificado por Amado Perez
    if _cod_abogado is not null and _cod_abogado <> '001' then
		continue foreach;
	end if

	if _cnt_dias = a_dias then
	else
		continue foreach;
	end if
	
	if _no_tramite is not null and trim(_no_tramite) <> "" then
		let _origen = "WORKFLOW";
	else
		let _origen = "DEIVID";
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

	select count(*)
	  into _cantidad
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and actualizado  = 1
 	   and cod_tipotran NOT IN ("001","003"); --reserva inicial, disminucion

    select nombre
      into _n_asegurado
      from cliclien
     where cod_cliente = _cod_asegurado;

    select nombre
      into _n_evento
      from recevent
     where cod_evento = _cod_evento;

    let _cantidad2 = 0;
	let _dias = 0;

	if _cantidad <> 0 then
		continue foreach;
	end if
			

--	select nombre,
--		   usuario
--	  into _n_ajustador,
--		   _usuario
--	  from recajust
--	 where cod_ajustador = _cod_ajustador;

    let a_ajustador = replace(a_ajustador ,'ancon.com/', "");
    let _usuario = trim(upper(a_ajustador[1,8]));

	select e_mail into _e_mail from insuser where usuario = _usuario;


	return _numrecla,
	       _no_unidad,
		   _no_documento,
		   _n_asegurado,
	       _fecha_reclamo,
		   _n_evento,
		   _cnt_dias,
		   _n_ajustador,
		   _e_mail,
		   'TERCERO2',
		   _origen
		   with resume;


end foreach

end procedure