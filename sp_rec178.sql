-- Procedure que cierra los reclamos de manera masiva 

-- Creado    : 10/12/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec178;

create procedure sp_rec178()
returning char(20),
		  dec(16,2),
		  integer,
		  char(100);

define _no_reclamo		char(10);
define _numrecla		char(20);
define _reserva			dec(16,2);

define _no_tramite      char(10);
define _incidente		integer;
define _user_added      char(10);

define _error			integer;
define _error_desc		char(50);

set isolation to dirty read;

let _error = 0;

begin work;

foreach
 select reclamo
   into _numrecla
   from deivid_tmp:tmp_reservas_4
  where actualizado = 0

 select	no_reclamo,
		no_tramite,
		incidente,
		user_added
   into	_no_reclamo,
		_no_tramite,
		_incidente,
		_user_added
   from recrcmae
  where numrecla = _numrecla;

	select sum(variacion)
	  into _reserva
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and actualizado  = 1;

	if _reserva is null then
		let _reserva = 0.00;
	end if

	--{
	if _reserva <> 0.00 then

		-- Proceso que cierra las reservas
		call sp_rec158(_no_reclamo, _reserva) returning _error, _error_desc;

		if _error <> 0 then
			rollback work;
			return _numrecla, _reserva, _error, _error_desc;
		end if 

	end if

	insert into wfcieres (no_reclamo,no_tramite,incidente,user_added)
	values(_no_reclamo,_no_tramite,_incidente,_user_added);

	update deivid_tmp:tmp_reservas_4
	   set actualizado = 1
	 where reclamo     = _numrecla; 

	update recrcmae
	   set estatus_reclamo = "C"
	 where numrecla        = _numrecla; 
	--}

	return _numrecla,
		   _reserva,
		   0,
		   "Actualizacion Exitosa"
		   with resume;

end foreach

--rollback work;
commit work;

return "",
	   0.00,
	   0,
	   "Actualizacion Exitosa"
	   with resume;

end procedure