-- Reporte de Registros Contables de Produccion
-- 
-- Creado    : 29/10/2002 - Autor: Marquelda Valdelamar
-- Modificado: 29/10/2002 - Autor: Marquelda Valdelamar.
-- Modificado: 26/04/2007 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - d_cobr_sp_cob61_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_sac63bk;
CREATE PROCEDURE sp_sac63bk(a_tipo smallint)
returning smallint,
          char(50),
		  char(25);

define _error_cod	integer;
define _error_isam	integer;
define _error_desc	char(100);

define _cuenta		char(25);
define _cod_aux		char(5);
define _cantidad	integer;

define _no_poliza	char(10);
define _no_endoso	char(5);

define _no_remesa	char(10);
define _renglon		integer;

define _no_tranrec	char(10);
define _tipo_comp	smallint;

define _no_requis	char(10);
define _monto_may	dec(16,2);
define _monto_aux	dec(16,2);
define _auxiliar	char(1);

begin 
on exception set _error_cod, _error_isam, _error_desc
	drop table tmp_cta;
	return _error_cod, _error_desc, "";
end exception

create temp table tmp_cta(
cuenta		char(25),
tipo_error	smallint
) with no log;

set isolation to dirty read;
--set debug file to "sp_sac63.trc";
--trace on;


if a_tipo = 1 then -- Produccion

	foreach
	 select a.cuenta
	   into _cuenta
	   from endedmae e, endasien a
	  where e.no_poliza    = a.no_poliza
	    and e.no_endoso    = a.no_endoso
		and e.sac_asientos = 1
	  group by a.cuenta

		select count(*)
		  into _cantidad
		  from cglcuentas
		 where cta_cuenta = _cuenta;

		if _cantidad = 0 then

			insert into tmp_cta
			values (_cuenta, 1);

		end if

	end foreach

	foreach
	 select e.no_poliza,
	        e.no_endoso,
			a.cuenta
	   into _no_poliza,
	        _no_endoso,
	        _cuenta
	   from endedmae e, endasien a, cglcuentas c
	  where e.no_poliza    = a.no_poliza
	    and e.no_endoso    = a.no_endoso
		and a.cuenta       = c.cta_cuenta
		and c.cta_auxiliar = "S"
		and e.sac_asientos = 1

		select count(*)
		  into _cantidad
		  from endasiau
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and cuenta    = _cuenta;

		if _cantidad = 0 then

			insert into tmp_cta
			values (_cuenta, 2);

		else

		   foreach
			select cod_auxiliar
			  into _cod_aux
			  from endasiau
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso
			   and cuenta    = _cuenta

				select count(*)
				  into _cantidad
				  from cglauxiliar
				 where aux_cuenta  = _cuenta
				   and aux_tercero = _cod_aux;

				if _cantidad = 0 then
					
					insert into cglauxiliar(
					aux_cuenta,
					aux_tercero,
					aux_pctreten,
					aux_saldoret,
					aux_corriente,
					aux_30dias,
					aux_60dias,
					aux_90dias,
					aux_120dias,
					aux_150dias,
					aux_ultimatrx,
					aux_ultimodcmto,
					aux_observacion
					)
					values(
					_cuenta,
					_cod_aux,
					0.00,
					0.00,
					0.00,
					0.00,
					0.00,
					0.00,
					0.00,
					0.00,
					"",
					"",
					""
					);

					insert into tmp_cta
					values (trim(_cuenta) || "-" || trim(_cod_aux), 3);

				end if

			end foreach

		end if

	end foreach

