-- Procedimeinto para actualizar el monto de la visa o ach en mantenimiento de visa/ach cuando la vigencia entre en vigor.

-- Creado    : 02/05/2013 - Autor: Armando Moreno M.
-- Modificado: 02/05/2013 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_sis404bk;

CREATE PROCEDURE "informix".sp_sis404bk(a_no_documento char(20))
RETURNING SMALLINT;

DEFINE _no_tarjeta       CHAR(19); 
DEFINE _monto            DEC(16,2);
DEFINE _no_documento     CHAR(20); 
DEFINE _vigencia_inic    DATE;
DEFINE _nueva_renov		 CHAR(1);
DEFINE _monto_visa       DEC(16,2);

DEFINE _no_poliza		 CHAR(10);
define _no_cuenta        char(17); 
define _fecha_hoy        date;


let _fecha_hoy = '30/07/2013';

-- Procesa Todas las Tarjetas de Credito

FOREACH
 SELECT h.no_tarjeta,
		c.monto,
		c.no_documento
   INTO _no_tarjeta,
		_monto,
		_no_documento
   FROM cobtacre c, cobtahab h
  WHERE c.no_tarjeta = h.no_tarjeta
    and c.no_documento = a_no_documento

  let _no_poliza = sp_sis21(_no_documento);

  select monto_visa,vigencia_inic,nueva_renov
    into _monto_visa,_vigencia_inic,_nueva_renov
	from emipomae
   where no_poliza = _no_poliza;

  if (_fecha_hoy = _vigencia_inic) and _nueva_renov = 'R' then

	update cobtacre
	   set monto        = _monto_visa
	 where no_tarjeta   = _no_tarjeta
	   and no_documento = _no_documento;

  end if
    
END FOREACH


-- Procesa Todas las Cuentas para ACH

FOREACH

 SELECT h.no_cuenta,
		c.monto,
		c.no_documento
   INTO _no_cuenta,
		_monto,
		_no_documento
   FROM cobcutas c, cobcuhab h
  WHERE trim(c.no_cuenta) = trim(h.no_cuenta)
    and c.no_documento    = a_no_documento

  let _no_poliza = sp_sis21(_no_documento);

  select monto_visa,vigencia_inic,nueva_renov
    into _monto_visa,_vigencia_inic,_nueva_renov
	from emipomae
   where no_poliza = _no_poliza;

  if (_fecha_hoy = _vigencia_inic) and _nueva_renov = 'R' then

	update cobcutas
	   set monto        = _monto_visa
	 where no_cuenta    = _no_cuenta
	   and no_documento = _no_documento;

  end if


END FOREACH

return 0;

END PROCEDURE;
