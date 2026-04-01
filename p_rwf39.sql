-- Trae la Informacion de la Transaccion para Workflow
-- Creado: 27/07/2004 - Amado Perez

DROP PROCEDURE sp_cwf5;

CREATE PROCEDURE "informix".sp_cwf5(v_no_tranrec CHAR(10))
 RETURNING char(50), 			--v_grupo, 
		   char(50), 			--v_ajus_interno,
		   char(50), 			--v_ajus_externo,
		   DEC(16,2),			--v_monto_total, 
		   DEC(16,2),			--v_variacion, 
		   DEC(16,2),			--v_incurrido_tr,
		   DEC(16,2),			--v_reserva_tr,
		   char(1), 			--v_estatus, 
		   char(10),			--v_fecha, 
		   DEC(16,2), 		    --v_reserva, 
		   DEC(16,2), 		    --v_pagado,
		   DEC(16,2), 		    --v_recuperos, 
		   DEC(16,2), 		    --v_incurrido, 
		   char(10), 			--v_accion, 
		   char(10), 			--v_siniestro, 
		   varchar(20), 		--v_deducible,
		   char(10), 			--v_tr_ant_no, 
		   char(10),			--v_tr_ant_fecha,
		   CHAR(100),			--v_nombre_de, 
		   CHAR(100),			--v_asegurado, 
		   CHAR(100),			--v_reclamante,	134
		   CHAR(50),			--v_tipo_trans,	135
		   CHAR(10),			--v_periodos,	136
		   CHAR(10),			--v_transaccion	137
		   CHAR(8),				--              138
		   CHAR(15),			--              139
		   CHAR(18),			--              140
		   CHAR(20),			--              141
		   CHAR(50),			--              142
		   smallint;

--- Reclamos

BEGIN

DEFINE v_nombre_cia   CHAR(50);
DEFINE v_transaccion  CHAR(10);
DEFINE v_tipo_trans   CHAR(50);
DEFINE v_periodo      CHAR(7);
DEFINE v_impresa      DATE;
DEFINE v_elaborada    CHAR(10);
DEFINE v_grupo        CHAR(50);
DEFINE v_nombre_de    CHAR(100);
DEFINE v_asegurado    CHAR(100);
DEFINE v_reclamante   CHAR(100);
DEFINE v_ajus_interno CHAR(50);
DEFINE v_ajus_externo CHAR(50);
DEFINE v_fe_audiencia CHAR(10);
DEFINE v_poliza       CHAR(20);
DEFINE v_monto_total  DEC(16,2);
DEFINE v_variacion    DEC(16,2);
DEFINE v_incurrido_tr DEC(16,2);
DEFINE v_reserva_tr   DEC(16,2);
DEFINE v_descrip      REFERENCES TEXT;
DEFINE v_descrip_1    CHAR(100);
DEFINE v_descrip_2    CHAR(100);
DEFINE v_descrip_3    CHAR(100);
DEFINE v_descrip_4    CHAR(100);
DEFINE v_descrip_5    CHAR(100);
DEFINE v_descrip_6    CHAR(100);
DEFINE v_descrip_7    CHAR(100);
DEFINE v_estatus      CHAR(1);
DEFINE v_fecha        CHAR(10);
DEFINE v_reserva      DEC(16,2);
DEFINE v_pagado       DEC(16,2);
DEFINE v_recuperos    DEC(16,2);
DEFINE v_incurrido    DEC(16,2);
DEFINE v_accion       CHAR(10);
DEFINE v_siniestro    CHAR(10);
DEFINE v_deducible    DEC(16,2);
DEFINE v_tr_ant_no    CHAR(10);
DEFINE v_tr_ant_fecha CHAR(10);
DEFINE v_reaseg       CHAR(15);
DEFINE v_reaseg_monto DECIMAL(8,2);
DEFINE v_coaseg       CHAR(15);
DEFINE v_coaseg_monto DECIMAL(8,2);
DEFINE v_cober        CHAR(15);
DEFINE v_cober_monto  DECIMAL(8,2);
DEFINE v_pagos        CHAR(15);
DEFINE v_pagos_monto  DECIMAL(8,2);
DEFINE v_agente       CHAR(50);

