-- Verificacion de los reaseguros de reclamos a nivel de transacciones

-- Creado    : 04/08/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_rec93;
create procedure sp_rec93()
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

set isolation to dirty read;
--set debug file to "sp_rec93.trc";
--trace on;

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
	   and periodo[1,4] >= 2018 --2013,2008
  order by no_reclamo, no_tranrec

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

		select no_poliza
		  into _no_poliza
		  from recrcmae
		 where no_reclamo = _no_reclamo;

		select serie
		  into _serie
		  from emipomae
		 where no_poliza = _no_poliza;

		let _cod_contrato = "00000";
		
	   foreach	
		select cod_contrato
		  into _cod_contrato
		  from reacomae
		 where serie	     = _serie
		   and tipo_contrato = 1 	
			exit foreach;
		end foreach

{
		if _cod_contrato <> "00000" then

			insert into rectrrea(
			no_tranrec,
			orden,
			cod_contrato,
			porc_partic_suma,
			porc_partic_prima,
			tipo_contrato
			)
			values(
			_no_tranrec,
			1,
			_cod_contrato,
			0.00,
			0.00,
			1
			);

		end if
--}

--{
		insert into rectrrea(
		no_tranrec,
		orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima,
		tipo_contrato,
		cod_cober_reas
		)
		select
		_no_tranrec,
		r.orden,
		r.cod_contrato,
		r.porc_partic_suma,
		r.porc_partic_prima,
		c.tipo_contrato,
		r.cod_cober_reas
		 from recreaco r, reacomae c
		where r.no_reclamo   = _no_reclamo
		  and r.cod_contrato = c.cod_contrato;	 

		insert into rectrref(
		no_tranrec,
		orden,
		cod_coasegur,
		cod_contrato,
		porc_partic_reas,
		cod_cober_reas
		)
		select
		_no_tranrec,
		orden,
		cod_coasegur,
		cod_contrato,
		porc_partic_reas,
		cod_cober_reas
		from recreafa
		where no_reclamo = _no_reclamo;	 
--}
		 
		 return _transaccion,
				_no_tranrec,
		        _nombre_tipo,
		        _periodo,
		        _cod_contrato,
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
return "0","","","","00000",today,"",0.00,0.00,0.00 with resume;
end procedure
