-- Procedimiento que Carga los Datos para la Apadea
-- Carga la tabla de cib_coberturas cuando las transacciones son de pago
-- de los reclamantes nuevos
-- Creado    : 18/02/2002 - Autor: Amado Perez M. 
-- Modificado: 18/02/2002 - Autor: Amado Perez M. 

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis331;		

CREATE PROCEDURE "informix".sp_sis331()
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
DEFINE _fecharegistro   DATE;


SET ISOLATION TO DIRTY READ;

DELETE FROM cib_coberturas;

LET _fecharegistro = CURRENT;
--LET _fecharegistro = '20/12/2000';

FOREACH

	SELECT codigo,
	       numerorecl,
		   numerorec2,
		   codasegura
	  INTO _codigo,
	       _numerorecl,
		   _numerorec2,
		   _codasegura
	  FROM cib_reclamantes
 --	 WHERE fecharegistro = _fecharegistro

	LET _monto = 0;

	FOREACH
		SELECT a.cod_cobertura,
		       a.monto,
			   b.cod_tipotran
		  INTO _cod_cobertura,
		       _monto,
			   _cod_tipotran
		  FROM rectrcob a, rectrmae b
		 WHERE a.no_tranrec = b.no_tranrec
		   AND b.numrecla = _numerorecl
		   AND b.cod_cliente = _codigo    
		   AND b.cod_tipotran = '004'

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

	END FOREACH

END FOREACH

COMMIT;

LET _mensaje = 'Actualizacion Exitosa ...';
RETURN 0, _mensaje;
       


END PROCEDURE;