elif a_tipo = 2 then -- Reclamos

	foreach
	 select a.cuenta
	   into _cuenta
	   from rectrmae e, recasien a
	  where e.no_tranrec   = a.no_tranrec
		and e.sac_asientos = 1
	  group by a.cuenta

		select count(*)
		  into _cantidad
		  from cglcuentas
		 where cta_cuenta = _cuenta;

		if _cantidad = 0 then

			foreach
			 select a.no_tranrec
			   into _no_tranrec
			   from rectrmae e, recasien a
			  where e.no_tranrec   = a.no_tranrec
				and e.sac_asientos = 1
				and a.cuenta       = _cuenta

				insert into tmp_cta
				values (trim(_cuenta) || "-" || _no_tranrec , 1);

			end foreach

		end if

	end foreach

	foreach
	 select a.no_tranrec,
	        a.cuenta,
	        a.tipo_comp
	   into _no_tranrec,
	        _cuenta,
			_tipo_comp
	   from rectrmae e, recasien a, cglcuentas c
	  where e.no_tranrec   = a.no_tranrec
		and a.cuenta       = c.cta_cuenta
		and c.cta_auxiliar = "S"
		and e.sac_asientos = 1

		select count(*)
		  into _cantidad
		  from recasiau
		 where no_tranrec = _no_tranrec
		   and cuenta     = _cuenta
		   and tipo_comp  = _tipo_comp;

		if _cantidad = 0 then

			insert into tmp_cta
			values (_cuenta, 2);

		end if

	end foreach

elif a_tipo = 3 then -- Cobros

	foreach
	 select a.cuenta
	   into _cuenta
	   from cobredet e, cobasien a
	  where e.no_remesa    = a.no_remesa
	    and e.renglon      = a.renglon
		--and e.no_remesa    = '1374044'
		and e.sac_asientos = 1
	  group by a.cuenta

		select count(*)
		  into _cantidad
		  from cglcuentas
		 where cta_cuenta = _cuenta;

		if _cantidad = 0 then

			insert into tmp_cta
			values (_cuenta, 1);

		end if

	end foreach

	foreach
	 select no_remesa,
	        renglon
	   into _no_remesa,
	        _renglon
	   from cobredet
	  where sac_asientos = 1

		foreach
		 select cuenta,
		        cod_auxiliar
		   into _cuenta,
	            _cod_aux
		   from cobasiau
		  where no_remesa    = _no_remesa
		    and renglon      = _renglon

			select count(*)
			  into _cantidad
			  from cglterceros
			 where ter_codigo = _cod_aux;

			if _cantidad = 0 then

				insert into tmp_cta
				values (trim(_cuenta) || "-" || trim(_no_remesa) || " (" || _renglon || ")" || " " || _cod_aux, 2);

			else

				select count(*)
				  into _cantidad
				  from cglauxiliar
				 where aux_cuenta  = _cuenta
				   and aux_tercero = _cod_aux;

				if _cantidad = 0 then

					insert into cglauxiliar(
					aux_cuenta,
					aux_tercero,
					aux_pctreten,
					aux_saldoret,
					aux_corriente,
					aux_30dias,
					aux_60dias,
					aux_90dias,
					aux_120dias,
					aux_150dias,
					aux_ultimatrx,
					aux_ultimodcmto,
					aux_observacion
					)
					values(
					_cuenta,
					_cod_aux,
					0.00,
					0.00,
					0.00,
					0.00,
					0.00,
					0.00,
					0.00,
					0.00,
					"",
					"",
					""
					);

				end if

			end if

		end foreach

	end foreach

	foreach
	 select e.no_remesa,
	        e.renglon,
			a.cuenta
	   into _no_remesa,
	        _renglon,
	        _cuenta
	   from cobredet e, cobasien a, cglcuentas c
	  where e.no_remesa    = a.no_remesa
	    and e.renglon      = a.renglon
		and a.cuenta       = c.cta_cuenta
		and c.cta_auxiliar = "S"
		and e.sac_asientos = 1

		select count(*)
		  into _cantidad
		  from cobasiau
		 where no_remesa = _no_remesa
	       and renglon   = _renglon
		   and cuenta    = _cuenta;

		if _cantidad = 0 then

			insert into tmp_cta
			values (trim(_cuenta) || "-" || _no_remesa || " (" || _renglon || ")", 3);

		end if

	end foreach