DEFINE v_tipotran     CHAR(3);
DEFINE v_reclamo      CHAR(10);
DEFINE v_compania     CHAR(3);
DEFINE v_no_poliza    CHAR(10);
DEFINE v_cliente      CHAR(10);
DEFINE v_contratante  CHAR(10);
DEFINE v_cod_reclamante CHAR(10);
DEFINE v_interno      CHAR(3);
DEFINE v_externo      CHAR(3);
DEFINE v_estado       CHAR(1);
DEFINE v_valor        CHAR(5);
DEFINE v_cod_grupo    CHAR(5);
DEFINE v_numrecla     CHAR(18);
DEFINE v_periodos     CHAR(10);
DEFINE v_duplicado    CHAR(10);
DEFINE v_no_recibo    CHAR(10);
DEFINE v_user_added   CHAR(8);

DEFINE _no_unidad     CHAR(5);
DEFINE _cod_coasegur  CHAR(3);
DEFINE _porc_coas     DEC(7,4);
DEFINE _porc_reas     DEC(9,6);
DEFINE _no_tranrec    CHAR(10);
DEFINE _tr_pago       CHAR(3);
DEFINE _tr_salv       CHAR(3);
DEFINE _tr_recup      CHAR(3);
DEFINE _tr_deduc      CHAR(3);
DEFINE _cant_impres   SMALLINT;
DEFINE _tran_ant      CHAR(10);
DEFINE _cerrar_rec    SMALLINT;
DEFINE _perd_total    SMALLINT;
DEFINE _perd_desc     CHAR(15);
DEFINE _cod_agente    CHAR(5);

DEFINE _no_tranrec_tmp   CHAR(10);
DEFINE _cod_tipotran_tmp CHAR(3);
DEFINE _fecha_tmp        DATE;
DEFINE _transaccion_tmp  CHAR(10);
DEFINE _variacion_tmp, _monto_tmp, _pagado_tr, _recuperos_tr DEC(16,2);
DEFINE _no_tranrec_int, _tran_ant_int INTEGER; 

DEFINE _cod_ramo      CHAR(3);
DEFINE v_ramo_sis     SMALLINT;


SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_rwf19.trc"; 
--trACE ON;

LET v_monto_total  = 0;
LET v_variacion    = 0;
LET v_incurrido_tr = 0;
LET v_reserva_tr   = 0;
LET v_reserva      = 0;
LET v_pagado       = 0;
LET v_recuperos    = 0;
LET v_incurrido    = 0;
LET v_deducible    = 0;
LET v_coaseg_monto = 0;
LET v_reaseg_monto = 0;
LET v_cober_monto  = 0;
LET v_pagos_monto  = 0;
LET v_accion       = NULL;
LET v_descrip_1    = NULL;
LET v_descrip_2    = NULL;
LET v_descrip_3    = NULL;
LET v_descrip_4    = NULL;
LET v_descrip_5    = NULL;
LET v_descrip_6    = NULL;
LET v_descrip_7    = NULL; 

CREATE TEMP TABLE tmp_rectr(
            no_tranrec_int INTEGER,
			no_tranrec     CHAR(10),
			no_reclamo     CHAR(10),
			cod_tipotran   CHAR(3),
			fecha          DATE,
			transaccion    CHAR(10),  
			variacion      DEC(16,2),
			monto          DEC(16,2),
			PRIMARY KEY (no_tranrec)
			) WITH NO LOG;
                  
select no_reclamo
  into v_reclamo
  from rectrmae
 where no_tranrec = v_no_tranrec;

foreach
select no_tranrec,
       cod_tipotran,
	   fecha,
	   transaccion,
	   variacion,
	   monto
  into _no_tranrec_tmp,
       _cod_tipotran_tmp,
	   _fecha_tmp,
	   _transaccion_tmp,
	   _variacion_tmp,
	   _monto_tmp
  from rectrmae
 where no_reclamo = v_reclamo
   and actualizado = 1
    or (no_tranrec = v_no_tranrec
   and actualizado = 0)

 let _no_tranrec_int = _no_tranrec_tmp;

 insert into tmp_rectr(
 no_tranrec_int,
 no_tranrec,    
 no_reclamo,
 cod_tipotran,  
 fecha,         
 transaccion,   
 variacion,     
 monto
 )         
 values(
 _no_tranrec_int,
 _no_tranrec_tmp,
 v_reclamo,
 _cod_tipotran_tmp,
 _fecha_tmp,
 _transaccion_tmp,
 _variacion_tmp,
 _monto_tmp
 );

end foreach

let _no_tranrec_int = v_no_tranrec;

