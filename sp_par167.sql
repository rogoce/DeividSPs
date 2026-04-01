-- Procedimiento que Realiza los Pagos a los Medicos de las Polizas de Salud del Plan Dental

-- Creado    : 14/09/2005 - Autor: Amado Perez Mendoza
-- Modificado: 14/09/2005 - Autor: Amado Perez Mendoza

-- SIS v.2.0 - d_cheq_sp_che29_crit - DEIVID, S.A.

DROP PROCEDURE sp_par167;

CREATE PROCEDURE sp_par167() 
  RETURNING CHAR(5),
			CHAR(16),
			CHAR(16);

DEFINE _cod_agente          CHAR(5); 
DEFINE _monto               CHAR(16);
DEFINE _saldo               CHAR(16);

--SET DEBUG FILE TO "sp_pro30.trc"; 
--trace on;

SET ISOLATION TO DIRTY READ;


-- Nombre de la Compania

--LET _nombre_compania = sp_sis01(a_compania); 

FOREACH
 SELECT cod_agente, 
        monto,
		saldo
   INTO _cod_agente,
    	_monto,
		_saldo
   FROM agtdeuda

 RETURN _cod_agente,
		_monto,
		_saldo;

END FOREACH


END PROCEDURE;
