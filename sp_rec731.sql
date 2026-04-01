-- Procedimiento para mostrar los reportes por reclamos en un periodo determinado. 
-- Creado    : 06/03/2015 - Autor: Jaime Chevalier
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rec731;

CREATE PROCEDURE "informix".sp_rec731(a_compania CHAR(3), periodo_ini CHAR(7), periodo_fin CHAR(7), a_evento CHAR(255) DEFAULT "*") 
			RETURNING   CHAR(3),      --COD EVENTO
			            char(50),     --NOMBRE EVENTO
			            CHAR(18),     --NUMRECLA
			            CHAR(20),     --NO DOCUMENTO
			            VARCHAR(100), --ASEGURADO
						DATE,	      --FECHA SINIESTRO
						DATE,	      --FECHA RECLAMO
						SMALLINT,	  --ESTATUS DE AUDIENCIA
						VARCHAR(20),  --ESTATUS DE AUDIENCIA
			  		    CHAR(50),     --COMPAÑIA
						CHAR(255),
						DEC(16,2),
						DEC(16,2),
						DEC(16,2),
						DEC(16,2),
						DEC(16,2),
						DEC(16,2);
						
DEFINE v_numrecla     	   CHAR(18);
DEFINE v_no_documento	   CHAR(20);
DEFINE _cod_asegurado	   CHAR(10);
DEFINE v_fecha_siniestro   DATE;	 	
DEFINE v_fecha_reclamo	   DATE;  	
DEFINE v_estatus_audiencia SMALLINT;
DEFINE _cod_sucursal	   CHAR(3);
DEFINE v_compania_nombre   CHAR(50); 
DEFINE v_asegurado    	   VARCHAR(100);
DEFINE v_desc_estatus      VARCHAR(20);
DEFINE v_filtros           CHAR(255);
DEFINE v_codigo            CHAR(10);
DEFINE v_saber		       CHAR(3);
DEFINE _tipo               CHAR(1);
DEFINE v_cod_evento        CHAR(3);
DEFINE v_nombre_evento     CHAR(50);
DEFINE _filtros            VARCHAR(255);
DEFINE _pagado_bruto	   DEC(16,2);
DEFINE _pagado_neto		   DEC(16,2);
DEFINE _reserva_bruto		DEC(16,2);
DEFINE _reserva_neto		DEC(16,2);
DEFINE _incurrido_bruto		DEC(16,2);
DEFINE _incurrido_neto		DEC(16,2);

CREATE TEMP TABLE tmp_reclamo_evento(
		cod_evento        CHAR(3),
		numrecla     	  CHAR(18),
		no_documento	  CHAR(20),
		cod_asegurado	  CHAR(10),			
		fecha_siniestro   DATE,	 	
		fecha_reclamo	  DATE,  	
		estatus_audiencia SMALLINT,
		cod_sucursal	  CHAR(3),
		seleccionado      SMALLINT DEFAULT 1 NOT NULL,
		pagado_bruto	  DEC(16,2),
		pagado_neto	      DEC(16,2),
		reserva_bruto	  DEC(16,2),
		reserva_neto	  DEC(16,2),
		incurrido_bruto   DEC(16,2),
		incurrido_neto	  DEC(16,2)		
		) WITH NO LOG;

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

LET v_asegurado = "";
LET v_desc_estatus = "";

call sp_rec01(a_compania, '001', periodo_ini, periodo_fin) returning _filtros;

let _pagado_bruto	 = 0;
let _pagado_neto	 = 0;
let _reserva_bruto	 = 0;
let _reserva_neto	 = 0;
let _incurrido_bruto = 0;
let _incurrido_neto	 = 0;

FOREACH
  SELECT cod_evento,
         numrecla,
         no_documento,
		 cod_asegurado,
		 fecha_siniestro,
		 fecha_reclamo,
		 estatus_audiencia,
		 cod_sucursal
	INTO v_cod_evento,
	     v_numrecla,	
		 v_no_documento,	  	
		 _cod_asegurado,	  		  
		 v_fecha_siniestro, 
		 v_fecha_reclamo,	  	
		 v_estatus_audiencia,
		 _cod_sucursal
	FROM recrcmae
   WHERE actualizado = 1
     AND periodo >= periodo_ini
     AND periodo <= periodo_fin
   ORDER BY 2

   select sum(pagado_bruto),
          sum(pagado_neto),
		  sum(reserva_bruto),
		  sum(reserva_neto),
		  sum(incurrido_bruto),
		  sum(incurrido_neto)
	 into _pagado_bruto,
          _pagado_neto,
	      _reserva_bruto,
          _reserva_neto,
          _incurrido_bruto,
		  _incurrido_neto
	 from tmp_sinis
	where seleccionado = 1
      and numrecla     = v_numrecla;	

 
	INSERT INTO tmp_reclamo_evento(
	cod_evento,
	numrecla,
	no_documento,
	cod_asegurado,			
	fecha_siniestro,	 	
	fecha_reclamo,  	
	estatus_audiencia,
	cod_sucursal,
    pagado_bruto,
    pagado_neto,
	reserva_bruto,
	reserva_neto,
	incurrido_bruto,
	incurrido_neto
	)
	VALUES(
	v_cod_evento,
	v_numrecla,     	  	
	v_no_documento,	  	
	_cod_asegurado,	  	 
	v_fecha_siniestro, 	
	v_fecha_reclamo,	  	
	v_estatus_audiencia,
	_cod_sucursal,
	_pagado_bruto,
    _pagado_neto,
	_reserva_bruto,
	_reserva_neto,
	_incurrido_bruto,
	_incurrido_neto	
	);

