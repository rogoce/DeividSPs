-- Procedimiento que verifica que cuadre el detalle y el saldo de los auxiliares

-- Creado    : 09/09/2008 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac86;

create procedure sp_sac86()
returning char(2),
          char(25),
		  char(5),
		  smallint,
		  smallint,
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _tipo_resumen	char(2);
define _cuenta			char(25);
define _cod_auxiliar	char(5);
define _ano				smallint;
define _mes				smallint;
define _debito_det		dec(16,2);
define _credito_det		dec(16,2);
define _debito_sal		dec(16,2);
define _credito_sal		dec(16,2);
define _cantidad		smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

begin 
on exception set _error, _error_isam, _error_desc

	return "",
		   "",
		   "",
		   0,
		   0,
		   0,
		   0,
		   0,
		   0;	

end exception

set isolation to dirty read;

foreach 
 select res1_tipo_resumen,
        res1_cuenta,
		res1_auxiliar,
		year(res_fechatrx),
		month(res_fechatrx),
		sum(res1_debito),
		sum(res1_credito * -1)
   into	_tipo_resumen,
		_cuenta,
		_cod_auxiliar,
		_ano,
		_mes,
		_debito_det,
		_credito_det
   from cglresumen e, cglresumen1 d
  where e.res_noregistro = d.res1_noregistro
    and res_tipcomp      not in ("020", "021")
--    and d.res1_auxiliar  = "0024"
--    and d.res1_cuenta    = "2310198"
  group by 1, 2, 3, 4, 5
  order by 1, 2, 3, 4, 5

	select sld1_debitos,
	       sld1_creditos
	  into _debito_sal,
		   _credito_sal
	  from cglsaldoaux1
	 where sld1_tipo    = _tipo_resumen
	   and sld1_cuenta  = _cuenta
	   and sld1_tercero = _cod_auxiliar
	   and sld1_ano     = _ano
	   and sld1_periodo = _mes;

	if _debito_sal is null then
		let _debito_sal = 0.00;
	end if
	
		
	if _credito_sal is null then
		let _credito_sal = 0.00;
	end if
		
	if _debito_det  <> _debito_sal  or 
	   _credito_det	<> _credito_sal	then

{
		select count(*)
		  into _cantidad
	      from cglsaldoaux1
		 where sld1_tipo     = _tipo_resumen
		   and sld1_cuenta   = _cuenta
		   and sld1_tercero  = _cod_auxiliar
		   and sld1_ano      = _ano
		   and sld1_periodo  = _mes;

		if _cantidad = 0 then

			call sp_sac88(_tipo_resumen, _cuenta, _cod_auxiliar, _ano) returning _error, _error_desc;

		end if

	    update cglsaldoaux1
		   set sld1_debitos	 = _debito_det,
		       sld1_creditos = _credito_det
		 where sld1_tipo     = _tipo_resumen
		   and sld1_cuenta   = _cuenta
		   and sld1_tercero  = _cod_auxiliar
		   and sld1_ano      = _ano
		   and sld1_periodo  = _mes;
--}

		return _tipo_resumen,
			   _cuenta,
			   _cod_auxiliar,
			   _ano,
			   _mes,
			   _debito_det,
			   _credito_det,
			   _debito_sal,
			   _credito_sal
			   with resume;	

	end if

end foreach

foreach
 select sld1_debitos,
        sld1_creditos,
		sld1_tipo,
	    sld1_cuenta,
		sld1_tercero,
		sld1_ano,
		sld1_periodo
   into _debito_sal,
   	    _credito_sal,
	    _tipo_resumen,
		_cuenta,
		_cod_auxiliar,
		_ano,
		_mes
   from cglsaldoaux1

	if _mes = 14 then

		select sum(res1_debito),
		       sum(res1_credito * -1)
		  into _debito_det,
		       _credito_det
		  from cglresumen e, cglresumen1 d
		 where res1_tipo_resumen   = _tipo_resumen
		   and res1_cuenta         = _cuenta
		   and res1_auxiliar       = _cod_auxiliar
		   and year(res_fechatrx)  = _ano
		   and month(res_fechatrx) = 12
		   and e.res_noregistro    = d.res1_noregistro
		   and res_tipcomp         = "021";

	elif _mes = 13 then

		select sum(res1_debito),
		       sum(res1_credito * -1)
		  into _debito_det,
		       _credito_det
		  from cglresumen e, cglresumen1 d
		 where res1_tipo_resumen   = _tipo_resumen
		   and res1_cuenta         = _cuenta
		   and res1_auxiliar       = _cod_auxiliar
		   and year(res_fechatrx)  = _ano
		   and month(res_fechatrx) = 12
		   and e.res_noregistro    = d.res1_noregistro
		   and res_tipcomp         = "020";

	else

		select sum(res1_debito),
		       sum(res1_credito * -1)
		  into _debito_det,
		       _credito_det
		  from cglresumen e, cglresumen1 d
		 where res1_tipo_resumen   = _tipo_resumen
		   and res1_cuenta         = _cuenta
		   and res1_auxiliar       = _cod_auxiliar
		   and year(res_fechatrx)  = _ano
		   and month(res_fechatrx) = _mes
		   and e.res_noregistro    = d.res1_noregistro
		   and res_tipcomp         not in ("020", "021");

	end if

	if _debito_det is null then
		let _debito_det = 0.00;
	end if

		
	if _credito_det is null then
		let _credito_det = 0.00;
	end if

	if _debito_det  <> _debito_sal  or 
	   _credito_det	<> _credito_sal	then

{
	    update cglsaldoaux1
		   set sld1_debitos	 = _debito_det,
		       sld1_creditos = _credito_det
		 where sld1_tipo     = _tipo_resumen
		   and sld1_cuenta   = _cuenta
		   and sld1_tercero  = _cod_auxiliar
		   and sld1_ano      = _ano
		   and sld1_periodo  = _mes;
--}

		return _tipo_resumen,
			   _cuenta,
			   _cod_auxiliar,
			   _ano,
			   _mes,
			   _debito_det,
			   _credito_det,
			   _debito_sal,
			   _credito_sal
			   with resume;	

	end if

end foreach

end

return "",
	   "",
	   "",
	   0,
	   0,
	   0,
	   0,
	   0,
	   0;	

end procedure



