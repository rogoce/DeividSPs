-- Reporte de Registros Contables de Reclamos
-- 
-- Creado    : 22/01/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 22/01/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_para_sp_par295_dw1 - DEIVID, S.A.

--DROP PROCEDURE sp_par295a;

CREATE PROCEDURE "informix".sp_par295a()
RETURNING CHAR(18),	 -- Numrecla
		  CHAR(10),	 --	No_tranrec
		  CHAR(10),   -- Transaccion
		  CHAR(25),	 -- Cuenta					  
		  DEC(16,2), -- Debito					  
		  DEC(16,2), -- Credito					  
		  CHAR(2);	 -- Tipo de comprobante		  

DEFINE _no_tranrec		 CHAR(10);
DEFINE v_cuenta			 CHAR(25);	
DEFINE v_nombre_cuenta   CHAR(50);
DEFINE v_debito_val      DEC(16,2);
DEFINE v_credito_val         DEC(16,2);
DEFINE v_debito          DEC(16,2);
DEFINE v_credito         DEC(16,2);
DEFINE v_compania_nombre CHAR(50); 
DEFINE v_tipo_comp       Smallint;
DEFINE v_comprobante     CHAR(25);
DEFINE v_cod_auxiliar    CHAR(5);
define _numrecla         char(18);
define _no_reclamo       char(10);
define _transaccion      char(10);

LET v_debito  = 0;
LET v_credito = 0;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01("001"); 

CREATE TEMP TABLE tmp_prod(
		tipo_comprobante smallint,
		cuenta		   	 CHAR(25),
		debito      	 DECIMAL(16,2),
		credito		     DECIMAL(16,2),
		numrecla         char(18),
		no_tranrec       char(10),
		transaccion      char(10)
		) WITH NO LOG;

CREATE TEMP TABLE tmp_prod2(
		tipo_comprobante smallint,
		cuenta		   	 CHAR(25),
		debito      	 DECIMAL(16,2),
		credito		     DECIMAL(16,2),
		numrecla         char(18),
		no_tranrec       char(10),
		cod_auxiliar     char(5)
		) WITH NO LOG;


-- Lectura de la Tabla de Remesas detalle

SET ISOLATION TO DIRTY READ;

FOREACH

	 SELECT numrecla
	   INTO _numrecla
	   FROM c
	  order by numrecla
 
	 select no_reclamo into _no_reclamo from recrcmae
	 where numrecla = _numrecla;

 foreach

	 SELECT no_tranrec,
	        transaccion
	   INTO _no_tranrec,
	        _transaccion
	   FROM rectrmae
	  WHERE no_reclamo  = _no_reclamo
	    AND actualizado = 1

	   FOREACH
		SELECT debito,
			   credito,
			   cuenta,
			   tipo_comp
		  INTO v_debito,
		       v_credito,
		       v_cuenta,
			   v_tipo_comp
		  FROM recasien
		 WHERE no_tranrec = _no_tranrec

			INSERT INTO tmp_prod(
			tipo_comprobante,
			cuenta,   
			debito,	  
		    credito,
			numrecla,
			no_tranrec,
			transaccion
			)
			VALUES(
			v_tipo_comp,
			v_cuenta,  
			v_debito,
			v_credito,
			_numrecla,
			_no_tranrec,
			_transaccion
			);

	  END FOREACH

	  FOREACH
		SELECT debito,
			   credito,
			   cuenta,
			   cod_auxiliar
		  INTO v_debito,
		       v_credito,
		       v_cuenta,
			   v_cod_auxiliar
		  FROM recasiau
		 WHERE no_tranrec = _no_tranrec

			INSERT INTO tmp_prod2(
			tipo_comprobante,
			cuenta,   
			debito,	  
		    credito,
			numrecla,
			no_tranrec,
			cod_auxiliar
			)
			VALUES(
			v_tipo_comp,
			v_cuenta,  
			v_debito,
			v_credito,
			_numrecla,
			_no_tranrec,
			v_cod_auxiliar
			);

	  END FOREACH

 END FOREACH;
end foreach

FOREACH
 SELECT tipo_comprobante,
        cuenta, 
        debito, 
        credito,
		numrecla,
		no_tranrec,
		transaccion
   INTO v_comprobante,
   		v_cuenta, 
        v_debito, 
        v_credito,
		_numrecla,
		_no_tranrec,
		_transaccion
   FROM tmp_prod
  order by numrecla

	RETURN _numrecla,
	       _no_tranrec,
		   _transaccion,
		   v_cuenta,			
		   v_debito,         
		   v_credito,        
		   v_comprobante
		   WITH RESUME;

END FOREACH;

DROP TABLE tmp_prod;

END PROCEDURE;

