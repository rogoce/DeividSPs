   DROP procedure sp_rec142;
   CREATE procedure "informix".sp_rec142(a_cia CHAR(03),a_agencia CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7))

   RETURNING CHAR(50),
			 CHAR(3),
			 INTEGER,
			 INTEGER,
			 DEC(16,2),
			 INTEGER,
			 INTEGER,
			 DEC(16,2),
   			 integer;
--------------------------------------------
---  APADEA
---  INFORMACION ESTADISTICA MENSUAL 
---
---  Amado Perez M. 02/02/2007
---  Ref. Power Builder 
--------------------------------------------

    DEFINE v_cod_ramo,v_cod_subramo,_cod_ramo,_cod_subramo  CHAR(3);
    DEFINE v_desc_ramo        CHAR(50);
    DEFINE v_desc_subramo     CHAR(50);
    DEFINE descr_cia	      CHAR(45);
    DEFINE unidades2          SMALLINT;
    DEFINE _no_poliza,_no_reclamo         CHAR(10);
    DEFINE v_cant_polizas,_cnt_reclamo          INTEGER;
    DEFINE v_prima_suscrita,v_prima_retenida,
           _prima_suscrita,_prima_retenida,v_suma_asegurada,_total_pri_sus,v_incurrido_bruto   DECIMAL(16,2);
    DEFINE _tipo,_nueva_renov              CHAR(01);
    DEFINE v_filtros          CHAR(255);
	DEFINE _mes2,_mes,_ano2,_orden   SMALLINT;
	DEFINE _fecha2     	      DATE;
	DEFINE _cod_tipoprod	  char(3);
	DEFINE _cod_sucursal      char(3);
	DEFINE _prima_pma		  dec(16,2);
	DEFINE _prima_col		  dec(16,2);
	DEFINE _prima_chi		  dec(16,2);
	DEFINE _prima_otro		  dec(16,2);
	DEFINE _incu_pma		  dec(16,2);
	DEFINE _incu_col		  dec(16,2);
	DEFINE _incu_chi		  dec(16,2);
	DEFINE _incu_otro		  dec(16,2);
	DEFINE _cod_cobertura     char(5);
	DEFINE _prima_neta		  dec(16,2);
	DEFINE _incurrido_bruto	  dec(16,2);
	DEFINE _prima_auto_part   dec(16,2);
	DEFINE _prima_auto_come   dec(16,2);
	DEFINE _incu_auto_part    dec(16,2);
	DEFINE _incu_auto_come    dec(16,2);
	DEFINE _no_endoso         char(5);
	DEFINE _cnt_poliza_p      int;
	DEFINE _cnt_poliza_c      int;
	DEFINE _cnt_incu_p        int;
	DEFINE _cnt_incu_c        int;
	define _inc_bruto         dec(16,2);
	DEFINE _cantidad          int;
	define _agno              int;
	DEFINE _incu_auto		  dec(16,2);
	define _periodo           char(7);
	define _no_unidad         char(5);
	define _cod_tipoveh       char(3);
	define _uso_auto          char(1);
	define _tipo_auto         char(3);
	define _cnt_danos		  int;
    define _inc_danos		  dec(16,2);
	define _cod_tipo		  CHAR(3);
	define _tot_uni			  INTEGER;
	define _tot_rec			  INTEGER;
	define _tot_incur		  DEC(16,2);
	define _rc_uni 			  INTEGER;
	define _rc_rec 			  INTEGER;
	define _rc_incur		  DEC(16,2);
	define _cant_cob_p 		  smallint;
	define _cant_cob_d		  smallint;
	define _cnt_danos2		  int;
    define _inc_danos2		  dec(16,2);

	 CREATE TEMP TABLE tmp_auto(
	        cod_tipo         CHAR(3),
			tot_uni          INTEGER,
			tot_rec          INTEGER,
			tot_incur        DEC(16,2),
			rc_uni           INTEGER,
			rc_rec           INTEGER,
			rc_incur         DEC(16,2),
			agno             integer,
			PRIMARY KEY(cod_tipo,agno)) WITH NO LOG;
	        
    
LET v_cod_ramo       = NULL;
LET v_cod_subramo    = NULL;
LET v_desc_subramo   = NULL;
LET v_cant_polizas   = 0;
LET v_prima_suscrita = 0;
LET _prima_suscrita  = 0;
LET _tipo            = NULL;

LET descr_cia = sp_sis01(a_cia);

-- Descomponer los periodos en fechas

LET _ano2 = a_periodo2[1,4];
LET _mes2 = a_periodo2[6,7];
LET _mes = _mes2;

IF _mes2 = 12 THEN
   LET _mes2 = 1;
   LET _ano2 = _ano2 + 1;
