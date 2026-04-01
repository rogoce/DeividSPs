-- Procedimiento que verifica que cuadre el detalle y el saldo de los auxiliares

-- Creado    : 09/09/2008 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac142;

create procedure sp_sac142()
returning char(2),
          char(25),
		  smallint,
		  smallint,
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(3);

define _tipo_resumen	char(2);
define _cuenta			char(25);
define _ano				smallint;
define _ano2			smallint;
define _mes				smallint;
define _ccosto			char(3);

define _ano_fiscal		smallint;
define _mes_fiscal		smallint;

define _saldo_inicio	dec(16,2);
define _saldo_final		dec(16,2);
define _saldo_calc		dec(16,2);
define _saldo_aux		dec(16,2);

define _debito			dec(16,2);
define _credito			dec(16,2);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc

	return "",
		   "",
		   0,
		   0,
		   0,
		   0,
		   0,
		   0,
		   "";	

end exception

select par_mesfiscal,
       par_anofiscal
  into _mes_fiscal,
       _ano_fiscal
  from cglparam;


-- Verifica el movimiento de cada mes

--{
foreach 
 select sld_tipo,
        sld_cuenta,
		sld_ccosto,
		sld_ano,
		sld_incioano
   into	_tipo_resumen,
		_cuenta,
		_ccosto,
		_ano,
		_saldo_inicio
   from cglsaldoctrl
--  where sld_cuenta = "26410"
  order by 1, 2, 3, 4

	let _saldo_calc = _saldo_inicio;

	foreach
	 select	sldet_debtop,
	        sldet_cretop,
			sldet_saldop,
			sldet_periodo
	   into	_debito,
	        _credito,
			_saldo_aux,
			_mes
	   from cglsaldodet
	  where sldet_tipo	 = _tipo_resumen
	    and sldet_cuenta = _cuenta
		and sldet_ccosto = _ccosto
		and sldet_ano	 = _ano
	  order by sldet_periodo

		let _saldo_calc = _saldo_calc + _debito + _credito;
		

		if _ano > _ano_fiscal then
			exit foreach;
		end if

		if _ano = _ano_fiscal and _mes > _mes_fiscal then 
			exit foreach;
		end if

		if _saldo_calc <> _saldo_aux then

--			 update cglsaldoaux1
--			    set sld1_saldo   = _saldo_calc
--			  where sld1_tipo	 = _tipo_resumen
--			    and sld1_cuenta	 = _cuenta
--				and sld1_tercero = _cod_auxiliar
--				and sld1_ano	 = _ano
--				and sld1_periodo = _mes;

			return _tipo_resumen,
				   _cuenta,
				   _ano,
				   _mes,
				   _debito,
				   _credito,
				   _saldo_aux,
				   _saldo_calc,
				   _ccosto
				   with resume;	

		end if

	end foreach

end foreach
--}

-- Verifica los acumulados al inico del ano
{
foreach 
 select sld_tipo,
        sld_cuenta,
		sld_ano,
		sld_incioano
   into	_tipo_resumen,
		_cuenta,
		_ano,
		_saldo_inicio
   from cglsaldoctrl
  order by 1, 2, 3, 4

	 select	sum(sldet_debtop + sldet_cretop)
	   into	_saldo_aux
	   from cglsaldodet
	  where sldet_tipo	 = _tipo_resumen
	    and sldet_cuenta = _cuenta
		and sldet_ano	 = _ano;

	let _saldo_calc = _saldo_inicio + _saldo_aux;
	let _ano2       = _ano + 1;

	 select sld_incioano
	   into	_saldo_final
	   from cglsaldoctrl
	  where sld_tipo	= _tipo_resumen
		and	sld_cuenta	= _cuenta
		and sld_ano		= _ano2;

	if _saldo_final is null then
		continue foreach;
	end if

	if _saldo_calc <> _saldo_final then

--		 update cglsaldoaux
--		    set sld_incioano = _saldo_calc
--		  where sld_tipo	 = _tipo_resumen
--			and	sld_cuenta	 = _cuenta
--		    and sld_tercero  = _cod_auxiliar
--			and sld_ano		 = _ano2;


		return _tipo_resumen,
			   _cuenta,
			   _ano,
			   0,
			   _saldo_inicio,
			   _saldo_aux,
			   _saldo_calc,
			   _saldo_final,
			   ""
			   with resume;	

	end if

end foreach
--}

end

return "",
	   "",
	   0,
	   0,
	   0,
	   0,
	   0,
	   0,
	   "";	

end procedure