foreach
   select rectrmae.cod_tipotran, 
          rectrmae.transaccion, 
          rectrmae.periodo,
          rectrmae.fecha, 
          rectrmae.no_reclamo, 
          rectrmae.monto,
          rectrmae.variacion, 
          rectrmae.cod_compania, 
          rectrmae.cod_cliente,
          rectrmae.numrecla, 
          rectrmae.no_tranrec, 
          rectrmae.no_impresion,
		  rectrmae.cerrar_rec,
		  rectrmae.perd_total,
		  rectrmae.user_added
     into v_tipotran, 
     	  v_transaccion, 
     	  v_periodo, 
     	  v_elaborada, 
     	  v_reclamo,
          v_monto_total, 
          v_variacion, 
          v_compania, 
          v_cliente, 
          v_numrecla,
		  _no_tranrec, 
		  _cant_impres, 
		  _cerrar_rec,
		  _perd_total,
		  v_user_added
     from rectrmae
    where rectrmae.no_tranrec  = v_no_tranrec
--	  and rectrmae.actualizado = 1

   select inscias.descr_compania into v_nombre_cia
     from inscias
    where inscias.codigo_compania = v_compania;

   select rectitra.nombre into v_tipo_trans
     from rectitra
    where rectitra.cod_tipotran  = v_tipotran;

	SELECT par_ase_lider
	  INTO _cod_coasegur
	  FROM parparam
	 WHERE cod_compania = v_compania;

  	SELECT porc_partic_coas
	  INTO _porc_coas
	  FROM reccoas
	 WHERE no_reclamo   = v_reclamo
	   AND cod_coasegur = _cod_coasegur;

	IF _porc_coas IS NULL THEN
	  LET _porc_coas = 0;
	END IF

	IF v_tipo_trans IS NULL THEN
	  LET v_tipo_trans = "";
	END IF

