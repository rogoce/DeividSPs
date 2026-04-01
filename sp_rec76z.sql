-- SOLO PARA PRUEBAS AMADO --
-- (Proceso diario) para buscar las requisiciones de firma electronica
-- Para poder agregar mas transacciones de reclamos a una misma 

-- Modificado: 14/06/2006 - Autor: Armando Moreno Montenegro

drop procedure sp_rec76z;

create procedure "informix".sp_rec76z()
 returning  char(10),	--no_requis
			dec(16,2),  --monto
			char(100),	--a nombre de
			date,		--fecha captura
			char(8),	--user_added
			char(3),
			char(3);

define _no_requis		  char(10);
define _fecha_captura	  date;
define _nombre			  char(100);
define _monto			  dec(16,2);
define _firma_electronica smallint;
define _cod_banco         char(3);
define _cod_chequera      char(3);
define _periodo_pago	  smallint;
define _dias			  integer;
define _user_added        char(8);
define _fecha_time        datetime year to fraction(5);
define _cnt				  integer;
define _origen_cheque     char(1);

--SET DEBUG FILE TO "sp_rec76a.trc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;

let _fecha_time 	= CURRENT;

update wf_firmas set orden = 0;

foreach
	select cod_banco,
	       cod_chequera
	  into _cod_banco,
		   _cod_chequera
	  from chqbanch
	 where cod_ramo <> '*' -- Se modifico ya que tambien hay de autos
--	 where cod_ramo = '018'

	select firma_electronica
	  into _firma_electronica
	  from chqchequ
	 where cod_banco    = _cod_banco
	   and cod_chequera	= _cod_chequera;

	if _firma_electronica = 1 then	--es chequera de firma electronica
	else
		continue foreach;	
	end if

    update chqchmae
	   set autorizado    = 1
	 where autorizado    = 0
	   and pagado        = 0
	   and anulado       = 0
 	   and origen_cheque = "S"
	   and cod_banco     = _cod_banco
	   and cod_chequera  = _cod_chequera
	   and en_firma	  in (0, 4)
	   and monto         > 0.00
	   and fecha_captura = '04/06/2011';

	foreach
	 select	no_requis,
			monto,
			a_nombre_de,
			periodo_pago,
			user_added,
			fecha_captura,
			origen_cheque
	   into	_no_requis,
			_monto,
			_nombre,
			_periodo_pago,
			_user_added,
			_fecha_captura,
			_origen_cheque
	   from	chqchmae
	  where autorizado    = 1
		and pagado        = 0
		and anulado       = 0
 		and origen_cheque in ("3","G","S")
		and cod_banco     = _cod_banco
		and cod_chequera  = _cod_chequera
		and en_firma	  in (0, 4)
		and monto         > 0.00
	    and fecha_captura = '04/06/2011'
 --		and origen_cheque in ("3","G")
-- 		and no_requis = '335575'

	   select count(*)
	     into _cnt
	     from chqchrec
	    where no_requis = _no_requis;
	    
	   if _cnt > 0  then
	   else
		if _origen_cheque = "3"	then
			continue foreach;
		end if
	   end if  	

     if _origen_cheque = "3" then  -- Caso 09862 USER: CMARIN 
	    let _cnt = 0;
		select count(*)
		  into _cnt
		  from chqchrec
	     where no_requis = _no_requis
	       and numrecla[1,2] in ('02','20','18');

        if _cnt = 0 then
			continue foreach;
		end if   
     end if

	 let _dias = today - _fecha_captura;
	 let _dias = 1;

     set lock mode to wait;

 	 if _origen_cheque = 'G' then
		if _dias = 0 then

			update chqchmae
			   set en_firma         = 1,
			       fecha_paso_firma = _fecha_time
			 where no_requis        = _no_requis;

			return _no_requis,
				   _monto,
				   _nombre,
				   _fecha_time,
				   _user_added,
				   _cod_banco,   
				   _cod_chequera
				   with resume;
		end if
	 elif _origen_cheque = 'S' then
		update chqchmae
		   set en_firma         = 1,
		       fecha_paso_firma = _fecha_time
		 where no_requis        = _no_requis;

		return _no_requis,
			   _monto,
			   _nombre,
			   _fecha_time,
			   _user_added,
			   _cod_banco,   
			   _cod_chequera
			   with resume;
	 else
		 if _periodo_pago = 0 then    --diario

			if _dias >= 1 then

				update chqchmae
				   set en_firma         = 1,
				       fecha_paso_firma = _fecha_time
				 where no_requis        = _no_requis;

				return _no_requis,
					   _monto,
					   _nombre,
					   _fecha_time,
					   _user_added,
					   _cod_banco,   
					   _cod_chequera
					   with resume;
			end if

		 elif _periodo_pago = 1 then  --semanal

			if _dias > 7 then

				update chqchmae
				   set en_firma         = 1,
				       fecha_paso_firma = _fecha_time
				 where no_requis        = _no_requis;

				return _no_requis,
					   _monto,
					   _nombre,
					   _fecha_time,
					   _user_added,
					   _cod_banco,   
					   _cod_chequera
					   with resume;

			end if

		 else	--mensual

			if _dias > 30 then

				update chqchmae
				   set en_firma         = 1,
				       fecha_paso_firma = _fecha_time
				 where no_requis        = _no_requis;

				return _no_requis,
					   _monto,
					   _nombre,
					   _fecha_time,
					   _user_added,
					   _cod_banco,   
					   _cod_chequera
					   with resume;
			end if

		 end if
	 end if

     set isolation to dirty read;

	end foreach

end foreach

end procedure
