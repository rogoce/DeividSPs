-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_bo015;

create procedure "informix".sp_bo015()
returning integer,
          char(50);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

define _ano			char(4);
define _periodo		smallint;
define _enlace 		char(10);
define _ccosto		char(3);
define _monto		dec(16,2);
define _monto2		dec(16,2);
define _estatus		char(1);
define _cia_comp	char(3);

--set debug file to "sp_bo015.trc";
--trace on;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error,  _error_desc;
end exception

-- Estatus de Cada periodo (Cerrado o Abierto)

let _cia_comp = sp_bo050("sac");

foreach
 select per_ano,
		per_mes,
		per_status
   into _ano,
        _periodo,
		_estatus
   from sac:cglperiodo

	update ef_estfin
	   set status   = _estatus
	 where ano      = _ano
	   and periodo  = _periodo
	   and cia_comp = _cia_comp;

end foreach

let _cia_comp = sp_bo050("sac001");

foreach
 select per_ano,
		per_mes,
		per_status
   into _ano,
        _periodo,
		_estatus
   from sac001:cglperiodo

	update ef_estfin
	   set status   = _estatus
	 where ano      = _ano
	   and periodo  = _periodo
	   and cia_comp = _cia_comp;

end foreach

let _cia_comp = sp_bo050("sac002");

foreach
 select per_ano,
		per_mes,
		per_status
   into _ano,
        _periodo,
		_estatus
   from sac002:cglperiodo

	update ef_estfin
	   set status   = _estatus
	 where ano      = _ano
	   and periodo  = _periodo
	   and cia_comp = _cia_comp;

end foreach

{
let _cia_comp = sp_bo050("sac003");

foreach
 select per_ano,
		per_mes,
		per_status
   into _ano,
        _periodo,
		_estatus
   from sac003:cglperiodo

	update ef_estfin
	   set status   = _estatus
	 where ano      = _ano
	   and periodo  = _periodo
	   and cia_comp = _cia_comp;

end foreach

let _cia_comp = sp_bo050("sac004");

foreach
 select per_ano,
		per_mes,
		per_status
   into _ano,
        _periodo,
		_estatus
   from sac004:cglperiodo

	update ef_estfin
	   set status   = _estatus
	 where ano      = _ano
	   and periodo  = _periodo
	   and cia_comp = _cia_comp;

end foreach

let _cia_comp = sp_bo050("sac005");

foreach
 select per_ano,
		per_mes,
		per_status
   into _ano,
        _periodo,
		_estatus
   from sac005:cglperiodo

	update ef_estfin
	   set status   = _estatus
	 where ano      = _ano
	   and periodo  = _periodo
	   and cia_comp = _cia_comp;

end foreach

let _cia_comp = sp_bo050("sac006");

foreach
 select per_ano,
		per_mes,
		per_status
   into _ano,
        _periodo,
		_estatus
   from sac006:cglperiodo

	update ef_estfin
	   set status   = _estatus
	 where ano      = _ano
	   and periodo  = _periodo
	   and cia_comp = _cia_comp;

end foreach

let _cia_comp = sp_bo050("sac007");

foreach
 select per_ano,
		per_mes,
		per_status
   into _ano,
        _periodo,
		_estatus
   from sac007:cglperiodo

	update ef_estfin
	   set status   = _estatus
	 where ano      = _ano
	   and periodo  = _periodo
	   and cia_comp = _cia_comp;

end foreach

let _cia_comp = sp_bo050("sac008");

foreach
 select per_ano,
		per_mes,
		per_status
   into _ano,
        _periodo,
		_estatus
   from sac008:cglperiodo

	update ef_estfin
	   set status   = _estatus
	 where ano      = _ano
	   and periodo  = _periodo
	   and cia_comp = _cia_comp;

end foreach
}

-- Estatus del Perido de la Compania Consolidada

let _cia_comp = "999";
 
foreach
 select ano, 
        periodo, 
        min(status)
   into _ano,
        _periodo,
		_estatus
   from ef_estfin
  where cia_comp <> _cia_comp
  group by ano, periodo
  order by ano, periodo	

	update ef_estfin
	   set status   = _estatus
	 where ano      = _ano
	   and periodo  = _periodo
	   and cia_comp = _cia_comp;

end foreach

--{
-- Primas Cobradas

call sp_bo060();

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set prima_cobrada = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set prima_cobrada = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("131");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_prima_cobrada = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_prima_cobrada = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach
--}

-- Comisiones pagadas a corredores

call sp_bo012("521");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set gascompagcor = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set gascompagcor = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("521");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_gascompagcor = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_gascompagcor = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

-- Comisiones pagadas a reaseguradores

call sp_bo012("522");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set gascompagrea = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set gascompagrea = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("522");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_gascompagrea = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_gascompagrea = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

-- Comisiones reaseguro cedido

call sp_bo012("413");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set gascomreaced = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set gascomreaced = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("413");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_gascomreaced = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_gascomreaced = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo012("415");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set gascomreaced = gascomreaced + _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set gascomreaced = gascomreaced + _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("415");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_gascomreaced = pre_gascomreaced + _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_gascomreaced = pre_gascomreaced + _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

-- Impuesto recuperado sobre prima

call sp_bo012("422");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	let _monto  = _monto  * -1;
	let _monto2 = _monto2 * -1;

	update ef_estfin
	   set gasimprecpri = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set gasimprecpri = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("422");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

--	let _monto  = _monto  * -1;
--	let _monto2 = _monto2 * -1;

	update ef_estfin
	   set pre_gasimprecpri = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_gasimprecpri = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo012("423");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	let _monto  = _monto  * -1;
	let _monto2 = _monto2 * -1;

	update ef_estfin
	   set gasimprecpri = gasimprecpri + _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set gasimprecpri = gasimprecpri + _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("423");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