{
	-- Puede Haber Mas de un Contrato de Retencion, Por eso el Foreach
	-- Debe escoger el primero en orden de aplicacion, por eso esta ordenado

	LET _porc_reas = NULL;

	FOREACH
	 SELECT	porc_partic_prima
	   INTO	_porc_reas
	   FROM	recreaco r, reacomae c
	  WHERE	r.cod_contrato  = c.cod_contrato
	    AND r.no_reclamo    = v_reclamo
	    ANDDc.tipo_contrato = 1
	  ORDER BY r.orden
		EXIT FOREACH;
	END FOREACH

	IF _porc_reas IS NULL THEN
		LET _porc_reas = 0;
	END IF
}

   LET v_impresa = Current;

   select recrcmae.no_poliza, recrcmae.cod_reclamante, recrcmae.ajust_interno,
          recrcmae.ajust_externo, recrcmae.fecha_audiencia,
          recrcmae.fecha_reclamo, recrcmae.estatus_reclamo,
          recrcmae.fecha_siniestro, recrcmae.no_unidad
     into v_no_poliza, v_cod_reclamante, v_interno, v_externo, v_fe_audiencia,
          v_fecha, v_estado, v_siniestro, _no_unidad
     from recrcmae
    where recrcmae.no_reclamo  = v_reclamo;

	IF _cerrar_rec = 1 THEN
           LET v_accion = 'Cerrar';
        ELSE
	   LET v_accion = '';
	END IF

	LET v_estatus = v_estado;

	LET v_tr_ant_no = NULL;

   select MAX(no_tranrec_int)
     into _tran_ant_int
     from tmp_rectr
    where no_reclamo  = v_reclamo
      and no_tranrec_int  < _no_tranrec_int;

   LET _tran_ant = _tran_ant_int;

   If _tran_ant IS NOT NULL THEN
      select fecha, transaccion
        into v_tr_ant_fecha, v_tr_ant_no
        from rectrmae
       where no_reclamo = v_reclamo
         and no_tranrec = _tran_ant;
   Else
      LET v_tr_ant_no    = "";
      LET v_tr_ant_fecha = "";
   End if

   select emipomae.cod_grupo, emipomae.cod_contratante, emipomae.no_documento, emipomae.cod_ramo
     into v_cod_grupo, v_contratante, v_poliza, _cod_ramo
     from emipomae
    where emipomae.no_poliza  = v_no_poliza;

   select cligrupo.nombre into v_grupo
     from cligrupo
    where cligrupo.cod_grupo  = v_cod_grupo;

   select cliclien.nombre into v_nombre_de
     from cliclien
    where cliclien.cod_cliente = v_cliente;

   select cliclien.nombre into v_asegurado
     from cliclien
    where cliclien.cod_cliente = v_contratante;

   select cliclien.nombre into v_reclamante
     from cliclien
    where cliclien.cod_cliente = v_cod_reclamante;

   select recajust.nombre into v_ajus_interno
     from recajust
    where recajust.cod_ajustador = v_interno;

   select recajust.nombre into v_ajus_externo
     from recajust
    where recajust.cod_ajustador = v_externo;

   select ramo_sis
     into v_ramo_sis
	 from prdramo 
	where cod_ramo = _cod_ramo;

   foreach
	select cod_agente 
	  into _cod_agente
	  from emipoagt
	 where no_poliza = v_no_poliza
	 exit foreach;
   end foreach

   select nombre 
     into v_agente
	 from agtagent
	where cod_agente = _cod_agente;

   if v_ajus_externo Is Null Then
	  LET v_ajus_externo = "";
   end if

   if v_grupo Is Null Then
	  LET v_grupo = "";
   end if

   if v_ajus_interno Is Null Then
	  LET v_ajus_interno = "";
   end if

   if v_asegurado Is Null Then
	  LET v_asegurado = "";
   end if

   if v_reclamante Is Null Then
	  LET v_reclamante = "";
   end if

   if v_nombre_de Is Null Then
	  LET v_nombre_de = "";
   end if

   select SUM(recrccob.deducible) into v_deducible
     from recrccob, rectrcob
    where recrccob.no_reclamo    = v_reclamo
      and recrccob.cod_cobertura = rectrcob.cod_cobertura
      and rectrcob.no_tranrec    = v_no_tranrec;

   if v_deducible Is Null Then
	  LET v_deducible = 0.00;
   end if

   IF v_periodo[6,7] = "01" OR v_periodo[6,7] = "1" THEN
      LET v_periodos = "ENE - " || v_periodo[1,4];
   END IF
   IF v_periodo[6,7] = "02" OR v_periodo[6,7] = "2" THEN
      LET v_periodos = "FEB - " || v_periodo[1,4];
   END IF
   IF v_periodo[6,7] = "03" OR v_periodo[6,7] = "3" THEN
      LET v_periodos = "MAR - " || v_periodo[1,4];
   END IF
   IF v_periodo[6,7] = "04" OR v_periodo[6,7] = "4" THEN
      LET v_periodos = "ABR - " || v_periodo[1,4];
   END IF
   IF v_periodo[6,7] = "05" OR v_periodo[6,7] = "5" THEN
      LET v_periodos = "MAY - " || v_periodo[1,4];
   END IF
   IF v_periodo[6,7] = "06" OR v_periodo[6,7] = "6" THEN
      LET v_periodos = "JUN - " || v_periodo[1,4];
   END IF
   IF v_periodo[6,7] = "07" OR v_periodo[6,7] = "7" THEN
      LET v_periodos = "JUL - " || v_periodo[1,4];
   END IF
   IF v_periodo[6,7] = "08" OR v_periodo[6,7] = "8" THEN
      LET v_periodos = "AGO - " || v_periodo[1,4];
   END IF
   IF v_periodo[6,7] = "09" OR v_periodo[6,7] = "9" THEN
      LET v_periodos = "SEP - " || v_periodo[1,4];
   END IF
   IF v_periodo[6,7] = "10" THEN
      LET v_periodos = "OCT - " || v_periodo[1,4];
   END IF
   IF v_periodo[6,7] = "11" THEN
      LET v_periodos = "NOV - " || v_periodo[1,4];
   END IF
   IF v_periodo[6,7] = "12" THEN
      LET v_periodos = "DIC - " || v_periodo[1,4];
   END IF

	IF _cant_impres = 0 THEN
		LET v_duplicado = '';
	ELSE
		LET v_duplicado = 'DUPLICADO';
	END IF

	-- Totales del Reclamo

	SELECT SUM(variacion)
	  INTO v_reserva
	  FROM tmp_rectr
	 WHERE no_reclamo  = v_reclamo
	   AND no_tranrec_int <= _no_tranrec_int;

	IF v_reserva IS NULL THEN
		LET v_reserva = 0;
	END IF

	SELECT cod_tipotran
	  INTO _tr_pago
	  FROM rectitra
	 WHERE tipo_transaccion = 4;

	SELECT SUM(monto)
	  INTO v_pagado
	  FROM tmp_rectr
	 WHERE no_reclamo   = v_reclamo
	   AND cod_tipotran = _tr_pago
	   AND no_tranrec_int <= _no_tranrec_int;

	IF v_pagado IS NULL THEN
		LET v_pagado = 0;
	END IF

	SELECT cod_tipotran
	  INTO _tr_salv
	  FROM rectitra
	 WHERE tipo_transaccion = 5;

	SELECT cod_tipotran
	  INTO _tr_recup
	  FROM rectitra
	 WHERE tipo_transaccion = 6;

	SELECT cod_tipotran
	  INTO _tr_deduc
	  FROM rectitra
	 WHERE tipo_transaccion = 7;

	SELECT SUM(monto)
	  INTO v_recuperos
	  FROM tmp_rectr
	 WHERE no_reclamo    = v_reclamo
	   AND no_tranrec_int <= _no_tranrec_int
	   AND (cod_tipotran = _tr_salv  OR
	        cod_tipotran = _tr_recup OR
	        cod_tipotran = _tr_deduc);

   	IF v_recuperos IS NULL THEN
		LET v_recuperos = 0;
	END IF

	LET v_reserva	= v_reserva   / 100 * _porc_coas;
	LET v_pagado	= v_pagado    / 100 * _porc_coas;
	LET v_recuperos	= v_recuperos / 100 * _porc_coas;

	LET v_incurrido = v_reserva + v_pagado+ v_recuperos;

	-- Totales de la Transaccion

	SELECT variacion
	  INTO v_reserva_tr
	  FROM tmp_rectr
	 WHERE no_reclamo  = v_reclamo
	   AND no_tranrec_int = _no_tranrec_int;

	IF v_reserva_tr IS NULL THEN
		LET v_reserva_tr = 0;
	END IF

	SELECT monto
	  INTO _pagado_tr
	  FROM tmp_rectr
	 WHERE no_reclamo   = v_reclamo
	   AND cod_tipotran = _tr_pago
	   AND no_tranrec_int = _no_tranrec_int;

	IF _pagado_tr IS NULL THEN
		LET _pagado_tr = 0;
	END IF

	SELECT monto
	  INTO _recuperos_tr
	  FROM tmp_rectr
	 WHERE no_reclamo    = v_reclamo
	   AND no_tranrec_int = _no_tranrec_int
	   AND (cod_tipotran = _tr_salv  OR
	        cod_tipotran = _tr_recup OR
	        cod_tipotran = _tr_deduc);

	IF _recuperos_tr IS NULL THEN
		LET _recuperos_tr = 0;
	END IF

	LET v_reserva_tr  = v_reserva_tr   / 100 * _porc_coas;
	LET _pagado_tr	  = _pagado_tr     / 100 * _porc_coas;
	LET _recuperos_tr = _recuperos_tr  / 100 * _porc_coas;

	LET v_incurrido_tr = v_reserva_tr + _pagado_tr + _recuperos_tr;

