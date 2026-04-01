-- Reporte de los Datos para Banco General

-- Creado    : 09/03/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 09/03/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob49;

CREATE PROCEDURE "informix".sp_cob49(
a_compania		CHAR(3),
a_sucursal		CHAR(3)
) RETURNING CHAR(19),
			CHAR(100),
			DEC(16,2),
			DATE,
			CHAR(20),
            CHAR(50);

DEFINE _no_lote_char     CHAR(5);
DEFINE _tipo_tarjeta     CHAR(1);
DEFINE _fecha            DATE;     
DEFINE _no_tarjeta       CHAR(19); 
DEFINE _monto            DEC(16,2);
DEFINE _no_documento     CHAR(20); 
DEFINE v_compania_nombre CHAR(50); 
DEFINE _cant_tran        INTEGER;  
DEFINE _nombre			 CHAR(100);

LET  v_compania_nombre = sp_sis01(a_compania); 

FOREACH
 SELECT no_lote,
		fecha
   INTO _no_lote_char,
		_fecha
   FROM cobtalot
  ORDER BY no_lote

	FOREACH
	 SELECT	renglon,
			no_tarjeta,
			monto,
			no_documento,
			nombre
	   INTO	_cant_tran,
			_no_tarjeta,
			_monto,
			_no_documento,
			_nombre
	   FROM cobtatra
	  WHERE no_lote = _no_lote_char
	  ORDER BY renglon

	  select tipo_tarjeta
	    into _tipo_tarjeta
		from cobtahab
	   where no_tarjeta = _no_tarjeta;

	   if _tipo_tarjeta = "4" then -- American Express
			continue foreach;
	   end if

		RETURN _no_tarjeta,
			   _nombre,	
			   _monto,	
			   _fecha,
			   _no_documento,
			   v_compania_nombre
			   WITH RESUME;

	END FOREACH
  		   	
END FOREACH

END PROCEDURE