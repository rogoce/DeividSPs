-- Informes de cobranzas por corredor
-- SIS v.3.3.20 - DEIVID, S.A.
-- Creado    : 19/11/2008 - Autor: Ricardo Jimenez Banda
-- Modificado para informe de corredores Federico Coronado


DROP procedure sp_web52;

CREATE procedure "informix".sp_web52(a_agente CHAR(5), a_desde DATE, a_hasta DATE )
RETURNING   CHAR(20) 	as no_documento,   	-- _no_documento
			CHAR(100) 	as nombre_cliente,	-- _nombre cliente
			CHAR(30)	as cedula,   		-- _cedula
			CHAR(10)	as no_recibo, 		-- _recibo
			date		as fecha,  			-- _fecha
			DEC(16,2)	as monto, 			-- _monto
			DEC(16,2)	as prima,			-- _prima_neta
			CHAR(50)	as nombre_agente,	-- _nombre
			CHAR(100)	as compania,		-- _compañia
			DATE		as vigencia_inic,  	-- _vigencia_inic
			DATE		as vigencia_final;	-- _vigencia_final
  


	 DEFINE _cod_compania                    CHAR(3);
	 DEFINE _no_documento                    CHAR(20);
	 DEFINE _vigencia_inic                   DATE;
     DEFINE _vigencia_final                  DATE;
	 DEFINE _cod_ramo						 CHAR(3);
	 DEFINE _estatus_poliza                  SMALLINT;
	 DEFINE _cod_formapag 					 CHAR(3);
	 DEFINE _desc_formapag 					 CHAR(50);
	 DEFINE _descr_cia                       CHAR(100);
     DEFINE _no_recibo                       CHAR(10);
	 DEFINE _cod_grupo                       CHAR(5);
	 DEFINE _no_remesa                       CHAR(10);
	 DEFINE _renglon                         SMALLINT;
	 DEFINE _cod_agente                      CHAR(5);
	 DEFINE _nombre                          CHAR(50);
	 DEFINE _ramo                            CHAR(100);
	 DEFINE _prima_neta                      DEC(16,2);
	 DEFINE _no_poliza                       CHAR(10);
	 DEFINE _cod_corr						 SMALLINT;
	 DEFINE _cod_tipoprod                    CHAR(3);
	 define _tipo_produccion                 smallint;
	 define _cod_contratante                 CHAR(10); 
	 DEFINE v_cedula_ruc     				 CHAR(30);
	 DEFINE v_nombre_clte  					 CHAR(100);
	 define _fecha                           date;
	 define _monto							 Decimal(16,2);
	 

	 SET ISOLATION TO DIRTY READ;

	 LET  _descr_cia      = " ";
	 LET  _vigencia_inic  = CURRENT;
	 LET  _vigencia_final = CURRENT;
	 LET  _prima_neta     = 0 ;
	 LET  _cod_corr       = 0 ;

	 FOREACH  
		SELECT  a.cod_compania,
          		a.no_poliza,
              	a.no_recibo,
         		a.prima_neta,
         		a.no_remesa,
				a.renglon,
				a.fecha,
				a.monto
          INTO _cod_compania,
           	   _no_poliza,
			   _no_recibo,
		       _prima_neta,
			   _no_remesa,
			   _renglon,
			   _fecha,
			   _monto
		 FROM  cobredet a inner join cobreagt b on a.no_remesa = b.no_remesa
		 WHERE a.fecha    BETWEEN a_desde AND a_hasta
  		   AND a.actualizado  = 1
  		   AND a.tipo_mov     in ("P", "N")
		   and a.renglon = b.renglon
           and b.cod_agente = a_agente

/*		SELECT count(*)
		  INTO _cod_corr
		  FROM cobreagt
		 WHERE no_remesa  = _no_remesa
		   AND renglon    = _renglon
		   AND cod_agente = a_agente;

		IF _cod_corr = 0 THEN
		   CONTINUE FOREACH;
		END IF
*/
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
			   cod_contratante
          INTO _cod_grupo,
           	   _cod_ramo,
           	   _cod_formapag,
               _estatus_poliza,
               _no_documento,
			   _vigencia_inic,
			   _vigencia_final,
			   _cod_tipoprod,
			   _cod_contratante
          FROM emipomae
          WHERE no_poliza = _no_poliza;

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
		 
		 SELECT nombre,
			   cedula
		  INTO v_nombre_clte,
			   v_cedula_ruc
		  FROM cliclien
		 WHERE cod_cliente = _cod_contratante;

        LET _descr_cia = sp_sis01(_cod_compania);
		
		RETURN  _no_documento, v_nombre_clte, v_cedula_ruc, _no_recibo, _fecha, _monto, _prima_neta,_nombre,_descr_cia,_vigencia_inic, _vigencia_final
		        WITH RESUME;
		
	  END FOREACH
   		
END PROCEDURE