

drop procedure sp_rec76e;

create procedure "informix".sp_rec76e(a_no_requis char(10))
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
define _user_added        char(8);
define _fecha_time        datetime year to fraction(5);

--SET DEBUG FILE TO "sp_rec76a.trc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;

let _fecha_time = CURRENT;

foreach
	select cod_banco,
	       cod_chequera
	  into _cod_banco,
		   _cod_chequera
	  from chqbanch
	 where cod_ramo <> '*'
	 group by cod_banco,cod_chequera

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
				fecha_captura,
				monto,
				a_nombre_de,
				periodo_pago,
				user_added
		   into	_no_requis,
				_fecha_captura,
				_monto,
				_nombre,
				_periodo_pago,
				_user_added
		   from	chqchmae
		  where autorizado    = 1
			and pagado        = 0
			and anulado       = 0
			and origen_cheque in("3","S","K")
			and cod_banco     = _cod_banco
			and cod_chequera  = _cod_chequera
			and en_firma	  in (0, 4, 5)
			and no_requis     = a_no_requis

		if _periodo_pago = 0 then    --diario

			update chqchmae
			   set en_firma         = 1,
				   fecha_paso_firma = _fecha_time
			 where no_requis        = _no_requis;

			--mandar a firma
			return _no_requis,
				   _monto,
				   _nombre,
				   _fecha_captura,
				   _user_added,
				   _cod_banco, 
				   _cod_chequera
				   WITH RESUME;
				exit foreach;

		elif _periodo_pago = 1 then  --semanal

			update chqchmae
			   set en_firma         = 1,
				   fecha_paso_firma = _fecha_time
			 where no_requis        = _no_requis;

			--mandar a firma
			return _no_requis,
				   _monto,
				   _nombre,
				   _fecha_captura,
				   _user_added,
				   _cod_banco,
				   _cod_chequera 
				   WITH RESUME;

				exit foreach;
	    else		 --> Mensual no estaba incluido -- Amado 31/01/2012 lo habilite porque habia unos problemas con la bd y hay requisiciones con problemas
			update chqchmae
			   set en_firma         = 1,
				   fecha_paso_firma = _fecha_time
			 where no_requis        = _no_requis;

			--mandar a firma
			return _no_requis,
				   _monto,
				   _nombre,
				   _fecha_captura,
				   _user_added,
				   _cod_banco,
				   _cod_chequera 
				   WITH RESUME;

			exit foreach;
		end if
	end foreach
end foreach
end procedure
