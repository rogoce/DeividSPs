--------------------------------------------
---  REPORTE AUDITORIA INTERNA DE AUTOMOVIL
---  Armando Moreno M. 07/06/2022
--------------------------------------------

DROP procedure sp_amm_aud_prod;
CREATE procedure sp_amm_aud_prod()
RETURNING char(3),char(20),date,date,date,varchar(100),varchar(50),char(15),varchar(50),varchar(50),varchar(50),char(10),smallint,char(1),char(1);

BEGIN

    DEFINE v_no_poliza                        CHAR(10);
    DEFINE v_no_documento                     CHAR(20);
    DEFINE v_vigencia_inic					  DATE;
    DEFINE v_vigencia_final					  DATE;
    DEFINE v_contratante,v_placa              CHAR(10);
    DEFINE v_no_unidad                        CHAR(5);
    DEFINE v_no_motor                         CHAR(30);
    DEFINE v_cod_marca                        CHAR(5);
    DEFINE v_cod_modelo                       CHAR(5);
    DEFINE v_ano_auto                         SMALLINT;
    DEFINE v_nom_modelo,v_nom_marca           CHAR(50);
	DEFINE _fecha_suscripcion                 DATE;
	DEFINE _cod_agente                        char(5);
	define _n_corredor						  varchar(50);
	DEFINE _uso_auto,_nueva_renov             char(1);
	DEFINE _cod_producto                      char(5);
	DEFINE v_producto                         varchar(50);
	DEFINE _cod_ramo                          char(3);
	define _estatus                           smallint;
	define _estatus_char                      char(15);
	define _n_asegurado                       varchar(100);

SET ISOLATION TO DIRTY READ;
    
FOREACH WITH HOLD
   SELECT no_poliza,
		  no_documento,
		  vigencia_inic,
		  vigencia_final,
		  nueva_renov,
		  fecha_suscripcion,
		  cod_ramo,
		  cod_contratante,
		  estatus_poliza
	 INTO v_no_poliza,
		  v_no_documento,
		  v_vigencia_inic,
		  v_vigencia_final,
		  _nueva_renov,
		  _fecha_suscripcion,
		  _cod_ramo,
		  v_contratante,
		  _estatus
	 FROM emipomae
	WHERE cod_ramo in('002','020')
	  AND actualizado = 1
	  and fecha_suscripcion between '31/05/2021' and '31/05/2022'

   foreach
	   SELECT cod_agente
		 INTO _cod_agente
		 FROM emipoagt
		WHERE no_poliza = v_no_poliza

	  exit foreach;
   end foreach

   select nombre
     into _n_corredor
	 from agtagent
	where cod_agente = _cod_agente;
	
   select nombre
     into _n_asegurado
	 from cliclien
	where cod_cliente = v_contratante;

   if _estatus = 1 then
		let _estatus_char = 'Vigente';
   elif _estatus = 2 then
		let _estatus_char = 'Cancelada';
   elif _estatus = 3 then
		let _estatus_char = 'Vencida';
   else
		let _estatus_char = 'Anulada';
   end if

   FOREACH 
	  SELECT no_unidad,
			 cod_producto
		INTO v_no_unidad,
			 _cod_producto
		FROM emipouni
	   WHERE no_poliza = v_no_poliza

	   SELECT nombre
		 INTO v_producto
		 FROM prdprod
		WHERE cod_producto = _cod_producto;
		
        select no_motor,
		       uso_auto
		  into v_no_motor,
		       _uso_auto
		  from emiauto
		 where no_poliza = v_no_poliza
           and no_unidad = v_no_unidad;

		select cod_marca,
		       cod_modelo,
			   placa,
			   ano_auto
		  into v_cod_marca,
		       v_cod_modelo,
			   v_placa,
			   v_ano_auto
		  from emivehic
         where no_motor = v_no_motor;
		 
		select nombre into v_nom_marca from emimarca where cod_marca = v_cod_marca;
		select nombre into v_nom_modelo from emimodel where cod_marca = v_cod_marca and cod_modelo = v_cod_modelo;
		
		 return _cod_ramo,v_no_documento,v_vigencia_inic,v_vigencia_final,_fecha_suscripcion,_n_asegurado,v_producto,_estatus_char,
                _n_corredor,v_nom_marca,v_nom_modelo,v_placa,v_ano_auto,_uso_auto,_nueva_renov with resume;

   END FOREACH 
END FOREACH
END
END PROCEDURE;
