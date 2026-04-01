-- Informes de cobranzas por corredor
-- SIS v.3.3.20 - DEIVID, S.A.
-- Creado    : 19/11/2008 - Autor: Ricardo Jimenez Banda


DROP procedure sp_leyri04;

CREATE procedure "informix".sp_leyri04(a_agente CHAR(5), a_desde DATE, a_hasta DATE )
RETURNING   CHAR(3),   -- _cod_compania
			CHAR(100), -- _descr_cia
			CHAR(3),   -- _cod_ramo
			CHAR(100), -- _ramo
			CHAR(20),  -- _no_documento
			DATE,      -- _vigencia_inic
			DATE,	   -- _vigencia_final
			SMALLINT,  -- _estatus_poliza
			CHAR(3),   -- _cod_formapag
			CHAR(10),  -- _no_recibo
			CHAR(50),  -- _nombre
			DEC(16,2), -- _prima_neta
			CHAR(50);  -- _desc_formapag
  


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
	 DEFINE _cod_corr						 SMALLINT;
	 DEFINE _cod_tipoprod                    CHAR(3);
	 define _tipo_produccion                 smallint;
	 define _nueva_renov					 char(1);

	 SET ISOLATION TO DIRTY READ;

	 LET  _descr_cia      = " ";
	 LET  _vigencia_inic  = CURRENT;
	 LET  _vigencia_final = CURRENT;
	 LET  _prima_neta     = 0 ;
	 LET  _cod_corr       = 0 ;

	 FOREACH  
		SELECT  cod_compania,
          		no_poliza,
              	no_recibo,
         		prima_neta,
         		no_remesa,
				renglon
          INTO _cod_compania,
           	   _no_poliza,
			   _no_recibo,
		       _prima_neta,
			   _no_remesa,
			   _renglon
		 FROM  cobredet
		 WHERE cobredet.fecha    BETWEEN a_desde AND a_hasta
  		   AND cobredet.actualizado  = 1
  		   AND cobredet.tipo_mov     in ("P", "N")

		SELECT count(*)
		  INTO _cod_corr
		  FROM cobreagt
		 WHERE no_remesa  = _no_remesa
		   AND renglon    = _renglon
		   AND cod_agente = a_agente;

		IF _cod_corr = 0 THEN
		   CONTINUE FOREACH;
		END IF

		SELECT nombre
	      INTO _nombre
	      FROM agtagent    
	     WHERE cod_agente   = a_agente
	       AND cod_compania = _cod_compania;
		
		IF _nombre IS NULL OR _nombre = " " THEN
           CONTINUE FOREACH;
        END IF


		SELECT cod_grupo,
		 	   cod_ramo,
		 	   cod_formapag,
               estatus_poliza,
               no_documento,
			   vigencia_inic,
			   vigencia_final,
			   cod_tipoprod,
			   nueva_renov
          INTO _cod_grupo,
           	   _cod_ramo,
           	   _cod_formapag,
               _estatus_poliza,
               _no_documento,
			   _vigencia_inic,
			   _vigencia_final,
			   _cod_tipoprod,
			   _nueva_renov
          FROM emipomae
          WHERE no_poliza = _no_poliza;

			if _nueva_renov <> "N" then
				continue foreach;
			end if

			if _cod_ramo <> "002" then
				continue foreach;
			end if

			SELECT tipo_produccion
			  INTO _tipo_produccion
			  FROM emitipro
			 WHERE cod_tipoprod = _cod_tipoprod;

			-- Si es coaseguro minoritario no va

			if _tipo_produccion = 3 then
				continue foreach;
			end if


        IF _cod_ramo IS NULL OR _cod_ramo = " " THEN
           CONTINUE FOREACH;
        END IF
		
		SELECT nombre
		  INTO _ramo
		  FROM prdramo
		 WHERE cod_ramo = _cod_ramo;

	    SELECT nombre
		  INTO _desc_formapag
		  FROM cobforpa
		 WHERE cod_formapag = _cod_formapag;

        LET _descr_cia = sp_sis01(_cod_compania);
		
		RETURN  _cod_compania, _descr_cia, _cod_ramo, _ramo, _no_documento, _vigencia_inic, _vigencia_final,
		        _estatus_poliza, _cod_formapag, _no_recibo, _nombre, _prima_neta, _desc_formapag  WITH RESUME;
		
	  END FOREACH
   		
END PROCEDURE