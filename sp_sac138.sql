-- DDDW CUENTAS DE SAC

--drop procedure sp_sac138;

create procedure "informix".sp_sac138()
RETURNING CHAR(12), CHAR(50);

DEFINE		_cuenta		CHAR(12);
DEFINE		_nombre		CHAR(50);

foreach
	 select	cta_cuenta,
			cta_nombre
	   into	_cuenta,
			_nombre
	   from sac:cglcuentas

	   RETURN _cuenta, _nombre with resume;

end foreach

end procedure