--	let _monto  = _monto  * -1;
--	let _monto2 = _monto2 * -1;

	update ef_estfin
	   set pre_gasimprecpri = pre_gasimprecpri + _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_gasimprecpri = pre_gasimprecpri + _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

-- Impuesto pagado sobre prima

call sp_bo012("531");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set gasimppagpri = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set gasimppagpri = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("531");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_gasimppagpri = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_gasimppagpri = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

-- Gastos de manejo

call sp_bo012("564");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set gasgasman    = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set gasgasman    = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("564");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_gasgasman    = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_gasgasman    = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

-- Gastos de inspeccion

call sp_bo012("999");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set gasgasins    = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set gasgasins    = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("999");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_gasgasins    = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_gasgasins    = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

-- Gastos de cobranza

call sp_bo012("420");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set gasgascob    = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set gasgascob    = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("420");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_gasgascob    = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_gasgascob    = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

-- Siniestros pagados neto de salvamento

call sp_bo012("541");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set sinsinpagsal = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set sinsinpagsal = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("541");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_sinsinpagsal = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_sinsinpagsal = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

-- Recobros

call sp_bo012("419");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set sinrecobros  = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set sinrecobros  = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("419");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_sinrecobros  = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_sinrecobros  = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo012("544");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set sinrecobros  = sinrecobros + _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set sinrecobros  = sinrecobros + _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("544");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_sinrecobros  = pre_sinrecobros + _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_sinrecobros  = pre_sinrecobros + _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

-- Recuperado de Reaseguro Cedido

call sp_bo012("417");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set sinrecreaced = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set sinrecreaced = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("417");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_sinrecreaced = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_sinrecreaced = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

-- Variacion de reserva de siniestros en tramite

call sp_bo012("221");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set sinvarressin = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set sinvarressin = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

--call sp_bo054("221");
call sp_bo054("553");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_sinvarressin = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_sinvarressin = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

-- Porcion recuperable reaseguro

call sp_bo012("222");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set sinporrecrea = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set sinporrecrea = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

{
call sp_bo054("222");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_sinporrecrea = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_sinporrecrea = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach
}

-- Primas emitidas seguros directos

call sp_bo012("411");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set ingprisegdir = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set ingprisegdir = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("411");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_ingprisegdir = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_ingprisegdir = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

-- Presupuesto de Gastos de Administracion

update ef_estfin
   set pre_gasgasadmin = pre_ingprisegdir * -0.1019
 where ano = 2009;  

-- Primas reaseguro asumido

call sp_bo012("412");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set ingprireaasu = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set ingprireaasu = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("412");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_ingprireaasu = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_ingprireaasu = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

-- Reaseguro cedido proporcional

call sp_bo012("511");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set ingreacedpro = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set ingreacedpro = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("511");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_ingreacedpro = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_ingreacedpro = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

-- Reaseguro cedido xsp -- Exceso de Perdida

call sp_bo012("513");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set ingreacedxsp = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set ingreacedxsp = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("513");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_ingreacedxsp = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_ingreacedxsp = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

-- Aumento - Disminucion de reservas

call sp_bo012("551");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set ingaumdisres = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set ingaumdisres = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("551");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_ingaumdisres = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_ingaumdisres = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

-- Reserva catastrofica y estadistica

call sp_bo012("562");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set gasrescatest = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set gasrescatest = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("562");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_gasrescatest = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_gasrescatest = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo012("563");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set gasrescatest = gasrescatest + _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set gasrescatest = gasrescatest + _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("563");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_gasrescatest = pre_gasrescatest + _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_gasrescatest = pre_gasrescatest + _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

-- Gastos Administrativos

call sp_bo012("600");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set gasgasadmin  = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set gasgasadmin  = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("600");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_gasgasadmin  = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_gasgasadmin  = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo012("6000184");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set gasgasadmin  = gasgasadmin - _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set gasgasadmin  = gasgasadmin - _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("6000184");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_gasgasadmin  = pre_gasgasadmin - _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_gasgasadmin  = pre_gasgasadmin - _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

-- Interes Ganados en Inversiones

call sp_bo012("7000104");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set gasintganinv = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set gasintganinv = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("7000104");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_gasintganinv = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_gasintganinv = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo012("7000106");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set gasintganinv = gasintganinv + _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set gasintganinv = gasintganinv + _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("7000106");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_gasintganinv = pre_gasintganinv + _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_gasintganinv = pre_gasintganinv + _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

-- Otros ingresos y egresos

call sp_bo012("700");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set gasotringgas = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set gasotringgas = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("700");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_gasotringgas = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_gasotringgas = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo012("7000104");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set gasotringgas = gasotringgas - _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set gasotringgas = gasotringgas - _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("7000104");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_gasotringgas = pre_gasotringgas - _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_gasotringgas = pre_gasotringgas - _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo012("7000106");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set gasotringgas = gasotringgas - _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set gasotringgas = gasotringgas - _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("7000106");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_gasotringgas = pre_gasotringgas - _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_gasotringgas = pre_gasotringgas - _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

-- Gastos financieros

call sp_bo012("6000184");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set gasgasfinan  = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set gasgasfinan  = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

call sp_bo054("6000184");

foreach
 select ano,
		periodo,
		enlace,
		ccosto,
		cia_comp,
        monto,
		monto_mes
   into _ano,
		_periodo,
		_enlace,
		_ccosto,
		_cia_comp,
        _monto,
		_monto2
   from	ef_sumas

	update ef_estfin
	   set pre_gasgasfinan  = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set pre_gasgasfinan  = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

end

return 0, "Actualizacion Exitosa";

end procedure