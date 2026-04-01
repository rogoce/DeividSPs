-- Reporte de Registros Contables de Produccion
-- 
-- Creado    : 29/10/2002 - Autor: Marquelda Valdelamar
-- Modificado: 29/10/2002 - Autor: Marquelda Valdelamar.
-- Modificado: 26/04/2007 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - d_cobr_sp_cob61_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_sac73;

CREATE PROCEDURE "informix".sp_sac73() 
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
	and e.fecha_impresion >= "01/07/2007"
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

drop table tmp_cta;

end procedure
