-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_bo019;

create procedure "informix".sp_bo019()
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

-- Otros

call sp_bo012("6000");

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
	   set ga_otros      = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_otros      = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo = "M"
       and cia_comp	    = _cia_comp;

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
	   set ga_otros		= ga_otros - _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
	   and cia_comp     = _cia_comp;

	update ef_estfin
	   set ga_otros     = ga_otros - _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
	   and cia_comp     = _cia_comp;

end foreach

-- Salarios

call sp_bo012("6000101");

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
	   set gp_salarios  = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
       and cia_comp	    = _cia_comp;

	update ef_estfin
	   set gp_salarios  = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
       and cia_comp	    = _cia_comp;

end foreach

{
-- Vacaciones Sumado a Salario

call sp_bo012("6000102");

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
	   set gp_salarios  = gp_salarios + _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
       and cia_comp	    = _cia_comp;

	update ef_estfin
	   set gp_salarios  = gp_salarios + _monto2
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

call sp_bo012("6000102");

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
	   set gp_vacaciones = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
       and cia_comp	    = _cia_comp;

	update ef_estfin
	   set gp_vacaciones = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
       and cia_comp	    = _cia_comp;

end foreach
--}

-- Decimo Tercer Mes

call sp_bo012("6000103");

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
	   set gp_decimo    = _monto
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "A"
       and cia_comp	    = _cia_comp;

	update ef_estfin
	   set gp_decimo    = _monto2
     where ano          = _ano
       and periodo      = _periodo
       and enlace       = _enlace
       and ccosto       = _ccosto
       and tipo_calculo = "M"
       and cia_comp	    = _cia_comp;

end foreach

-- Seguro Social

call sp_bo012("6000104");

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
	   set gp_seg_social = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gp_seg_social = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Seguro Educativo

call sp_bo012("6000105");

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
	   set gp_seg_edu    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gp_seg_edu    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Riesgos Profesionales

call sp_bo012("6000106");

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
	   set gp_ries_pro   = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gp_ries_pro   = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Gastos de Representacion

call sp_bo012("6000107");

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
	   set gp_gas_rep    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gp_gas_rep    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Bonificacion

call sp_bo012("6000113");

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
	   set gp_bon_ger    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gp_bon_ger    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Seguros Empleados

call sp_bo012("6000112");

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
	   set gp_seg_emp    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gp_seg_emp    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Fondo Cesantia

call sp_bo012("6000109");

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
	   set gp_fondo_ces  = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gp_fondo_ces  = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Indemninacion

call sp_bo012("6000108");

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
	   set gp_imdemni    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gp_imdemni    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Alquileres

call sp_bo012("6000120");

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
	   set ga_alquiler   = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_alquiler   = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Luz

call sp_bo012("6000121");

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
	   set ga_luz        = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_luz        = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Telefono

call sp_bo012("6000122");

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
	   set ga_telefono   = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_telefono   = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Papeleria y Utiles

call sp_bo012("6000124");

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
	   set ga_papeleria  = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_papeleria  = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Agua

call sp_bo012("6000123");

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
	   set ga_agua       = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_agua       = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Leasing Vehicular

call sp_bo012("6000185");

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
	   set ga_leasing    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_leasing    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Mantenimiento de Vehiculos

call sp_bo012("6000127");

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
	   set ga_mant_veh   = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_mant_veh   = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Honorarios Profesionales

call sp_bo012("6000128");

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
	   set ga_hon_pro    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin			 
	   set ga_hon_pro    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Reparaciones y Mantenimientos

call sp_bo012("6000130");

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
	   set ga_rep_man    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_rep_man    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Reparacion y Mantenimiento Equipos

call sp_bo012("6000131");

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
	   set ga_rep_man_eq = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_rep_man_eq = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Reparacion y Mantenimiento Otros

call sp_bo012("6000132");

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
	   set ga_rep_man_ot = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_rep_man_ot = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Seguros

