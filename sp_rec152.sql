-- Verificacion de los reaseguros de reclamos a nivel de transacciones

-- Creado    : 04/08/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_rec152;

create procedure sp_rec152()
returning char(10),
		  char(10),	
          char(50),
          char(7),
          char(5),
          date,
          char(8),
          dec(16,2),
          dec(16,2),
          dec(16,4);

define _no_tranrec		char(10);
define _no_reclamo		char(10);
define _transaccion		char(10);
define _nombre_tipo		char(50);
define _cod_tipotran	char(3);
define _cantidad		smallint;
define _periodo			char(7);

define _serie			smallint;
define _no_poliza		char(10);
define _cod_contrato	char(5);
define _fecha			date;
define _user_added		char(8);
define _monto			dec(16,2);
define _variacion		dec(16,2);
define _porcentaje		dec(16,4);
define _renglon			smallint;

define _error			integer;
define _error_desc		char(50);
define _periodo_verifica char(7);

set isolation to dirty read;

--set debug file to "sp_rec152.trc";
--trace on;
select periodo_verifica
  into _periodo_verifica
  from emirepar;

foreach
	 select no_tranrec,
			no_reclamo,
			transaccion,
			cod_tipotran,
			periodo,
			fecha,
			user_added,
			monto,
			variacion
	   into _no_tranrec,
			_no_reclamo,
			_transaccion,
			_cod_tipotran,
			_periodo,
			_fecha,
			_user_added,
			_monto,
			_variacion
	   from rectrmae
	  where actualizado  = 1
		and sac_asientos <> 2
		and periodo      = _periodo_verifica
	  order by no_reclamo, no_tranrec

	call sp_sis201(_no_reclamo) returning _error, _error_desc;

	select nombre
	  into _nombre_tipo
	  from rectitra
	 where cod_tipotran = _cod_tipotran;

	-- Verificando Si Existen Contratos

	select count(*)
	  into _cantidad
	  from rectrrea
	 where no_tranrec = _no_tranrec;

	if _cantidad = 0 then

		call sp_sis58(_no_tranrec) returning _error, _error_desc;
		 		
		 return _transaccion,
				_no_tranrec,
		        _nombre_tipo,
		        _periodo,
		        null,
		        _fecha,
				_user_added,
				_monto,
				_variacion,
				null
				with resume;

	else

		foreach	
		 select orden
		   into _renglon
		   from rectrrea
		  where no_tranrec    = _no_tranrec
		    and tipo_contrato = 3
			and porc_partic_suma <> 0
			and porc_partic_prima <> 0

			select count(*)
			  into _cantidad
			  from rectrref
			 where no_tranrec = _no_tranrec 
			   and orden      = _renglon;

			if _cantidad = 0 then

				select nombre
				  into _nombre_tipo
				  from rectitra
				 where cod_tipotran = _cod_tipotran;
				 
				 return _transaccion,
						_no_tranrec,
				        _nombre_tipo,
				        _periodo,
				        null,
				        _fecha,
						_user_added,
						_monto,
						_variacion,
						null
						with resume;

			else
				foreach
					select sum(porc_partic_reas)
					  into _porcentaje
					  from rectrref
					 where no_tranrec = _no_tranrec 
					   and orden      = _renglon
					 group by cod_cober_reas

					if _porcentaje is null then
						let _porcentaje = 0.00;
					end if

					if _porcentaje <> 100 then

						 return _transaccion,
								_no_tranrec,
						        _nombre_tipo,
						        _periodo,
						        null,
						        _fecha,
								_user_added,
								_monto,
								_variacion,
								_porcentaje
								with resume;

					end if
				end foreach
			end if

		end foreach

	end if

	-- Verificanco Sumatoria de Porcentaje
	foreach
		select sum(porc_partic_suma)
		  into _porcentaje
		  from rectrrea
		 where no_tranrec = _no_tranrec
		 group by cod_cober_reas

		if _porcentaje is null then
			let _porcentaje = 0.00;
		end if

		if _porcentaje <> 100 then

	{
			update rectrrea
			   set porc_partic_suma = 100
		     where no_tranrec       = _no_tranrec;
	--}

			 return _transaccion,
					_no_tranrec,
			        _nombre_tipo,
			        _periodo,
			        "00000",
			        _fecha,
					_user_added,
					_monto,
					_variacion,
					_porcentaje
					with resume;
		end if
	end foreach
	-- Verificando Mas de Una Retencion
  foreach
	select count(*)
	  into _cantidad
	  from rectrrea
	 where no_tranrec    = _no_tranrec
	   and tipo_contrato = 1
	   group by cod_cober_reas

	if _cantidad > 1 then

		 return _transaccion,
				_no_tranrec,
		        _nombre_tipo,
		        _periodo,
		        "00000",
		        _fecha,
				_user_added,
				_monto,
				_variacion,
				_cantidad
				with resume;
	end if
  end foreach
end foreach

return "0",
	   "",
       "",
       "",
       "00000",
       today,
	   "",
	   0.00,
	   0.00,
	   0.00
	   with resume;

end procedure
