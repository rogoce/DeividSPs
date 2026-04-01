--Para sacar punto 47

DROP procedure sp_super0103;
CREATE procedure sp_super0103()
RETURNING char(20),varchar(50),varchar(50),varchar(50),varchar(30),varchar(30),varchar(30),char(50),char(50),char(50),
          date,date,date,char(50),varchar(30),smallint,dec(16,2),decimal(16,2),char(30),varchar(50);

BEGIN
    DEFINE _cod_contratante,v_factura,_no_poliza,_cod_pagador,_cod_asegurado      						CHAR(10);
	define _n_perpago          											char(40);
	DEFINE _no_endoso													CHAR(5);
    DEFINE v_documento                           						CHAR(20);
    DEFINE v_codramo,v_codsucursal,cod_mov, _cod_tipocan       			CHAR(3);
    DEFINE v_codgrupo                            						CHAR(5);
    DEFINE v_prima_suscrita,v_prima_retenida,v_reaseguro,_suma_asegurada  				DECIMAL(16,2);
    DEFINE v_desc_cliente                        						CHAR(45);
    DEFINE v_desc_ramo,v_desc_grupo,v_descr_cia,v_tipo_cancelacion		CHAR(50);
    DEFINE v_filtros                             						CHAR(100);
    DEFINE _tipo                                 						CHAR(01);
    DEFINE _vig_ini,_vigencia_inic,_vig_fin,_fecha_suscripcion                           					DATE;
	DEFINE _periodo                                                  	CHAR(7);
	DEFINE _porc_partic_agt                                             DEC(5,2);
    DEFINE v_saber		     											CHAR(2);
    DEFINE v_codigo		     											CHAR(5);
    DEFINE _cod_agente													CHAR(5);
	DEFINE v_corredor,n_ramo													CHAR(50);
	DEFINE _suc_prom        	    CHAR(3);
    DEFINE _cod_vendedor		    CHAR(3);
    DEFINE _nombre_vendedor,n_agente	    	CHAR(50);
	define _user_added                                                  CHAR(10); 
	DEFINE _user_added_desc												CHAR(50);
	define n_riesgo,_ced_aseg,_ced_cont,_ced_pag						char(30);
	define _cod_perpago 		char(3);
	define _cod_cliente  		char(10);
	define _cliente_pep          smallint;
	define _cod_riesgo integer;
	define _nacionalidad,_nacionalidad_ase,_nacionalidad_pag,n_cont,n_aseg,n_pag             varchar(50);

    LET v_prima_suscrita = 0;
    LET v_prima_retenida = 0;
    LET v_reaseguro      = 0;
    LET v_desc_cliente   = NULL;
    LET v_desc_ramo      = NULL;
    LET v_desc_grupo     = NULL;
    LET v_descr_cia      = NULL;
    LET v_filtros        = NULL;

    LET v_descr_cia = sp_sis01('001');

    SET ISOLATION TO DIRTY READ;

CALL sp_pro34f('001','001','2021-10','2022-10','*','*','*','*','*','*','1','*') RETURNING v_filtros;

FOREACH
	 SELECT x.cod_ramo,
			x.no_documento,
			x.cod_contratante,
			x.suma_asegurada,
			x.prima,
			x.cod_agente,
			x.no_poliza
	   INTO v_codramo,
			v_documento,
			_cod_contratante,
			_suma_asegurada,
		    v_prima_suscrita,
			_cod_agente,
			_no_poliza
	   FROM temp_det x
	  WHERE x.seleccionado = 1
	  ORDER BY x.cod_ramo,x.cod_contratante

	foreach
		select cod_asegurado
		  into _cod_asegurado
		  from emipouni
		 where no_poliza = _no_poliza
		exit foreach; 
	end foreach
			
		SELECT cod_perpago,cod_pagador,fecha_suscripcion,vigencia_inic,vigencia_final
		 INTO _cod_perpago,_cod_pagador,_fecha_suscripcion,_vig_ini,_vig_fin
		 FROM emipomae
		WHERE no_poliza = _no_poliza;
		
		select nombre,cedula,cliente_pep,nacionalidad
		  into n_cont,_ced_cont,_cliente_pep,_nacionalidad
		  from cliclien
		 where cod_cliente = _cod_contratante;
		 
		select nombre,cedula,nacionalidad
		  into n_aseg,_ced_aseg,_nacionalidad_ase
		  from cliclien
		 where cod_cliente = _cod_asegurado;
		 
		select nombre,cedula,nacionalidad
		  into n_pag,_ced_pag,_nacionalidad_pag
		  from cliclien
		 where cod_cliente = _cod_pagador;
		 
		select cod_riesgo into _cod_riesgo from ponderacion
		where cod_cliente = _cod_contratante;
				
		select nombre into n_riesgo from cliriesgo
		where cod_riesgo = _cod_riesgo;	

	    --Ramo
	    SELECT nombre
		  INTO n_ramo
		  FROM prdramo
		 WHERE cod_ramo = v_codramo;
		
	    SELECT nombre
		  INTO _n_perpago
		  FROM cobperpa
		 WHERE cod_perpago = _cod_perpago;

	    --Corredor
	    SELECT nombre
		  INTO n_agente
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;
  
        RETURN v_documento, n_cont, n_aseg, n_pag,_ced_cont,_ced_aseg,_ced_pag,_nacionalidad,_nacionalidad_ase,_nacionalidad_pag, _fecha_suscripcion, _vig_ini, _vig_fin, n_ramo,n_riesgo, 
		      _cliente_pep,_suma_asegurada, v_prima_suscrita, _n_perpago, n_agente
              WITH RESUME;
		end foreach
END
END PROCEDURE;
