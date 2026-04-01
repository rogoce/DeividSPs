-- Formulario de Impresion de las Transacciones de Recuperos-- 
-- Creado    : 17/07/2001 - Autor: Marquelda Valdelamar
-- Modificado: 24/04/2002 - Autor: Marquelda Valdelamar

--
DROP PROCEDURE sp_rec53a;

CREATE PROCEDURE "informix".sp_rec53a(
a_compania    CHAR(3),
a_no_recupero CHAR(5),
a_no_tran_rec CHAR(5)
) RETURNING	CHAR(5),       -- no_recupero
            CHAR(18), 	   -- Reclamo
			CHAR(5),       -- no_transaccion
			CHAR(50),	   -- Abogado_antes
			CHAR(50),      -- Abogado_despues
			CHAR(50), 	   -- Coaseguro_antes
			CHAR(50),      -- Coaseguro_despues
			DATE,          -- fecha de la transaccion
			CHAR(50),      -- nombre del tipo de cambio
  			DATE,     	   -- Fecha antes   
			DATE,     	   -- Fecha despues 
			CHAR(50),      -- estatus_recobro_antes
			CHAR(50),      -- estatus_recobro_despues
			CHAR(50),      -- estatus_abogado_antes
			CHAR(50),      -- estatus_abogado_despues
			DECIMAL(16,2), -- monto_antes
			DECIMAL(16,2), -- monto_despues
			CHAR(8),       -- usuario de adicion
	  		DATE,          -- fecha de adicion
			CHAR(100), 	   -- Nombre Tercero    	   	
			CHAR(50),      -- nombre_cliente
			CHAR(20),      -- no_documento
			DECIMAL(16,2), -- pagado_reclamo
			DECIMAL(16,2), -- monto_arreglo
			DECIMAL(16,2), -- monto_recuperado
			DECIMAL(16,2), -- saldo
			CHAR(100);     -- nombre_compania

DEFINE _cod_coasegur            CHAR(3);
DEFINE _cod_abogado_ant         CHAR(3);
DEFINE _cod_abogado_des         CHAR(3);
DEFINE _cod_coasegur_ant        CHAR(3);
DEFINE _cod_coasegur_des		CHAR(3);
DEFINE _estatus_rec_ant         INTEGER;
DEFINE _estatus_rec_des         INTEGER;
DEFINE _estatus_abo_ant         CHAR(1);
DEFINE _estatus_abo_des         CHAR(1);
DEFINE _no_reclamo              CHAR(10);
DEFINE _no_poliza               CHAR(10);
DEFINE _cod_contratante         CHAR(10);
DEFINE _tipo_cambio             INTEGER;


DEFINE v_numrecla               CHAR(18);
DEFINE v_nombre_coasegur_ant    CHAR(50); 
DEFINE v_nombre_coasegur_des    CHAR(50); 
DEFINE v_nombre_abo_ant         CHAR(50); 
DEFINE v_nombre_abo_des         CHAR(50); 
DEFINE v_fecha_tran             DATE;
DEFINE v_tipo_cambio            CHAR(50);
DEFINE v_fecha_antes		    DATE;
DEFINE v_fecha_despues          DATE;
DEFINE v_estatus_rec_ant        CHAR(50);
DEFINE v_estatus_rec_des	    CHAR(50);
DEFINE v_estatus_abo_ant        CHAR(50);
DEFINE v_estatus_abo_des 	    CHAR(50);
DEFINE v_monto_antes            DECIMAL(16,2);
DEFINE v_monto_despues		    DECIMAL(16,2);
DEFINE v_nombre_tercero         CHAR(100);
DEFINE v_user_added             CHAR(8);
DEFINE v_date_added             DATE;
DEFINE v_nombre_cliente         CHAR(50);
DEFINE v_no_documento           CHAR(20);
DEFINE v_compania_nombre        CHAR(100);

DEFINE v_pagado_reclamo         DECIMAL(16,2);
DEFINE v_monto_recuperado       DECIMAL(16,2);
DEFINE v_monto_arreglo          DECIMAL(16,2);
DEFINE v_saldo                  DECIMAL(16,2);
DEFINE v_monto_pagado           DECIMAL(16,2);

