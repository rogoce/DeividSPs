-- Informe de Honorarios prof Corredores para la SUPERINTENDENCIA DE SEGUROS Y REASEGUROS
-- 
-- Creado    : 03/05/2001 - Autor: Armando Moreno Montenegro
-- Modificado: 03/05/2001 - Autor: Armando Moreno Montenegro
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che163b;

CREATE PROCEDURE "informix".sp_che163b(a_compania CHAR(3),a_sucursal CHAR(3),a_periodo CHAR(7)) 

DEFINE v_nom_corredor    CHAR(50);
DEFINE v_no_poliza,v_licencia       CHAR(10);
DEFINE _cod_agente       CHAR(5);
DEFINE v_cod_ramo,v_cod_tiporamo    CHAR(3);
DEFINE v_descr_cia       CHAR(50);
DEFINE v_filtros      	 CHAR(255);
DEFINE _tipo          	 CHAR(1);
DEFINE _cnt_vida         SMALLINT;
DEFINE _cnt_gen          SMALLINT;
DEFINE _cnt_fian         SMALLINT;
DEFINE _prima_suscrita   DEC(16,2); 
DEFINE _prima_vid         DEC(16,2);
DEFINE _prima_gen         DEC(16,2);
DEFINE _prima_fian        DEC(16,2);
DEFINE _porc_partic_agt   DEC(5,2);

SET ISOLATION TO DIRTY READ;

LET v_descr_cia = sp_sis01(a_compania);

    CREATE TEMP TABLE tmp_tabla(
                 cod_corredor    CHAR(5),
				 cnt_vid        SMALLINT,
				 cnt_gen        SMALLINT,
				 cnt_fia        SMALLINT,
				 prima_vid      DEC(16,2),
				 prima_gen      DEC(16,2),
				 prima_fia      DEC(16,2)
                 ) WITH NO LOG;
LET _cnt_vida = 0;
LET _cnt_gen  = 0;
LET _cnt_fian = 0;
LET _prima_vid = 0.00;
LET _prima_gen = 0.00;
LET _prima_fian = 0.00;

FOREACH
 -- Lectura de Polizas
	SELECT x.no_poliza,
		   x.cod_ramo,
		   x.prima_suscrita
	  INTO v_no_poliza,
	   	   v_cod_ramo,
		   _prima_suscrita
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
	SELECT cod_agente,
	       porc_partic_agt
	  INTO _cod_agente,
	       _porc_partic_agt
	  FROM emipoagt
	 WHERE no_poliza = v_no_poliza

		LET _cnt_vida = 0;
		LET _cnt_gen  = 0;
		LET _cnt_fian = 0;
		LET _prima_vid = 0.00;
		LET _prima_gen = 0.00;
		LET _prima_fian = 0.00;

		 IF v_cod_tiporamo = "001" THEN
			LET _cnt_vida = 1;
			LET _prima_vid = _prima_suscrita * _porc_partic_agt / 100;
		 END IF

		 IF v_cod_tiporamo = "002" THEN
			LET _cnt_gen = 1;
			LET _prima_gen = _prima_suscrita * _porc_partic_agt / 100;
		 END IF

		 IF v_cod_tiporamo = "003" THEN
			LET _cnt_fian = 1;
			LET _prima_fian = _prima_suscrita * _porc_partic_agt / 100;
		 END IF

          INSERT INTO tmp_tabla
                VALUES(_cod_agente,
					   _cnt_vida,
					   _cnt_gen,
					   _cnt_fian,
                       _prima_vid,
                       _prima_gen,
					   _prima_fian
						);
	END FOREACH

END FOREACH;

END PROCEDURE