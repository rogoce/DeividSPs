-- Informes de incentivos de corredores
-- SIS v.3.3.20 - DEIVID, S.A.
-- Creado    : 17/07/2009 
-- Autor: Henry Giron	 d_prod_sp_junio2009_dw1


DROP procedure sp_junio2009;

CREATE procedure "informix".sp_junio2009(a_ramo CHAR(255),a_desde DATE, a_hasta DATE )
RETURNING   CHAR(3),  -- cia                
			CHAR(100), --  cia_des            
            CHAR(5),   --  agente             
            CHAR(50),  --  nombre             
            CHAR(3),  --  cod_ramo           
			CHAR(100),	--  des_ramo			
			DEC(16,2),	--  prima_neta         
			DEC(16,2),	  --  prima_cobrada      
			DEC(16,2),	 --  comision           
			DEC(16,2), --  fidelidad          
			DEC(16,2),	 --  cobranza           
			DEC(16,2);  --  rentabilidad
  
DEFINE a_cod_ramo                        CHAR(3);
DEFINE v_filtros                       CHAR(255);
DEFINE _tipo                             CHAR(1);

DEFINE a_agente  						 CHAR(5);
DEFINE _cod_compania                     CHAR(3);
DEFINE _no_documento                    CHAR(20);
DEFINE _vigencia_inic                       DATE;
DEFINE _vigencia_final                      DATE;
DEFINE _cod_ramo						  CHAR(3);
DEFINE _estatus_poliza                  SMALLINT;
DEFINE _cod_formapag 					  CHAR(3);
DEFINE _desc_formapag 					 CHAR(50);
DEFINE _descr_cia                      CHAR(100);
DEFINE _no_recibo                       CHAR(10);
DEFINE _cod_grupo                        CHAR(5);
DEFINE _no_remesa                       CHAR(10);
DEFINE _renglon                         SMALLINT;
DEFINE _cod_agente                       CHAR(5);
DEFINE _nombre                          CHAR(50);
DEFINE _ramo                           CHAR(100);
DEFINE _prima_neta                     DEC(16,2);
DEFINE _no_poliza                       CHAR(10);
DEFINE _cod_corr						SMALLINT;
DEFINE v_prima_cobrada,v_prima_neta	   DEC(16,2);
DEFINE v_com,v_fide,v_cobro,v_renta	   DEC(16,2);
DEFINE _desde, _hasta        			 CHAR(7);
DEFINE _mes_char						 CHAR(2);
DEFINE _ano_char  						 CHAR(4);


SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_junio
            (cia                CHAR(3),
			 cia_des            CHAR(100),
             agente             CHAR(5),
             nombre             CHAR(50),
             cod_ramo           CHAR(3),
			 des_ramo			CHAR(100),
			 prima_neta         DEC(16,2),
			 prima_cobrada      DEC(16,2),
			 comision           DEC(16,2),
			 fidelidad          DEC(16,2),
			 cobranza           DEC(16,2),
			 rentabilidad       DEC(16,2),
	     	 seleccionado       SMALLINT  DEFAULT 1 NOT NULL,
			 PRIMARY KEY(cia,agente)) WITH NO LOG;

CREATE TEMP TABLE tmp_com
            (cia                CHAR(3),
             agente             CHAR(5),
             cod_ramo           CHAR(3),
			 no_poliza			CHAR(10),
			 comision           DEC(16,2),
			 PRIMARY KEY(cia,agente,cod_ramo,no_poliza)) WITH NO LOG;

LET  _descr_cia      = " ";
LET  _vigencia_inic  = CURRENT;
LET  _vigencia_final = CURRENT;
LET  _prima_neta     = 0 ;
LET  _cod_corr       = 0 ;
LET v_prima_cobrada  = 0;
LET v_prima_neta     = 0;
LET v_com			 = 0;
LET v_fide		     = 0;
LET v_cobro		     = 0;
LET v_renta			 = 0;

-- Para trabajar el periodo

IF  MONTH(a_desde) < 10 THEN
	LET _mes_char = '0'|| MONTH(a_desde);
ELSE
	LET _mes_char = MONTH(a_desde);
END IF

LET _ano_char = YEAR(a_desde);
LET _desde  = _ano_char || "-" || _mes_char;

IF  MONTH(a_hasta) < 10 THEN
	LET _mes_char = '0'|| MONTH(a_hasta);
ELSE
	LET _mes_char = MONTH(a_hasta);
END IF

LET _ano_char = YEAR(a_hasta);
LET _hasta  = _ano_char || "-" || _mes_char;