elif a_tipo = 4 then -- Cheques

	-- Eliminacion de Cuentas con valores en 0.00

	delete from chqchcta
	 where cuenta  is null
	   and debito  = 0.00
	   and credito = 0.00;

	-- Verificacion de que exitan las cuentas

	foreach
	 select a.cuenta
	   into _cuenta
	   from chqchmae e, chqchcta a
	  where e.no_requis    = a.no_requis
	    and e.pagado       = 1
		and e.sac_asientos = 0
	  group by a.cuenta

		select count(*)
		  into _cantidad
		  from cglcuentas
		 where cta_cuenta = _cuenta;

		if _cantidad = 0 then

			insert into tmp_cta
			values (_cuenta, 1);

		end if

	end foreach

	-- Verificacion de que existan los auxiliares por programa

	foreach
		select x.cod_auxiliar,
			   e.no_requis
		  into _cuenta,
			   _no_requis
		  from chqchmae e, chqchcta a, chqctaux x
		 where e.no_requis    = a.no_requis
		   and e.pagado       = 1
		   and e.sac_asientos = 0
		   and x.cuenta       = a.cuenta
		   and x.no_requis    = a.no_requis
		   and x.cod_auxiliar is not null
		 group by e.no_requis, x.cod_auxiliar

		select count(*)
		  into _cantidad
		  from cglterceros
		 where ter_codigo = _cuenta;

		if _cuenta is null then
			let _cuenta = "";
		end if

		if _cantidad = 0 then
			insert into tmp_cta
			values (trim(_cuenta) || " - " || _no_requis, 2);
		end if
	end foreach

	foreach
	 select x.cuenta,
	        x.cod_auxiliar
	   into _cuenta,
	        _cod_aux
	   from chqchmae e, chqchcta a, chqctaux x
	  where e.no_requis    = a.no_requis
	    and e.pagado       = 1
		and e.sac_asientos = 0
		and x.cuenta       = a.cuenta
		and x.no_requis    = a.no_requis
		and x.cod_auxiliar is not null
	  group by x.cuenta, x.cod_auxiliar

		select count(*)
		  into _cantidad
		  from cglauxiliar
		 where aux_cuenta  = _cuenta
		   and aux_tercero = _cod_aux;

		if _cantidad = 0 then
			
			let _cuenta = trim(_cuenta) || "-" || trim(_cod_aux);

			insert into tmp_cta
			values (_cuenta, 3);

			--{
			call sp_sac136(_cuenta, _cod_aux) returning _error_cod, _error_desc;

			if _error_cod <> 0 then

				return 3,
				       _error_desc,
					   _error_cod
					   with resume;

			end if
			--}

		end if

	end foreach

	-- Verificacion de que exitan los auxiliares por usuario

	foreach
	 select a.cod_auxiliar
	   into _cuenta
	   from chqchmae e, chqchcta a
	  where e.no_requis    = a.no_requis
	    and e.pagado       = 1
		and e.sac_asientos = 0
		and a.cod_auxiliar is not null
	  group by a.cod_auxiliar

		select count(*)
		  into _cantidad
		  from cglterceros
		 where ter_codigo = _cuenta;

		if _cantidad = 0 then

			insert into tmp_cta
			values (_cuenta, 4);

		end if

	end foreach

	foreach
	 select a.cuenta,
	        a.cod_auxiliar
	   into _cuenta,
	        _cod_aux
	   from chqchmae e, chqchcta a
	  where e.no_requis    = a.no_requis
	    and e.pagado       = 1
		and e.sac_asientos = 0
		and a.cod_auxiliar is not null
	  group by a.cuenta, a.cod_auxiliar

		select count(*)
		  into _cantidad
		  from cglauxiliar
		 where aux_cuenta  = _cuenta
		   and aux_tercero = _cod_aux;

		if _cantidad = 0 then
			
			let _cuenta = trim(_cuenta) || "-" || trim(_cod_aux);

			insert into tmp_cta
			values (_cuenta, 5);

		end if

	end foreach

	-- Verificacion de que cuadren Mayor Vs Auxiliar

	foreach
	 select a.no_requis,
	        a.renglon,
			a.cuenta,
	        sum(a.debito - a.credito)
	   into _no_requis,
	        _renglon,
			_cuenta,
	        _monto_may
	   from chqchmae e, chqchcta a
	  where e.no_requis    = a.no_requis
	    and e.pagado       = 1
		and e.sac_asientos = 0
	  group by a.no_requis, a.renglon, a.cuenta

		select cta_auxiliar
		  into _auxiliar
		  from cglcuentas
		 where cta_cuenta = _cuenta;

		if _auxiliar = "S" then

			select sum(debito - credito)
			  into _monto_aux
			  from chqctaux
			 where no_requis = _no_requis
			   and renglon   = _renglon;

			if _monto_aux is null then
				let _monto_aux = 0.00;
			end if

			if _monto_may <> _monto_aux then

				insert into tmp_cta
				values (_no_requis || " - " || _renglon, 6);

			end if

		end if

	end foreach

