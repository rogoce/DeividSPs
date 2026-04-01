 DROP procedure sp_pro25;
 CREATE procedure "informix".sp_pro25(a_compania CHAR(3),a_no_poliza CHAR(20),a_fecha_desde DATE)
   RETURNING CHAR(5),CHAR(3),CHAR(5),SMALLINT,CHAR(10),CHAR(30),DECIMAL(16,2),
             CHAR(50),DATE,DATE,CHAR(100),DATE,CHAR(20),CHAR(50),
             CHAR(30),CHAR(30);
 
--------------------------------------------
---  LISTADO DE FLOTAS DE AUTOMOVIL      ---
---         POLIZAS VIGENTES             ---
---  Yinia M. Zamora - agosto 2000 - YMZM
---  Ref. Power Builder - d_sp_pro25
--------------------------------------------

 BEGIN

    DEFINE v_no_poliza                   CHAR(10);
    DEFINE v_no_documento                CHAR(20);
    DEFINE v_vigencia_inic,v_vigencia_final,v_fecha_cancel   DATE;
    DEFINE v_contratante,v_placa              CHAR(10);
    DEFINE v_cod_ramo                         CHAR(3);
    DEFINE v_suma_asegurada                   DECIMAL(16,2);
    DEFINE v_descripcion                      CHAR(50);
    DEFINE v_no_unidad                        CHAR(5);
    DEFINE v_no_motor                         CHAR(30);
    DEFINE v_cod_marca                        CHAR(5);
    DEFINE v_cod_modelo                       CHAR(5);
    DEFINE v_ano_auto                         SMALLINT;
    DEFINE v_desc_nombre                      CHAR(100);
    DEFINE v_nom_modelo,v_nom_marca           CHAR(30);
    DEFINE v_descr_cia                        CHAR(50);

    LET v_descr_cia = sp_sis01(a_compania);
	LET v_descripcion = " ";
    SET ISOLATION TO DIRTY READ; 

foreach
    SELECT cod_ramo
      INTO v_cod_ramo
      FROM prdramo
     WHERE ramo_sis = 1


    FOREACH WITH HOLD

       SELECT y.no_poliza,
       		  y.no_documento,
       		  y.vigencia_inic,
              y.vigencia_final,
              y.cod_contratante,
              y.fecha_cancelacion
         INTO v_no_poliza,
         	  v_no_documento,
         	  v_vigencia_inic,
              v_vigencia_final,
              v_contratante,
              v_fecha_cancel
         FROM emipomae y,emitipro z
        WHERE y.cod_compania = a_compania
          AND y.no_documento    = a_no_poliza
          AND y.cod_ramo        = v_cod_ramo
          AND y.vigencia_final >= a_fecha_desde
		  AND y.cod_tipoprod    = z.cod_tipoprod
          AND z.tipo_produccion <> 4
			   
		 SELECT nombre
		  INTO v_desc_nombre
		  FROM cliclien
		 WHERE cod_compania = a_compania
		   AND cod_cliente  = v_contratante;

       FOREACH 
          SELECT no_unidad,
          		 suma_asegurada
            INTO v_no_unidad,
            	 v_suma_asegurada
            FROM emipouni
           WHERE no_poliza = v_no_poliza

			select max(no_factura)
			  into v_descripcion
			  from endedmae e, endeduni u
			 where e.no_poliza = u.no_poliza
			   and e.no_endoso = u.no_endoso
			   and e.no_poliza = v_no_poliza
			   and u.no_unidad = v_no_unidad
			   and e.cod_endomov in ("011", "004"); 

          SELECT no_motor
            INTO v_no_motor
            FROM emiauto
           WHERE no_poliza = v_no_poliza
             AND no_unidad = v_no_unidad;

          SELECT cod_marca,
          		 cod_modelo,
          		 ano_auto,
          		 placa
            INTO v_cod_marca,
            	 v_cod_modelo,
            	 v_ano_auto,
            	 v_placa
            FROM emivehic
           WHERE no_motor = v_no_motor;

          SELECT nombre
            INTO v_nom_modelo
            FROM emimodel
           WHERE cod_marca  = v_cod_marca
             AND cod_modelo = v_cod_modelo;

          SELECT nombre
            INTO v_nom_marca
            FROM emimarca
           WHERE cod_marca  = v_cod_marca;

         RETURN v_no_unidad,
         		v_cod_modelo,
         		v_cod_marca,
         		v_ano_auto,
                v_placa,
                v_no_motor,
                v_suma_asegurada,
                v_descripcion,
                v_vigencia_inic,
                v_vigencia_final,
                v_desc_nombre,
                a_fecha_desde,
                v_no_documento,
                v_descr_cia,	
                v_nom_modelo,
                v_nom_marca WITH RESUME;

          END FOREACH 
    END FOREACH
end foreach
END
END PROCEDURE;
