-- POLIZAS VIGENTES POR RAMO
--
-- Creado    : 08/10/2000 - Autor: Yinia Zamora

-- Modificado: 16/08/2001 - Marquelda Valdelamar (inclusion de filtro de cliente)
--			   05/09/2001                         inclusion de filtro de poliza
-- SIS v.2.0 - DEIVID, S.A.

   DROP procedure sp_pro395a;
   CREATE procedure "informix".sp_pro395a()

   RETURNING CHAR(20),CHAR(50),DECIMAL(16,2),DECIMAL(16,2),VARCHAR(50),char(10);


    DEFINE v_cod_ramo,v_cod_sucursal,_cod_tipoprod  			 CHAR(3);
    DEFINE v_saber					  			 CHAR(2);
    DEFINE v_cod_grupo,_cod_acreedor,_limite	 CHAR(5);
    DEFINE v_contratante,v_codigo,_temp_poliza	 CHAR(10);
    DEFINE v_asegurado                			 CHAR(45);
    DEFINE v_desc_ramo,v_descr_cia,v_desc_agente,_tipo_prod CHAR(50);
    DEFINE v_desc_grupo               			 CHAR(40);
    DEFINE _no_documento               			 CHAR(20);
    DEFINE v_vigencia_inic,v_vigencia_final   	 DATE;
    DEFINE v_cant_polizas             			 INTEGER;
    DEFINE v_prima_suscrita,_suma_asegurada   	 DECIMAL(16,2);
    DEFINE _tipo              					 CHAR(1);
    DEFINE v_filtros          					 CHAR(255);
	DEFINE _no_poliza							 CHAR(10);
	DEFINE _cant,_estatus_poliza                 SMALLINT;
    DEFINE _cod_cobertura                        char(5);
	DEFINE _desc_cobertura                       VARCHAR(50);

    LET v_cod_ramo       = NULL;
    LET v_cod_sucursal   = NULL;
    LET v_cod_grupo      = NULL;
    LET v_contratante    = NULL;
    LET _no_documento    = NULL;
    LET v_desc_ramo      = NULL;
    LET v_descr_cia      = NULL;
    LET _suma_asegurada   = 0;
    LET v_prima_suscrita = 0;
    LET _tipo            = NULL;

    SET ISOLATION TO DIRTY READ;


	SET ISOLATION TO DIRTY READ;

    FOREACH WITH HOLD

	   select cod_cliente
	     into v_contratante
		 from a

	  foreach

	       SELECT no_documento
	         INTO _no_documento
	         FROM emipomae
	        WHERE cod_contratante = v_contratante
			  and cod_ramo = '001'
			  and actualizado = 1

	    exit foreach;

	  end foreach

	  if _no_documento is not null then

			let _no_poliza = sp_sis21(_no_documento);

	       SELECT nombre
	         INTO v_asegurado
	         FROM cliclien
	        WHERE cod_cliente = v_contratante;

	       SELECT estatus_poliza,cod_tipoprod,suma_asegurada,prima_suscrita
	         INTO _estatus_poliza,_cod_tipoprod,_suma_asegurada,v_prima_suscrita
	         FROM emipomae
	        WHERE no_poliza = _no_poliza;


			if _estatus_poliza = 1 then

		       SELECT nombre
		         INTO _tipo_prod
		         FROM emitipro
		        WHERE cod_tipoprod = _cod_tipoprod;


		       RETURN _no_documento,_tipo_prod,_suma_asegurada,v_prima_suscrita,
		              v_asegurado,v_contratante WITH RESUME;

			end if

	  end if

	end foreach

END PROCEDURE;