elif a_tipo = 6 then -- Planilla

end if

select count(*)
  into _cantidad
  from tmp_cta;

if _cantidad = 0 then

	return 0,
	       "Todas las Cuentas estan Correctas",
		   ""
		   with resume;
else

	select count(*)
	  into _cantidad
	  from tmp_cta
	 where tipo_error = 1;

	if _cantidad <> 0 then

		foreach
		 select cuenta
		   into _cuenta
		   from tmp_cta
		  where tipo_error = 1
		  group by cuenta
		  order by cuenta

			return 1,
			       "No Existe Cuenta en el Mayor",
				   _cuenta
				   with resume;

		end foreach

	end if

	select count(*)
	  into _cantidad
	  from tmp_cta
	 where tipo_error = 2;

	if _cantidad <> 0 then

		foreach
		 select cuenta
		   into _cuenta
		   from tmp_cta
		  where tipo_error = 2
		  group by cuenta
		  order by cuenta

			return 2,
			       "No Existe Auxiliar para la Cuenta",
				   _cuenta
				   with resume;

		end foreach

	end if

	select count(*)
	  into _cantidad
	  from tmp_cta
	 where tipo_error = 3;

	if _cantidad <> 0 then

		foreach
		 select cuenta
		   into _cuenta
		   from tmp_cta
		  where tipo_error = 3
		  group by cuenta
		  order by cuenta

			return 3,
			       "No Existe Auxiliar para la Cuenta",
				   _cuenta
				   with resume;

		end foreach

	end if

	select count(*)
	  into _cantidad
	  from tmp_cta
	 where tipo_error = 4;

	if _cantidad <> 0 then

		foreach
		 select cuenta
		   into _cuenta
		   from tmp_cta
		  where tipo_error = 4
		  group by cuenta
		  order by cuenta

			return 4,
			       "No Existe Auxiliar para la Cuenta",
				   _cuenta
				   with resume;

		end foreach

	end if

	select count(*)
	  into _cantidad
	  from tmp_cta
	 where tipo_error = 5;

	if _cantidad <> 0 then

		foreach
		 select cuenta
		   into _cuenta
		   from tmp_cta
		  where tipo_error = 5
		  group by cuenta
		  order by cuenta

			return 5,
			       "No Existe Auxiliar para la Cuenta",
				   _cuenta
				   with resume;

		end foreach

	end if

	select count(*)
	  into _cantidad
	  from tmp_cta
	 where tipo_error = 6;

	if _cantidad <> 0 then

		foreach
		 select cuenta
		   into _cuenta
		   from tmp_cta
		  where tipo_error = 6
		  group by cuenta
		  order by cuenta

			return 6,
			       "No Cuadra Mayor Vs Auxiliar para la Requisicion",
				   _cuenta
				   with resume;

		end foreach

	end if

end if

end

--drop table tmp_cta;

end procedure
