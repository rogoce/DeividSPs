-- Procedimiento para sacar el monto para una transaccion
--
-- creado: 06/01/2020 - Autor: Amado Perez M.

DROP PROCEDURE sp_rwf173;
CREATE PROCEDURE "informix".sp_rwf173(a_no_tranrec CHAR(10), a_grupo CHAR(25), a_cod_aprobacion CHAR(3))
			RETURNING DEC(16,2);  -- Monto de la transaccion

DEFINE _monto_tran     DEC(16,2);
DEFINE _no_reclamo     CHAR(10);
DEFINE _perd_total     SMALLINT;
DEFINE _cant           SMALLINT;
DEFINE _monto_da       DEC(16,2);
DEFINE _monto_col      DEC(16,2);
DEFINE _limite_2       DEC(16,2);
DEFINE _perd_total_tr  SMALLINT;
DEFINE _perd_total_t   SMALLINT;
DEFINE _cod_tipotran   CHAR(3);
DEFINE _user_added     CHAR(8);
DEFINE _monto_alq      DEC(16,2);

LET _monto_tran        = 0;
LET _monto_col         = 0;
LET _monto_da          = 0;
LET _limite_2          = 0;
LET _perd_total_tr     = 0;
LET _monto_alq         = 0;


SET ISOLATION TO DIRTY READ;
-- cod_aprobacion = '008' Colision y Vuelco
-- cod_aprobacion = '009' Daños a la propiedad ajena

--set debug file to "sp_rwf173.trc";
--trace on;


 SELECT no_reclamo,
        monto,
        perd_total,
		cod_tipotran,
        user_added
   INTO _no_reclamo,
        _monto_tran,
        _perd_total,
		_cod_tipotran,
        _user_added
   FROM rectrmae
  WHERE no_tranrec = a_no_tranrec;
  
 {IF _perd_total = 1 THEN
	 SELECT count(*)
	   INTO _perd_total_tr
	   FROM rectrmae
	  WHERE no_reclamo = _no_reclamo
	    AND perd_total = 1
		AND actualizado = 1
		AND no_tranrec <> a_no_tranrec;
 END IF	
 
 IF _perd_total_tr IS NULL THEN
	LET _perd_total_tr = 0;
 END IF

IF _perd_total = 1 AND _perd_total_tr = 0 THEN
	return 0.00;
END IF
}
  
-- Cambio pedido por Guillermo Salas 18-09-2017
-- MODIFICAR APROBACION DE WF PARA QUE TODAS LAS TRANSACCIONES REALIZADAS DONDE SE IDENTIFIQUE QUE EL SINIESTRO ES UNA PERDIDA TOTAL LA MISMA DEBERA IR APROBACION EXCLUSIVAMENTE DEL SR. GUILLERMO SALAS 
LET _perd_total = 0;
LET _perd_total_t = 0;
LET _perd_total_tr = 0;

SELECT perd_total
  INTO _perd_total
  FROM recrcmae
 WHERE no_reclamo = _no_reclamo;

SELECT count(*)
  INTO _perd_total_t
  FROM recterce  
 WHERE no_reclamo = _no_reclamo
   AND perd_total = 1;
   
SELECT perd_total
  INTO _perd_total_tr
  FROM rectrmae
 WHERE no_tranrec = a_no_tranrec 
   and wf_aprobado <> 0; --> Contando todos excepto los rechazados
   
IF _perd_total > 0 OR _perd_total_t > 0 OR _perd_total_tr = 1 THEN
	return 0.00;
END IF
---  
 FOREACH
	select monto
	  into _monto_col
	  from rectrcob a, prdcober b
	 where a.cod_cobertura = b.cod_cobertura
	   and a.no_tranrec = a_no_tranrec
	   and a.monto <> 0
	   and b.nombre like 'COLISI%'	  
 END FOREACH 
 
 IF _monto_col IS NULL THEN
	LET _monto_col = 0;	
 END IF
  
 FOREACH
	select monto
	  into _monto_da
	  from rectrcob a, prdcober b
	 where a.cod_cobertura = b.cod_cobertura
	   and a.no_tranrec = a_no_tranrec
	   and a.monto <> 0
	   and b.nombre like 'DA%PROP%AJENA%'	  
 END FOREACH 

 IF _monto_da IS NULL THEN
	LET _monto_da = 0;	
 END IF
 
 FOREACH
	select monto
	  into _monto_alq
	  from rectrcob a, prdcober b
	 where a.cod_cobertura = b.cod_cobertura
	   and a.no_tranrec = a_no_tranrec
	   and a.monto <> 0
	   and (b.nombre like 'ENDOSO%EXTRA%PLUS%'
	    or b.nombre like 'ENDOSO%TU%CHOFER%PRIVADO%' 
	    or b.nombre like 'REEMBOLSO%AUTO%SUSTITUTO%') 
 END FOREACH 

 IF _monto_alq IS NULL THEN
	LET _monto_alq = 0;	
 END IF
 

 IF _monto_col <> 0 THEN
	SELECT limite_2 
	  INTO _limite_2
	  FROM wf_aprodet
	 WHERE cod_aprobacion = '008'
	   AND grupo = a_grupo;
 END IF

 IF _monto_da <> 0 THEN
 	SELECT limite_2 
	  INTO _limite_2
	  FROM wf_aprodet
	 WHERE cod_aprobacion = '009'
	   AND grupo = a_grupo;
 END IF

 IF _monto_alq <> 0 and _cod_tipotran = '004' THEN
 	SELECT limite_2 
	  INTO _limite_2
	  FROM wf_aprodet
	 WHERE cod_aprobacion = '012'
	   AND grupo = a_grupo;
 END IF

 IF _cod_tipotran = '002' AND a_cod_aprobacion = '010' THEN -- Caso 6104 Abogada Lisbeth de Leon tenga autonomía de aumentar y aprobarse sus reservas hasta un limite de B/.5,000.00 sin autorización de los firmantes
	SELECT limite_2 
	  INTO _limite_2
	  FROM wf_aprodet
	 WHERE cod_aprobacion = a_cod_aprobacion	
	   AND grupo = a_grupo;
 END IF
  
 IF _limite_2 IS NULL THEN
	LET _limite_2 = 0;	
 END IF
 
 IF _limite_2 = 0 THEN
	SELECT limite_2 
	  INTO _limite_2
	  FROM wf_aprodet
	 WHERE cod_aprobacion = a_cod_aprobacion	
	   AND grupo = a_grupo;
 END IF
 
 IF _limite_2 IS NULL THEN
	LET _limite_2 = 0;	
 END IF 

 RETURN _limite_2;

END PROCEDURE
