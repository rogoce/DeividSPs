-- Procedure que cierra los reclamos abiertos hace mas de 3 meses que no han tenido movimiento

drop procedure sp_rwf84;

create procedure sp_rwf84()
returning char(20),
          date,
		  smallint,
		  smallint,
		  dec(16,2),
		  char(50);

define _fecha_inicio	date;
define _fecha_reclamo	date;
define _cantidad		smallint;
define _no_reclamo		char(10);
define _numrecla		char(20);
define _reserva			dec(16,2);
define _no_poliza		char(10);
define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _nombre_ramo		char(50);
define _perd_total		smallint;

define _no_tramite      char(10);
define _incidente		integer;
define _user_added      char(10);

define _error			integer;
define _error_desc		char(50);
define _dias            integer;

let _fecha_inicio = MDY(1,1,2006);

set isolation to dirty read;

let _error = 0;
let _reserva = 0.00;


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
  where fecha_reclamo  >= '01-10-2010'
	and actualizado    = 1
	and incidente is not null
	and today - fecha_reclamo > 90

	select cod_ramo,
	       cod_subramo
	  into _cod_ramo,
	       _cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo <> "002" and _cod_ramo <> "020" then
		continue foreach;
	end if

{	if _cod_ramo in ("001", "003", "010", "011", "012", "013", "014") then
		continue foreach;
	end if

	-- Ramos Patrimoniales

	if _cod_ramo in ("006", "009", "015") then
		continue foreach;
	end if

	if _cod_ramo    = "015" and
	   _cod_subramo = "008" then
		continue foreach;
	end if
}
--	De acuerdo a Instrucciones del Sr. Wilson del 25/08/2009
-- 	Modificado por Demetrio Hurtado

{	if _cod_ramo in ("002", "020") then
	
		if _perd_total = 1 then
			continue foreach;
		end if

	end if

	select sum(variacion)
	  into _reserva
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and actualizado  = 1;

	if _reserva is null then
		let _reserva = 0.00;
	end if

	if _reserva = 0.00 then
		continue foreach;
	end if
}
	select count(*)
	  into _cantidad
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and actualizado  = 1
	   and cod_tipotran <> "001"  --reserva inicial
	   and cod_tipotran <> "011"; --cierre del reclamo

	if _cantidad <> 0 then
		continue foreach;
	end if
			
	-- Proceso que cierra las reservas


	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	-- Inserta info en wfcieres para abortar los incidentes del mapa de control reclamos poliza.	Armando 19/10/2010
	if today - _fecha_reclamo in (91) then

	insert into wfcieres (no_reclamo,no_tramite,incidente,user_added)
	values(_no_reclamo,_no_tramite,_incidente,_user_added);

	return _numrecla,
	       _fecha_reclamo,
		   _error,
		   today - _fecha_reclamo,
		   _reserva,
		   _nombre_ramo
		   with resume;
	end if

end foreach

return "",
       "",
	   0,
	   0,
	   0.00,
	   ""
	   with resume;

end procedure