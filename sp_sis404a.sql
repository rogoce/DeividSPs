-- Procedimeinto para actualizar el monto de la visa o ach en mantenimiento de visa/ach cuando la vigencia entre en vigor.

-- Creado    : 02/05/2013 - Autor: Armando Moreno M.
-- Modificado: 02/05/2013 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis404a;

CREATE PROCEDURE "informix".sp_sis404a()
RETURNING dec(16,2),dec(16,2),char(10),char(20),date,char(3),smallint;

DEFINE _no_tarjeta       CHAR(19); 
DEFINE _monto            DEC(16,2);
DEFINE _no_documento     CHAR(20); 
DEFINE _vigencia_inic    DATE;
DEFINE _nueva_renov		 CHAR(1);
DEFINE _monto_visa       DEC(16,2);

DEFINE _no_poliza		 CHAR(10);
define _no_cuenta        char(17); 
define _fecha_hoy        date;
define _estatus,_cnt     smallint;


let _fecha_hoy = today;

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

  let _no_poliza = sp_sis21(_no_documento);

  select monto_visa,vigencia_inic,nueva_renov,estatus_poliza
    into _monto_visa,_vigencia_inic,_nueva_renov,_estatus
	from emipomae
   where no_poliza   = _no_poliza
     and actualizado = 1;

  select count(*)
    into _cnt
	from endedmae
   where actualizado = 1
     and no_poliza = _no_poliza
     and cod_endomov <> '011';

  if _cnt = 0 then

	  if _monto <> _monto_visa and _estatus <> 2 then
			return _monto,_monto_visa,_no_poliza,_no_documento,_vigencia_inic,'TCR',_estatus with resume;
	  end if

  end if
    
END FOREACH

{
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

  let _no_poliza = sp_sis21(_no_documento);

  select monto_visa,vigencia_inic,nueva_renov,estatus_poliza
    into _monto_visa,_vigencia_inic,_nueva_renov,_estatus
	from emipomae
   where no_poliza   = _no_poliza
     and actualizado = 1;

  select count(*)
    into _cnt
	from endedmae
   where actualizado = 1
     and no_poliza = _no_poliza
     and cod_endomov <> '011';

  if _cnt = 0 then

	  if _monto <> _monto_visa and _estatus <> 2 then
			return _monto,_monto_visa,_no_poliza,_no_documento,_vigencia_inic,'ACH',_estatus with resume;
	  end if

  end if

END FOREACH	}


END PROCEDURE;
