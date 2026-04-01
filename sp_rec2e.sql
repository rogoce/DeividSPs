-- Reporte de Reclamos Pendientes por Contrato de Reaseguro
-- 
-- Creado    : 25/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 25/08/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 27/06/2002 - Autor: Amado Perez M. (Se incluye filtro de agente)
--
-- SIS v.2.0 - d_recl_sp_rec02e_dw5 - DEIVID, S.A.

DROP PROCEDURE sp_rec02e;

CREATE PROCEDURE "informix".sp_rec02e(a_compania CHAR(03),a_agencia CHAR(03),a_periodo CHAR(7),a_sucursal CHAR(255) DEFAULT "*",a_ajustador CHAR(255) DEFAULT "*", a_ramo CHAR(255) DEFAULT "*",a_contrato CHAR(255) DEFAULT "*",a_agente CHAR(255) DEFAULT "*")
RETURNING CHAR(18),      -- Reclamo
          CHAR(100),     -- Cliente
          CHAR(20),      -- Poliza
          DATE,          -- Fecha Siniestro
          DATE,          -- Ultima Fecha
          DECIMAL(16,2), -- Pagado Cedido
          DECIMAL(16,2), -- Reserva Cedido
          DECIMAL(16,2), -- Incurrido Cedido
          CHAR(50),      -- Ramo
          CHAR(50), 	 -- Contrato
		  CHAR(50),      -- Compania
		  CHAR(255),
		  integer;      -- Filtros

DEFINE v_filtros          CHAR(255);
DEFINE _tipo              CHAR(1);

DEFINE v_doc_reclamo      CHAR(18);     
DEFINE v_cliente_nombre   CHAR(100);    
DEFINE v_doc_poliza       CHAR(20);     
DEFINE v_fecha_siniestro  DATE;         
DEFINE v_ultima_fecha     DATE;         
DEFINE v_pagado_cedido    DECIMAL(16,2);
DEFINE v_reserva_cedido   DECIMAL(16,2);
DEFINE v_incurrido_cedido DECIMAL(16,2);
DEFINE v_ramo_nombre      CHAR(50);     
DEFINE v_contrato_nombre  CHAR(50);     
DEFINE v_compania_nombre  CHAR(50);     

DEFINE _no_reclamo        CHAR(10);     
DEFINE _no_poliza         CHAR(10);     
DEFINE _cod_ramo          CHAR(3);      
DEFINE _cod_contrato      CHAR(5);      
DEFINE _cod_cliente       CHAR(10);     
DEFINE _periodo           CHAR(7);      
DEFINE _tipo_contrato     SMALLINT;     
DEFINE _porc_reas         DECIMAL;      

DEFINE _pagado_bruto      DECIMAL(16,2);
DEFINE _reserva_bruto     DECIMAL(16,2);
DEFINE _incurrido_bruto   DECIMAL(16,2);
define v_serie			  integer;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania);

-- Cargar el Incurrido

CALL sp_rec02(
a_compania, 
a_agencia, 
a_periodo,
a_sucursal,
a_ajustador,
'*',
a_ramo,
a_agente
) RETURNING v_filtros; 

-- Tabla Temporal para los Contratos

CREATE TEMP TABLE tmp_contrato1(
		cod_contrato		 CHAR(5)   NOT NULL,
		contrato_nombre      CHAR(50)  NOT NULL,
		no_reclamo           CHAR(10)  NOT NULL,
		no_poliza            CHAR(10)  NOT NULL,
		cod_ramo             CHAR(3)   NOT NULL,
		periodo              CHAR(7)   NOT NULL,
		numrecla             CHAR(18)  NOT NULL,
		ultima_fecha         DATE      NOT NULL,
		pagado_bruto         DEC(16,2) NOT NULL,
		reserva_bruto        DEC(16,2) NOT NULL,
		incurrido_bruto      DEC(16,2) NOT NULL,
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL,
		PRIMARY KEY (cod_contrato, no_reclamo)
		) WITH NO LOG; 


SET ISOLATION TO DIRTY READ;

