drop procedure sp_rec81;

create procedure sp_rec81()
returning smallint,
		  char(20),
          char(20),
          char(5),
          char(30);

define _numrecla		char(20);
define _no_documento	char(20);
define _no_unidad		char(5);
define _no_poliza		char(10);
define _no_reclamo		char(10);
define _no_motor		char(30);

foreach
 select r.numrecla,
        r.no_unidad,
		p.no_documento,
		p.no_poliza,
		r.no_reclamo
   into _numrecla,
        _no_unidad,
		_no_documento,
		_no_poliza,
		_no_reclamo
   from recrcmae r, emipomae p
  where r.no_poliza = p.no_poliza
	and p.cod_ramo  = "002"
	and r.no_motor  is null
--	and numrecla    = "02-1195-00130-01"

{
	select no_motor
	  into _no_motor
	  from emiauto
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;
	
	if _no_motor is null then

	   foreach
		select no_motor
		  into _no_motor
		  from endmoaut
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
			exit foreach;
		end foreach

	end if

	if _no_motor is null then

	   foreach
		select no_motor
		  into _no_motor
		  from emiauto a, emipomae p
		 where a.no_poliza    = p.no_poliza
		   and a.no_unidad    = _no_unidad
		   and p.no_documento = _no_documento
			exit foreach;
		end foreach

	end if

	if _no_motor = "123" then
		let _no_motor = null;
	end if
	
	if _no_motor is null then
		let _no_motor = "00000";
	end if

--	if _no_motor is not null then
		
		update recrcmae
		   set no_motor   = _no_motor
		 where no_reclamo = _no_reclamo;

--	end if
}

	return _numrecla,
		   _no_documento,
           _no_unidad,
		   _no_motor
	       with resume;	

end foreach

end procedure