LET v_monto_pagado = 0.00;
LET v_saldo        = 0.00;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

SET ISOLATION TO DIRTY READ;

 SELECT cod_abogado_ant,
        cod_abogado_des,
		cod_coasegur_ant,
		cod_coasegur_des,
	   	fecha_tran,
		tipo_cambio,
	    fecha_antes,
	    fecha_despues,
		estatus_rec_ant,
		estatus_rec_des,
		estatus_abo_ant,
		estatus_abo_des,
		monto_antes,
		monto_despues,
		user_added,
	   	date_added
  INTO  _cod_abogado_ant,
        _cod_abogado_des,
  		_cod_coasegur_ant,
  		_cod_coasegur_des,
  	   	v_fecha_tran,
		_tipo_cambio,
  	   	v_fecha_antes,
  	    v_fecha_despues,
		_estatus_rec_ant,
		_estatus_rec_des,
		_estatus_abo_ant,
		_estatus_abo_des,
		v_monto_antes,
		v_monto_despues,
		v_user_added,
	   	v_date_added
  FROM  rectrare
  WHERE no_recupero = a_no_recupero
    AND no_tran_rec = a_no_tran_rec;
   
  SELECT no_reclamo,
         numrecla,
		 nombre_tercero,
		 pagado_reclamo,
		 monto_arreglo
		-- monto_recuperado
   INTO	 _no_reclamo,
         v_numrecla,
		 v_nombre_tercero,
		 v_pagado_reclamo,
		 v_monto_arreglo
		-- v_monto_recuperado
    FROM recrecup
   WHERE no_recupero = a_no_recupero;
  
  	SELECT no_poliza
	  INTO _no_poliza
	  FROM recrcmae
	 WHERE no_reclamo= _no_reclamo;

-- Nombre del Cliente
	SELECT cod_contratante,
	       no_documento
	  INTO _cod_contratante,
	       v_no_documento
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO v_nombre_cliente
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;

-- Nombre del abogado
	SELECT nombre_abogado
	  INTO v_nombre_abo_ant
	  FROM recaboga
	 WHERE cod_abogado = _cod_abogado_ant;

	SELECT nombre_abogado
	  INTO v_nombre_abo_des
	  FROM recaboga
	 WHERE cod_abogado = _cod_abogado_des;

 --Compania Coaseguradora
	SELECT nombre
	  INTO v_nombre_coasegur_ant
	  FROM emicoase
	 WHERE cod_coasegur = _cod_coasegur_ant;

	SELECT nombre
	  INTO v_nombre_coasegur_des
	  FROM emicoase
	 WHERE cod_coasegur = _cod_coasegur_des;

--Calculo de Recuperado y monto
    SELECT SUM (monto)
	  INTO v_monto_recuperado
	  FROM rectrmae a, rectitra b
     WHERE a.no_reclamo = _no_reclamo
	   AND a.cod_tipotran = b.cod_tipotran
       AND a.actualizado = 1
	   AND b.tipo_transaccion = 6;

--Calculo del Total pagado
{    SELECT SUM (monto)
	  INTO v_monto_pagado
	  FROM rectrmae a, rectitra b
     WHERE a.no_reclamo = _no_reclamo
	   AND a.cod_tipotran = b.cod_tipotran
       AND a.actualizado = 1
	   AND b.tipo_transaccion = 4;}

	LET v_monto_recuperado = v_monto_recuperado * -1;

	IF v_monto_recuperado IS NULL THEN
	 LET v_monto_recuperado = 0.00;
	END IF

	LET v_saldo = v_monto_arreglo - v_monto_recuperado;

--Tipo de Cambio
	IF _tipo_cambio = 1 THEN
		LET v_tipo_cambio = 'Estatus de Recobro';
	ELIF _tipo_cambio = 2 THEN
	    LET v_tipo_cambio = 'Compania de Subrogacion';
	ELIF _tipo_cambio = 3 THEN
	    LET v_tipo_cambio = 'Abogado';
	ELIF _tipo_cambio = 4 THEN
	    LET v_tipo_cambio = 'Fecha de Resolucion';
	ELIF _tipo_cambio = 5 THEN
	    LET v_tipo_cambio = 'Fecha Prescripcion';
	ELIF _tipo_cambio = 6 THEN
	    LET v_tipo_cambio = 'Fecha de Envio de Documento';
	ELIF _tipo_cambio = 7 THEN
	    LET v_tipo_cambio = 'Fecha de Audiencia';
	ELIF _tipo_cambio = 8 THEN
	    LET v_tipo_cambio = 'Estatus de Abogado';
	ELSE  
		LET v_tipo_cambio = 'Monto del Arreglo';
	END IF

