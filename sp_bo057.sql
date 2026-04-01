-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_bo057;

create procedure "informix".sp_bo057()
returning integer,
          char(50);

define _error		integer;

define _ano			char(4);
define _periodo		smallint;
define _enlace 		char(10);
define _ccosto		char(3);
define _cia_comp	char(3);
define _monto		dec(16,2);
define _monto2		dec(16,2);

set isolation to dirty read;

begin 
on exception set _error
	return _error, "Error al Actualizar Registros";
end exception

-- Salarios

call sp_bo058("6000101");

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
	   set pre_gp_salarios  = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gp_salarios  = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
       and cia_comp	     = _cia_comp;

end foreach

{
-- Vacaciones Sumado a Salario

call sp_bo058("6000102");

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
	   set pre_gp_salarios = pre_gp_salarios + _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gp_salarios = pre_gp_salarios + _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
       and cia_comp	     = _cia_comp;

end foreach
}

-- Vacaciones por Separado

call sp_bo058("6000102");

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
	   set pre_gp_vacaciones = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gp_vacaciones = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Decimo Tercer Mes

call sp_bo058("6000103");

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
	   set pre_gp_decimo    = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gp_decimo    = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Seguro Social

call sp_bo058("6000104");

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
	   set pre_gp_seg_social = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;


	update ef_estfin
	   set pre_gp_seg_social = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Seguro Educativo

call sp_bo058("6000105");

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
	   set pre_gp_seg_edu    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gp_seg_edu    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Riesgos Profesionales

call sp_bo058("6000106");

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
	   set pre_gp_ries_pro   = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gp_ries_pro   = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Gastos de Representacion

call sp_bo058("6000107");

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
	   set pre_gp_gas_rep    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gp_gas_rep    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Bonificacion

call sp_bo058("6000115");

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
	   set pre_gp_bon_ger    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gp_bon_ger    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Seguros Empleados

call sp_bo058("6000112");

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
	   set pre_gp_seg_emp    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gp_seg_emp    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Fondo Cesantia

call sp_bo058("6000109");

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
	   set pre_gp_fondo_ces  = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gp_fondo_ces  = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Indemninacion

call sp_bo058("6000108");

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
	   set pre_gp_imdemni    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gp_imdemni    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Alquileres

call sp_bo058("6000120");

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
	   set pre_ga_alquiler   = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_ga_alquiler   = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Luz

call sp_bo058("6000121");

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
	   set pre_ga_luz        = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_ga_luz        = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Telefono

call sp_bo058("6000122");

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
	   set pre_ga_telefono   = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_ga_telefono   = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Papeleria y Utiles

call sp_bo058("6000124");

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
	   set pre_ga_papeleria  = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_ga_papeleria  = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

call sp_bo058("6000125");

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
	   set pre_ga_papeleria  = pre_ga_papeleria + _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_ga_papeleria  = pre_ga_papeleria + _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Agua

call sp_bo058("6000123");

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
	   set pre_ga_agua   = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_ga_agua   = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Equipo Rodante

call sp_bo058("6000126");

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
	   set pre_ga_eq_rod     = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_ga_eq_rod     = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Leasing Vehicular

call sp_bo058("6000185");

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
	   set pre_ga_leasing = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_ga_leasing = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Mantenimiento de Vehiculos

call sp_bo058("6000127");

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
	   set pre_ga_mant_veh = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_ga_mant_veh = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Honorarios Profesionales

call sp_bo058("6000128");

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
	   set pre_ga_hon_pro    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin			 
	   set pre_ga_hon_pro    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

call sp_bo058("6000129");

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
	   set pre_ga_hon_pro    = pre_ga_hon_pro + _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_ga_hon_pro    = pre_ga_hon_pro + _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Reparaciones y Mantenimientos

call sp_bo058("6000130");

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
	   set pre_ga_rep_man    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_ga_rep_man    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Reparacion y Mantenimiento Equipos

call sp_bo058("6000131");

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
	   set pre_ga_rep_man_eq = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_ga_rep_man_eq = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Reparacion y Mantenimiento Otros

call sp_bo058("6000132");

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
	   set pre_ga_rep_man_ot = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_ga_rep_man_ot = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Seguros

call sp_bo058("6000133");

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
	   set pre_ga_seguros    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_ga_seguros    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Aseo, limpieza, cafeteria

call sp_bo058("6000134");

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
	   set pre_ga_aseo       = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_ga_aseo       = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Porte Postal

call sp_bo058("6000135");

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
	   set pre_ga_postal     = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_ga_postal     = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Cuotas y Suscripciones

call sp_bo058("6000136");

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
	   set pre_ga_cuotas     = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_ga_cuotas     = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Entrenamiento de Personal

call sp_bo058("6000137");

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
	   set pre_ga_ent_per    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_ga_ent_per    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Miscelaneos

call sp_bo058("6000138");

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
	   set pre_ga_misce      = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_ga_misce      = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Relaciones Publicas

call sp_bo058("6000160");

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
	   set pre_gc_rel_pub    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gc_rel_pub    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Publicidad y Propaganda

call sp_bo058("6000161");

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
	   set pre_gc_pub_pro    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gc_pub_pro    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Junta Directiva

call sp_bo058("6000114");

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
	   set pre_gc_jun_dir = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gc_jun_dir = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Reunion Junta Directiva

call sp_bo058("6000162");

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
	   set pre_ga_jun_dir_reu = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_ga_jun_dir_reu = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Donaciones

call sp_bo058("6000164");

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
	   set pre_gc_donacion   = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gc_donacion   = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Gastos de Presidencia

call sp_bo058("6000169");

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
	   set pre_ga_presidencia = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_ga_presidencia = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Viajes

call sp_bo058("6000165");

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
	   set pre_gc_viajes     = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gc_viajes     = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Reuniones Corredores

call sp_bo058("6000163");

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
	   set pre_gc_reu_cor    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gc_reu_cor    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Adiestramiento Agentes

call sp_bo058("6000170");

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
	   set pre_gc_adies_agen = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gc_adies_agen = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Premios y Concuros

call sp_bo058("6000171");

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
	   set pre_gc_premios = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gc_premios = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Patrocinios Deportivos

call sp_bo058("6000172");

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
	   set pre_gc_patrocinios = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gc_patrocinios = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Atencion Empleados

call sp_bo058("6000166");

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
	   set pre_gc_ate_emp    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gc_ate_emp    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Uniformes

call sp_bo058("6000167");

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
	   set pre_gp_uniformes = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gp_uniformes = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Transporte

call sp_bo058("6000168");

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
	   set pre_gp_transporte = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gp_transporte = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Depreciacion y Amortizacion

call sp_bo058("6000180");

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
	   set pre_gg_dep_amor   = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gg_dep_amor   = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Impuestos

call sp_bo058("6000182");

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
	   set pre_gg_impuestos  = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pre_gg_impuestos  = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

end

return 0, "Actualizacion Exitosa";

end procedure