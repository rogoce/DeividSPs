-- Comparacion entre cob03 y cob05.
-- 
-- Creado    : 20/01/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 20/01/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_para_sp_par70_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_par70;

CREATE PROCEDURE "informix".sp_par70(
a_compania	CHAR(3), 
a_agencia	CHAR(3), 
a_periodo 	DATE
) 
RETURNING CHAR(20), 
		  dec(16,2),
		  dec(16,2);

DEFINE v_doc_poliza        	CHAR(20); 
define _contador			smallint;
define _saldo				dec(16,2);
define _saldo2				dec(16,2);
 
CREATE TEMP TABLE tmp_comp(
		doc_poliza      CHAR(20),
		saldo1			dec(16,2),
		saldo2			dec(16,2)
		) WITH NO LOG;

CALL sp_cob03(
a_compania,
a_agencia,
a_periodo
);

FOREACH
 SELECT	doc_poliza,     
		saldo 
   INTO	v_doc_poliza,     
		_saldo 
   FROM	tmp_moros
  WHERE seleccionado = 1

	insert into tmp_comp
	values (v_doc_poliza, _saldo, 0.00);

END FOREACH
					 
DROP TABLE tmp_moros;

--CALL sp_cob07(
CALL sp_cob05(
a_compania,
a_agencia,
a_periodo
);

FOREACH
 SELECT	doc_poliza,     
		saldo 
   INTO	v_doc_poliza,     
		_saldo 
   FROM	tmp_moros
  WHERE seleccionado = 1

	insert into tmp_comp
	values (v_doc_poliza, 0.00, _saldo);

END FOREACH

let _contador = 0;

FOREACH
 SELECT	doc_poliza,     
		sum(saldo1),
		sum(saldo2) 
   INTO	v_doc_poliza,     
		_saldo,
		_saldo2 
   FROM	tmp_comp
  group by 1
  order by 1

--	let _contador = _contador + 1;

	if abs(_saldo - _saldo2) > 0.01 then

		RETURN 	v_doc_poliza,     
				_saldo,  
				_saldo2
				WITH RESUME;

	end if

END FOREACH

DROP TABLE tmp_moros;
DROP TABLE tmp_comp;

END PROCEDURE;

