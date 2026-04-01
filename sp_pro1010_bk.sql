DROP procedure sp_pro1010;
CREATE procedure "informix".sp_pro1010(a_compania CHAR(03),a_agencia CHAR(03),a_periodo1 CHAR(07),a_periodo2 CHAR(07),a_codsucursal CHAR(255) DEFAULT "*",a_codgrupo CHAR(255) DEFAULT "*",a_codagente CHAR(255) DEFAULT "*",a_codusuario CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*",a_cliente CHAR(255) DEFAULT "*", a_no_documento CHAR(255) DEFAULT "*")
RETURNING CHAR(3),	   -- cod_ramo
 		  CHAR(50),    -- desc. ramo
 		  CHAR(10),    -- no_factura
 		  CHAR(20),    -- no_documento
          CHAR(50),    -- cliente
          DEC(16,2),   -- suma asegurada
          DEC(16,2),   -- prima suscrita
          CHAR(50),    -- desc. cia
          DATE,	  	   -- vig ini
		  DATE,	  	   -- vig fin
          CHAR(255),   -- filtros
		  CHAR(50),    -- corredor 
		  integer,	   -- cant_anual 
		  integer,	   -- cant_realizo 
		  integer,	   -- cant_faltan 
		  DATE,		   -- ult_vig 
		  char(255),   -- realizadas
		  CHAR(100),   -- fecha_hoy      
		  CHAR(10),	   -- poliza      
		  CHAR(5);     -- endoso      
	   
--------------------------------------------
---  DETALLE DE POLIZAS DECLARATIVAS - ANUAL    ---
---  Henry Giron - julio 2001 - AMM	 ---
--------------------------------------------
   BEGIN
      DEFINE v_nopoliza,v_nofactura          CHAR(10);
      DEFINE v_nodocumento                   CHAR(20);
      DEFINE v_noendoso,_cod_corredor        CHAR(5);
      DEFINE v_cod_sucursal,v_cod_ramo,v_cod_tipoprod  CHAR(03);
      DEFINE v_cod_usuario                   CHAR(8);
      DEFINE v_cod_contratante               CHAR(10);
      DEFINE v_prima_suscrita,v_suma_asegurada   DECIMAL(16,2);
      DEFINE v_comision                      DECIMAL(9,2);
      DEFINE v_desc_nombre                   CHAR(100);
      DEFINE v_desc_ramo,v_corredor          CHAR(50);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo                           CHAR(01);
      DEFINE v_estatus                       SMALLINT;
      DEFINE v_forma_pago                    CHAR(3);
      DEFINE v_cant_pagos                    SMALLINT;
      DEFINE v_descr_cia                     CHAR(50);
	  DEFINE v_vig_ini,v_vig_fin			 DATE;
	  DEFINE v_cant_anual					 integer;
	  DEFINE v_cant_realizo					 integer;
	  DEFINE v_cant_faltan					 integer;
	  DEFINE v_ult_vig          			 DATE;
	  DEFINE v_fecha_hoy          			 DATE;	  
      DEFINE v_realizadas                    CHAR(255);
      DEFINE v_realizadas_tmp                CHAR(255);
	  DEFINE v_fecha_actual	 				 CHAR(100);
	  DEFINE ls_mes_letra                    CHAR(50);
	  DEFINE ls_anio_letra                   CHAR(4);
	  DEFINE v_anio							 integer;
	  DEFINE v_mes							 integer;
	  DEFINE v_mes_hasta					 integer;	  
	  DEFINE v_contador						 integer;
	  DEFINE v_diferencia    				 integer; 
	  DEFINE _valido 	  					 integer;
	  DEFINE ls_diferencia                   CHAR(2);

      LET v_prima_suscrita  = 0;
      LET v_diferencia      = 0;
      LET v_suma_asegurada  = 0;
      LET v_cant_pagos      = 0;
      LET v_estatus         = NULL;
      LET v_comision        = 0;
      LET v_cod_contratante = NULL;
	  LET v_realizadas      = "";
	  LET v_ult_vig         = null;
	  LET v_fecha_hoy       = current;
      LET v_anio            = 0;
      LET v_mes             = 0;
	  LET v_contador        = 0;
	  LET ls_anio_letra     = "";
	  LET v_realizadas_tmp  = "";
	  call sp_sis20(v_fecha_hoy)  returning v_fecha_actual;

      LET v_descr_cia = sp_sis01(a_compania);
      CALL sp_pro69(a_compania,a_agencia,a_periodo1,
                    a_periodo2,a_codsucursal,a_codgrupo,a_codagente,
                    a_codusuario,a_codramo,a_cliente, a_no_documento)
                    RETURNING v_filtros;

--	  Set debug file to "sp_pr984.trc";

      SET ISOLATION TO DIRTY READ;
      FOREACH WITH HOLD
         SELECT cod_ramo,
         		no_factura,
         		no_documento,
         		cod_contratante,
                suma_asegurada,
                prima,
				vigencia_inic,
				vigencia_final,
				cod_agente
           INTO v_cod_ramo,
           		v_nofactura,
           		v_nodocumento,
           		v_cod_contratante,
                v_suma_asegurada,
                v_prima_suscrita,
				v_vig_ini,
				v_vig_fin,
				_cod_corredor
                FROM temp_det
               WHERE seleccionado = 1
               ORDER BY cod_ramo, vigencia_final

--			 if trim(v_nodocumento) <> "0108-00010-01" then
--			    continue foreach;
--		    end if

			 let _valido = 0;
		  select count(*) 
		    into _valido
		    from emipomae 
		   where no_documento in (v_nodocumento) -- "0108-00010-01" )  
