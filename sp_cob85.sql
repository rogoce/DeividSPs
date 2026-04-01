-- CONSULTA DE PRIMAS POR COBRAR
-- Procedimiento que extrae los Saldos de la Poliza
 
-- Creado    : 26/09/2000 - Autor: Marquelda Valdelamar
-- Modificado: 20/02/2002 - Autor: Armando Moreno
-- SIS v.2.0 - DEIVID, S.A.
-- ref sp_cob25

DROP PROCEDURE sp_cob85;

CREATE PROCEDURE "informix".sp_cob85(
a_compania 		CHAR(3), 
a_sucursal 		CHAR(3), 
a_no_documento  CHAR(20)
) RETURNING	DEC(16,2); -- Saldo

DEFINE v_monto            DEC(16,2);
DEFINE v_saldo            DEC(16,2);	 

DEFINE _no_poliza        CHAR(10);
DEFINE _no_requis		 CHAR(10);
DEFINE _pagado           SMALLINT;
DEFINE _anulado          SMALLINT;

SET ISOLATION TO DIRTY READ;

--DROP TABLE tmp_saldo1;

CREATE TEMP TABLE tmp_saldo1(
		monto           DEC(16,2)
		) WITH NO LOG;   

 -- Lectura de Polizas	

LET v_monto = 0;

FOREACH

 SELECT no_poliza
   INTO _no_poliza
   FROM emipomae
  WHERE no_documento = a_no_documento
    AND actualizado  = 1

		FOREACH

			SELECT prima_bruta
			  INTO v_monto
			  FROM endedmae
			 WHERE no_poliza   = _no_poliza
			   AND actualizado = 1
			   AND prima_bruta <> 0
			   AND activa = 1

			INSERT INTO tmp_saldo1(
			monto
			)
			VALUES(
			v_monto
			);

		END FOREACH;

		--Remesas
   		FOREACH
			 SELECT monto
			   INTO v_monto
			   FROM cobredet
			  WHERE no_poliza   = _no_poliza
			    AND actualizado = 1
				AND tipo_mov IN ('P', 'N', 'X')

			LET v_monto = v_monto * -1;

			INSERT INTO tmp_saldo1(
			monto
			)
			VALUES(
			v_monto
		    );

	    END FOREACH

		--Cheques
	    FOREACH
			 SELECT monto,
			 	    no_requis
			   INTO v_monto,
			 	    _no_requis
			   FROM chqchpol
			  WHERE no_poliza = _no_poliza

			 SELECT pagado,
				   anulado
			   INTO _pagado,
				   _anulado
			   FROM chqchmae
			  WHERE no_requis = _no_requis;

			 IF _pagado = 1 AND
			   _anulado = 0 THEN

				INSERT INTO tmp_saldo1(
				monto
				)
				VALUES(
				v_monto
				);
			 END IF
				
	    END FOREACH

END FOREACH

LET v_saldo = 0;

 SELECT SUM(monto)
   INTO v_saldo
   FROM tmp_saldo1;

DROP TABLE tmp_saldo1;

RETURN v_saldo;

--DROP TABLE tmp_saldo1;

END PROCEDURE
