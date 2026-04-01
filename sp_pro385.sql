-- Consulta de Auditores
-- Creado    : 16/12/2019 - Autor: Henry Girón  
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_pro385('001','001','2019-09','2019-09',"*","*","*","*","*","*")

DROP procedure sp_pro385;
CREATE procedure "informix".sp_pro385(
a_compania    CHAR(03),
a_agencia     CHAR(03),
a_periodo1    CHAR(07),
a_periodo2    CHAR(07),
a_codsucursal CHAR(255) DEFAULT "*",
a_codgrupo    CHAR(255) DEFAULT "*",
a_codagente   CHAR(255) DEFAULT "*",
a_codusuario  CHAR(255) DEFAULT "*",
a_codramo     CHAR(255) DEFAULT "*",
a_reaseguro   CHAR(255) DEFAULT "*"
)
-- ramo, factura, v_poliza, v_asegurado, v_fecha,
-- v_prima suscrita, v_porc_comis, comisión,
-- vigencia_inicial, vigencia_final

RETURNING CHAR(3)     as v_cod_ramo,
		  CHAR(50)    as v_desc_ramo,		  
		  CHAR(10)    as v_nofactura,
		  CHAR(20)    as v_nodocumento,
		  varchar(50) as v_nombre_cli,
		  date        as v_fecha,		  
		  DEC(16,2)   as v_prima_suscrita,
		  DEC(10,2)   as v_comision,		  
          DEC(10,2)   as v_porc_comision,
		 -- DEC(5,2)    as v_porc_comis_agt,
		  date        as v_vigencia_inic,
		  date        as v_vigencia_final,		  		  
          CHAR(50)    as v_descr_cia,
          CHAR(255)   as v_filtros,
          char(7)     as v_periodo;
BEGIN
      DEFINE v_cod_sucursal,v_cod_ramo,v_cod_tipoprod  CHAR(03);
      DEFINE v_cod_agente                    CHAR(5);
      DEFINE v_prima_suscrita                DECIMAL(16,2);
      DEFINE v_comision                      DECIMAL(10,2);
      DEFINE v_porc_comision                 DECIMAL(10,2);
      DEFINE v_filtros                       CHAR(255);
      DEFINE v_desc_ramo,v_descr_cia         CHAR(50);
	  define v_nofactura			         char(10);
	  define v_nombre_cli			         varchar(50);
	  define v_vigencia_inic		         date;
	  define v_vigencia_final		         date;
	  define v_fecha		                 date;
	  define v_nodocumento		             char(20);
	  define v_cod_contratante	             char(10);
	  define v_nopoliza			             char(10);
	  define v_porc_comis_agt                DEC(5,2);
	  define v_periodo                       char(7);
	  drop table if exists temp_det;	
      LET v_prima_suscrita  = 0;
      LET v_comision        = 0;
      LET v_porc_comision   = 0;

      LET v_descr_cia = sp_sis01(a_compania);
      CALL sp_pro34(a_compania,
      				a_agencia,
      				a_periodo1,
                    a_periodo2,
                    a_codsucursal,
                    a_codgrupo,
                    a_codagente,
                    a_codusuario,
                    a_codramo,
                    a_reaseguro)
                    RETURNING v_filtros;

	  SET ISOLATION TO DIRTY READ;
--set debug file to "sp_pro385.trc";
--trace on;
      FOREACH  --WITH HOLD
         SELECT a.cod_ramo, 
		        a.no_poliza, 
				a.no_factura,
            	SUM(a.prima),
         		SUM(a.comision)
		   INTO v_cod_ramo,
		        v_nopoliza,
		        v_nofactura,
           		v_prima_suscrita,
           		v_comision				
           FROM temp_det  a , endedmae b
          WHERE a.seleccionado = 1 --and a.no_factura = '09-236664'
          and a.no_poliza = b.no_poliza
          and a.no_endoso = b.no_endoso
          and a.no_factura = b.no_factura
       GROUP BY a.cod_ramo,a.no_poliza,a.no_factura
       ORDER BY a.cod_ramo,a.no_factura,a.no_poliza
	   
        { SELECT cod_ramo,
		        no_factura,
            	SUM(prima),
         		SUM(comision)
           INTO v_cod_ramo,
		        v_nofactura,
           		v_prima_suscrita,
           		v_comision
           FROM temp_det
          WHERE seleccionado = 1
       GROUP BY cod_ramo,no_factura
       ORDER BY cod_ramo,no_factura}
	   
	    select fecha_emision, periodo
		  into v_fecha, v_periodo
		  from endedmae
		 where no_factura = v_nofactura		 
		   and cod_compania = a_compania
		   and no_poliza = v_nopoliza
		   and actualizado  = 1;
		      

		select no_documento,
			   cod_contratante,
			   vigencia_inic,
			   vigencia_final
		  into v_nodocumento,
			   v_cod_contratante,
			   v_vigencia_inic,
			   v_vigencia_final
		  from emipomae
		 where no_poliza    = v_nopoliza
		   --and cod_compania = a_compania
		   and actualizado  = 1;		   	   	   
		   
		select trim(nombre)
		  into v_nombre_cli
		  from cliclien
		 where cod_cliente = v_cod_contratante; 		   

         SELECT nombre
           INTO v_desc_ramo
           FROM prdramo
          WHERE cod_ramo = v_cod_ramo;

         IF v_prima_suscrita <> 0 THEN
            LET v_porc_comision = ((v_comision/v_prima_suscrita)*100);
         END IF
		 {
		 foreach
		 select porc_comis_agt
		   into v_porc_comis_agt
		   from temp_det		     
		  where seleccionado = 1 
		    and no_factura = v_nofactura
			order by 1 desc
		   exit foreach;
		   
			end foreach
			}
		 
         RETURN v_cod_ramo,
         		v_desc_ramo,
				v_nofactura,
				v_nodocumento,
				v_nombre_cli,
				v_fecha,		  
         		v_prima_suscrita,
         		v_comision,
                v_porc_comision,
				--v_porc_comis_agt,
				v_vigencia_inic,
				v_vigencia_final,
                v_descr_cia,
                v_filtros,
                v_periodo				
				WITH RESUME;					  

      END FOREACH

   --DROP TABLE temp_det;
END
END PROCEDURE;