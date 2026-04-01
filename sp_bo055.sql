-- Procedimiento que crea el formato en blanco de la tabla ef_estfin

-- Creado    : 24/06/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo055;

create procedure "informix".sp_bo055()
returning integer,
          char(50);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

define _ano			char(4);
define _periodo		smallint;
define _enlace 		char(10);
define _ccosto		char(3);
define _estatus		char(1);
define _cia_comp	char(3);

define _ano_fiscal	smallint;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error,  _error_desc;
end exception

select par_anofiscal
  into _ano_fiscal
  from cglparam;

let _ano_fiscal = _ano_fiscal - 1;

set lock mode to wait;

delete from ef_estfin;

set isolation to dirty read;

foreach
 select sldet_ano, 
        sldet_periodo, 
        sldet_enlace
   into _ano,
        _periodo,
		_enlace
   from ef_saldodet
  where sldet_ano >= _ano_fiscal
  group by sldet_ano, sldet_periodo, sldet_enlace

	foreach
	 select cen_cia_comp,
	        cen_codigo
	   into	_cia_comp,
			_ccosto
	   from sac999:ef_cglcentro

		-- Montos Mensuales
		set lock mode to wait;

		insert into ef_estfin(
		       ano, 
		       periodo, 
		       enlace, 
		       ccosto,
			   tipo_calculo,
			   cia_comp
		       )
	    values (
			   _ano,
			   _periodo,
			   _enlace,
			   _ccosto,
			   "M",
			   _cia_comp
		       );

		-- Montos Acumulados

		insert into ef_estfin(
		       ano, 
		       periodo, 
		       enlace, 
		       ccosto,
			   tipo_calculo,
			   cia_comp
		       )
	    values (
			   _ano,
			   _periodo,
			   _enlace,
			   _ccosto,
			   "A",
			   _cia_comp
		       );

		set isolation to dirty read;

	end foreach

end foreach

end

return 0, "Actualizacion Exitosa";

end procedure