--Estatus del Abogando Anterior
	IF _estatus_abo_ant = 'N'  THEN
		 LET v_estatus_abo_ant = 'No Aplica';
	ELIF _estatus_abo_ant = 'I' THEN
		 LET v_estatus_abo_ant = 'Investigacion';
	ELIF _estatus_abo_ant = 'D' THEN
		 LET v_estatus_abo_ant = 'Demanda';
	ELSE
		 LET v_estatus_abo_ant = 'Secuestro';
	END IF

--Estatus del Abogado Destino
	IF _estatus_abo_des = 'D' THEN
		LET v_estatus_abo_des = 'Demanda';
	ELIF _estatus_abo_des = 'N' THEN
		LET v_estatus_abo_des = 'No Aplica';
	ELIF _estatus_abo_des = 'I' THEN
		LET v_estatus_abo_des = 'Investigacion';
	ELSE
		LET v_estatus_abo_des = 'Secuestro';
	END IF

--Estatus del Recobro Anterior
	IF _estatus_rec_ant = 1 THEN
		 LET v_estatus_rec_ant = 'Tramite';
	ELIF _estatus_rec_ant  = 2 THEN
		 LET v_estatus_rec_ant = 'Investigacion';
	ELIF _estatus_rec_ant  = 3 THEN
		 LET v_estatus_rec_ant = 'Subrogacion';
	ELIF _estatus_rec_ant  = 4 THEN
		 LET v_estatus_rec_ant = 'Abogado'; 
	ELIF _estatus_rec_ant  = 5 THEN
		 LET v_estatus_rec_ant = 'Arreglo de Pago'; 
	ELIF _estatus_rec_ant  = 6 THEN
		 LET v_estatus_rec_ant = 'Infructuoso'; 
	ELIF _estatus_rec_ant  = 7 THEN
		 LET v_estatus_rec_ant = 'Recuperado';
	ELSE
		 LET v_estatus_rec_ant = NULL; 
	END  IF

--Estatus del Recobro Despues
	IF _estatus_rec_des = 1 THEN
		 LET v_estatus_rec_des = 'Tramite';
	ELIF _estatus_rec_des  = 2 THEN
		 LET v_estatus_rec_des = 'Investigacion';
	ELIF _estatus_rec_des  = 3 THEN
		 LET v_estatus_rec_des = 'Subrogacion';
	ELIF _estatus_rec_des  = 4 THEN
		 LET v_estatus_rec_des = 'Abogado'; 
	ELIF _estatus_rec_des  = 5 THEN
		 LET v_estatus_rec_des = 'Arreglo de Pago'; 
	ELIF _estatus_rec_des  = 6 THEN
		 LET v_estatus_rec_des = 'Infructuoso'; 
	ELIF _estatus_rec_des = 7 THEN 
	 	 LET v_estatus_rec_des = 'Recuperado'; 
	ELSE 
		LET v_estatus_rec_des = NULL;
	END  IF

RETURN	    a_no_recupero,
            v_numrecla,
			a_no_tran_rec,
			v_nombre_abo_ant,
			v_nombre_abo_des,
			v_nombre_coasegur_ant,
			v_nombre_coasegur_des,
    		v_fecha_tran,
			v_tipo_cambio,
		   	v_fecha_antes,
		   	v_fecha_despues,
			v_estatus_rec_ant,
			v_estatus_rec_des,
			v_estatus_abo_ant,
			v_estatus_abo_des,
			v_monto_antes,
			v_monto_despues,
			v_user_added,
		   	v_date_added,
			v_nombre_tercero,
			v_nombre_cliente,
			v_no_documento,
			v_pagado_reclamo,
			v_monto_arreglo,
			v_monto_recuperado,
			v_saldo,
			v_compania_nombre
			WITH RESUME;
END PROCEDURE;

