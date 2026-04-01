-- Procedimiento que Carga de Subrograciones por Cobrar a Compania Aseguradora
-- a una Fecha Dada
-- 
-- Creado    : 17/08/2000 - Autor: Amado Perez Mendoza 
-- Modificado: 17/08/2000 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec10;
--DROP TABLE tmp_subrogacion;
CREATE PROCEDURE "informix".sp_rec10(a_compania CHAR(3), a_agencia CHAR(3), a_fecha DATE, a_aseguradora CHAR(255) DEFAULT "*", a_cliente CHAR(255) DEFAULT "*") 
			RETURNING   CHAR(100),
		    	        CHAR(18),
		            	DATE,
		            	CHAR(50),
		               	DEC(16,2),
						CHAR(50),
						CHAR(255),
						DECIMAL(16,2),
						CHAR(10),
						DATE;   -- fecha_recupero add:10/01/17:Henry
						

DEFINE v_asegurado     	  	 CHAR(100);
DEFINE v_numrecla         	 CHAR(18);
DEFINE v_fecha_envio	     DATE;
DEFINE v_coaseguradora       CHAR(50);
DEFINE v_monto_recuperado    DEC(16,2);
DEFINE v_compania_nombre     CHAR(50);
DEFINE v_filtros             CHAR(255);

DEFINE _cod_ramo        CHAR(3);
DEFINE _no_reclamo      CHAR(10);      
DEFINE _no_poliza       CHAR(10);
DEFINE _cod_cliente		CHAR(10);
DEFINE _cod_coasegur    CHAR(3);
DEFINE _tipo			CHAR(1);
DEFINE _mto_rec			DEC(16,2);
define _saldo           DEC(16,2);
DEFINE _no_recupero     CHAR(10);
define _fecha_recupero   date;

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);


CREATE TEMP TABLE tmp_subrogacion(
		asegurado            CHAR(100) NOT NULL,
		numrecla             CHAR(18)  NOT NULL,
		fecha_envio 		 DATE,	   
		monto_recuperado     DEC(16,2),
		coaseguradora        CHAR(50),
		cod_coasegur         CHAR(3),
		cod_cliente          CHAR(10),
		no_recupero          CHAR(10),
		fecha_recupero       DATE,
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL
		) WITH NO LOG;   
FOREACH	

 SELECT no_reclamo,
		fecha_envio,
		monto_arreglo,
		cod_coasegur,
		no_recupero,
		fecha_recupero
   INTO _no_reclamo,
		v_fecha_envio,
		v_monto_recuperado,
		_cod_coasegur,
		_no_recupero,
		_fecha_recupero
   FROM recrecup
  WHERE cod_compania    = a_compania
    AND estatus_recobro = 3				--subrogacion
    AND fecha_recupero <= a_fecha

   	-- Lectura de Reclamos

 	SELECT numrecla,
           no_poliza
   	  INTO v_numrecla,
           _no_poliza
      FROM recrcmae
     WHERE no_reclamo = _no_reclamo 
	   AND actualizado = 1;

	-- Lectura de Polizas

	SELECT cod_ramo,
		   cod_contratante
	  INTO _cod_ramo,
		   _cod_cliente
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	-- Lectura de Cliente

	SELECT nombre
	  INTO v_asegurado
 	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

    -- Lectura de Coaseguradora
	SELECT nombre
	  INTO v_coaseguradora
	  FROM emicoase
	 WHERE cod_coasegur = _cod_coasegur;


	INSERT INTO tmp_subrogacion(
	asegurado,          
	numrecla,           
	fecha_envio, 		
	monto_recuperado,   
	coaseguradora,
	cod_coasegur,
	cod_cliente,
	no_recupero,
	fecha_recupero
	)
	VALUES(
	v_asegurado,     	  	
	v_numrecla,         	
	v_fecha_envio,	    
	v_monto_recuperado,   
	v_coaseguradora,
	_cod_coasegur,
	_cod_cliente,
	_no_recupero,
	_fecha_recupero
	);
END FOREACH;

-- Filtros
LET v_filtros = "";

IF a_aseguradora <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Aseguradora: " ||  TRIM(a_aseguradora);

	LET _tipo = sp_sis04(a_aseguradora);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_subrogacion
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_coasegur NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros
				   
		UPDATE tmp_subrogacion
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_coasegur IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_cliente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Cliente: " ||  TRIM(a_cliente);

	LET _tipo = sp_sis04(a_cliente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_subrogacion
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cliente NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros
				   
		UPDATE tmp_subrogacion
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cliente IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF


--Recorre la tabla temporal y asigna valores a variables de salida
FOREACH WITH HOLD
 SELECT asegurado,           
 		numrecla,           
 		fecha_envio, 		
 		monto_recuperado,   
		coaseguradora,
		no_recupero,
		fecha_recupero
   INTO v_asegurado,     	  
    	v_numrecla,         	
    	v_fecha_envio,	    
    	v_monto_recuperado, 
    	v_coaseguradora,
        _no_recupero,
        _fecha_recupero
   FROM tmp_subrogacion
  WHERE seleccionado = 1
  ORDER BY coaseguradora, numrecla
  
  select no_reclamo
    into _no_reclamo
	from recrcmae
   where numrecla = v_numrecla;
 
  let _mto_rec = 0; 
 
  SELECT sum(rectrmae.monto) * -1
    INTO _mto_rec
    FROM rectrmae, rectitra  
   WHERE rectitra.cod_tipotran = rectrmae.cod_tipotran 
     AND rectrmae.no_reclamo = _no_reclamo 
	 AND rectrmae.actualizado = 1
	 AND rectitra.tipo_transaccion = 6;

	 if _mto_rec is null then
		let _mto_rec = 0;
	end if
    let _saldo = 0;	
    LET _saldo = v_monto_recuperado - _mto_rec;
	
	RETURN v_asegurado,     	  	 	
		   v_numrecla,         	
		   v_fecha_envio,
		   v_coaseguradora,	    
		   v_monto_recuperado,   
		   v_compania_nombre, 
		   v_filtros,
           _saldo,
           _no_recupero,
           _fecha_recupero		   
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_subrogacion;
END PROCEDURE;