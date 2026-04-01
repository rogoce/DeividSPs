-- Procedimiento que extrae la Cartera de Oficina para una fecha dada
-- a una Fecha Dada
-- 
-- Creado    : 07/09/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 07/09/2000 - Autor: Amado Perez Mendoza
-- Modificado: 03/07/2002 - Autor: Amado Perez Mendoza. Se modifica la salida para que salga el monto del arreglo y saldo
--														como lo pidio Michelle Zarak..
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec28;
--DROP TABLE tmp_arreglo;
CREATE PROCEDURE "informix".sp_rec28(a_compania CHAR(3), a_agencia CHAR(3), a_fecha DATE) 
			RETURNING   CHAR(5),
						CHAR(100),
						CHAR(18),
						DATE,
						DATE,
						CHAR(100),
						DEC(16,2),
						DEC(16,2),
						CHAR(50);


DEFINE v_recupero   	  CHAR(5);
DEFINE v_asegurado        CHAR(100);
DEFINE v_reclamo          CHAR(18);
DEFINE v_fech_resol       DATE;
DEFINE v_inicio_ges       DATE;
DEFINE v_tercero	      CHAR(100);
DEFINE v_monto_saldo      DEC(16,2);
DEFINE v_compania_nombre  CHAR(50);

DEFINE _cod_abogado      CHAR(3);
DEFINE _no_reclamo       CHAR(10);      
DEFINE _no_poliza        CHAR(10);
DEFINE _cod_cliente	     CHAR(10);
DEFINE _deducible        DEC(16,2);
DEFINE _pagado_reclamo   DEC(16,2);
DEFINE v_deducible       DEC(16,2);
DEFINE _monto            DEC(16,2);
DEFINE _monto_tot        DEC(16,2);
DEFINE v_monto_arreglo   DEC(16,2);

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

CREATE TEMP TABLE tmp_arreglo(
		no_recupero		 CHAR(5)   NOT NULL,
		no_reclamo       CHAR(10)  NOT NULL,
		no_poliza        CHAR(10)  NOT NULL,    
		cod_cliente	     CHAR(10)  NOT NULL,  
		reclamo       	 CHAR(18)  NOT NULL,
		fech_resol		 DATE,
		inicio_ges		 DATE,
		tercero          CHAR(100),
		pagado_reclamo   DEC(16,2) NOT NULL,
		monto_arreglo DEC(16,2) NOT NULL
		) WITH NO LOG;   

FOREACH	

 SELECT cod_abogado
   INTO _cod_abogado
   FROM recaboga
  WHERE oficina = 1

 FOREACH

 	SELECT no_recupero,
 		   no_reclamo,
           fecha_resolucion,
		   fecha_envio,
		   nombre_tercero,
		   pagado_reclamo,
		   monto_arreglo 
  	  INTO v_recupero,
	       _no_reclamo,
		   v_fech_resol,
		   v_inicio_ges,
		   v_tercero,
		   _pagado_reclamo,
		   v_monto_arreglo
   	  FROM recrecup
  	 WHERE cod_abogado = _cod_abogado
	   AND estatus_recobro = 2
	   AND cod_compania = a_compania
	   AND fecha_recupero <= a_fecha

   	-- Lectura de Reclamos

 	SELECT numrecla,
		   no_poliza
   	  INTO v_reclamo,
		   _no_poliza
      FROM recrcmae
     WHERE no_reclamo = _no_reclamo
       AND cod_compania = a_compania
	   AND actualizado = 1;
 	

	-- Lectura de Polizas

	SELECT cod_contratante
	  INTO _cod_cliente
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

 			   
	INSERT INTO tmp_arreglo(
	no_recupero,		
	no_reclamo,    
	no_poliza,      
	cod_cliente,	  
	reclamo,       
	fech_resol,		
	inicio_ges,		
	tercero,       
	pagado_reclamo,
	monto_arreglo
	)
	VALUES(
	v_recupero,
	_no_reclamo,    
	_no_poliza,  
	_cod_cliente,	  
	v_reclamo,      
    v_fech_resol,		
	v_inicio_ges,		
	v_tercero,
	_pagado_reclamo,
	v_monto_arreglo
	);
	END FOREACH;

END FOREACH;


--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT no_recupero,	
        no_reclamo,    
 		no_poliza,         
 		cod_cliente,	   
 		reclamo,       
 		fech_resol,		   
 		inicio_ges,		
 		tercero,       	
 		pagado_reclamo,
 		monto_arreglo   
   INTO v_recupero,
        _no_reclamo,    
		_no_poliza,  
		_cod_cliente,	
		v_reclamo,      
    	v_fech_resol,	
    	v_inicio_ges,	
    	v_tercero,
		_pagado_reclamo,
		v_monto_arreglo
   FROM tmp_arreglo
  ORDER BY no_recupero

	-- Lectura de Cliente

	SELECT nombre
	  INTO v_asegurado
 	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	IF v_asegurado IS NULL THEN
		LET v_asegurado = " ";
	END IF 

    LET _monto_tot = 0;

{    FOREACH WITH HOLD

	 SELECT deducible
	   INTO _deducible
	   FROM recrccob
	  WHERE no_reclamo = _no_reclamo    

	  LET v_deducible = v_deducible + _deducible;

	END FOREACH}

    FOREACH WITH HOLD

	 SELECT a.monto
	   INTO _monto
	   FROM rectrmae a, rectitra b
	  WHERE a.no_reclamo = _no_reclamo
	    AND a.actualizado = 1
	    AND b.cod_tipotran = a.cod_tipotran  
	    AND b.tipo_transaccion = 6  

	  LET _monto_tot = _monto_tot + _monto;

	END FOREACH

	LET _monto_tot = _monto_tot * (-1);

	LET v_monto_saldo = v_monto_arreglo - _monto_tot;
	-- falta el saldo del recupero
	RETURN v_recupero,   	 
		   v_asegurado,       
		   v_reclamo,           
	 	   v_fech_resol,      
		   v_inicio_ges,      
		   v_tercero,
		   v_monto_arreglo,	     
		   v_monto_saldo,     
		   v_compania_nombre 
		   WITH RESUME;   	

END FOREACH



DROP TABLE tmp_arreglo;
END PROCEDURE