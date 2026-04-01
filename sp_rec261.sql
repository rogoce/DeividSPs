-- Procedimiento que Carga el Listado de Presentacion de Cuenta - Recobros
-- en un Periodo Dado
-- 
-- Creado    : 11/11/2015 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.


DROP PROCEDURE sp_rec261;
--DROP TABLE tmp_pos_recob;
CREATE PROCEDURE "informix".sp_rec261(a_periodo1 CHAR(7), a_periodo2 CHAR(7)) 
			RETURNING   VARCHAR(100), 
						CHAR(18),
						DEC(16,2),
						DEC(16,2),
		            	CHAR(10),
						DATE,
		            	VARCHAR(255),
						VARCHAR(50),
						INT,
						VARCHAR(30),
						VARCHAR(30),
						SMALLINT,
						VARCHAR(50),
						VARCHAR(255);
						

DEFINE v_nombre          VARCHAR(100);
DEFINE v_numrecla        CHAR(18);
DEFINE v_compania_nombre VARCHAR(50);
DEFINE v_filtros         VARCHAR(255);

DEFINE _no_reclamo        CHAR(10);      
DEFINE _cod_cliente       CHAR(10);
DEFINE v_monto_solicitado DEC(16,2);
DEFINE v_monto_pagado     DEC(16,2);
DEFINE v_no_requis        CHAR(10);
DEFINE _no_procede        SMALLINT;
DEFINE v_fecha_recibido   DATE;
DEFINE v_nota             VARCHAR(255);
DEFINE _ajust_interno     CHAR(3);
DEFINE v_ajustador        VARCHAR(50);
DEFINE v_no_cheque        INT;
DEFINE _firma1            VARCHAR(20);
DEFINE _firma2            VARCHAR(20);
DEFINE _fecha_firma1      DATE;
DEFINE _en_firma          SMALLINT;
DEFINE v_firma            VARCHAR(30);
DEFINE v_n_en_firma       VARCHAR(30);

DEFINE _tipo            CHAR(1);

DEFINE _fecha_inic       DATE;
DEFINE _fecha_fin        DATE;

-- Nombre de la Compania
--SET DEBUG FILE TO "sp_rec259.trc";  
--TRACE ON;                                                                 

SET ISOLATION TO DIRTY READ;

LET v_compania_nombre = sp_sis01('001');

CREATE TEMP TABLE tmp_pos_recob(
		nombre               VARCHAR(100) 	NOT NULL,
		numrecla             CHAR(18)  		NOT NULL,
		monto_solicitado     DEC(16,2) 		NOT NULL,
		monto_pagado         DEC(16,2)		DEFAULT 0.00,
		no_requis            CHAR(10),
		fecha_recibido       DATE      		NOT NULL,
		nota                 VARCHAR(255),
		ajustador            VARCHAR(50) 	NOT NULL,
		no_cheque            INT,
		firma                VARCHAR(30),
		n_en_firma           VARCHAR(30),
		no_procede           SMALLINT,
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL
		) WITH NO LOG;   

let _fecha_inic      = MDY(a_periodo1[6,7], 1, a_periodo1[1,4]); 
let _fecha_fin       = sp_sis36(a_periodo2);

FOREACH	

 SELECT	no_reclamo,
        cod_cliente,
		monto_solicitado,
		no_requis,
		no_procede,
		fecha_recibido,
		nota
   INTO	_no_reclamo,
   		_cod_cliente,
		v_monto_solicitado,
        v_no_requis,
        _no_procede,
        v_fecha_recibido,
		v_nota
   FROM recrcsxp
  WHERE fecha_recibido >= _fecha_inic
    AND fecha_recibido <= _fecha_fin
   -- AND no_procede = a_no_procede	
		
	-- Lectura de Reclamos
	
	SELECT numrecla,
	       ajust_interno
	  INTO v_numrecla,
	       _ajust_interno
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;
	 
	SELECT nombre
      INTO v_ajustador
      FROM recajust
     WHERE cod_ajustador = _ajust_interno;  
	 
	-- Lectura de Cliente
	
	SELECT nombre
	  INTO v_nombre
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	-- Lectura de Cheques

	SELECT no_cheque,
		   firma1,
		   firma2,
		   fecha_firma1,
		   en_firma,
		   monto
	  INTO v_no_cheque,
		   _firma1,
		   _firma2,
		   _fecha_firma1,
		   _en_firma,
		   v_monto_pagado
	  FROM chqchmae
	 WHERE no_requis = v_no_requis;

	let v_firma = "";
	 
	let v_n_en_firma = "";
	if _en_firma in(0,4) then
		let v_n_en_firma = "NO ESTA EN FIRMA";
	elif _en_firma = 1 then
		if _fecha_firma1 is null then
			let v_n_en_firma = "EN FIRMA 1 ";
		   select UPPER(descripcion)
			 into v_firma
			 from insuser
			where windows_user = _firma1;
			LET v_n_en_firma = v_n_en_firma || TRIM(v_firma);
		else
			let v_n_en_firma = "EN FIRMA 2";
		   select UPPER(descripcion)
			 into v_firma
			 from insuser
			where windows_user = _firma2;
			LET v_n_en_firma = v_n_en_firma || TRIM(v_firma);
		end if
	elif _en_firma = 2 then
		let v_n_en_firma = "FIRMADO";
	elif _en_firma in(3,5) then
		let v_n_en_firma = "RECHAZADO";
	end if
	

	INSERT INTO tmp_pos_recob(
	nombre,
	numrecla,
	monto_solicitado,
	monto_pagado,
	no_requis,
	fecha_recibido,
	nota,
	ajustador,
	no_cheque,
	firma,
	n_en_firma,
	no_procede
	)
	VALUES(
	v_nombre,      
	v_numrecla,       
	v_monto_solicitado,
	v_monto_pagado,
	v_no_requis,    
	v_fecha_recibido,
	v_nota,
	v_ajustador,
	v_no_cheque,
	v_firma,
	v_n_en_firma,
	_no_procede
	);
END FOREACH;

-- Filtros
LET v_filtros = "";


{IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_pos_recob
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros
				   
		UPDATE tmp_pos_recob
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_cliente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Asegurado: " ||  TRIM(a_cliente);

	LET _tipo = sp_sis04(a_cliente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_pos_recob
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contratante NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros
				   
		UPDATE tmp_pos_recob
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contratante IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF
}

--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT nombre,
		numrecla,
		monto_solicitado,
		monto_pagado,
		no_requis,
		fecha_recibido,
		nota,
		ajustador,
		no_cheque,
		firma,
		n_en_firma,
		no_procede
   INTO v_nombre,      
		v_numrecla,       
		v_monto_solicitado,
		v_monto_pagado,
		v_no_requis,    
		v_fecha_recibido,
		v_nota,
		v_ajustador,
		v_no_cheque,
		v_firma,
		v_n_en_firma,
		_no_procede
   FROM tmp_pos_recob
  WHERE seleccionado = 1
  ORDER BY numrecla

	RETURN 	v_nombre,      
			v_numrecla,       
			v_monto_solicitado,
			v_monto_pagado,
			v_no_requis,    
			v_fecha_recibido,
			v_nota,
			v_ajustador,
			v_no_cheque,
			v_firma,
			v_n_en_firma,
			_no_procede,
		    TRIM(v_compania_nombre),
		    TRIM(v_filtros)
		    WITH RESUME;

END FOREACH

DROP TABLE tmp_pos_recob;
END PROCEDURE;