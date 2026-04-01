-- Generacion del Archivo para Banco General

-- Creado    : 22/02/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 22/02/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob44;

CREATE PROCEDURE "informix".sp_cob44(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_user			CHAR(8)
) RETURNING SMALLINT,
            CHAR(100);

DEFINE _campo			CHAR(174);
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
DEFINE _monto_char      CHAR(11);
DEFINE _fecha_exp		CHAR(7);
DEFINE _no_documento	CHAR(20);
DEFINE _nombre			CHAR(100);
DEFINE _cod_cliente		CHAR(10);

DEFINE _cant_tran		INTEGER;
DEFINE _cant_tran_char  CHAR(3);

DEFINE _error_code      SMALLINT;

LET _afiliacion = '001908342013 ';

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob44.trc"; 
--TRACE ON;                                                                

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Actualizar los Lotes';         
END EXCEPTION           

DELETE FROM cobtaban;

--DROP TABLE tmp_tarjeta;

--CREATE TEMP TABLE tmp_tarjeta(
--	campo	CHAR(174)   
--	) WITH NO LOG;

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

	IF   _monto > 9999999.99 THEN
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
			 
	LET _campo = '1' ||
	             '2' ||
				 _no_lote_char || ' ' ||
				 '000 ' ||
				 _cant_tran_char ||	' ' ||
				 _monto_char ||	' ' ||
				 _afiliacion ||
				 ' ' ||
				 '5' ||
				 _id_operador ||
				 '0000000 ' ||
				 '0000000 ' ||
				 _id_terminal ||
				 _fecha_char[1,2] || _fecha_char[4,5] || _fecha_char[7,10] || 
				 '00000000000 ' ||
				 _id_sucursal ||
				 ' ' ||
				 '00' ||
				 '000000000.00 ' ||
				 '000 ' ||
				 '                                   ' ||
				 _afiliacion ||
				 '      ';

	INSERT INTO cobtaban
	VALUES (_campo);

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

 	 UPDATE cobtacre
	    SET fecha_ult_tran = _fecha
	  WHERE no_tarjeta     = _no_tarjeta
	    AND no_documento   = _no_documento;

		LET _cant_tran_char = sp_set_codigo(3, _cant_tran);
		LET _fecha_char     = _fecha;

		LET _monto_char = '000000000';

		IF   _monto > 99999.99 THEN
			LET _monto_char[1,9] = _monto;
		ELIF _monto > 9999.99 THEN
			LET _monto_char[2,9] = _monto;
		ELIF _monto > 999.99 THEN
			LET _monto_char[3,9] = _monto;
		ELIF _monto > 99.99 THEN
			LET _monto_char[4,9] = _monto;
		ELIF _monto > 9.99 THEN
			LET _monto_char[5,9] = _monto;
		ELSE
			LET _monto_char[6,9] = _monto;
		END IF

		LET _campo = '2' ||
		             '2' ||
					 _no_lote_char || ' ' ||
					 _cant_tran_char || ' ' ||
					 '0' || 
					 _no_tarjeta[1,4] || _no_tarjeta[6,9] || _no_tarjeta[11,14] || _no_tarjeta[16,19] || ' ' ||
					 _codigo ||
					 TRIM(_monto_char) || ' ' ||
					 _fecha_char[1,2] || _fecha_char[4,5] || _fecha_char[9,10] || ' ' ||
					 '000000' ||
					 '                       ' ||
					 '0000000.00 ' ||
					 _id_operador ||
					 '                         ' ||
					 '             ' ||
					 '  ' ||
					 ' ' ||
					 '00000 ' ||
					 ' ' ||
					 '  ' ||
					 ' ' ||
					 'E' ||
					 ' ' ||
					 ' ' ||
					 _fecha_exp[1,2] || _fecha_exp[6,7] ||
					 '                        '; 
					 						
		INSERT INTO cobtaban
		VALUES (_campo);

	END FOREACH
  		   	
END FOREACH

RETURN 0, 'Actualizacion Exitosa ...'; 

END 

END PROCEDURE;
