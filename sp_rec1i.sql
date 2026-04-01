-- Reporte de Incurrido Neto Total por Corredor
--
-- Creado    : 04/08/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 21/08/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_sp_rec01i_dw4 - DEIVID, S.A.

DROP PROCEDURE sp_rec01i;

--SET DEBUG FILE TO "rec1i.txt";
--TRACE ON;
CREATE PROCEDURE "informix".sp_rec01i(
a_compania CHAR(3),
a_agencia CHAR(3),
a_periodo1 CHAR(7),
a_periodo2 CHAR(7),
a_sucursal CHAR(255) DEFAULT "*",
a_ramo CHAR(255) DEFAULT "*",
a_agente CHAR(255) DEFAULT "*", 
a_ajustador CHAR(255) DEFAULT "*")
 RETURNING DECIMAL(16,2),
 DECIMAL(16,2),
 DECIMAL(16,2),
 DECIMAL(16,2),
 DECIMAL(16,2),
 DECIMAL(16,2),
 CHAR(50),
 SMALLINT,
 CHAR(50),
 CHAR(255);

DEFINE v_pagado_bruto    DECIMAL(16,2);
DEFINE v_pagado_neto     DECIMAL(16,2);
DEFINE v_reserva_bruto   DECIMAL(16,2);
DEFINE v_reserva_neto    DECIMAL(16,2);
DEFINE v_incurrido_bruto DECIMAL(16,2);
DEFINE v_incurrido_neto  DECIMAL(16,2);
DEFINE v_agente_nombre   CHAR(50);
DEFINE v_compania_nombre CHAR(50);
DEFINE v_periodo         CHAR(7);
DEFINE v_filtros         CHAR(255);

DEFINE _no_poliza        CHAR(10);
DEFINE _cod_agente       CHAR(5);
DEFINE _porc_partic      DEC(5,2);
DEFINE _pagado_bruto     DECIMAL(16,2);
DEFINE _pagado_neto      DECIMAL(16,2);
DEFINE _reserva_bruto    DECIMAL(16,2);
DEFINE _reserva_neto     DECIMAL(16,2);
DEFINE _incurrido_bruto  DECIMAL(16,2);
DEFINE _incurrido_neto   DECIMAL(16,2);
DEFINE _tipo             CHAR(1);
DEFINE v_cantidad        SMALLINT;

-- Nombre de la Compania



LET v_compania_nombre = sp_sis01(a_compania);

CREATE TEMP TABLE tmp_agente(
		cod_agente			CHAR(5),
		no_poliza       	CHAR(20),
		pagado_bruto		DEC(16,2),	
		pagado_neto			DEC(16,2),	
		reserva_bruto		DEC(16,2),
		reserva_neto		DEC(16,2),
		incurrido_bruto		DEC(16,2),	
		incurrido_neto		DEC(16,2),	
		agente_nombre		CHAR(50),
		cantidad            SMALLINT,
	   	seleccionado        SMALLINT  DEFAULT 1 NOT NULL,
	    PRIMARY KEY (cod_agente)) WITH NO LOG;


-- Cargar el Incurrido

LET v_filtros = sp_rec01(
a_compania,
a_agencia, 
a_periodo1,
a_periodo2,
a_sucursal,
'*', 
a_ramo,
a_agente,
a_ajustador, 
'*', 
'*'
); 


FOREACH
 SELECT no_poliza,
        pagado_bruto,
 		pagado_neto,
	    reserva_bruto,
	    reserva_neto,
	    incurrido_bruto,
	    incurrido_neto
  INTO	_no_poliza,	
   		_pagado_bruto,
   		_pagado_neto, 
	    _reserva_bruto,	
	    _reserva_neto,
	    _incurrido_bruto,	
	    _incurrido_neto
   FROM tmp_sinis 
 
 
	FOREACH 
	 SELECT cod_agente,porc_partic_agt
	   INTO _cod_agente,_porc_partic
	   FROM emipoagt
	  WHERE no_poliza = _no_poliza

		SELECT nombre
		  INTO v_agente_nombre
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

		LET v_pagado_bruto    = _pagado_bruto    * _porc_partic / 100;
		LET v_pagado_neto     = _pagado_neto     * _porc_partic / 100;
		LET v_reserva_bruto   = _reserva_bruto   * _porc_partic / 100;
		LET v_reserva_neto    = _reserva_neto    * _porc_partic / 100;
		LET v_incurrido_bruto = _incurrido_bruto * _porc_partic / 100;
		LET v_incurrido_neto  = _incurrido_neto  * _porc_partic / 100;

        BEGIN 
		    ON EXCEPTION IN (-239)
			 UPDATE tmp_agente
			        SET pagado_bruto    = pagado_bruto + v_pagado_bruto,
					    pagado_neto     = pagado_neto  + v_pagado_neto,
						reserva_bruto   = reserva_bruto + v_reserva_bruto,
						reserva_neto    = reserva_neto  + v_reserva_neto,
						incurrido_bruto = incurrido_bruto + v_incurrido_bruto,
						incurrido_neto  = incurrido_neto  + v_incurrido_neto,
						cantidad        = cantidad + 1
				   WHERE cod_agente     = _cod_agente;
	
			END EXCEPTION;

	   INSERT INTO tmp_agente(
		cod_agente,	
		pagado_bruto,
		pagado_neto,	
		reserva_bruto,	
		reserva_neto,
		incurrido_bruto,	
		incurrido_neto,
		agente_nombre,
		cantidad,
		seleccionado)
		VALUES(
		_cod_agente,
		v_pagado_bruto,
		v_pagado_neto,	
		v_reserva_bruto,	
		v_reserva_neto,
		v_incurrido_bruto,	
		v_incurrido_neto,
	   	v_agente_nombre,
	   	1,
	   	1);	
	
	   END;
	END FOREACH

END FOREACH

-- Filtros para Agente

IF a_agente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Agente: " ||  TRIM(a_agente);

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_agente
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros
	
		UPDATE tmp_agente
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

FOREACH 
 SELECT pagado_bruto,
		pagado_neto,	
		reserva_bruto,	
		reserva_neto,
		incurrido_bruto,	
		incurrido_neto,
	   	agente_nombre,
	   	cantidad
	
   INTO	v_pagado_bruto,
		v_pagado_neto,	
		v_reserva_bruto,	
		v_reserva_neto,
		v_incurrido_bruto,	
		v_incurrido_neto,
		v_agente_nombre,
		v_cantidad
	
   FROM tmp_agente
  WHERE seleccionado = 1
  ORDER BY agente_nombre

		RETURN v_pagado_bruto,	
			   v_pagado_neto,	
			   v_reserva_bruto, 
			   v_reserva_neto,
			   v_incurrido_bruto,	
			   v_incurrido_neto,
			   v_agente_nombre,
			   v_cantidad,
			   v_compania_nombre,
			   v_filtros
			   WITH RESUME;
END FOREACH

DROP TABLE tmp_sinis;
DROP TABLE tmp_agente;

END PROCEDURE;
