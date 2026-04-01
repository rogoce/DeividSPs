-- Reporte de los Siniestros por Causa

-- Creado    : 03/07/2013 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_rec208;

create procedure "informix".sp_rec208(a_periodo char(7)) 
returning smallint,
          char(50);

define _transaccion		char(10);
define _no_reclamo		char(10);
define _no_tranrec		char(10);
define _no_poliza		char(10);
define _cod_ramo		char(3);
define _perd_total		smallint;
define _cod_cobertura	char(5);
define _cod_tipotran	char(3);
define _monto			dec(16,2);
define _variacion		dec(16,2);
define _monto_concepto	dec(16,2);
define _incurrido_bruto	dec(16,2);
define _porc_coas       dec(7,4);
define _no_motor		char(50);
define _no_chasis		char(50);
define _periodo			char(7);

define _nombre_causa	char(50);
define _tipo_causa		smallint;
define _legal			smallint;

-- Causas del Siniestro

--  1. Gastos Medicos (P)
--  2. Legal (P)
--  3. Perdida Total - Robo
--  4. Perdida Total - Colision
--  5. Perdida Total - Incendio
--  6. Perdida Parcial
--  7. Danos a Terceros - Lesiones Corporales
--  8. Danos a Terceros - Danos a Cosas

--  9. Perdida Total sin Cobertura

-- 10. Perdida Total - Caida de Objetos
-- 11. Perdida Total - Inundacion

set isolation to dirty read;

-- Para cargar en DWHServer
-- call dl_ltable_inf('recsincau', 0)

-- El procedure sp_rec212 actualiza las causas dependiendo de la cobertura

delete from recsincau where periodo = a_periodo;

foreach
 select	no_reclamo,
        cod_tipotran,
		monto,
		variacion,
		no_tranrec,
		transaccion
   into	_no_reclamo,
        _cod_tipotran,
		_monto,
		_variacion,
		_no_tranrec,
		_transaccion
   from rectrmae
  where	periodo     = a_periodo
    and actualizado = 1

	select no_poliza,
	       perd_total,
		   no_motor
	  into _no_poliza,
	       _perd_total,
		   _no_motor
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select no_chasis
	  into _no_chasis
	  from emivehic
	 where no_motor = _no_motor;
	  	
	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo not in ("002", "020") then
		continue foreach;
	end if

	-- Informacion de Coaseguro

	select porc_partic_coas
	  into _porc_coas
      from reccoas
     where no_reclamo   = _no_reclamo
       and cod_coasegur = "036";

	if _porc_coas is null then
		let _porc_coas = 0;
	end if

	-- Calculo del Incurrido

	let _monto     = _monto     / 100 * _porc_coas;
	let _variacion = _variacion / 100 * _porc_coas;

	if _cod_tipotran in ("004", "008", "009") then -- Pago de Reclamo

		let _incurrido_bruto = _monto + _variacion;

	elif _cod_tipotran in ("005", "006", "007") then -- Salvamentos, Recuperos, Deducibles

		let _incurrido_bruto = _monto;

	else

		let _incurrido_bruto = _variacion;
		let _monto           = 0.00;

	end if

	-- Determinacion del Tipo de Causa del Siniestro

	if _perd_total = 1 then

		foreach
		 select cod_cobertura
		   into _cod_cobertura
		   from recrccob
		  where no_reclamo = _no_reclamo

			select causa_siniestro
			  into _tipo_causa
			  from prdcober
			 where cod_cobertura = _cod_cobertura;

			if _tipo_causa not in (3, 4, 5, 10, 11) then
				let _tipo_causa = 4;
			end if
							
			exit foreach;
							
		end foreach

		insert into recsincau
		values (_transaccion, _tipo_causa, _monto, _variacion, _incurrido_bruto, _no_reclamo, a_periodo, 0, _no_chasis, 0, 0);
	
	else

		let _legal = 0;

		if _cod_tipotran = "004" then -- Pago del Reclamo

			select sum(monto)
			  into _monto_concepto
			  from rectrcon
			 where no_tranrec   = _no_tranrec
			   and cod_concepto = "012";	-- Legal

			if _monto_concepto <> 0.00 then 
				let _legal = 1;
			end if

		end if

		if _legal = 1 then

			let _tipo_causa = 2;

			insert into recsincau
			values (_transaccion, _tipo_causa, _monto, _variacion, _incurrido_bruto, _no_reclamo, a_periodo, 0, _no_chasis, 0, 0);

		else

			foreach 
			 select cod_cobertura,
			        monto,
					variacion
			   into	_cod_cobertura,
			        _monto,
					_variacion
			   from rectrcob
			  where no_tranrec = _no_tranrec
			
				-- Calculo del Incurrido

				let _monto     = _monto     / 100 * _porc_coas;
				let _variacion = _variacion / 100 * _porc_coas;

				if _cod_tipotran in ("004", "008", "009") then -- Pago de Reclamo

					let _incurrido_bruto = _monto + _variacion;

				elif _cod_tipotran in ("005", "006", "007") then -- Salvamentos, Recuperos, Deducibles

					let _incurrido_bruto = _monto;

				else -- Movimientos de Reservas

					let _incurrido_bruto = _variacion;
					let _monto           = 0.00;

				end if

				-- Determinacion del Tipo de Causa del Siniestro

				select causa_siniestro
				  into _tipo_causa
				  from prdcober
				 where cod_cobertura = _cod_cobertura;

				if _tipo_causa not in (1, 7, 8) then -- Gastos Medicos, Lesiones Corporales, Danos a Cosas
					let _tipo_causa = 6; -- Perdida Parcial
				end if

				insert into recsincau
				values (_transaccion, _tipo_causa, _monto, _variacion, _incurrido_bruto, _no_reclamo, a_periodo, 0, _no_chasis, 0, 0);

			end foreach

		end if

	end if

