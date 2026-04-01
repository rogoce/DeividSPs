-- Recibos por cuenta-- 
-- Creado    : 12/12/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 12/12/2000 - Autor: Lic. Armando Moreno
--
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_cob39a;
CREATE PROCEDURE "informix".sp_cob39a(
a_compania CHAR(3),
a_agencia CHAR(3),
a_periodo1 CHAR(7),
a_periodo2 CHAR(7),
a_cuenta CHAR(255) DEFAULT "*"
)
RETURNING CHAR(25) as CUENTA,
		  DATE as FECHA,
          CHAR(10) as RECIBO,
          CHAR(10) as REMESA,
          DECIMAL(16,2) as DEBITO,
          DECIMAL(16,2) as CREDITO,
          CHAR(50) as COMPANIA,
          CHAR(255) as FILTRO,
		  CHAR(50) as NOMBRE_CUENTA,
		  CHAR(50) as recibi_de,
		  CHAR(30) as no_reclamo,
		  DECIMAL(16,2) as monto_pagado,
		  SMALLINT as cantidad,
		  DECIMAL(16,2) as calculo_perdida;

DEFINE v_debito			  DECIMAL(16,2);
DEFINE v_credito 		  DECIMAL(16,2);
DEFINE v_compania_nombre  CHAR(50);
DEFINE v_filtros          CHAR(255);
DEFINE v_no_remesa        CHAR(10);
DEFINE v_no_recibo        CHAR(10);
DEFINE v_cuenta           CHAR(25);
DEFINE v_doc_remesa       CHAR(30);
DEFINE v_nombre_cuenta    CHAR(50);
DEFINE v_fecha		      DATE;
DEFINE _tipo              CHAR(1);

DEFINE v_renglon          SMALLINT;
define _recibi_de		  char(50);
DEFINE _no_reclamo        CHAR(10);
define _monto_pagado      DECIMAL(16,2);
define _monto_pagado2      DECIMAL(16,2);
DEFINE _cantidad          SMALLINT;
	
-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

LET v_compania_nombre = sp_sis01(a_compania);

CREATE TEMP TABLE tmp_prod(
		cuenta		   	CHAR(25),
		fecha		 	DATE,
		no_recibo   	CHAR(10),
		no_remesa		CHAR(10),
		debito      	DECIMAL(16,2),
		credito		    DECIMAL(16,2),
		renglon		   	SMALLINT,
		seleccionado   	SMALLINT  DEFAULT 1 NOT NULL,
		recibi_de		char(50),
		reclamo         CHAR(30),
		monto_pagado    DECIMAL(16,2),
		monto_pagado2    DECIMAL(16,2),
		cantidad 	   	SMALLINT
		) WITH NO LOG;

CREATE INDEX iend1_tmp_prod ON tmp_prod(cuenta);

 --SET DEBUG FILE TO "sp_cob39a.trc";      
 --TRACE ON;
 
FOREACH WITH HOLD
	-- Informacion de remesas

	SELECT c.fecha,
		   c.no_recibo,
		   c.no_remesa,
		   c.renglon,
		   c.doc_remesa,
		   m.recibi_de
	  INTO v_fecha,
	  	   v_no_recibo,
	  	   v_no_remesa,
	  	   v_renglon,
	  	   v_doc_remesa,
		   _recibi_de
	  FROM cobredet c, cobremae m
	 WHERE c.periodo     >= a_periodo1 
	   and c.periodo     <= a_periodo2
	   AND c.no_remesa   = m.no_remesa
	   AND c.tipo_mov    <> "B"
