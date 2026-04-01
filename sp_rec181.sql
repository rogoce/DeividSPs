-- Procedimiento que verifica las reservas de reclamos de un periodo vs el periodo anterior
 
-- Creado     :	04/12/2010 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec181;		

create procedure "informix".sp_rec181(a_no_tranrec char(10))
returning char(20),
          char(10),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          char(7),
          char(7);

define _no_reclamo	char(10);
define _numrecla	char(20);
define _reserva_ant	dec(16,2);
define _reserva_act	dec(16,2);
define _variacion	dec(16,2);

define _fecha		date;
define _periodo_ant	char(7);
define _periodo_act char(7);

set isolation to dirty read;

create temp table tmp_reserva(
no_reclamo		char(10),
reserva_ant		dec(16,2) 	default 0,
reserva_act		dec(16,2) 	default 0,
variacion		dec(16,2) 	default 0
) with no log;

select periodo,
       numrecla
  into _periodo_act,
       _numrecla
  from rectrmae 
 where no_tranrec = a_no_tranrec;

let _fecha       = sp_sis36(_periodo_act);
let _fecha       = _fecha - 1 units month;
let _periodo_ant = sp_sis39(_fecha);

-- Reservas Periodo Anterior

foreach 
 select no_reclamo,		
        SUM(variacion)
   into _no_reclamo,	
        _reserva_ant
   from rectrmae 
  where cod_compania = "001"
    and periodo      <= _periodo_ant 
	and actualizado  = 1
	and numrecla     = _numrecla    
  group by no_reclamo
 having sum(variacion) > 0 

	insert into tmp_reserva(no_reclamo, reserva_ant)
	values (_no_reclamo, _reserva_ant);

end foreach

-- Reservas Periodo Actual

foreach 
 select no_reclamo,		
        SUM(variacion)
   into _no_reclamo,	
        _reserva_act
   from rectrmae 
  where cod_compania = "001"
    and periodo      <= _periodo_act 
	and actualizado  = 1
	and numrecla     = _numrecla    
  group by no_reclamo
 having sum(variacion) > 0 

	insert into tmp_reserva(no_reclamo, reserva_act)
	values (_no_reclamo, _reserva_act);

end foreach

-- Variacion Periodo Actual

foreach 
 select no_reclamo,		
        SUM(variacion)
   into _no_reclamo,	
        _variacion
   from rectrmae 
  where cod_compania = "001"
    and periodo      = _periodo_act 
	and actualizado  = 1
	and numrecla     = _numrecla    
  group by no_reclamo

	insert into tmp_reserva(no_reclamo, variacion)
	values (_no_reclamo, _variacion);

end foreach

foreach 
 select no_reclamo,		
        SUM(reserva_ant),
        SUM(reserva_act),
        SUM(variacion)
   into _no_reclamo,	
        _reserva_ant,
        _reserva_act,
        _variacion
   from tmp_reserva 
  group by no_reclamo

	if (_reserva_ant + _variacion - _reserva_act) <> 0 then

		select numrecla
		  into _numrecla
		  from recrcmae
		 where no_reclamo = _no_reclamo;

		return _numrecla,
		       _no_reclamo,
		       _reserva_ant,
			   _variacion,
			   (_reserva_ant + _variacion),
			   _reserva_act,
			   (_reserva_ant + _variacion - _reserva_act),
			   _periodo_ant,
			   _periodo_act 
			   with resume; 

	end if

end foreach

drop table tmp_reserva;

return "",
       "",
       0,
	   0,
	   0,
	   0,
	   0,
	   _periodo_ant,
	   _periodo_act; 

end procedure