END FOREACH

-- Filtros para Eventos
LET v_filtros = "";
IF a_evento <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Evento: " ||  TRIM(a_evento);

	LET _tipo = sp_sis04(a_evento);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_reclamo_evento
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_evento NOT IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = "";
	ELSE		        -- Excluir estos Registros
				   
		UPDATE tmp_reclamo_evento
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_evento IN (SELECT codigo FROM tmp_codigos);
           LET v_saber = " Ex";
	END IF
	
	FOREACH
		SELECT recevent.nombre,tmp_codigos.codigo
	      INTO v_nombre_evento,v_codigo
	      FROM recevent,tmp_codigos
	     WHERE recevent.cod_evento = codigo
	     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_nombre_evento) || (v_saber);
    END FOREACH
	
	DROP TABLE tmp_codigos;
	
END IF

LET v_filtros = TRIM(v_filtros);

FOREACH	WITH HOLD
	SELECT cod_evento,
		   numrecla,
		   no_documento,
		   cod_asegurado,			
		   fecha_siniestro,	 	
		   fecha_reclamo,  	
		   estatus_audiencia,
		   cod_sucursal,
		   pagado_bruto,
           pagado_neto,
	       reserva_bruto,
           reserva_neto,
           incurrido_bruto,
		   incurrido_neto		   
	  INTO v_cod_evento,
		   v_numrecla,     	  	
		   v_no_documento,	  	
		   _cod_asegurado,	  	 
		   v_fecha_siniestro, 	
		   v_fecha_reclamo,	  	
		   v_estatus_audiencia,
		   _cod_sucursal,
		   _pagado_bruto,
           _pagado_neto,
	       _reserva_bruto,
           _reserva_neto,
           _incurrido_bruto,
		   _incurrido_neto
	  FROM tmp_reclamo_evento
	 WHERE seleccionado = 1
	 ORDER BY 1

	SELECT nombre
	  INTO v_asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_asegurado;
	 
	SELECT nombre
	  INTO v_nombre_evento
	  FROM recevent
	 WHERE cod_evento = v_cod_evento;

    IF v_estatus_audiencia = 0 THEN
		LET v_desc_estatus = 'Perdido';
    ELIF v_estatus_audiencia = 1 THEN
		LET v_desc_estatus = 'Ganado';
    ELIF v_estatus_audiencia = 2 THEN
		LET v_desc_estatus = 'Por Definir';
    ELIF v_estatus_audiencia = 3 THEN
		LET v_desc_estatus = 'Proceso Penal';
    ELIF v_estatus_audiencia = 4 THEN
		LET v_desc_estatus = 'Proceso Civil';
    ELIF v_estatus_audiencia = 5 THEN
		LET v_desc_estatus = 'Apelacion';
    ELIF v_estatus_audiencia = 6 THEN
		LET v_desc_estatus = 'Resuelto';
    ELIF v_estatus_audiencia = 7 THEN
		LET v_desc_estatus = 'FUT - Ganado';
    ELIF v_estatus_audiencia = 8 THEN
		LET v_desc_estatus = 'FUT - Responsable';
	ELSE
	    LET v_desc_estatus = 'Sin Estatus';
	END IF

    RETURN v_cod_evento,
	       v_nombre_evento,
	       v_numrecla,    
		   v_no_documento,
		   v_asegurado,
		   v_fecha_siniestro,
		   v_fecha_reclamo,
		   v_estatus_audiencia,
		   v_desc_estatus,
		   v_compania_nombre,
		   v_filtros,
		   _pagado_bruto,
           _pagado_neto,
	       _reserva_bruto,
           _reserva_neto,
           _incurrido_bruto,
		   _incurrido_neto		   
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_reclamo_evento;
DROP TABLE tmp_sinis;

END PROCEDURE;