--	   AND m.tipo_remesa IN("A","M","T", "C")
	   AND c.renglon     <> 0
	   AND c.actualizado = 1
	  --  and c.doc_remesa = '23-0519-00328-01'
	   and upper(m.recibi_de) like ('%PANAMA EMPRESARIAL, S.A%')

	FOREACH	
		SELECT debito,
			   credito,
			   cuenta
		  INTO v_debito,
		  	   v_credito,
		  	   v_cuenta
		  FROM cobasien
		 WHERE no_remesa = v_no_remesa
		   and renglon   = v_renglon
		   
			select no_reclamo 
			 into _no_reclamo
			 from rectrmae 
			where no_remesa = v_no_remesa
			  and renglon = v_renglon
			  and actualizado = 1;		

              let _monto_pagado2   = 0;	

           select perdida - ( deducible + salvamento + prima_pend )
		     into _monto_pagado2
             from recperdida 
			where no_reclamo =	_no_reclamo	;	  
		   
			  let _monto_pagado   = 0;		   
			  
			select count(*)   
			 into _cantidad
			 from rectrmae 
			where no_reclamo  = _no_reclamo 
			  and cod_tipotran = '004' 
			  and actualizado = 1;				  
			  
				if _cantidad is null then
					let _cantidad = 0;
				end if					  
			   
			select sum(monto)   
			 into _monto_pagado  
			 from rectrmae 
			where no_reclamo  = _no_reclamo 
			  and cod_tipotran = '004' 
			  and cod_tipopago = '003'
			  and actualizado = 1;		   
			  
				if _monto_pagado is null then
					let _monto_pagado = 0;
				end if				  

		-- Insercion / Actualizacion a la tabla temporal tmp_prod

		INSERT INTO tmp_prod(
		cuenta,
		fecha,
		no_recibo,
		no_remesa,
	    debito,
	    credito,
	 	renglon,
		recibi_de,
		reclamo,
		monto_pagado,
		cantidad,
		monto_pagado2
		)
		VALUES(
		v_cuenta,
		v_fecha,
		v_no_recibo,
		v_no_remesa,
		v_debito,
		v_credito,
		v_renglon,
		_recibi_de,
		v_doc_remesa,
		_monto_pagado,
		_cantidad,
		_monto_pagado2
		);

	END FOREACH
END FOREACH;

-- Procesos para Filtros

LET v_filtros = "";

IF a_cuenta <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Cuenta: " ||  TRIM(a_cuenta);

	LET _tipo = sp_sis04(a_cuenta);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

	   UPDATE tmp_prod
	   	  SET seleccionado = 0
		WHERE seleccionado = 1
		  AND cuenta NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

	   UPDATE tmp_prod
	   	  SET seleccionado = 0
		WHERE seleccionado = 1
		  AND cuenta IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

--------------------------------------------------------------------------

--Recorre la tabla temporal y asigna valores a variables de salida

FOREACH WITH HOLD
	SELECT cuenta,
		   fecha,
	 	   no_recibo,
	 	   no_remesa,
	 	   debito,
	 	   credito,
		   recibi_de,
		   reclamo,
		   renglon,
		   monto_pagado,
		   cantidad,
		   monto_pagado2
	  INTO v_cuenta,
	   	   v_fecha,
	   	   v_no_recibo,
	   	   v_no_remesa,
	   	   v_debito,
	   	   v_credito,
		   _recibi_de,
		   v_doc_remesa,
		   v_renglon,
		   _monto_pagado,
		   _cantidad,
		   _monto_pagado2
	  FROM tmp_prod
	 WHERE seleccionado = 1

	 SELECT cta_nombre
	   INTO v_nombre_cuenta
	   FROM cglcuentas
	  WHERE cta_cuenta = v_cuenta;	  	  	  	  
	  

	RETURN    v_cuenta,
	   		  v_fecha,
			  v_no_recibo,
			  v_no_remesa,
			  v_debito,
			  v_credito,
			  v_compania_nombre,
			  v_filtros,
			  v_nombre_cuenta,
			  _recibi_de,
			  v_doc_remesa,
			  _monto_pagado,
			  _cantidad,
			  _monto_pagado2
			  WITH RESUME;

END FOREACH;

DROP TABLE tmp_prod;

END PROCEDURE;