FOREACH 
 SELECT no_reclamo,		
 		no_poliza,			
 		pagado_bruto, 		
	    reserva_bruto, 	
	    incurrido_bruto,	
		cod_ramo,		
		periodo,
		numrecla,
		ultima_fecha
   INTO	_no_reclamo, 		
   		_no_poliza,	   	
   		_pagado_bruto, 		
	    _reserva_bruto,		
	    _incurrido_bruto,	
		_cod_ramo,			
		_periodo,
		v_doc_reclamo,
		v_ultima_fecha
   FROM tmp_sinis
  WHERE seleccionado = 1  

	-- Informacion de Reaseguro para Sacar la Distribucion de
	-- los contratos

	FOREACH
	 SELECT porc_partic_suma,
		    cod_contrato	
	   INTO _porc_reas,
		    _cod_contrato	
	   FROM recreaco
	  WHERE no_reclamo = _no_reclamo

		SELECT tipo_contrato
		  INTO _tipo_contrato
		  FROM reacomae
		 WHERE cod_contrato = _cod_contrato;

		IF _tipo_contrato <> 1 AND  -- Retencion
		   _tipo_contrato <> 3 THEN	-- Facultativos

			IF _porc_reas IS NULL THEN
				LET _porc_reas = 0;
			END IF

			LET v_pagado_cedido    = _pagado_bruto    * _porc_reas / 100;
			LET v_reserva_cedido   = _reserva_bruto   * _porc_reas / 100;
			LET v_incurrido_cedido = _incurrido_bruto * _porc_reas / 100;


            SELECT nombre
	          INTO v_contrato_nombre
	          FROM reacomae
        	 WHERE cod_contrato = _cod_contrato;

			INSERT INTO tmp_contrato1(
			cod_contrato,
			contrato_nombre,
			no_reclamo,           
			no_poliza,           
			cod_ramo,            
			periodo,             
			numrecla,            
			ultima_fecha,        
			pagado_bruto,        
			reserva_bruto,       
			incurrido_bruto     
			)
			VALUES(
			_cod_contrato,
			v_contrato_nombre,
			_no_reclamo,           
			_no_poliza,           
			_cod_ramo,            
			_periodo,             
			v_doc_reclamo,            
			v_ultima_fecha,        
			v_pagado_cedido,        
			v_reserva_cedido,       
			v_incurrido_cedido     
			);

		END IF

	END FOREACH

END FOREACH

--  Filtros de los Contratos

IF a_contrato <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Contrato: " ||  TRIM(a_sucursal);

	LET _tipo = sp_sis04(a_contrato);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contrato NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contrato IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

FOREACH
SELECT
	cod_contrato,
	contrato_nombre,
	no_reclamo,           
	no_poliza,           
	cod_ramo,            
	periodo,             
	numrecla,            
	ultima_fecha,        
	pagado_bruto,        
	reserva_bruto,       
	incurrido_bruto     
INTO
	_cod_contrato,
	v_contrato_nombre,
	_no_reclamo,           
	_no_poliza,           
	_cod_ramo,            
	_periodo,             
	v_doc_reclamo,            
	v_ultima_fecha,        
	v_pagado_cedido,        
	v_reserva_cedido,       
	v_incurrido_cedido     
 FROM tmp_contrato1
WHERE seleccionado = 1
ORDER BY contrato_nombre,cod_ramo,numrecla

   
	SELECT fecha_siniestro
	  INTO v_fecha_siniestro
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT no_documento,
		   cod_contratante	
	  INTO v_doc_poliza,
	       _cod_cliente
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO v_cliente_nombre		
	  FROM cliclien 
	 WHERE cod_cliente = _cod_cliente;

	SELECT serie
	  INTO v_serie
	  FROM reacomae 
	 WHERE cod_contrato = _cod_contrato;

	RETURN v_doc_reclamo,
	 	   v_cliente_nombre, 	
	 	   v_doc_poliza,		
	 	   v_fecha_siniestro, 
		   v_ultima_fecha,
		   v_pagado_cedido,		
		   v_reserva_cedido,  	
		   v_incurrido_cedido,	
		   v_ramo_nombre,
		   v_contrato_nombre,
		   v_compania_nombre,
		   v_filtros,
		   v_serie
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_sinis;
DROP TABLE tmp_contrato1;

END PROCEDURE;
