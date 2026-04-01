 --------------------------------------------
---       POLIZAS QUE PERTENECIERON A LOS NUMEROS DE PLACAS          --- 
---  Federico Coronado 12/04/2013 
--------------------------------------------
DROP procedure sp_imp14;
 CREATE procedure "informix".sp_imp14(a_no_placa CHAR(6))
    RETURNING CHAR(20),CHAR(30),char(10), date;
 BEGIN

    DEFINE v_no_poliza                   CHAR(10);
    DEFINE v_contratante,v_placa         CHAR(10);
    DEFINE v_no_unidad                   CHAR(5);
    DEFINE v_no_motor                    CHAR(30);
    DEFINE v_desc_nombre                 CHAR(100);
    DEFINE v_no_documento                CHAR(30);
	DEFINE v_estado_nombre               char(30);
	DEFINE v_vigencia_final              date;
	DEFINE v_estatus                     smallint;

   -- LET v_descr_cia = sp_sis01(a_compania);

	SET ISOLATION TO DIRTY READ; 

   -- LET v_no_poliza = sp_sis21(a_no_poliza);
     FOREACH
       SELECT no_motor
	   into v_no_motor
		FROM emivehic
	   WHERE placa = a_no_placa
	   and no_motor <> '' 
	   and no_motor is not null

       FOREACH
         select no_poliza, no_unidad
			into v_no_poliza, v_no_unidad
	     from emiauto
		 where no_motor = v_no_motor

         select cod_contratante, no_documento, estatus_poliza, vigencia_final
			into v_contratante, v_no_documento, v_estatus, v_vigencia_final 
		 from emipomae
		 where no_poliza = v_no_poliza;
		  
		 SELECT nombre
			INTO v_desc_nombre
         FROM cliclien
		 WHERE cod_cliente  = v_contratante;
		 
		 if v_estatus = 1 then
			let v_estado_nombre = "VIGENTE";
		elif v_estatus = 2 then
			let v_estado_nombre = "CANCELADA";
		elif v_estatus = 3 then
			let v_estado_nombre = "VENCIDA";
		elif v_estatus = 4 then
			let v_estado_nombre = "ANULADA";
		end if

         RETURN v_no_documento, v_desc_nombre, v_estado_nombre, v_vigencia_final
                 WITH RESUME;

		END FOREACH
	 END FOREACH

   END
END PROCEDURE