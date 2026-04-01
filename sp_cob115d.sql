-- CONSULTA DE PRIMAS POR COBRAR
-- Procedimiento que extrae los Saldos de la Poliza
 
-- Creado    : 26/09/2000 - Autor: Marquelda Valdelamar
-- Modificado: 20/02/2002 - Autor: Armando Moreno
-- SIS v.2.0 - DEIVID, S.A.
--   ref sp_cob25

DROP PROCEDURE sp_cob115d;

CREATE PROCEDURE "informix".sp_cob115d(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_no_documento	CHAR(20),
a_remesa		CHAR(10),
a_renglon		integer)
RETURNING	DEC(16,2); -- Saldo

DEFINE _no_poliza		CHAR(10);
DEFINE _no_requis		CHAR(10);
DEFINE v_monto			DEC(16,2);
DEFINE v_saldo			DEC(16,2);
DEFINE _anulado			SMALLINT;
DEFINE _pagado			SMALLINT;
define _fecha_actualizo	date;

SET ISOLATION TO DIRTY READ;

--DROP TABLE tmp_saldo2;

CREATE TEMP TABLE tmp_saldo2(
monto	DEC(16,2)) WITH NO LOG;

-- Lectura de Polizas
LET v_monto = 0;
let _fecha_actualizo = current;

select date_posteo
  into _fecha_actualizo
  from cobremae
 where no_remesa = a_remesa;

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
		   and fecha_impresion <= _fecha_actualizo

		INSERT INTO tmp_saldo2
				(monto)
		VALUES	(v_monto);
	END FOREACH;

	--Remesas
	FOREACH
		SELECT monto
		  INTO v_monto
		  FROM cobredet d, cobremae m
		 WHERE d.no_remesa = m.no_remesa
		   and no_poliza = _no_poliza
		   AND d.actualizado = 1
		   AND d.tipo_mov IN ('P', 'N', 'X')
		   AND (d.no_remesa <> a_remesa or (d.no_remesa = a_remesa and d.renglon <> a_renglon))
		   and m.date_posteo <= _fecha_actualizo

		LET v_monto = v_monto * -1;

		INSERT INTO tmp_saldo2
				(monto)
		VALUES	(v_monto);
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

		IF _pagado = 1 AND _anulado = 0 THEN

			INSERT INTO tmp_saldo2
					(monto)
			VALUES	(v_monto);
		END IF
	END FOREACH
END FOREACH

LET v_saldo = 0;

 SELECT SUM(monto)
   INTO v_saldo
   FROM tmp_saldo2;

DROP TABLE tmp_saldo2;

RETURN v_saldo;

--DROP TABLE tmp_saldo2;

END PROCEDURE