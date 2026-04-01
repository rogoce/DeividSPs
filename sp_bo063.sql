-- Procedimiento que crea los registros de los pasivos de los gastos 

-- Creado    : 15/10/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo063;

create procedure "informix".sp_bo063()
returning integer,
          char(50);

define _error	integer;

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

call sp_bo012("266200101");

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
	   set pas_gp_salarios  = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
       and cia_comp	    = _cia_comp;

	update ef_estfin
	   set pas_gp_salarios  = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
       and cia_comp	    = _cia_comp;

end foreach

{
-- Vacaciones Sumado a Salario

call sp_bo012("266200102");

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
	   set pas_gp_salarios  = pas_gp_salarios + _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
       and cia_comp	    = _cia_comp;

	update ef_estfin
	   set pas_gp_salarios  = pas_gp_salarios + _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
       and cia_comp	    = _cia_comp;

end foreach
}

--{
-- Vacaciones por Separado

call sp_bo012("266200102");

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
	   set pas_gp_vacaciones = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
       and cia_comp	    = _cia_comp;

	update ef_estfin
	   set pas_gp_vacaciones = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
       and cia_comp	    = _cia_comp;

end foreach
--}

-- Decimo Tercer Mes

call sp_bo012("266200103");

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
	   set pas_gp_decimo    = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
       and cia_comp	    = _cia_comp;

	update ef_estfin
	   set pas_gp_decimo    = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
       and cia_comp	    = _cia_comp;

end foreach

-- Seguro Social

call sp_bo012("266200104");

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
	   set pas_gp_seg_social = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_gp_seg_social = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Seguro Educativo

call sp_bo012("266200105");

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
	   set pas_gp_seg_edu    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_gp_seg_edu    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Riesgos Profesionales

call sp_bo012("266200106");

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
	   set pas_gp_ries_pro   = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_gp_ries_pro   = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Gastos de Representacion

call sp_bo012("266200107");

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
	   set pas_gp_gas_rep    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_gp_gas_rep    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Bonificacion

call sp_bo012("266200115");

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
	   set pas_gp_bon_ger    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_gp_bon_ger    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Seguros Empleados

call sp_bo012("266200112");

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
	   set pas_gp_seg_emp    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_gp_seg_emp    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Fondo Cesantia

call sp_bo012("266200109");

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
	   set pas_gp_fondo_ces  = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_gp_fondo_ces  = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Indemninacion

call sp_bo012("266200108");

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
	   set pas_gp_imdemni    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_gp_imdemni    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Alquileres

call sp_bo012("266200120");

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
	   set pas_ga_alquiler   = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_ga_alquiler   = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Luz

call sp_bo012("266200121");

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
	   set pas_ga_luz        = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_ga_luz        = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Telefono

call sp_bo012("266200122");

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
	   set pas_ga_telefono   = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_ga_telefono   = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Papeleria y Utiles

call sp_bo012("266200124");

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
	   set pas_ga_papeleria  = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_ga_papeleria  = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

call sp_bo012("266200125");

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
	   set pas_ga_papeleria  = pas_ga_papeleria + _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_ga_papeleria  = pas_ga_papeleria + _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Agua

call sp_bo012("266200123");

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
	   set pas_ga_agua       = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_ga_agua       = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Equipo Rodante

call sp_bo012("266200126");

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
	   set pas_ga_eq_rod     = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_ga_eq_rod     = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Leasing Vehicular

call sp_bo012("266200185");

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
	   set pas_ga_leasing    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_ga_leasing    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Mantenimiento de Vehiculos

call sp_bo012("266200127");

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
	   set pas_ga_mant_veh   = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_ga_mant_veh   = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Honorarios Profesionales

call sp_bo012("266200128");

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
	   set pas_ga_hon_pro    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin			 
	   set pas_ga_hon_pro    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

call sp_bo012("266200129");

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
	   set pas_ga_hon_pro    = pas_ga_hon_pro + _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_ga_hon_pro    = pas_ga_hon_pro + _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Reparaciones y Mantenimientos

call sp_bo012("266200130");

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
	   set pas_ga_rep_man    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_ga_rep_man    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Reparacion y Mantenimiento Equipos

call sp_bo012("266200131");

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
	   set pas_ga_rep_man_eq = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_ga_rep_man_eq = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Reparacion y Mantenimiento Otros

call sp_bo012("266200132");

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
	   set pas_ga_rep_man_ot = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_ga_rep_man_ot = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Seguros

call sp_bo012("266200133");

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
	   set pas_ga_seguros    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_ga_seguros    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Aseo, limpieza, cafeteria

call sp_bo012("266200134");

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
	   set pas_ga_aseo       = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_ga_aseo       = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Porte Postal

call sp_bo012("266200135");

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
	   set pas_ga_postal     = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_ga_postal     = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Cuotas y Suscripciones

call sp_bo012("266200136");

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
	   set pas_ga_cuotas     = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_ga_cuotas     = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Entrenamiento de Personal

call sp_bo012("266200137");

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
	   set pas_ga_ent_per    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_ga_ent_per    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Miscelaneos

call sp_bo012("266200138");

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
	   set pas_ga_misce      = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_ga_misce      = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Relaciones Publicas

call sp_bo012("266200160");

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
	   set pas_gc_rel_pub    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_gc_rel_pub    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Publicidad y Propaganda

call sp_bo012("266200161");

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
	   set pas_gc_pub_pro    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_gc_pub_pro    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Junta Directiva

call sp_bo012("266200114");

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
	   set pas_gc_jun_dir    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_gc_jun_dir    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Reunion Junta Directiva

call sp_bo012("266200162");

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
	   set pas_ga_jun_dir_reu = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_ga_jun_dir_reu = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Donaciones

call sp_bo012("266200164");

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
	   set pas_gc_donacion   = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_gc_donacion   = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Gastos de Presidencia

call sp_bo012("266200169");

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
	   set pas_ga_presidencia = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_ga_presidencia = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Viajes

call sp_bo012("266200165");

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
	   set pas_gc_viajes     = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_gc_viajes     = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Reuniones Corredores

call sp_bo012("266200163");

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
	   set pas_gc_reu_cor    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_gc_reu_cor    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Adiestramiento Agentes

call sp_bo012("266200170");

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
	   set pas_gc_adies_agen = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_gc_adies_agen = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Premios y Concuros

call sp_bo012("266200171");

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
	   set pas_gc_premios    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_gc_premios    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Patrocinios Deportivos

call sp_bo012("266200172");

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
	   set pas_gc_patrocinios = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_gc_patrocinios = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Atencion Empleados

call sp_bo012("266200166");

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
	   set pas_gc_ate_emp    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_gc_ate_emp    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Uniformes

call sp_bo012("266200167");

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
	   set pas_gp_uniformes  = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_gp_uniformes  = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Transporte

call sp_bo012("266200168");

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
	   set pas_gp_transporte = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_gp_transporte = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Depreciacion y Amortizacion

call sp_bo012("266200180");

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
	   set pas_gg_dep_amor   = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_gg_dep_amor   = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Impuestos

call sp_bo012("266200182");

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
	   set pas_gg_impuestos  = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set pas_gg_impuestos  = _monto2
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