  --Son 2 querys que traen la informacion para Panama Asistencia

  SELECT Cliclien.nombre, Emipomae.no_documento, Emimarca.nombre,
  Emimodel.nombre, Emivehic.ano_auto, Emivehic.placa,
  Emipomae.vigencia_inic, Emipomae.vigencia_final, Emipouni.no_unidad,
  Emiauto.uso_auto
   FROM informix.emipomae Emipomae, informix.emimarca Emimarca,
  informix.emimodel Emimodel, informix.cliclien Cliclien,
  informix.emipouni Emipouni, informix.emiauto Emiauto,
  informix.emivehic Emivehic
   WHERE Cliclien.cod_cliente = Emipomae.cod_contratante
   AND Emipomae.no_poliza = Emipouni.no_poliza
   AND Emiauto.no_poliza = Emipouni.no_poliza
   AND Emiauto.no_unidad = Emipouni.no_unidad
   AND Emivehic.no_motor = Emiauto.no_motor
   AND Emimodel.cod_marca = Emivehic.cod_marca
   AND Emimodel.cod_modelo = Emivehic.cod_modelo
   AND Emimarca.cod_marca = Emivehic.cod_marca
   AND (Emipomae.cod_ramo = '002'			-- Todas las  polizas de automovil
   AND Emipouni.vigencia_inic <= '&hoy'		-- Que estan vigentes a la fecha de hoy
   AND Emipouni.vigencia_final >= '&hoy'
   AND Emiauto.cod_tipoveh = '005'			-- Que el tipo de vehiculo sea "VEHICULOS LIVIANOS (CUPES,SEDANES,CAMIONETAS,4X4)"
   AND Emiauto.uso_auto = 'P'				-- De uso particular
   AND Emipomae.actualizado = 1				-- Actualizados
   AND Emipomae.estatus_poliza = 1)			-- cuyo estatus_poliza sea Vigente


  SELECT Cliclien.nombre, Emipomae.no_documento, Emimarca.nombre,
  Emimodel.nombre, Emivehic.ano_auto, Emivehic.placa,
  Emipomae.vigencia_inic, Emipomae.vigencia_final, Emipouni.no_unidad,
  Emiauto.uso_auto
   FROM informix.emipomae Emipomae, informix.emimarca Emimarca,
  informix.emimodel Emimodel, informix.cliclien Cliclien,
  informix.emipouni Emipouni, informix.emiauto Emiauto,
  informix.emivehic Emivehic, informix.emipocob Emipocob
   WHERE Cliclien.cod_cliente = Emipomae.cod_contratante
   AND Emipomae.no_poliza = Emipouni.no_poliza
   AND Emiauto.no_poliza = Emipouni.no_poliza
   AND Emiauto.no_unidad = Emipouni.no_unidad
   AND Emivehic.no_motor = Emiauto.no_motor
   AND Emimodel.cod_marca = Emivehic.cod_marca
   AND Emimodel.cod_modelo = Emivehic.cod_modelo
   AND Emimarca.cod_marca = Emivehic.cod_marca
   AND Emipocob.no_poliza = Emipouni.no_poliza
   AND Emipocob.no_unidad = Emipouni.no_unidad  
   AND Emipocob.no_poliza = Emipouni.no_poliza
   AND Emipocob.no_unidad = Emipouni.no_unidad  
   AND (Emipomae.cod_ramo = '002'		 -- Todas las  polizas de automovil
   AND Emipouni.vigencia_inic <= '&hoy'	 -- Que estan vigentes a la fecha de hoy
   AND Emipouni.vigencia_final >= '&hoy'
   AND Emipocob.cod_cobertura = '00907'	 --> que tengan la cobertura de Asistencia Vial
   AND Emipomae.actualizado = 1			 -- Actualizados
   AND Emipomae.estatus_poliza = 1)		 -- cuyo estatus_poliza sea Vigente
