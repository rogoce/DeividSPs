-- Procedimiento que verifica las reservas de reclamos de un periodo vs el periodo anterior
 
-- Creado     :	04/12/2010 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure ap_rec177a;		

create procedure "informix".ap_rec177a(a_numrecla char(20))
returning char(20),
          char(10),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          char(7),
          char(7),
          dec(16,2),
          char(10),
          smallint;


define _no_reclamo	char(10);
define _numrecla	char(20);
define _reserva_ant	dec(16,2);
define _reserva_act	dec(16,2);
define _variacion	dec(16,2);

--define _fecha		date;
define _periodo_ant	char(7);
define _periodo_act char(7);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

define _cant,_cant2        smallint;
define _fecha_cierre date;
define _no_tranrec   char(10);
define _reserva_cierre dec(16,2);
define _transaccion    char(10);
define _reserva_neg    dec(16,2);

begin
on exception set _error, _error_isam, _error_desc

	-- Se retorna 2 errores para que no siga el proceso de actualizacion
	-- de asientos en PowerBuilder

	return _error,
	       _error_isam,
	       0,
		   0,
		   0,
		   0,
		   0,
		   "",
		   "",
		   0,
		   "",0;

end exception

--set debug file to "sp_rec177.trc";
--trace on;

set isolation to dirty read;

let _numrecla = a_numrecla;

create temp table tmp_periodo(
periodo	char(7)
) with no log;

create temp table tmp_reserva(
no_reclamo		char(10),
reserva_ant		dec(16,2) 	default 0,
reserva_act		dec(16,2) 	default 0,
variacion		dec(16,2) 	default 0
) with no log;

foreach
 select periodo
   into	_periodo_act
   from rectrmae 
  where actualizado  = 1
    and sac_asientos = 0
  group by periodo
  order by periodo

	insert into tmp_periodo
	values (_periodo_act);

end foreach

--delete from tmp_periodo
--where periodo = '2014-01';

let _cant2 = 0;
let _transaccion = "";

foreach
 select periodo
   into _periodo_act
   from tmp_periodo

	let _periodo_ant = sp_sis147(_periodo_act);

	delete from tmp_reserva;

	-- Reservas Periodo Anterior

	foreach 
	 select no_reclamo,		
	        SUM(variacion)
	   into _no_reclamo,	
	        _reserva_ant
	   from rectrmae 
	  where periodo      <= _periodo_ant 
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
	  where periodo      <= _periodo_act 
		and actualizado  = 1
	--	and fecha        < today
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
	  where periodo      = _periodo_act 
		and actualizado  = 1
	--	and fecha        < today
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

      let _cant = 0;

    select count(*)
	  into _cant
	  from rectrmae
	 where no_reclamo   = _no_reclamo
	   and cod_tipotran <> '011'
	   and periodo      = _periodo_act;

		if (_reserva_ant + _variacion - _reserva_act) <> 0 and _cant = 0 then

	  		let _reserva_cierre = 0.00;

		    select transaccion,
			       no_tranrec
			  into _transaccion,
			       _no_tranrec
			  from rectrmae
			 where no_reclamo   = _no_reclamo
			   and cod_tipotran = '011'
			   and periodo      = _periodo_act
			   and actualizado = 1;

			 select SUM(variacion)
			   into _reserva_cierre
			   from rectrmae 
			  where no_reclamo = _no_reclamo
				and cod_tipotran <> '011'
				and actualizado  = 1;

			 select numrecla
			   into _numrecla
			   from recrcmae
			  where no_reclamo = _no_reclamo;


		   	 select count(*)
			   into _cant2
			   from rectrcob
			  where no_tranrec = _no_tranrec;


				return _numrecla,
				       _no_reclamo,
				       _reserva_ant,
					   _variacion,
					   (_reserva_ant + _variacion),
					   _reserva_act,
					   (_reserva_ant + _variacion - _reserva_act),
					   _periodo_ant,
					   _periodo_act,
					   _reserva_cierre,_transaccion,_cant2
					   with resume;

		   	let _reserva_neg = 0;

		   --	if _cant2 = 1 then
					   
				let _reserva_neg = _reserva_cierre * -1;

				if _reserva_cierre = 0 then
					let _reserva_neg = _reserva_cierre;
				end if 

				update rectrcob
				   set monto     = _reserva_cierre,
				       variacion = _reserva_neg
				 where no_tranrec = _no_tranrec
				   and variacion <> 0;
				       		    
				update rectrmae
				   set monto     = _reserva_cierre,
				       variacion = _reserva_neg
				 where no_tranrec = _no_tranrec;

		   --	end if

		end if

	end foreach

end foreach

end

drop table tmp_reserva;
drop table tmp_periodo;

return "",
       "",
       0,
	   0,
	   0,
	   0,
	   0,
	   _periodo_ant,
	   _periodo_act,
	   0,_transaccion,_cant2;

end procedure
