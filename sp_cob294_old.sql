-- Generacion del Archivo para Banco General --- American

-- Creado    : 25/10/2011 - Autor: Armando Moreno M.
-- Modificado: 16/10/2011 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob294;

CREATE PROCEDURE "informix".sp_cob294(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_user			CHAR(8)
) RETURNING SMALLINT,
            CHAR(100);

DEFINE _campo			CHAR(64);
DEFINE _afiliacion      CHAR(13);
DEFINE _id_operador     CHAR(3);
DEFINE _id_terminal     CHAR(15);
DEFINE _id_sucursal     CHAR(3);

DEFINE _fecha           DATE;
DEFINE _fecha_char      CHAR(10);

DEFINE _no_lote_char	CHAR(5);

DEFINE _no_tarjeta		CHAR(19);
DEFINE _codigo          CHAR(2);
DEFINE _monto			DEC(16,2);
DEFINE _monto_char      CHAR(13);
DEFINE _fecha_exp		CHAR(7);
DEFINE _no_documento	CHAR(20);
DEFINE _nombre			CHAR(100);
DEFINE _cod_cliente		CHAR(10);

DEFINE _cant_tran,_valor INTEGER;
DEFINE _cant_tran_char   CHAR(3);

DEFINE _error_code      SMALLINT;

--LET _afiliacion = '001908342013 ';

--SET DEBUG FILE TO "sp_cob294.trc";
--TRACE ON;                                                                

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar los Lotes';         
END EXCEPTION           

--DELETE FROM cobtaban3;
DELETE FROM cobtaban;

let _valor = 0;

-- Selecciona los Lotes

FOREACH
 SELECT no_lote,
		total_transac,
		id_operador,
		id_terminal,
		fecha,
		id_oficina,
		total_monto
   INTO _no_lote_char,
		_cant_tran,
		_id_operador,
		_id_terminal,
		_fecha,
		_id_sucursal,
		_monto
   FROM cobtalot
  ORDER BY no_lote

	LET _cant_tran_char = sp_set_codigo(3, _cant_tran);
	LET _fecha_char     = TODAY;

	LET _monto_char = '00000000000';

	IF _monto > 9999999.99 THEN
		LET _monto_char[1,11] = _monto;
	ELIF _monto > 999999.99 THEN
		LET _monto_char[2,11] = _monto;
	ELIF _monto > 99999.99 THEN
		LET _monto_char[3,11] = _monto;
	ELIF _monto > 9999.99 THEN
		LET _monto_char[4,11] = _monto;
	ELIF _monto > 999.99 THEN
		LET _monto_char[5,11] = _monto;
	ELIF _monto > 99.99 THEN
		LET _monto_char[6,11] = _monto;
	ELIF _monto > 9.99 THEN
		LET _monto_char[7,11] = _monto;
	ELSE
		LET _monto_char[8,11] = _monto;
	END IF
			 
   {	LET _campo = '107';

	INSERT INTO cobtaban3
	VALUES (_campo);
}
	FOREACH
	 SELECT	renglon,
			no_tarjeta,
			codigo,
			fecha_exp,
			monto,
			no_documento
	   INTO	_cant_tran,
			_no_tarjeta,
			_codigo,
			_fecha_exp,
			_monto,
			_no_documento
	   FROM cobtatra
	  WHERE no_lote = _no_lote_char
	  ORDER BY renglon

 	{ UPDATE cobtacre
	    SET fecha_ult_tran = _fecha
	  WHERE no_tarjeta     = _no_tarjeta
	    AND no_documento   = _no_documento;}

		LET _cant_tran_char = sp_set_codigo(3, _cant_tran);
		LET _fecha_char     = _fecha;

		LET _monto_char = '0000000000000';

		IF _monto > 999999999.99 THEN
			LET _monto_char[1,13] = _monto;
		ELIF   _monto > 99999999.99 THEN
			LET _monto_char[2,13] = _monto;
		ELIF _monto > 9999999.99 THEN
			LET _monto_char[3,13] = _monto;
		ELIF _monto > 999999.99 THEN
			LET _monto_char[4,13] = _monto;
		ELIF _monto > 99999.99 THEN
			LET _monto_char[5,13] = _monto;
		ELIF _monto > 9999.99 THEN
			LET _monto_char[6,13] = _monto;
		ELIF _monto > 999.99 THEN
			LET _monto_char[7,13] = _monto;
		ELIF _monto > 99.99 THEN
			LET _monto_char[8,13] = _monto;
		ELIF _monto > 9.99 THEN
			LET _monto_char[9,13] = _monto;
		ELSE
			LET _monto_char[10,13] = _monto;
		END IF

		let _monto_char = _monto_char[1,10] || _monto_char[12,13];

		LET _campo = _no_tarjeta[1,4] || _no_tarjeta[6,11] || _no_tarjeta[13,17] ||	'    ' ||
					 _fecha_exp[1,2] || _fecha_exp[6,7] ||
					 TRIM(_monto_char) ||  '      ' || _no_lote_char || _cant_tran_char || '               ';
		INSERT INTO cobtaban
		VALUES (_campo);

	END FOREACH
  		   	
END FOREACH

let _valor = sp_cob243a(a_user);

RETURN 0, 'Actualizacion Exitosa ...'; 

END 

END PROCEDURE;