--	         and vigencia_inic >= v_vig_ini
--		     and vigencia_final <= v_vig_fin 
			 AND no_factura     = v_nofactura
		     AND declarativa    = 1 
		     AND estatus_poliza = 1;

			  IF _valido = 0 or _valido is null then
			     continue foreach;
		     END IF

--           Trace on;
			 LET v_cod_ramo			=   v_cod_ramo;
			 LET v_nofactura		=   v_nofactura;
			 LET v_nodocumento		=   v_nodocumento;
			 LET v_cod_contratante	=   v_cod_contratante;
			 LET v_suma_asegurada	=   v_suma_asegurada;
			 LET v_prima_suscrita	=   v_prima_suscrita;
			 LET v_vig_ini			=   v_vig_ini;
			 LET v_vig_fin			=   v_vig_fin;
			 LET _cod_corredor		=   _cod_corredor;		

         SELECT nombre
           INTO v_desc_ramo
           FROM prdramo
          WHERE cod_ramo = v_cod_ramo;

         SELECT nombre
           INTO v_desc_nombre
           FROM cliclien
          WHERE cod_cliente = v_cod_contratante;

         SELECT nombre
           INTO v_corredor
           FROM agtagent
          WHERE cod_agente = _cod_corredor;

			LET v_cant_anual = (month(v_vig_fin) - month(v_vig_ini)) + ((year(v_vig_fin) - year(v_vig_ini)) * 12);

		 select count(*) 
		   into v_cant_realizo
		   from endedmae 
		  where trim(no_documento) = trim(v_nodocumento)
		    and vigencia_inic >= v_vig_ini
		    and vigencia_final <= v_vig_fin
		    and cod_endomov = "023";      

			if v_cant_realizo is null or v_cant_realizo = 0 then 
			   let v_cant_realizo = 0; 
		   end if

		foreach
		 select vigencia_inic 
		   into v_ult_vig 
		   from endedmae 
		  where trim(no_documento) = trim(v_nodocumento) 
		    and vigencia_inic >= v_vig_ini 
		    and vigencia_final <= v_vig_fin 
		    and cod_endomov = "023" 
		  order by vigencia_inic desc 
		   exit foreach;
		    end foreach

			if v_ult_vig is null or v_ult_vig = "" then
			   let v_ult_vig = v_vig_ini;  -- current;
		   end if

			LET v_cant_faltan = v_cant_anual - v_cant_realizo;

			LET v_anio = 0;
			LET v_mes = 0;
			LET v_mes_hasta = 0; 
			LET v_contador = 0;
			LET v_diferencia = 0; 
			LET ls_anio_letra = "";

		 select count(*) 
		   into v_diferencia
		   from endedmae 
		  where trim(no_documento) = trim(v_nodocumento)
		    and vigencia_inic >= v_vig_ini
		    and vigencia_final <= v_vig_fin
		    and cod_endomov = "023";      

			LET v_diferencia = (month(v_fecha_hoy) - month(v_ult_vig)) + ((year(v_fecha_hoy) - year(v_ult_vig)) * 12);

			if v_diferencia is null or v_diferencia = 0 then 
			   let v_diferencia = 0; 
		   end if			

		   LET ls_diferencia = v_diferencia; 
		   let v_mes  = month(v_ult_vig);
		   let v_anio = year(v_ult_vig);
		   
		   while v_diferencia >= 0				
				   LET v_mes = v_mes + 1;
				   IF v_mes = 1 THEN
				      LET ls_mes_letra = 'enero';
				   ELIF v_mes = 2 THEN
				      LET ls_mes_letra = 'febrero';
				   ELIF v_mes = 3 THEN
				      LET ls_mes_letra = 'marzo';
				   ELIF v_mes = 4 THEN
				      LET ls_mes_letra = 'abril';
				   ELIF v_mes = 5 THEN
				      LET ls_mes_letra = 'mayo';
				   ELIF v_mes = 6 THEN
				      LET ls_mes_letra = 'junio';
				   ELIF v_mes = 7 THEN
				      LET ls_mes_letra = 'julio';
				   ELIF v_mes = 8 THEN
				      LET ls_mes_letra = 'agosto';
				   ELIF v_mes = 9 THEN
				      LET ls_mes_letra = 'septiembre';
				   ELIF v_mes = 10 THEN
				      LET ls_mes_letra = 'octubre';
				   ELIF v_mes = 11 THEN
				      LET ls_mes_letra = 'noviembre';
				   ELIF v_mes = 12 THEN
				      LET ls_mes_letra = 'diciembre';
				   END IF
				   LET ls_anio_letra = v_anio;
				   LET v_contador = v_contador + 1;

				    if v_contador = 1 then
					   LET v_realizadas_tmp = trim(v_realizadas_tmp)||trim(upper(ls_mes_letra))||" DE "||trim(upper(ls_anio_letra)) ;
				   else
					   LET v_realizadas_tmp = trim(v_realizadas_tmp)||", "||trim(upper(ls_mes_letra))||" DE "||trim(upper(ls_anio_letra)) ;
				   end if
				   LET v_diferencia = v_diferencia - 1;
					if v_mes = 12 THEN
					   let v_anio = v_anio + 1;
					   LET v_mes  = 0;
				   end if
				   if v_anio = year(today) and v_mes = month(today) then 
					  LET v_diferencia = -1;
				   end if
		   end while
   		   LET v_realizadas = upper(trim(v_realizadas_tmp));

		  select trim(no_poliza),trim(no_endoso)
		    into v_nopoliza,v_noendoso
		    from endedmae 
		   where no_documento in (v_nodocumento)
			 AND no_factura     = v_nofactura ;
	
         RETURN v_cod_ramo,
         		v_desc_ramo,
         		v_nofactura,
         		v_nodocumento,
                v_desc_nombre,
                v_suma_asegurada,
                v_prima_suscrita,
                v_descr_cia,
				v_vig_ini,
				v_vig_fin,
                v_filtros,
				v_corredor,
				v_cant_anual,
				v_cant_realizo,
				v_cant_faltan,
				v_ult_vig,
				v_realizadas,
				v_fecha_actual,
				v_nopoliza,
				v_noendoso
                WITH RESUME;

--	      trace off;

      END FOREACH

   DROP TABLE temp_det;
   END
END PROCEDURE;
