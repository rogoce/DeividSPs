-- Ajustar Saldos
-- Creado    : 26/08/2003 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac255;
create procedure "informix".sp_sac255()
returning	char(3),
			char(30),
			dec(16,2);

define _ccosto	char(3); 
define _cuenta		char(30); 
define _saldo			dec(16,2); 
define _nombre				char(50);
define _tipo_contacto		smallint;
define _de_investigador		smallint;
define _de_electronico		smallint;
define _de_supervisor		smallint;
define _de_ejecutiva		smallint;
define _de_gestor			smallint;
define _return				smallint;
define _grupo				smallint;

set isolation to dirty read;

--drop table if exists tmp_tipo_accion;

foreach
	select cuenta,
		    ccosto,
			saldo_bk
	  into _cuenta,
		    _ccosto,
			_saldo
	  from deivid_tmp:ajuste_cglsaldo cgl

	update cglsaldoctrl
	   set sld_incioano = _saldo
	 where sld_ano = 2020
	   and sld_cuenta = _cuenta
	   and sld_ccosto = _ccosto;

	return	_cuenta,
			_ccosto,
			_saldo with resume;
end foreach

end procedure;