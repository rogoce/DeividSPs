-- Procedimiento que Carga los Datos para la Apadea
-- Carga la tabla de cib_coberturas para las transacciones de pago
-- hechas durante el dia, pero que no son las que ya fueron incluidas 
-- Creado    : 18/02/2002 - Autor: Amado Perez M. 
-- Modificado: 18/02/2002 - Autor: Amado Perez M. 

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis334;		

CREATE PROCEDURE "informix".sp_sis334()
RETURNING INTEGER, CHAR(250);

DEFINE _mensaje			CHAR(250);
DEFINE _codigo 			CHAR(10);
DEFINE _numerorecl 		CHAR(20);
DEFINE _numerorec2  	SMALLINT;
DEFINE _monto       	DEC(18,2);
DEFINE _cod_cobertura 	CHAR(5);
DEFINE _equivalente 	CHAR(2);
DEFINE _cod_tipotran    CHAR(3);
DEFINE _codasegura      SMALLINT;
DEFINE _fecharegistro, _fecharegistro1   DATE;

--DELETE FROM cib_coberturas;

SET ISOLATION TO DIRTY READ;

LET _fecharegistro = CURRENT;
--LET _fecharegistro = '20/12/2000';
LET _fecharegistro1 = _fecharegistro - 1;
--LET _fecharegistro1 = '21/03/2003';
LET _monto = 0;

SELECT fecha
  INTO _fecharegistro1
  FROM cib_contador;
--LET _fecharegistro1 = '20/12/2000';

FOREACH
	SELECT a.cod_cobertura,
	       a.monto,
		   b.cod_tipotran,
		   c.codasegura,
		   c.numerorecl,
		   c.numerorec2
	  INTO _cod_cobertura,
	       _monto,
		   _cod_tipotran,
		   _codasegura,
		   _numerorecl,
		   _numerorec2
	  FROM rectrcob a, rectrmae b, cib_reclamantes c
	 WHERE a.no_tranrec = b.no_tranrec
	   AND c.numerorecl = b.numrecla
	   AND c.codigo = b.cod_cliente
	   AND b.cod_tipotran = '004'
	   AND b.fecha >= _fecharegistro1
	   AND b.fecha <= _fecharegistro
	   AND c.fecharegistro <> _fecharegistro

	SELECT equivalente
	  INTO _equivalente
	  FROM cib_tipocobertura
	 WHERE cod_cobertura = _cod_cobertura;

	IF _equivalente IS NULL OR _equivalente = '' THEN
	   LET _equivalente = '17';
	END IF

	BEGIN
		ON EXCEPTION IN(-239, -268)
			UPDATE cib_coberturas
			   SET sum_monto = sum_monto + _monto
			 WHERE numerorecl = _numerorecl
			   AND numerorec2 = _numerorec2
			   AND equivalent = _equivalente;

		END EXCEPTION
		INSERT INTO cib_coberturas
		VALUES (_codasegura,
		        _numerorecl,
				_numerorec2,
				_equivalente,
				_monto,
				_fecharegistro,
				_fecharegistro
				);
	END

	UPDATE cib_reclamantes
	   SET monto = monto + _monto
	 WHERE numerorecl = _numerorecl
	   AND numerorec2 = _numerorec2;


END FOREACH

--COMMIT;

LET _mensaje = 'Actualizacion Exitosa ...';
RETURN 0, _mensaje;

END PROCEDURE;