{    BEGIN WORK;
		BEGIN
		 	UPDATE rectrmae
		 	   SET no_impresion = no_impresion + 1
		 	 WHERE no_tranrec   = v_no_tranrec;
			-- SE DEBE PONER EL COMMIT DESPUES DE HACER EL UPDATE PARA QUE NO SE BLOQUEN LOS REGISTROS
			-- 10.00 BALBOAS POR ESTE DESCUBRIMIENTO AMADO 13/08/2003
		END
 	COMMIT WORK;}

    SELECT x.descripcion 
      Into v_descrip 
      From rectrdes x
	 WHERE x.no_tranrec = v_no_tranrec;

    SELECT no_recibo 
	  INTO v_no_recibo
	  FROM cobredet
	 WHERE no_tranrec = v_no_tranrec;

	if _perd_total = 1 then
	   let _perd_desc = "Perdida Total";
	else
	   let _perd_desc = "";
	end if	


return v_grupo, 
       v_ajus_interno, 
       v_ajus_externo, 
       v_monto_total, 
       v_variacion, 
       v_incurrido_tr, 
       v_reserva_tr,
       v_estatus, 
       v_fecha, 
       v_reserva, 
       v_pagado,
       v_recuperos, 
       v_incurrido, 
       v_accion, 
       v_siniestro, 
       v_deducible,
       v_tr_ant_no, 
       v_tr_ant_fecha,
	   Trim(v_nombre_de), 
	   Trim(v_asegurado), 
	   Trim(v_reclamante),
	   v_tipo_trans,
	   v_periodos,
	   v_transaccion,
	   v_user_added,
	   _perd_desc,
	   v_numrecla,
	   v_poliza,
	   TRIM(v_agente),
	   v_ramo_sis
       with resume;								  

END FOREACH
END
DROP TABLE tmp_rectr;
END PROCEDURE;