call sp_bo012("6000133");

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
	   set ga_seguros    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_seguros    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Aseo, limpieza, cafeteria

call sp_bo012("6000134");

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
	   set ga_aseo       = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_aseo       = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Porte Postal

call sp_bo012("6000135");

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
	   set ga_postal     = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_postal     = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Cuotas y Suscripciones

call sp_bo012("6000136");

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
	   set ga_cuotas     = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_cuotas     = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Entrenamiento de Personal

call sp_bo012("6000137");

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
	   set ga_ent_per    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_ent_per    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Miscelaneos

call sp_bo012("6000138");

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
	   set ga_misce      = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_misce      = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Relaciones Publicas

call sp_bo012("6000160");

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
	   set gc_rel_pub    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gc_rel_pub    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Publicidad y Propaganda

call sp_bo012("6000161");

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
	   set gc_pub_pro    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gc_pub_pro    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Junta Directiva

call sp_bo012("6000114");

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
	   set gc_jun_dir    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gc_jun_dir    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Reunion Junta Directiva

call sp_bo012("6000162");

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
	   set ga_jun_dir_reu = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_jun_dir_reu = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Donaciones

call sp_bo012("6000164");

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
	   set gc_donacion   = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gc_donacion   = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Gastos de Presidencia

call sp_bo012("6000169");

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
	   set ga_presidencia = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_presidencia = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Viajes

call sp_bo012("6000165");

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
	   set gc_viajes     = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gc_viajes     = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Reuniones Corredores

call sp_bo012("6000163");

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
	   set gc_reu_cor    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gc_reu_cor    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Adiestramiento Agentes

call sp_bo012("6000170");

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
	   set gc_adies_agen = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gc_adies_agen = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Premios y Concuros

call sp_bo012("6000171");

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
	   set gc_premios    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gc_premios    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Patrocinios Deportivos

call sp_bo012("6000172");

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
	   set gc_patrocinios = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gc_patrocinios = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Atencion Empleados

call sp_bo012("6000166");

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
	   set gc_ate_emp    = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gc_ate_emp    = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Uniformes

call sp_bo012("6000167");

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
	   set gp_uniformes  = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gp_uniformes  = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Transporte

call sp_bo012("6000168");

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
	   set gp_transporte = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gp_transporte = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Depreciacion y Amortizacion

call sp_bo012("6000180");

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
	   set gg_dep_amor   = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gg_dep_amor   = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Impuestos

call sp_bo012("6000182");

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
	   set gg_impuestos  = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gg_impuestos  = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Registros Nuevos Cuando se creo el Presupuesto del 2010

-- Sobretiempo

call sp_bo012("6000110");

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
	   set gp_sobretiempo  = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gp_sobretiempo  = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Bonificacion Gerencial

call sp_bo012("6000111");

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
	   set gp_bonif_geren  = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gp_bonif_geren  = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Participacion en Utilidades

call sp_bo012("6000115");

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
	   set gp_partic_util  = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gp_partic_util  = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Formularios e Impresos

call sp_bo012("6000125");

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
	   set ga_form_impre  = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_form_impre  = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Gasolina

call sp_bo012("6000126");

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
	   set ga_gasolina  = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_gasolina  = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Honorarios Otros

call sp_bo012("6000129");

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
	   set ga_honor_otros  = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_honor_otros  = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Gastos No Deducibles

call sp_bo012("6000183");

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
	   set ga_gas_no_ded  = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_gas_no_ded  = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Reparacion y Mantenimiento Equipo de Computo

call sp_bo012("6000187");

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
	   set ga_rep_man_it  = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set ga_rep_man_it  = _monto2
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "M"
       and cia_comp	     = _cia_comp;

end foreach

-- Atencion a Clientes

call sp_bo012("6000186");

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
	   set gc_aten_cliente  = _monto
     where ano           = _ano
       and periodo       = _periodo
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
       and cia_comp	     = _cia_comp;

	update ef_estfin
	   set gc_aten_cliente  = _monto2
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