end foreach

-- Elimina los Registros Sin Transaccion

delete from recsincau 
 where periodo   = a_periodo
   and monto     = 0
   and variacion = 0
   and incurrido = 0;

-- Cuenta la Cantidad de Reclamos por tipo de causa

foreach
 select no_reclamo,
        tipo_causa
   into _no_reclamo,
        _tipo_causa
   from recsincau
  where periodo = a_periodo
  group by 1, 2
  order by 1, 2

	foreach
	 select transaccion
	   into _transaccion
	   from recsincau
	  where no_reclamo = _no_reclamo
        and tipo_causa = _tipo_causa
		and periodo    = a_periodo
	  order by transaccion

		update recsincau
		   set cantidad    = 1
	     where no_reclamo  = _no_reclamo
           and tipo_causa  = _tipo_causa
		   and periodo     = a_periodo
		   and transaccion = _transaccion;

		exit foreach;

	end foreach

end foreach

-- Cuenta la Cantidad de Chasis por Reclamo por Mes

foreach
 select no_reclamo,
        no_chasis
   into _no_reclamo,
        _no_chasis
   from recsincau
  where periodo = a_periodo
  group by 1, 2
  order by 1, 2

	foreach
	 select transaccion,
	        tipo_causa
	   into _transaccion,
	        _tipo_causa
	   from recsincau
	  where no_reclamo = _no_reclamo
        and no_chasis  = _no_chasis
		and periodo    = a_periodo
	  order by transaccion

		update recsincau
		   set cant_chasis_mes = 1
	     where no_reclamo      = _no_reclamo
           and tipo_causa      = _tipo_causa
		   and periodo         = a_periodo
		   and transaccion     = _transaccion;

		exit foreach;

	end foreach

end foreach

-- Cuenta la Cantidad de Chasis por Reclamo por Año

foreach
 select no_reclamo,
        no_chasis
   into _no_reclamo,
        _no_chasis
   from recsincau
  where periodo[1,4] = a_periodo[1,4]
  group by 1, 2
  order by 1, 2

	update recsincau
	   set cant_chasis_ano = 0
	 where no_reclamo      = _no_reclamo
	   and no_chasis       = _no_chasis
	   and periodo[1,4]    = a_periodo[1,4];
	     
	foreach
	 select transaccion,
	        tipo_causa,
			periodo
	   into _transaccion,
	        _tipo_causa,
			_periodo
	   from recsincau
	  where no_reclamo   = _no_reclamo
        and no_chasis    = _no_chasis
		and periodo[1,4] = a_periodo[1,4]
	  order by periodo, transaccion

		update recsincau
		   set cant_chasis_ano = 1
	     where no_reclamo      = _no_reclamo
           and tipo_causa      = _tipo_causa
		   and periodo         = _periodo
		   and transaccion     = _transaccion;

		exit foreach;

	end foreach

end foreach

return 0, "Actualizacion Exitosa";

end procedure