 DROP procedure sp_pro35;
 CREATE procedure "informix".sp_pro35(a_compania CHAR(3),a_agencia CHAR(3),a_no_poliza CHAR(20))
   RETURNING CHAR(5),CHAR(30),CHAR(30),CHAR(30),CHAR(30),
             SMALLINT,CHAR(10),CHAR(50),CHAR(100),CHAR(20),
             CHAR(03),CHAR(50),CHAR(50),dec(16,2),dec(16,2);

--------------------------------------------
---        DETALLE DE UNIDADES           --- 
---  Yinia M. Zamora - octubre 2000 - YMZM
---  Ref. Power Builder - d_sp_pro35
--------------------------------------------

 BEGIN

    DEFINE v_no_poliza                   CHAR(10);
    DEFINE v_contratante,v_placa         CHAR(10);
    DEFINE v_cod_ramo,v_cod_subramo      CHAR(3);
    DEFINE v_descripcion,v_nom_subramo   CHAR(50);
    DEFINE v_no_unidad                   CHAR(5);
    DEFINE v_no_motor,v_no_chasis        CHAR(30);
    DEFINE v_cod_marca                   CHAR(5);
    DEFINE v_cod_modelo                  CHAR(5);
    DEFINE v_ano_auto                    SMALLINT;
    DEFINE v_desc_nombre                 CHAR(100);
    DEFINE v_nom_modelo,v_nom_marca      CHAR(30);
    DEFINE v_descr_cia                   CHAR(50);
	define _suma_asegurada				 dec(16,2);
	define _prima_bruta					 dec(16,2);

    LET v_descr_cia = sp_sis01(a_compania);

	SET ISOLATION TO DIRTY READ; 

	LET v_no_poliza = sp_sis21(a_no_poliza);

    FOREACH WITH HOLD

       SELECT y.cod_contratante,
              y.cod_subramo,
              y.cod_ramo
         INTO v_contratante,
              v_cod_subramo,
			  v_cod_ramo
         FROM emipomae y
        WHERE y.no_poliza       = v_no_poliza

       SELECT nombre
         INTO v_desc_nombre
         FROM cliclien
        WHERE cod_compania = a_compania
          AND cod_cliente  = v_contratante;

       FOREACH WITH HOLD

          SELECT no_unidad,
          		 desc_unidad,
				 suma_asegurada,
				 prima_bruta
            INTO v_no_unidad,
            	 v_descripcion,
			     _suma_asegurada,
				 _prima_bruta
            FROM emipouni
           WHERE no_poliza = v_no_poliza
		   ORDER BY no_unidad

          SELECT no_motor
            INTO v_no_motor
            FROM emiauto
           WHERE no_poliza = v_no_poliza
             AND no_unidad = v_no_unidad;

          SELECT cod_marca,cod_modelo,ano_auto,no_chasis,placa
                 INTO v_cod_marca,v_cod_modelo,v_ano_auto,v_no_chasis,
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

          SELECT nombre
                 INTO v_nom_subramo
                 FROM prdsubra
                WHERE cod_ramo    = v_cod_ramo
                  AND cod_subramo = v_cod_subramo;
		 if _suma_asegurada is null then
			let _suma_asegurada = 0;
		 end if

         RETURN v_no_unidad,v_nom_marca,v_nom_modelo,v_no_motor,
                v_no_chasis,v_ano_auto,v_placa,v_descripcion,
                v_desc_nombre,a_no_poliza,v_cod_subramo,
                v_descr_cia,v_nom_subramo,_suma_asegurada,_prima_bruta
                WITH RESUME;

     END FOREACH

    END FOREACH

   END
END PROCEDURE;
