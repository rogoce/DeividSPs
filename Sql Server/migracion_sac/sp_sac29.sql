-- Reporte de Registros Contables de Produccion
-- 
-- Creado    : 29/10/2002 - Autor: Marquelda Valdelamar
-- Modificado: 29/10/2002 - Autor: Marquelda Valdelamar.
--
-- SIS v.2.0 - d_cobr_sp_cob61_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_sac29;

CREATE PROCEDURE "informix".sp_sac29(
a_periodo	CHAR(7),
a_tipo		smallint
) returning smallint,
            char(50),
		    char(25);

define _error_cod	integer;
define _error_isam	integer;
define _error_desc	char(100);

define _cuenta		char(25);
define _cod_aux		char(5);
define _cantidad	integer;
define _no_requis	char(10);

begin 
on exception set _error_cod, _error_isam, _error_desc
	drop table tmp_cta;
	return _error_cod, _error_desc, "";
end exception

create temp table tmp_cta(
cuenta	char(25)
) with no log;

set isolation to dirty read;

if a_tipo = 1 then -- Produccion

	foreach
	 select a.cuenta
	   into _cuenta
	   from endedmae e, endasien a
	  where e.no_poliza = a.no_poliza
	    and e.no_endoso = a.no_endoso
		and e.periodo   = a_periodo
	  group by a.cuenta

		select count(*)
		  into _cantidad
		  from cglcuentas
		 where cta_cuenta = _cuenta;

		if _cantidad = 0 then

			insert into tmp_cta
			values (_cuenta);

		end if

	end foreach

elif a_tipo = 2 then -- Reclamos

	foreach
	 select a.cuenta
	   into _cuenta
	   from rectrmae e, recasien a
	  where e.no_tranrec = a.no_tranrec
		and e.periodo    = a_periodo
	  group by a.cuenta

		select count(*)
		  into _cantidad
		  from cglcuentas
		 where cta_cuenta = _cuenta;

		if _cantidad = 0 then

			insert into tmp_cta
			values (_cuenta);


		end if

	end foreach

elif a_tipo = 3 then -- Cobros

	foreach
	 select a.cuenta
	   into _cuenta
	   from cobredet e, cobasien a
	  where e.no_remesa = a.no_remesa
	    and e.renglon   = a.renglon
		and e.periodo   = a_periodo
	  group by a.cuenta

		select count(*)
		  into _cantidad
		  from cglcuentas
		 where cta_cuenta = _cuenta;

		if _cantidad = 0 then

			insert into tmp_cta
			values (_cuenta);

		end if

	end foreach

	foreach
	 select a.cod_auxiliar
	   into _cuenta
	   from cobredet e, cobasiau a
	  where e.no_remesa = a.no_remesa
	    and e.renglon   = a.renglon
		and e.periodo   = a_periodo
	  group by a.cod_auxiliar

		select count(*)
		  into _cantidad
		  from cglterceros
		 where ter_codigo = _cuenta;

		if _cantidad = 0 then

			insert into tmp_cta
			values (_cuenta);

		end if

	end foreach

	foreach
	 select a.cuenta,
	 		a.cod_auxiliar
	   into _cuenta,
	        _cod_aux
	   from cobredet e, cobasiau a
	  where e.no_remesa = a.no_remesa
	    and e.renglon   = a.renglon
		and e.periodo   = a_periodo
	  group by a.cuenta, a.cod_auxiliar

		select count(*)
		  into _cantidad
		  from cglauxiliar
		 where aux_cuenta  = _cuenta
		   and aux_tercero = _cod_aux;

		if _cantidad = 0 then

			insert into tmp_cta
			values (_cuenta || "-" || _cod_aux);

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
	 select a.cuenta,
	        a.no_requis
	   into _cuenta,
	        _no_requis
	   from chqchmae e, chqchcta a
	  where e.no_requis = a.no_requis
		and e.periodo   = a_periodo
	  group by a.cuenta, a.no_requis

		select count(*)
		  into _cantidad
		  from cglcuentas
		 where cta_cuenta = _cuenta;

		if _cantidad = 0 then

			insert into tmp_cta
			values (_cuenta || "-" || _no_requis);

		end if

	end foreach

	-- Verificacion de que exitan los auxiliares por programa

	foreach
	 select x.cod_auxiliar,
	        a.no_requis
	   into _cuenta,
	        _no_requis
	   from chqchmae e, chqchcta a, chqctaux x
	  where e.no_requis    = a.no_requis
		and e.periodo      = a_periodo
		and x.cuenta       = a.cuenta
		and x.no_requis    = a.no_requis
		and x.cod_auxiliar is not null
	  group by x.cod_auxiliar, a.no_requis

		select count(*)
		  into _cantidad
		  from cglterceros
		 where ter_codigo = _cuenta;

		if _cantidad = 0 then

			insert into tmp_cta
			values (_cuenta || "-" || _no_requis);

		end if

	end foreach

	foreach
	 select x.cuenta,
	        x.cod_auxiliar,
	        a.no_requis
	   into _cuenta,
	        _cod_aux,
	        _no_requis
	   from chqchmae e, chqchcta a, chqctaux x
	  where e.no_requis    = a.no_requis
		and e.periodo      = a_periodo
		and x.cuenta       = a.cuenta
		and x.no_requis    = a.no_requis
		and x.cod_auxiliar is not null
	  group by x.cuenta, x.cod_auxiliar, a.no_requis

		select count(*)
		  into _cantidad
		  from cglauxiliar
		 where aux_cuenta  = _cuenta
		   and aux_tercero = _cod_aux;

		if _cantidad = 0 then
			
			let _cuenta = trim(_cuenta) || "-" || trim(_cod_aux) || "-" || _no_requis;

			insert into tmp_cta
			values (_cuenta);

		end if

	end foreach

	-- Verificacion de que exitan los auxiliares por usuario

	foreach
	 select a.cod_auxiliar,
	        a.no_requis
	   into _cuenta,
	        _no_requis
	   from chqchmae e, chqchcta a
	  where e.no_requis    = a.no_requis
		and e.periodo      = a_periodo
		and a.cod_auxiliar is not null
	  group by a.cod_auxiliar, a.no_requis

		select count(*)
		  into _cantidad
		  from cglterceros
		 where ter_codigo = _cuenta;

		if _cantidad = 0 then

			insert into tmp_cta
			values (_cuenta || "-" || _no_requis);

		end if

	end foreach

	foreach
	 select a.cuenta,
	        a.cod_auxiliar,
	        a.no_requis
	   into _cuenta,
	        _cod_aux,
	        _no_requis
	   from chqchmae e, chqchcta a
	  where e.no_requis    = a.no_requis
		and e.periodo      = a_periodo
		and a.cod_auxiliar is not null
	  group by a.cuenta, a.cod_auxiliar, a.no_requis

		select count(*)
		  into _cantidad
		  from cglauxiliar
		 where aux_cuenta  = _cuenta
		   and aux_tercero = _cod_aux;

		if _cantidad = 0 then
			
			let _cuenta = trim(_cuenta) || "-" || trim(_cod_aux) || "-" || _no_requis;

			insert into tmp_cta
			values (_cuenta);

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

	foreach
	 select cuenta
	   into _cuenta
	   from tmp_cta
	  group by cuenta
	  order by cuenta

		return 1,
		       "Cuenta No Existe en el Mayor",
			   _cuenta
			   with resume;

	end foreach

end if

end

drop table tmp_cta;

end procedure
