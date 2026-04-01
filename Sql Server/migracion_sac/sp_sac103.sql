-- Procedure que crea los saldos iniciales del año

-- Creado    : 13/09/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac103;

create procedure sp_sac103(a_ano_calc smallint)
returning smallint,
		  char(50);

define _tipo			char(2);
define _cuenta			char(25);
define _ccosto			char(3);
define _ano				char(4);
define _mes				smallint;
define _tercero			char(5);
define _i				smallint;

define _ano_ant			smallint ;

define _saldo_act		dec(16,2);
define _cantidad		smallint;

define _error			integer;
define _error_desc		char(50);

let _ano_ant  = a_ano_calc - 1;

--{
foreach
 select	sldet_tipo,
		sldet_cuenta,
		sldet_ccosto,
		sldet_ano,
		sldet_periodo,
        sldet_saldop
   into _tipo,
		_cuenta,
		_ccosto,
		_ano,
		_mes,
        _saldo_act
   from cglsaldodet
 where sldet_ano     = _ano_ant
   and sldet_periodo = 12

	if _cuenta[1,1] >= "4" then
		let _saldo_act = 0.00;
	end if		 

	select count(*)
	  into _cantidad
	  from cglsaldoctrl
	 where sld_tipo   =	_tipo
	   and sld_cuenta =	_cuenta
	   and sld_ccosto = _ccosto
	   and sld_ano	  =	a_ano_calc;

	if _cantidad = 0 then

		insert into cglsaldoctrl
		values (_tipo, _cuenta, _ccosto, a_ano_calc, _saldo_act);

	else

		update cglsaldoctrl
		   set sld_incioano = _saldo_act
		 where sld_tipo     = _tipo
		   and sld_cuenta   = _cuenta
		   and sld_ccosto   = _ccosto
		   and sld_ano	    = a_ano_calc;
		
	end if

	select count(*)
	  into _cantidad
	  from cglsaldodet
	 where sldet_tipo    =	_tipo
	   and sldet_cuenta  =	_cuenta
	   and sldet_ccosto  = _ccosto
	   and sldet_ano	 = a_ano_calc
	   and sldet_periodo = 1;

	if _cantidad = 0 then

		for _i = 1 to 14

			insert into cglsaldodet
			values (_tipo, _cuenta, _ccosto, a_ano_calc, _i, 0.00, 0.00, 0.00);

		end for

	end if

end foreach
--}

foreach
 select	sld1_tipo,
        sld1_cuenta,
		sld1_tercero,
		sld1_ano,
		sld1_periodo,
		sld1_saldo
   into _tipo,
		_cuenta,
		_tercero,
		_ano,
		_mes,
        _saldo_act
   from	cglsaldoaux1
  where sld1_ano     = _ano_ant
    and sld1_periodo = 12

	if _cuenta[1,1] >= "4" then
		let _saldo_act = 0.00;
	end if		 

	select count(*)
	  into _cantidad
	  from cglsaldoaux
	 where sld_tipo    = _tipo
	   and sld_cuenta  = _cuenta
	   and sld_tercero = _tercero
	   and sld_ano	    = a_ano_calc;

	if _cantidad = 0 then

		insert into cglsaldoaux
		values (_tipo, _cuenta, _tercero, a_ano_calc, _saldo_act);

	else

		update cglsaldoaux
		   set sld_incioano = _saldo_act
		 where sld_tipo     = _tipo
		   and sld_cuenta   = _cuenta
		   and sld_tercero  = _tercero
		   and sld_ano	    = a_ano_calc;
		
	end if

	select count(*)
	  into _cantidad
	  from cglsaldoaux1
	 where sld1_tipo    = _tipo
	   and sld1_cuenta  = _cuenta
	   and sld1_tercero = _tercero
	   and sld1_ano	    = a_ano_calc
	   and sld1_periodo = 1;

	if _cantidad = 0 then

		for _i = 1 to 14

			insert into cglsaldoaux1
			values (_tipo, _cuenta, _tercero, a_ano_calc, _i, 0.00, 0.00, 0.00);

		end for

	end if

end foreach

return 0, "Actualizacion Exitosa";

end procedure