FOREACH
	   SELECT   d.cod_compania,
          		d.no_poliza,
         		d.no_remesa,
				d.renglon,	      --      d.cod_agente,
				d.monto,
				d.prima_neta
	     INTO _cod_compania,
           	  _no_poliza,
			  _no_remesa,
			  _renglon,			  --       a_agente,
	          v_prima_cobrada,
			  v_prima_neta
	     FROM cobredet d, cobremae m 
	    WHERE d.fecha    BETWEEN a_desde AND a_hasta         
	      AND d.actualizado  = 1
	      AND d.tipo_mov     IN ('P','N')
	      AND d.no_remesa    = m.no_remesa
	      AND m.tipo_remesa  IN ('A', 'M', 'C')

		SELECT count(*)
		  INTO _cod_corr
		  FROM cobreagt
		 WHERE no_remesa  = _no_remesa
		   AND renglon    = _renglon;

		IF _cod_corr = 0 THEN
		   CONTINUE FOREACH;
		END IF


		FOREACH
		 Select cod_agente
		   Into a_agente
		   From cobreagt
		  Where no_remesa = _no_remesa
		    And renglon   = _renglon
		  EXIT FOREACH;
		END FOREACH	


		SELECT nombre
	      INTO _nombre
	      FROM agtagent    
	     WHERE cod_agente   = a_agente
	       AND cod_compania = _cod_compania;
		
		IF _nombre IS NULL OR _nombre = " " THEN
           CONTINUE FOREACH;
        END IF

		FOREACH
	  	SELECT cod_ramo
		  INTO a_cod_ramo
		  FROM emipomae
		 WHERE no_poliza = _no_poliza
		  EXIT FOREACH;
		END FOREACH	


		SELECT nombre
		  INTO _ramo
		  FROM prdramo
		 WHERE cod_ramo = a_cod_ramo;

        LET _descr_cia = sp_sis01(_cod_compania);


		BEGIN
			ON EXCEPTION IN(-239)
				UPDATE  tmp_junio
				   SET prima_neta     =  prima_neta    	+ v_prima_neta,
					   prima_cobrada     =   prima_cobrada    + v_prima_cobrada
				 WHERE cia = _cod_compania
				   AND agente = a_agente
				   AND cod_ramo = a_cod_ramo;

        	END EXCEPTION

			INSERT INTO tmp_junio
			VALUES (_cod_compania,
			 _descr_cia,
              a_agente,
             _nombre,
             a_cod_ramo,
			 _ramo,
			 v_prima_neta,
			 v_prima_cobrada,
			 0,
			 0,
			 0,
			 0,
			 1);
		END


	  -- comision de cobranza
		LET v_com			 = 0;
		SELECT sum(chqcomis.comision)
		    INTO v_com 
		    FROM chqcomis  
		   WHERE ( chqcomis.cod_agente = a_agente ) AND  
				 ( chqcomis.no_poliza = _no_poliza ) AND  
		         ( chqcomis.fecha  BETWEEN a_desde AND a_hasta );

		BEGIN
			ON EXCEPTION IN(-239)
        	END EXCEPTION

			INSERT INTO tmp_com
			VALUES (_cod_compania,
              a_agente,
             a_cod_ramo,
			 _no_poliza,
			 v_com);
		END


END FOREACH

-- Procesos para Filtros

LET v_filtros = "";

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_junio
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_junio
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

--set debug file to "sp_jun.trc";
--trace on;


 FOREACH     
	 SELECT cia,
	        agente,
			cod_ramo
	   INTO _cod_compania,
	        a_agente,
			a_cod_ramo
	   FROM tmp_junio
      WHERE seleccionado = 1
	  ORDER BY agente

		LET v_fide		     = 0;
		LET v_cobro		     = 0;
		LET v_renta			 = 0;

	  -- comision

		SELECT sum(comision)
		    INTO v_com 
		    FROM tmp_com
		   WHERE ( agente = a_agente ) AND  
				 ( cod_ramo = a_cod_ramo ) ;

		IF  v_com IS NULL  THEN
           LET v_com = 0 ;
        END IF


	  -- fidelidad
		    SELECT sum(chqfidel.comision)   
		    INTO v_fide 
		    FROM chqfidel  
		   WHERE ( chqfidel.cod_agente = a_agente ) AND  
				 ( chqfidel.cod_ramo = a_cod_ramo ) AND  
		         ( chqfidel.periodo BETWEEN _desde AND _hasta );

		IF  v_fide IS NULL  THEN
           LET v_fide = 0 ;
        END IF


	  -- cobranza
		  SELECT sum(chqboni.comision)
		    INTO v_cobro  
		    FROM chqboni  
		   WHERE ( chqboni.cod_agente = a_agente ) AND  
				 ( chqboni.cod_ramo = a_cod_ramo ) AND  
		         ( chqboni.periodo BETWEEN _desde AND _hasta );

		IF  v_cobro IS NULL  THEN
           LET v_cobro = 0 ;
        END IF


	  -- rentabilidad
		  SELECT sum(chqrenta3.comision)
		    INTO v_renta  
		    FROM chqrenta3  
		   WHERE ( chqrenta3.cod_agente = a_agente ) AND  
				 ( chqrenta3.cod_ramo = a_cod_ramo ) AND  
		         ( chqrenta3.periodo BETWEEN _desde AND _hasta );

		IF  v_renta IS NULL  THEN
           LET v_renta = 0 ;
        END IF


	UPDATE  tmp_junio
	   SET  comision      = v_com,
			fidelidad     = v_fide,
			cobranza      = v_cobro,
			rentabilidad  = v_renta
	 WHERE cia = _cod_compania
	   AND agente = a_agente
	   AND cod_ramo = a_cod_ramo;


END FOREACH


 FOREACH     
	 SELECT cia,
			 cia_des,
             agente,
             nombre,
             cod_ramo,
			 des_ramo,
			 prima_neta,
			 prima_cobrada,
			 comision,
			 fidelidad,
			 cobranza,
			 rentabilidad
	   INTO _cod_compania,
			 _descr_cia,
              a_agente,
             _nombre,
             a_cod_ramo,
			 _ramo,
			 v_prima_neta,
			 v_prima_cobrada,
			 v_com,
			 v_fide,
			 v_cobro,
			 v_renta
	   FROM tmp_junio
      WHERE seleccionado = 1
	  ORDER BY agente



       RETURN _cod_compania,	--1
			 _descr_cia,		--2
             a_agente,			--3
             _nombre,			--4
             a_cod_ramo,		--5
			 _ramo,				--6
			 v_prima_neta,		--7
			 v_prima_cobrada,	--8
			 v_com,				--9
			 v_fide,			--10
			 v_cobro,			--11
			 v_renta			--12
             WITH RESUME;


END FOREACH

DROP TABLE tmp_junio;
   		
END PROCEDURE