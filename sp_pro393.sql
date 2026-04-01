 DROP procedure sp_pro393;

 CREATE procedure "informix".sp_pro393(a_periodo1 char(7), a_periodo2 char(7))
   RETURNING char(20),		--v_no_documento,	   
 			 char(10),		--_cod_contratante,	   
			 char(100),		--_n_contratante,	   
			 char(3),		--_cod_ramo,		   
			 char(50),		--_n_ramo,			   
			 char(12),		--_estatus_char,	   
			 char(3),		--_cod_sucursal,
			 char(50),  	--_n_sucursal,
			 smallint,		--	_leasing,
			 date,			--	v_vigencia_inic,
			 date,			--	v_vigencia_final,
			 dec(16,2),		--	_prima_neta,
			 char(5),		--_cod_agente,
			 char(50),		--_n_agente,
			 char(1),		-- nueva_renov
			 smallint,		-- conoce a tu cliente activo o inactivo
			 char(50),		-- _direccion,
			 char(10),		-- _telefono1,
			 char(10),		-- _telefono2,
			 char(10),		-- _celular,
			 char(10),		-- _fax,
			 char(20),		-- _apartado,
			 char(30);		-- _cedula

 BEGIN
    define v_no_poliza        CHAR(10);
    define v_no_documento     CHAR(20);
    define v_vigencia_inic	  DATE;
    define v_vigencia_final	  DATE;
    define v_fecha_cancel     DATE;
    define v_contratante      CHAR(10);
	define _n_contratante     CHAR(100);
    define _cod_ramo          CHAR(3);
	define _n_ramo            char(50);
    define _suma_asegurada    DECIMAL(16,2);
    define v_descr_cia        CHAR(50);
	define _cod_sucursal	  CHAR(3);
	define _n_sucursal        CHAR(30);
	define _fecha_suscripcion DATE;
	define _prima             dec(16,2);
	define _cod_subramo       char(3);
	define _n_subramo         char(50);
	define _cod_asegurado     char(10);
	define _estatus           smallint;
	define _prima_suscrita    dec(16,2);
	define _prima_retenida    dec(16,2);
	define _no_factura        char(10);
	define _periodo           char(7);
	define _cod_grupo		  char(3);
	define _n_grupo			  char(30);
	define _cod_tipoprod	  char(3);
	define _n_tipoprod        char(50);
	define _sucursal_origen	  char(3);
	define _leasing			  smallint;
	define _descuento		  dec(16,2);
	define _impuesto		  dec(16,2);
	define _prima_neta		  dec(16,2);
	define _recargo			  dec(16,2);
	define _gastos			  dec(16,2);
	define _prima_bruta		  dec(16,2);
	define _cod_pagador		  char(10);
	define _n_pagador		  char(100);
	define _cod_formapag	  char(3);
	define _n_formapag        char(50);
	define _cod_perpago		  char(3);
	define _n_perpago		  char(50);
	define _estatus_char      char(12);
	define _fecha_impresion   date;
	define _porc_comis_agt    decimal(5,2);
	define _cod_contratante   char(10);
	define _cod_agente        char(5);
	define _n_agente          char(50);
	define _nueva_renov       char(1);
	define _direccion    	  char(50);
	define _apartado          char(20);
	define _cedula            varchar(30,0);
	define _telefono1         char(10);
	define _telefono2         char(10);
	define _conoce_cliente    smallint;
	define _celular           char(10);
	define _fax               char(10);

SET ISOLATION TO DIRTY READ; 

let _porc_comis_agt = 0.00;

FOREACH WITH HOLD

       SELECT no_documento
         INTO v_no_documento
         FROM emipomae
        WHERE actualizado = 1
		  AND periodo >= a_periodo1
		  AND periodo <= a_periodo2
		  AND estatus_poliza = 1
		  AND nueva_renov = "R"
		  AND prima_neta >= 300
	    GROUP BY no_documento
		ORDER BY no_documento

	   let v_no_poliza = sp_sis21(v_no_documento);

       SELECT vigencia_inic,
              vigencia_final,
              fecha_cancelacion,
			  cod_sucursal,
			  fecha_suscripcion,
			  cod_contratante,
			  cod_subramo,
			  estatus_poliza,
			  cod_ramo,
			  cod_grupo,
			  cod_tipoprod,
			  periodo,
			  fecha_impresion,
			  sucursal_origen,
			  no_factura,
			  leasing,
			  prima,
			  descuento,
			  impuesto,
			  prima_neta,
			  recargo,
			  gastos,
			  prima_bruta,
			  suma_asegurada,
			  prima_neta,
			  cod_pagador,
			  cod_formapag,
			  cod_perpago,
			  nueva_renov
         INTO v_vigencia_inic,
              v_vigencia_final,
              v_fecha_cancel,
			  _cod_sucursal,
			  _fecha_suscripcion,
			  _cod_contratante,
			  _cod_subramo,
			  _estatus,
			  _cod_ramo,
			  _cod_grupo,
			  _cod_tipoprod,
			  _periodo,
			  _fecha_impresion,
			  _sucursal_origen,
			  _no_factura,
			  _leasing,
			  _prima,
			  _descuento,
			  _impuesto,
			  _prima_neta,
			  _recargo,
			  _gastos,
			  _prima_bruta,
			  _suma_asegurada,
			  _prima_neta,
			  _cod_pagador,
			  _cod_formapag,
			  _cod_perpago,
			  _nueva_renov
         FROM emipomae
        WHERE no_poliza   = v_no_poliza
          AND actualizado = 1;

		let _estatus_char = '';

		if _estatus = 1 then
			let _estatus_char = 'VIGENTE';
		elif _estatus = 2 then
			let _estatus_char = 'CANCELADA';
		elif _estatus = 3 then
			let _estatus_char = 'VENCIDA';
		else
			let _estatus_char = '*';
		end if

	   let _prima = 0;

       SELECT descripcion
         INTO _n_sucursal
         FROM insagen
        WHERE codigo_agencia  = _cod_sucursal
          AND codigo_compania = "001";
	   	
       FOREACH
        
          SELECT cod_agente,
		         porc_comis_agt
            INTO _cod_agente,
				 _porc_comis_agt
            FROM emipoagt
           WHERE no_poliza = v_no_poliza

		  exit foreach;

       END FOREACH

	   select nombre
	     into _n_agente
		 from agtagent
		where cod_agente = _cod_agente;

	   select nombre
	     into _n_ramo
		 from prdramo
		where cod_ramo = _cod_ramo;

	   select nombre,
	          direccion_1,
			  telefono1,
			  telefono2,
			  celular,
			  fax,
			  apartado,
			  cedula,
			  conoce_cliente
	     into _n_contratante,
		      _direccion,
			  _telefono1,
			  _telefono2,
			  _celular,
			  _fax,
			  _apartado,
			  _cedula,
			  _conoce_cliente
		 from cliclien
		where cod_cliente = _cod_contratante;

	   return v_no_documento,
	          _cod_contratante,
			  _n_contratante,
			  _cod_ramo,
			  _n_ramo,
			  _estatus_char,
			  _cod_sucursal,
			  _n_sucursal,
			  _leasing,
			  v_vigencia_inic,
			  v_vigencia_final,
			  _prima_neta,
			  _cod_agente,
			  _n_agente,
			  _nueva_renov,
			  _conoce_cliente,
			  _direccion,
			  _telefono1,
			  _telefono2,
			  _celular,
			  _fax,
			  _apartado,
			  _cedula
	   with resume;	


END FOREACH

END
END PROCEDURE;
