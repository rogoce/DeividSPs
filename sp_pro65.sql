-- Informe para detectar corredores que han suscrito polizas
-- y no tienen licencia
-- Creado    : 17/05/2001 - Autor: Armando Moreno Montenegro
-- Modificado: 17/05/2001 - Autor: Armando Moreno Montenegro
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro65;

CREATE PROCEDURE "informix".sp_pro65(a_compania CHAR(3),a_sucursal CHAR(3),a_periodo CHAR(7)) 
RETURNING CHAR(10), --licencia
		  CHAR(50), --corredor
		  CHAR(20), --no_documento
		  CHAR(10), --TIPO
		  CHAR(40), --MENSAJE
		  DATE,	    --SUSP. DESDE
		  DATE,	    --SUSP. HASTA
		  CHAR(1),	--ESTATUS_LIC
		  CHAR(50); --CIA

DEFINE v_nom_corredor    CHAR(50);
DEFINE _estatus_licencia CHAR(1);
DEFINE v_no_poliza,v_licencia,_tipo_pol       CHAR(10);
DEFINE _cod_agente       CHAR(5);
DEFINE v_cod_ramo,v_cod_tiporamo    CHAR(3);
DEFINE v_descr_cia       CHAR(50);
DEFINE _mensaje          CHAR(40);
DEFINE v_filtros      	 CHAR(255);
DEFINE v_no_documento 	 CHAR(20);
DEFINE _tipo          	 CHAR(1);
DEFINE _cnt_vida         SMALLINT;
DEFINE _cnt_gen          SMALLINT;
DEFINE _cnt_fian         SMALLINT;
DEFINE _suspendido_desde,_suspendido_hasta DATE;
LET v_descr_cia = sp_sis01(a_compania);

{    CREATE TEMP TABLE tmp_tabla(
                 cod_corredor   CHAR(5),
				 cnt_vid        SMALLINT,
				 cnt_gen        SMALLINT,
				 cnt_fia        SMALLINT
                 ) WITH NO LOG;	}

FOREACH
 -- Lectura de Polizas
	SELECT x.no_poliza,
		   x.cod_ramo,
		   x.no_documento
	  INTO v_no_poliza,
	   	   v_cod_ramo,
		   v_no_documento
	  FROM emipomae x
	 WHERE x.cod_compania = a_compania
	   AND x.periodo      = a_periodo
	   AND x.nueva_renov  = "N"
	   AND x.actualizado  = 1

	SELECT cod_tiporamo
	  INTO v_cod_tiporamo
	  FROM prdramo
	 WHERE cod_ramo = v_cod_ramo;

 -- Lectura de Emipoagt(Corredores)

   FOREACH	
	SELECT cod_agente
	  INTO _cod_agente
	  FROM emipoagt
	 WHERE no_poliza = v_no_poliza

	SELECT nombre,
		   no_licencia,
		   vida,
		   general,
		   fianzas,
		   estatus_licencia,
		   suspendido_desde,
		   suspendido_hasta
	  INTO v_nom_corredor,
	   	   v_licencia,
		   _cnt_vida,
		   _cnt_gen,
		   _cnt_fian,
		   _estatus_licencia,
		   _suspendido_desde,
		   _suspendido_hasta
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

		LET _mensaje = " ";

		
		 IF v_cod_tiporamo = "001" THEN  --VIDA
			LET _tipo_pol = "VIDA";
			IF _cnt_vida = 0 THEN
				LET _mensaje = "El Corredor no suscribe VIDA";
			ELIF _estatus_licencia = "A" THEN
				CONTINUE FOREACH;
			ELIF _estatus_licencia = "P" THEN
				LET _mensaje = "Licencia Suspendida Permanentemente";
			ELIF _estatus_licencia = "T" THEN
				IF a_periodo between _suspendido_desde and _suspendido_hasta THEN
					LET _mensaje = "Licencia Suspendida Temporalmente";
				ELSE
					CONTINUE FOREACH;
				END IF
			END IF
		 END IF

		 IF v_cod_tiporamo = "002" THEN	 --GENERALES
			LET _tipo_pol = "GENERALES";
			IF _cnt_gen = 0 THEN
				LET _mensaje = "El Corredor no suscribe GENERALES";
			ELIF _estatus_licencia = "A" THEN
				CONTINUE FOREACH;
			ELIF _estatus_licencia = "P" THEN
				LET _mensaje = "Licencia Suspendida Permanentemente";
			ELIF _estatus_licencia = "T" THEN
				IF a_periodo between _suspendido_desde and _suspendido_hasta THEN
					LET _mensaje = "Licencia Suspendida Temporalmente";
				ELSE
					CONTINUE FOREACH;
				END IF
			END IF
		 END IF

		 IF v_cod_tiporamo = "003" THEN	 --FIANZAS
			LET _tipo_pol = "FIANZAS";
			IF _cnt_fian = 0 THEN
				LET _mensaje = "El Corredor no suscribe FIANZAS";
			ELIF _estatus_licencia = "A" THEN
				CONTINUE FOREACH;
			ELIF _estatus_licencia = "P" THEN
				LET _mensaje = "Licencia Suspendida Permanentemente";
			ELIF _estatus_licencia = "T" THEN
				IF a_periodo between _suspendido_desde and _suspendido_hasta THEN
					LET _mensaje = "Licencia Suspendida Temporalmente";
				ELSE
					CONTINUE FOREACH;
				END IF
			END IF
		 END IF


	RETURN v_licencia,
		   v_nom_corredor,
		   v_no_documento,
		   _tipo_pol,
		   _mensaje,
		   _suspendido_desde,
		   _suspendido_hasta,
		   _estatus_licencia,
		   v_descr_cia
		   WITH RESUME;
	END FOREACH
END FOREACH;
END PROCEDURE