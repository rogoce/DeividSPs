-- Registros Contables de los Pagos de Prima
-- 
-- Creado    : 26/08/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 26/08/2002 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - d_cobr_sp_cob89_dw1 DEIVID, S.A.

DROP PROCEDURE sp_cob89;

CREATE PROCEDURE "informix".sp_cob89(a_compania CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7))
RETURNING CHAR(25),	 -- Cuenta
		  CHAR(50),	 -- Nombre Cuenta
		  DEC(16,2), -- Debito
		  DEC(16,2), -- Credito
		  CHAR(50),	 -- Compania
		  CHAR(1);   -- Tipo de Remesa

DEFINE _cod_tipoprod     CHAR(3);  
DEFINE _tipo_produccion  SMALLINT; 
DEFINE _no_poliza		 CHAR(10);
DEFINE _no_remesa		 CHAR(10);
DEFINE _renglon			 SMALLINT;  

DEFINE v_cuenta			 CHAR(25);	
DEFINE v_debito          DEC(16,2);
DEFINE v_credito         DEC(16,2);

DEFINE _monto            DEC(16,2);
DEFINE _tipo_remesa      CHAR(1);

DEFINE v_nombre_cuenta   CHAR(50);
DEFINE v_compania_nombre CHAR(50); 

LET  v_compania_nombre = sp_sis01(a_compania); 

CREATE TEMP TABLE tmp_prod(
	tipo_remesa     CHAR(1),
	cuenta		   	CHAR(25),
	debito      	DECIMAL(16,2),
	credito		    DECIMAL(16,2)
	) WITH NO LOG;

SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT	no_poliza,
        no_remesa,
		renglon
   INTO	_no_poliza,
        _no_remesa,
		_renglon
   FROM	cobredet
  WHERE cod_compania = a_compania
	AND actualizado = 1
	AND tipo_mov   IN ('P', 'N')
    AND periodo    >= a_periodo1
    AND periodo    <= a_periodo2
	AND monto      <> 0

	SELECT cod_tipoprod
	  INTO _cod_tipoprod
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;
	 
	 IF _tipo_produccion = 4 THEN
	 	CONTINUE FOREACH;
	 END IF 	

	SELECT tipo_remesa
	  INTO _tipo_remesa
	  FROM cobremae
	 WHERE no_remesa = _no_remesa;

	IF _tipo_remesa = "F" Or
	   _tipo_remesa = "T" Then
	END IF

   FOREACH
	SELECT debito,
		   credito,
		   cuenta
	  INTO v_debito,
	       v_credito,
	       v_cuenta
	  FROM cobasien
	 WHERE no_remesa = _no_remesa
	   AND renglon   = _renglon
	   AND cuenta[1,3] IN ("144", "131")

		INSERT INTO tmp_prod(
		tipo_remesa,
		cuenta,   
		debito,	  
	    credito
		)
		VALUES(
		_tipo_remesa,
		v_cuenta,  
		v_debito,
		v_credito
		);

	  	LET v_debito = 0;
	  	LET v_credito = 0;

  END FOREACH

END FOREACH

FOREACH
 SELECT tipo_remesa,
 		cuenta, 
        SUM(debito), 
        SUM(credito)
   INTO _tipo_remesa,
   		v_cuenta, 
        v_debito, 
        v_credito
   FROM tmp_prod
  GROUP BY 1, 2
  ORDER BY 1, 2

{	LET _monto = v_debito - v_credito;

	IF _monto >= 0.00 THEN
		LET v_debito  = _monto;
		LET v_credito = 0.00;
	ELSE
		LET v_debito  = 0.00;
		LET v_credito = _monto * -1;
	END IF
}
	 SELECT nombre
	   INTO v_nombre_cuenta
	   FROM cglctas
	  WHERE cuenta = v_cuenta;

	RETURN v_cuenta,			
		   v_nombre_cuenta,  
		   v_debito,         
		   v_credito,        
		   v_compania_nombre,
		   _tipo_remesa
		   WITH RESUME;	 		

END FOREACH;

DROP TABLE tmp_prod;

END PROCEDURE;


