-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_bo017;

create procedure "informix".sp_bo017()
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
define _cia_comp1	char(3);
define _cia_comp2	char(3);
define _monto		dec(16,2);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _cia_comp1 = sp_bo050("sac");	  -- Ancon
let _cia_comp2 = sp_bo050("sac001");  -- Allied

-- Ponderacion de los gastos por Ramo

-- Total de Gastos Administrativos

-- Acumulado

delete from ef_sumas;

insert into ef_sumas
select ano, periodo, '99999999', "001", sum(gasgasadmin), 0.00, cia_comp
  from ef_estfin
 where tipo_calculo = "A"
   and cia_comp     in (_cia_comp1, _cia_comp2)
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
	   set gastotgasadm = _monto
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
select ano, periodo, '99999999', "001", sum(gasgasadmin), 0.00, cia_comp
  from ef_estfin
 where tipo_calculo = "M"
   and cia_comp     in (_cia_comp1, _cia_comp2)
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
	   set gastotgasadm = _monto
     where ano          = _ano
       and periodo      = _periodo
	   and enlace       matches "*"
       and ccosto       matches "*"
       and tipo_calculo = "M"
       and cia_comp     = _cia_comp;

end foreach

update ef_estfin
   set gasgasadmin  = gastotgasadm * porcpescar / 100
 where cia_comp     in (_cia_comp1, _cia_comp2)
   and gastotgasadm <> 0.00;

-- Total de los intereses ganados en inversiones

-- Acumulado

delete from ef_sumas;

insert into ef_sumas
select ano, periodo, '99999999', "001", sum(gasintganinv), 0.00, cia_comp
  from ef_estfin
 where tipo_calculo = "A"
   and cia_comp     in (_cia_comp1, _cia_comp2)
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
	   set gastotintganinv = _monto
     where ano             = _ano
       and periodo         = _periodo
	   and enlace          matches "*"
       and ccosto          matches "*"
       and tipo_calculo    = "A"
       and cia_comp        = _cia_comp;

end foreach

-- Mensual

delete from ef_sumas;

insert into ef_sumas
select ano, periodo, '99999999', "001", sum(gasintganinv), 0.00, cia_comp
  from ef_estfin
 where tipo_calculo = "M"
   and cia_comp     in (_cia_comp1, _cia_comp2)
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
	   set gastotintganinv = _monto
     where ano             = _ano
       and periodo         = _periodo
	   and enlace          matches "*"
       and ccosto          matches "*"
       and tipo_calculo    = "M"
       and cia_comp        = _cia_comp;

end foreach

update ef_estfin
   set gasintganinv    = gastotintganinv * porcpescar / 100
 where cia_comp        in (_cia_comp1, _cia_comp2)
   and gastotintganinv <> 0.00;

-- Total de otros ingresos gastos

-- Acumulado

delete from ef_sumas;

insert into ef_sumas
select ano, periodo, '99999999', "001", sum(gasotringgas), 0.00, cia_comp
  from ef_estfin
 where tipo_calculo = "A"
   and cia_comp     in (_cia_comp1, _cia_comp2)
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
	   set gastototringgas = _monto
     where ano             = _ano
       and periodo         = _periodo
	   and enlace          matches "*"
       and ccosto          matches "*"
       and tipo_calculo    = "A"
       and cia_comp        = _cia_comp;

end foreach

-- Mensual

delete from ef_sumas;

insert into ef_sumas
select ano, periodo, '99999999', "001", sum(gasotringgas), 0.00, cia_comp
  from ef_estfin
 where tipo_calculo = "M"
   and cia_comp     in (_cia_comp1, _cia_comp2)
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
	   set gastototringgas = _monto
     where ano             = _ano
       and periodo         = _periodo
	   and enlace          matches "*"
       and ccosto          matches "*"
       and tipo_calculo    = "M"
       and cia_comp        = _cia_comp;

end foreach

update ef_estfin
   set gasotringgas    = gastototringgas * porcpescar / 100
 where cia_comp        in (_cia_comp1, _cia_comp2)
   and gastototringgas <> 0.00;

-- Total de gastos financieros

-- Acumulado

delete from ef_sumas;

insert into ef_sumas
select ano, periodo, '99999999', "001", sum(gasgasfinan), 0.00, cia_comp
  from ef_estfin
 where tipo_calculo = "A"
   and cia_comp     in (_cia_comp1, _cia_comp2)
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
	   set gastotgasfinan  = _monto
     where ano             = _ano
       and periodo         = _periodo
	   and enlace          matches "*"
       and ccosto          matches "*"
       and tipo_calculo    = "A"
       and cia_comp        = _cia_comp;

end foreach

-- Acumulado

delete from ef_sumas;

insert into ef_sumas
select ano, periodo, '99999999', "001", sum(gasgasfinan), 0.00, cia_comp
  from ef_estfin
 where tipo_calculo = "M"
   and cia_comp     in (_cia_comp1, _cia_comp2)
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
	   set gastotgasfinan  = _monto
     where ano             = _ano
       and periodo         = _periodo
	   and enlace          matches "*"
       and ccosto          matches "*"
       and tipo_calculo    = "M"
       and cia_comp        = _cia_comp;

end foreach

update ef_estfin
   set gasgasfinan    = gastotgasfinan * porcpescar / 100
 where cia_comp       in (_cia_comp1, _cia_comp2)
   and gastotgasfinan <> 0.00;

end

return 0, "Actualizacion Exitosa";

end procedure