ELSE
   LET _mes2 = _mes2 + 1;
END IF

LET _fecha2 = MDY(_mes2,1,_ano2);
LET _fecha2 = _fecha2 - 1;
--begin work;
SET ISOLATION TO DIRTY READ;
--Crea tabla temp_ramo
--CALL sp_pr94a();

--trae cant. de polizas vig. temp_perfil
{CALL sp_rec142b(
a_cia,
a_agencia,
_fecha2,
'*',
'4;Ex') RETURNING v_filtros;}

--trae primas suscritas del mes. tmp_prod 
CALL sp_rec142c(
a_cia,
a_agencia,
a_periodo1,
a_periodo2,
'*',
'*',
'*',
'*',
'4;Ex',		--Reaseguro Asumido Excluido
'*'
) RETURNING v_filtros;

--Trae los siniestros brutos incurridos

{CALL sp_rec142d(
a_cia,
a_agencia,
a_periodo1,
a_periodo2
);
}
LET v_filtros = sp_rec142d(
				a_cia, 
				a_agencia, 
				a_periodo1, 
				a_periodo2
				); 


-- Excluye los Reclamos en Reaseguro Asumido

{update tmp_siniest
   set seleccionado = 0
 where seleccionado = 1
   and cod_tipoprod = "004";
 

--Trae la cant. de reclamos por ramo
{CALL sp_rec142f(
a_cia, 
a_periodo1, 
a_periodo2
) RETURNING v_filtros;
}
LET _prima_auto_part     = 0;
LET _prima_auto_come	 = 0;
LET _incu_auto_part 	 = 0;
LET _incu_auto_come 	 = 0;
LET _cnt_poliza_p        = 0;
LET _cnt_poliza_c        = 0;
LET _cnt_incu_p          = 0;
LET _cnt_incu_c          = 0;

--SET DEBUG FILE TO "sp_rec142.trc";-- Nombre de la Compania
--TRACE ON;


FOREACH
 SELECT no_poliza
   INTO _no_poliza
   FROM tmp_prod
  WHERE	seleccionado = 1
  GROUP BY no_poliza

	SELECT periodo
	  INTO _periodo
	  FROM tmp_pol_p
	 WHERE no_poliza = _no_poliza;

	-- Informacion de Poliza
   SELECT nueva_renov,
   	      cod_subramo	
     INTO _nueva_renov,
		  _cod_subramo
     FROM emipomae
    WHERE no_poliza = _no_poliza;

   LET _agno = _periodo[1,4];

   FOREACH
	SELECT no_unidad
	  INTO _no_unidad
	  FROM emipouni
	 WHERE no_poliza = _no_poliza

    SELECT cod_tipoveh,
	       uso_auto
	  INTO _cod_tipoveh,
	       _uso_auto
	  FROM emiauto
	 WHERE no_poliza = _no_poliza
	   AND no_unidad = _no_unidad;

	LET _cant_cob_p = 0;
	LET _cant_cob_d = 0;

    SELECT count(*)
	  INTO _cant_cob_p
	  FROM emipocob
	 WHERE no_poliza = _no_poliza
	   AND no_unidad = _no_unidad
	   AND cod_cobertura IN ('00102');

    SELECT count(*)
	  INTO _cant_cob_d
	  FROM emipocob
	 WHERE no_poliza = _no_poliza
	   AND no_unidad = _no_unidad
	   AND cod_cobertura IN ('00113');

	LET _tipo_auto = "";

    IF _cod_subramo = "001" THEN
		IF _cod_tipoveh = '005'	THEN
			LET _tipo_auto = "001";
		ELIF _cod_tipoveh = '011' OR _cod_tipoveh = '012' THEN
			LET _tipo_auto = "006";
		ELSE
			LET _tipo_auto = "001";
		END IF
	ELIF _cod_subramo = "012" THEN
	    IF _uso_auto = "P" THEN
			IF _cod_tipoveh = '005'	THEN
				LET _tipo_auto = "001";
			ELIF _cod_tipoveh = '011' OR _cod_tipoveh = '012' THEN
				LET _tipo_auto = "006";
			ELSE
				LET _tipo_auto = "001";
			END IF
		ELSE
		    IF _cod_tipoveh = '008' THEN
				LET _tipo_auto = "002";
			ELIF _cod_tipoveh = '009' THEN
				LET _tipo_auto = "003";
			ELIF _cod_tipoveh = '010' THEN
				LET _tipo_auto = "004";
			ELIF _cod_tipoveh = '011' OR _cod_tipoveh = '012' THEN
				LET _tipo_auto = "008";
			ELIF _cod_tipoveh = '003' THEN
				LET _tipo_auto = "005";
			END IF
		END IF
	ELIF _cod_subramo = "002" THEN
	    IF _cod_tipoveh = '008' THEN
			LET _tipo_auto = "002";
		ELIF _cod_tipoveh = '009' THEN
			LET _tipo_auto = "003";
		ELIF _cod_tipoveh = '010' THEN
			LET _tipo_auto = "004";
		ELIF _cod_tipoveh = '011' OR _cod_tipoveh = '012' THEN
			LET _tipo_auto = "008";
		ELIF _cod_tipoveh = '003' THEN
			LET _tipo_auto = "005";
		END IF
	ELIF _cod_subramo = "005" THEN
	    IF _cod_tipoveh = '003' THEN
			LET _tipo_auto = "005";
		ELIF _cod_tipoveh = '011' OR _cod_tipoveh = '012' THEN
			LET _tipo_auto = "007";
		END IF
	END IF

	IF _tipo_auto <> "" THEN
	   BEGIN
          ON EXCEPTION IN(-239)
             UPDATE tmp_auto
                SET tot_uni = tot_uni + _cant_cob_p,
				    rc_uni  = rc_uni + _cant_cob_d
              WHERE cod_tipo = _tipo_auto
                AND agno     = _agno;

          END EXCEPTION
          INSERT INTO tmp_auto
              VALUES(_tipo_auto,
                     _cant_cob_p,
                     0,
                     0,
					 _cant_cob_d,
					 0,
					 0,
					 _agno
                     );
       END
	END IF


   END FOREACH

END FOREACH



---RECLAMOS


FOREACH
	SELECT cod_ramo,
		   no_reclamo,
		   no_poliza,
		   no_unidad,
		   incurrido_bruto,
		   periodo
	  INTO _cod_ramo,
		   _no_reclamo,
		   _no_poliza,
		   _no_unidad,
		   _incu_auto,
		   _periodo
	  FROM tmp_sinis
	 WHERE seleccionado = 1

    LET _agno = _periodo[1,4];

	IF _incu_auto IS NULL THEN
		LET _incu_auto = 0.00;
	END IF

	SELECT cod_subramo
	  INTO _cod_subramo
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT no_unidad
	  INTO _no_unidad
	  FROM emipouni
	 WHERE no_poliza = _no_poliza
	   AND 	no_unidad = _no_unidad;

    SELECT cod_tipoveh,
	       uso_auto
	  INTO _cod_tipoveh,
	       _uso_auto
	  FROM emiauto
	 WHERE no_poliza = _no_poliza
	   AND no_unidad = _no_unidad;

	LET _tipo_auto = "";

    IF _cod_subramo = "001" THEN
		IF _cod_tipoveh = '005'	THEN
			LET _tipo_auto = "001";
		ELIF _cod_tipoveh = '011' OR _cod_tipoveh = '012' THEN
			LET _tipo_auto = "006";
		ELSE
			LET _tipo_auto = "001";
		END IF
	ELIF _cod_subramo = "012" THEN
	    IF _uso_auto = "P" THEN
			IF _cod_tipoveh = '005'	THEN
				LET _tipo_auto = "001";
			ELIF _cod_tipoveh = '011' OR _cod_tipoveh = '012' THEN
				LET _tipo_auto = "006";
			ELSE
				LET _tipo_auto = "001";
			END IF
		ELSE
		    IF _cod_tipoveh = '008' THEN
				LET _tipo_auto = "002";
			ELIF _cod_tipoveh = '009' THEN
				LET _tipo_auto = "003";
			ELIF _cod_tipoveh = '010' THEN
				LET _tipo_auto = "004";
			ELIF _cod_tipoveh = '011' OR _cod_tipoveh = '012' THEN
				LET _tipo_auto = "008";
			ELIF _cod_tipoveh = '003' THEN
				LET _tipo_auto = "005";
			END IF
		END IF
	ELIF _cod_subramo = "002" THEN
	    IF _cod_tipoveh = '008' THEN
			LET _tipo_auto = "002";
		ELIF _cod_tipoveh = '009' THEN
			LET _tipo_auto = "003";
		ELIF _cod_tipoveh = '010' THEN
			LET _tipo_auto = "004";
		ELIF _cod_tipoveh = '011' OR _cod_tipoveh = '012' THEN
			LET _tipo_auto = "008";
		ELIF _cod_tipoveh = '003' THEN
			LET _tipo_auto = "005";
		END IF
	ELIF _cod_subramo = "005" THEN
	    IF _cod_tipoveh = '003' THEN
			LET _tipo_auto = "005";
		ELIF _cod_tipoveh = '011' OR _cod_tipoveh = '012' THEN
			LET _tipo_auto = "007";
		END IF
	END IF

	IF _tipo_auto <> "" THEN
	   -- Codificacion primas por cobertura
 	   IF _cod_ramo = "002" THEN
	   		   LET _cnt_danos = 0;
			   LET _inc_danos = 0.00;
	   		   LET _cnt_danos2 = 0;
			   LET _inc_danos2 = 0.00;
			   FOREACH
			   		SELECT cod_cobertura,
						   sum(incurrido_abierto)
					  INTO _cod_cobertura,
					       _incurrido_bruto
					  FROM tmp_inc_cob
					 WHERE no_reclamo = _no_reclamo
				  GROUP BY cod_cobertura


                    IF _cod_cobertura = "00102" THEN
	   		            LET _cnt_danos2 = 1;
						LET _inc_danos2 = _inc_danos + _incurrido_bruto;
						IF _inc_danos IS NULL THEN
							LET _inc_danos = 0.00;	
						END IF
						LET _orden = 1;
					ELIF _cod_cobertura = "00113" THEN	--danos
	   		            LET _cnt_danos = 1;
						LET _inc_danos = _inc_danos + _incurrido_bruto;
						IF _inc_danos IS NULL THEN
							LET _inc_danos = 0.00;	
						END IF
						LET _orden = 2;
					ELIF _cod_cobertura = "00121" OR _cod_cobertura = "00119" THEN
						LET _orden = 3;
					ELIF _cod_cobertura = "00606" OR _cod_cobertura = "00118" OR _cod_cobertura = "00900" THEN
						LET _orden = 4;
					ELIF _cod_cobertura = "00103" OR _cod_cobertura = "00901" THEN
						LET _orden = 5;
					ELSE
						LET _orden = 6;
					END IF

			   END FOREACH

		   BEGIN
	          ON EXCEPTION IN(-239)
	             UPDATE tmp_auto
	                SET tot_rec   = tot_rec + _cnt_danos2,
					    tot_incur = tot_incur +	_inc_danos2,
						rc_rec    = rc_rec + _cnt_danos,
						rc_incur  = rc_incur + _inc_danos
	              WHERE cod_tipo  = _tipo_auto
	                AND agno      = _agno;

	          END EXCEPTION
	          INSERT INTO tmp_auto
	              VALUES(_tipo_auto,			  
	                     0,						  
	                     _cnt_danos2,						  
	                     _inc_danos2,
	                     0,  			  
						 _cnt_danos,	   		  
						 _inc_danos,	 		  
						 _agno					  
	                     );
	       END
  	   END IF
	END IF

END FOREACH


FOREACH
	SELECT cod_tipo, 	
		   tot_uni,  
	       tot_rec,  
	       tot_incur,
	       rc_uni,   
	       rc_rec,   
	       rc_incur, 
	       agno   
	  INTO _cod_tipo,
	       _tot_uni,   
		   _tot_rec,  
		   _tot_incur,
		   _rc_uni,   
	       _rc_rec,        
	       _rc_incur,   
    	   _agno   
	  FROM tmp_auto
	ORDER BY agno, cod_tipo

   IF _cod_tipo = "001" THEN
		  LET v_desc_ramo = "AUTOS PARTICULARES";
   ELIF _cod_tipo = "002" THEN
		  LET v_desc_ramo = "AUTOS COMERCIALES LIVIANOS";
   ELIF _cod_tipo = "003" THEN
		  LET v_desc_ramo = "AUTOS COMERCIALES MEDIANOS";
   ELIF _cod_tipo = "004" THEN
		  LET v_desc_ramo = "AUTOS COMERCIALES PESADOS";
   ELIF _cod_tipo = "005" THEN
		  LET v_desc_ramo = "TAXIS";
   ELIF _cod_tipo = "006" THEN
		  LET v_desc_ramo = "BUSES PARTICULARES";
   ELIF _cod_tipo = "007" THEN
		  LET v_desc_ramo = "BUSES PUBLICOS";
   ELSE
		  LET v_desc_ramo = "BUSES ESCOLARES";
   END IF

       RETURN  v_desc_ramo,
               _cod_tipo,
       		   _tot_uni,  
               _tot_rec,  
               _tot_incur,
               _rc_uni,   
			   _rc_rec,   
			   _rc_incur, 
			   _agno   
               WITH RESUME;
END FOREACH


DROP TABLE tmp_prod;
DROP TABLE tmp_sinis;
DROP TABLE tmp_cobp;
DROP TABLE tmp_inc_cob;
DROP TABLE tmp_auto;
DROP TABLE tmp_pol_p;
--commit work;
END PROCEDURE;
