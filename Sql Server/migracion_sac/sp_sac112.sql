-- Procedure que verifica que que saldocrtl mantenga saldos del periodo anterior al cambio de anio
-- Creado    : 13/09/2007 - Autor: Henry Giron	
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sac112;

create procedure sp_sac112()
returning CHAR(2), 
		CHAR(12), 
		CHAR(3), 
		CHAR(4) , 
		dec(16,2),
		dec(16,2);

define _tipo			char(2);
define _cuenta			char(25);
define _ccosto			char(3);
define _ano				char(4);
define _mes				smallint;

define _i				smallint;

define _ano_calc		smallint;
define _ano_ant			smallint ;

define _saldo_act		dec(16,2);
define _saldoctrl		dec(16,2);
define _cantidad		smallint;

define _error			integer;
define _error_desc		char(50);

CREATE TEMP TABLE tmp_saldoctrl (
		sld_tipo 		CHAR(2), 
		sld_cuenta 		CHAR(12), 
		sld_ccosto 		CHAR(3), 
		sld_ano 		CHAR(4), 
		sld_anterior 	dec(16,2),
		sld_incioano 	dec(16,2)
		) WITH NO LOG; 

let _ano_calc = 2009;
let _ano_ant  = _ano_calc - 1;

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
   and sldet_periodo = 14

	if _cuenta[1,1] >= "4" then
		let _saldo_act = 0.00;
	end if		 

	select count(*)
	  into _cantidad
	  from cglsaldoctrl
	 where sld_tipo   =	_tipo
	   and sld_cuenta =	_cuenta
	   and sld_ccosto = _ccosto
	   and sld_ano	  =	_ano_calc;

	if _cantidad = 0 then

		insert into tmp_saldoctrl
		values (_tipo, _cuenta, _ccosto, _ano_calc, _saldo_act,0);

	else

		select sld_incioano
		  into _saldoctrl
		  from cglsaldoctrl
		 where sld_tipo   =	_tipo
		   and sld_cuenta =	_cuenta
		   and sld_ccosto = _ccosto
		   and sld_ano	  =	_ano_calc;

 		if 	 _saldoctrl <> 	_saldo_act then 

			insert into tmp_saldoctrl
			values (_tipo, _cuenta, _ccosto, _ano_calc, _saldo_act,_saldoctrl);

		end if
		
	end if
 
end foreach

FOREACH	
  SELECT sld_tipo, 
		sld_cuenta, 
		sld_ccosto, 
		sld_ano, 
		sld_anterior,
		sld_incioano
	INTO _tipo, 
	    _cuenta, 
	    _ccosto, 
	    _ano_calc, 
	    _saldo_act,
	    _saldoctrl
    FROM tmp_saldoctrl
  RETURN _tipo, 
	    _cuenta, 
	    _ccosto, 
	    _ano_calc, 
	    _saldo_act,
	    _saldoctrl
    	 WITH RESUME;

END FOREACH;


DROP TABLE tmp_saldoctrl;


end procedure