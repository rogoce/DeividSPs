-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_bo016;

create procedure "informix".sp_bo016()
returning integer,
          char(50);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

define _ano			char(4);
define _periodo		smallint;
define _enlace 		char(10);
define _ccosto		char(3);
define _cia_comp	char(3);
define _monto		dec(16,2);

set isolation to dirty read;

--SET DEBUG FILE TO "sp_bo016.trc";  
--TRACE ON;                                                                 

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

-- Peso de la Cartera
-- Se basa en el monto de la prima suscrita del periodo para ponderar los gastos


-- Aseguradora Ancon

let _cia_comp = sp_bo050("sac");

-- Acumulado

delete from ef_sumas;

insert into ef_sumas
select ano, periodo, '99999999', "001", sum(ingprisegdir + ingprireaasu), 0.00, cia_comp
  from ef_estfin
 where tipo_calculo = "A"
   and cia_comp     = _cia_comp
 group by ano, periodo, cia_comp;

foreach
 select ano,
		periodo,
		ccosto,
        monto,
		cia_comp
   into _ano,
		_periodo,
		_ccosto,
        _monto,
		_cia_comp
   from	ef_sumas

	update ef_estfin
	   set ingtotprisus = _monto
     where ano          = _ano
       and periodo      = _periodo
	   and enlace       matches "*"
       and ccosto       matches "*"
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

end foreach

-- Mensual

delete from ef_sumas;

insert into ef_sumas
select ano, periodo, '99999999', "001", sum(ingprisegdir + ingprireaasu), 0.00, cia_comp
  from ef_estfin
 where tipo_calculo = "M"
   and cia_comp     = _cia_comp
 group by ano, periodo, cia_comp;

foreach
 select ano,
		periodo,
		ccosto,
        monto,
		cia_comp
   into _ano,
		_periodo,
		_ccosto,
        _monto,
		_cia_comp
   from	ef_sumas

	update ef_estfin
	   set ingtotprisus = _monto
     where ano          = _ano
       and periodo      = _periodo
	   and enlace       matches "*"
       and ccosto       matches "*"
       and tipo_calculo = "M"
	   and cia_comp	    = _cia_comp;

end foreach

update ef_estfin
   set porcpescar   = (ingprisegdir + ingprireaasu) / ingtotprisus * 100
 where cia_comp	    = _cia_comp
   and ingtotprisus <> 0.00;

-- Verificacion del 100%

-- Acumulado

delete from ef_sumas;

insert into ef_sumas
select ano, periodo, '99999999', "001", sum(porcpescar), 0.00, cia_comp
  from ef_estfin
 where tipo_calculo = "A"
   and cia_comp     = _cia_comp
 group by ano, periodo, cia_comp;

update ef_sumas
   set monto = monto - 100
 where monto <> 0.00;

foreach
 select ano,
		periodo,
		ccosto,
        monto,
		cia_comp
   into _ano,
		_periodo,
		_ccosto,
        _monto,
		_cia_comp
   from	ef_sumas

	update ef_estfin
	   set porcpescar   = porcpescar - _monto
     where ano          = _ano
       and periodo      = _periodo
	   and enlace       = "020103"
       and ccosto       = _ccosto
       and tipo_calculo = "A"
       and cia_comp     = _cia_comp;

end foreach

-- Mensual

delete from ef_sumas;

insert into ef_sumas
select ano, periodo, '99999999', "001", sum(porcpescar), 0.00, cia_comp
  from ef_estfin
 where tipo_calculo = "M"
   and cia_comp     = _cia_comp
 group by ano, periodo, cia_comp;

update ef_sumas
   set monto = monto - 100
 where monto <> 0.00;

foreach
 select ano,
		periodo,
		ccosto,
        monto,
		cia_comp
   into _ano,
		_periodo,
		_ccosto,
        _monto,
		_cia_comp
   from	ef_sumas

	update ef_estfin
	   set porcpescar   = porcpescar - _monto
     where ano          = _ano
       and periodo      = _periodo
	   and enlace       = "020103"
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach



-- Allied Insurance and Reinsurance

let _cia_comp = sp_bo050("sac001");

-- Acumulado

delete from ef_sumas;

insert into ef_sumas
select ano, periodo, '99999999', "001", sum(ingprisegdir + ingprireaasu), 0.00, cia_comp
  from ef_estfin
 where tipo_calculo = "A"
   and cia_comp     = _cia_comp
 group by ano, periodo, cia_comp;

foreach
 select ano,
		periodo,
		ccosto,
        monto,
		cia_comp
   into _ano,
		_periodo,
		_ccosto,
        _monto,
		_cia_comp
   from	ef_sumas

	update ef_estfin
	   set ingtotprisus = _monto
     where ano          = _ano
       and periodo      = _periodo
	   and enlace       matches "*"
       and ccosto       matches "*"
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

end foreach

-- Mensual

delete from ef_sumas;

insert into ef_sumas
select ano, periodo, '99999999', "001", sum(ingprisegdir + ingprireaasu), 0.00, cia_comp
  from ef_estfin
 where tipo_calculo = "M"
   and cia_comp     = _cia_comp
 group by ano, periodo, cia_comp;

foreach
 select ano,
		periodo,
		ccosto,
        monto,
		cia_comp
   into _ano,
		_periodo,
		_ccosto,
        _monto,
		_cia_comp
   from	ef_sumas

	update ef_estfin
	   set ingtotprisus = _monto
     where ano          = _ano
       and periodo      = _periodo
	   and enlace       matches "*"
       and ccosto       matches "*"
       and tipo_calculo = "M"
	   and cia_comp	    = _cia_comp;

end foreach

update ef_estfin
   set porcpescar   = (ingprisegdir + ingprireaasu) / ingtotprisus * 100
 where cia_comp	    = _cia_comp
   and ingtotprisus <> 0.00;

-- Verificacion del 100%

-- Acumulado

delete from ef_sumas;

insert into ef_sumas
select ano, periodo, '99999999', "001", sum(porcpescar), 0.00, cia_comp
  from ef_estfin
 where tipo_calculo = "A"
   and cia_comp     = _cia_comp
 group by ano, periodo, cia_comp;

update ef_sumas
   set monto = monto - 100
 where monto <> 0.00;

foreach
 select ano,
		periodo,
		ccosto,
        monto,
		cia_comp
   into _ano,
		_periodo,
		_ccosto,
        _monto,
		_cia_comp
   from	ef_sumas

	update ef_estfin
	   set porcpescar   = porcpescar - _monto
     where ano          = _ano
       and periodo      = _periodo
	   and enlace       = "020103"
       and ccosto       = _ccosto
       and tipo_calculo = "A"
       and cia_comp     = _cia_comp;

end foreach

-- Mensual

delete from ef_sumas;

insert into ef_sumas
select ano, periodo, '99999999', "001", sum(porcpescar), 0.00, cia_comp
  from ef_estfin
 where tipo_calculo = "M"
   and cia_comp     = _cia_comp
 group by ano, periodo, cia_comp;

update ef_sumas
   set monto = monto - 100
 where monto <> 0.00;

foreach
 select ano,
		periodo,
		ccosto,
        monto,
		cia_comp
   into _ano,
		_periodo,
		_ccosto,
        _monto,
		_cia_comp
   from	ef_sumas

	update ef_estfin
	   set porcpescar   = porcpescar - _monto
     where ano          = _ano
       and periodo      = _periodo
	   and enlace       = "020103"
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

end

return 0, "Actualizacion Exitosa";

end procedure