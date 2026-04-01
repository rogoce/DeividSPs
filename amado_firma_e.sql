-- (Proceso diario) para buscar las requisiciones de firma electronica
-- Para poder agregar mas transacciones de reclamos a una misma 

-- Modificado: 14/06/2006 - Autor: Armando Moreno Montenegro

drop procedure amado_firma_e;

create procedure "informix".amado_firma_e()
 returning  char(10),	--no_requis
			dec(16,2),  --monto
			char(100),	--a nombre de
			date,		--fecha captura
			char(8);	--user_added

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

--SET DEBUG FILE TO "sp_rec76a.trc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;

let _fecha_time 	= CURRENT;

foreach
	select cod_banco,
	       cod_chequera
	  into _cod_banco,
		   _cod_chequera
	  from chqbanch
	 where cod_ramo <> '*' -- Se modifico para prueba ya que tambien haya de autos
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

	foreach
	 select	no_requis,
			monto,
			a_nombre_de,
			periodo_pago,
			user_added,
			fecha_captura
	   into	_no_requis,
			_monto,
			_nombre,
			_periodo_pago,
			_user_added,
			_fecha_captura
	   from	chqchmae
	  where autorizado    = 1
		and pagado        = 0
		and anulado       = 0
		and origen_cheque = "3"
		and cod_banco     = _cod_banco
		and cod_chequera  = _cod_chequera
		and en_firma	  in (0, 4)
		and monto         > 0.00
 		and no_requis = '304310'

	   select count(*)
	     into _cnt
	     from chqchrec
	    where no_requis = _no_requis;
	    
	   if _cnt > 0 then
	   else
			continue foreach;
	   end if  	

	 let _dias = today - _fecha_captura;
 	 let _dias = 1;

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
				   _user_added
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
				   _user_added
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
				   _user_added
				   with resume;
		end if

	 end if

	end foreach

end foreach

end procedure
