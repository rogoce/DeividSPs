 DROP procedure sp_pro35_actuario;
 CREATE procedure "informix".sp_pro35_actuario(a_compania CHAR(3),a_agencia CHAR(3),a_periodo char(7), a_periodo2 char(7))
   RETURNING CHAR(20),CHAR(5),CHAR(50),SMALLINT,dec(16,2),char(1);


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
    DEFINE v_tipo_vehic                  CHAR(50);
    DEFINE v_cod_modelo                  CHAR(5);
    DEFINE v_ano_auto                    SMALLINT;
    DEFINE v_desc_nombre                 CHAR(100);
    DEFINE v_nom_modelo,v_nom_marca      CHAR(30);
    DEFINE v_descr_cia                   CHAR(50);
	define _suma_asegurada				 dec(16,2);
	define _prima_bruta					 dec(16,2);
	define _nombre_acreedor              char(100);
	define _no_doc                       char(20);
	define _nueva_renov                  char(1);
	define _cod_tipoauto                 char(3);
	define v_cod_marca                   char(5);

    LET v_descr_cia = sp_sis01(a_compania);

	SET ISOLATION TO DIRTY READ; 


		

    FOREACH WITH HOLD

       SELECT cod_subramo,
              cod_ramo,
			  no_documento,
			  nueva_renov,
			  no_poliza
         INTO v_cod_subramo,
			  v_cod_ramo,
			  _no_doc,
			  _nueva_renov,
			  v_no_poliza
         FROM emipomae
        WHERE actualizado = 1
		  AND periodo >= a_periodo
		  AND periodo <= a_periodo2
		  AND cod_ramo = '002'
		 order by no_documento

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

          SELECT nombre,
		         cod_tipoauto
            INTO v_nom_modelo,
			     _cod_tipoauto
            FROM emimodel
           WHERE cod_marca  = v_cod_marca
             AND cod_modelo = v_cod_modelo;

 
          SELECT nombre
            INTO v_tipo_vehic
            FROM emitiaut
           WHERE cod_tipoauto  = _cod_tipoauto;

		 if _suma_asegurada is null then
			let _suma_asegurada = 0;
		 end if

         RETURN _no_doc,v_no_unidad,v_tipo_vehic,v_ano_auto,_suma_asegurada,_nueva_renov WITH RESUME;

     END FOREACH

    END FOREACH

   END
END PROCEDURE;
