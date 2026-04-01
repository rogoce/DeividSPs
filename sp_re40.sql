-- Informe de Estatus del Reclamo. Encabezado y Detalle de Transacciones
-- Creado    : 17/01/2001 - Autor: Marquelda Valdelamar
-- Mod.      : 26/11/2001 - Autor: Armando Moreno
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_re40;

CREATE PROCEDURE sp_re40(
a_compania     CHAR(3),
a_agencia      CHAR(3),   
a_numrecla     CHAR(18)
)
RETURNING CHAR(20),	     -- no_documento
		  CHAR(18),	     -- numrecla
		  CHAR(50),	     -- estatus_reclamo
		  DATE,          -- fecha_reclamo
		  DATE, 	     -- fecha_siniestro
		  CHAR(50),      -- nombre_asegurado
		  CHAR(50),      -- ajustador_interno
		  CHAR(50),      -- ajustador_externo     
		  DEC(9,6),      -- reaseguro        
          DEC(7,4),      -- coaseguro
          CHAR(10),      -- transaccion,
          DATE,          -- fecha_tran,
          CHAR(50),      -- nombre_tran,
          CHAR(50),      -- nombre_cliente,
          DEC(16,2),     -- monto_tran,
		  DEC(16,2),     -- variacion,
          DEC(16,2),     -- reserva,
          DEC(16,2),     -- pagado,
		  DEC(16,2),     -- recuperos,
   		  DEC(16,2),     -- incurrido,
		  DEC(16,2),     -- deducible,
		  DEC(16,2),     -- estimado,
		  DEC(16,2),     -- pagado_tot      		
		  DEC(16,2),     -- pagado_recupero
		  CHAR(05),		 -- no_recupero
		  char(10),      -- deducible(transacciones)
		  CHAR(50),      -- grupo
		  CHAR(255),     -- compania
		  DEC(16,2),     -- incurrido neto
		  CHAR(50);		 -- RECLAMANTE
      			  		         
DEFINE _cod_coasegur        CHAR(3);      
DEFINE _ajust_interno       CHAR(3);
DEFINE _ajust_externo	    CHAR(3);
DEFINE _cod_tipotran        CHAR(3);
DEFINE _cod_contrato	    CHAR(5);
DEFINE _cod_grupo		    CHAR(5);
DEFINE _no_recupero 	    CHAR(5);
DEFINE _cod_cliente         CHAR(10);
DEFINE _cod_asegurado       CHAR(10);
DEFINE _no_reclamo 		    CHAR(10);
DEFINE _transaccion         CHAR(10);
DEFINE _anular_nt           CHAR(10);
DEFINE _no_tranrec          CHAR(10);
DEFINE _no_documento        CHAR(20);
DEFINE _nombre_interno	    CHAR(50);
DEFINE _nombre_externo	    CHAR(50);
DEFINE _nombre_asegurado    CHAR(50);
DEFINE _n_reclamante   		CHAR(50);
DEFINE _nombre_cliente      CHAR(50);
DEFINE _nombre_tran         CHAR(50);
DEFINE v_compania_nombre    CHAR(50);
DEFINE estatus              CHAR(50);
DEFINE _estatus_reclamo     CHAR(50);
DEFINE _grupo               CHAR(50);

DEFINE _tipo_contrato       INT;
DEFINE _tipo_transaccion    INT;

DEFINE _fecha_reclamo       DATE;
DEFINE _fecha_siniestro     DATE;
DEFINE _fecha_tran          DATE;

DEFINE _porc_partic_suma	DECIMAL(9,6);  -- % reaseguro
DEFINE _porc_partic_reas	DECIMAL(9,6);  -- % reaseguro
DEFINE _porc_partic_coas	DECIMAL(7,4);  -- % coaseguro
DEFINE _monto_tran          DECIMAL(16,2);
DEFINE _variacion           DECIMAL(16,2);
DEFINE _reserva     		DECIMAL(16,2);
DEFINE _pagado              DECIMAL(16,2);
DEFINE _recuperos           DECIMAL(16,2);
DEFINE _incurrido   		DECIMAL(16,2);
DEFINE _deducible   		DECIMAL(16,2);
DEFINE _estimado    		DECIMAL(16,2);
DEFINE _pagado_tot    		DECIMAL(16,2);
DEFINE _pagado_recup   		DECIMAL(16,2);
DEFINE _pagado_salida		DECIMAL(16,2);
DEFINE _recuperos_salida  	DECIMAL(16,2);
DEFINE _ded				  	DECIMAL(16,2);
DEFINE _cerrar_rec			SMALLINT;
DEFINE _wf_apr_j_fh 		DATETIME year to fraction(5);
DEFINE _wf_apr_jt_fh 		DATETIME year to fraction(5);
DEFINE _wf_apr_jt_2_fh 		DATETIME year to fraction(5);
DEFINE _wf_apr_g_fh			DATETIME year to fraction(5);
DEFINE _no_remesa           CHAR(10);
DEFINE _no_requis,_cod_reclamante  CHAR(10);
DEFINE _no_cheque 			INTEGER;

define _incurrido_bruto		dec(16,2);
define _incurrido_neto		dec(16,2);
define _sumar_incurrido		dec(16,2);

LET _reserva   		  = 0.00;
LET _pagado    		  = 0.00;
LET _recuperos 	 	  = 0.00;
LET _ded     	 	  = 0.00;
LET _incurrido 		  = 0.00;
LET _pagado_tot 	  = 0.00;
LET _pagado_recup 	  = 0.00;
LET _pagado_salida 	  = 0.00;
LET _recuperos_salida = 0.00;
LET _no_recupero      = Null;
LET _cod_coasegur     = sp_sis02(a_compania, a_agencia);
let _porc_partic_reas = 0;

LET _incurrido_bruto  = 0.00;
LET _incurrido_neto	  = 0.00;
LET _sumar_incurrido  = 0.00;

CREATE TEMP TABLE tmp_arreglo(
	   no_tranrec     CHAR(10),
	   transaccion    CHAR(10),
	   fecha	      DATE,
	   monto	      DEC(16,2),
	   variacion      DEC(16,2),
	   cod_tipotran	  CHAR(3),
	   cod_cliente	  CHAR(10),
	   cerrar_rec	  SMALLINT,
	   wf_apr_j_fh    DATETIME year to fraction(5), 
	   wf_apr_jt_fh   DATETIME year to fraction(5), 
	   wf_apr_jt_2_fh DATETIME year to fraction(5), 
	   wf_apr_g_fh	  DATETIME year to fraction(5),
	   anular_nt	  char(10)	
		) WITH NO LOG;
		
---SET DEBUG FILE TO "sp_re40.trc ";
--TRACE ON;

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania
	LET  v_compania_nombre = sp_sis01(a_compania);


-- Datos del Reclamo
	SELECT estatus_reclamo,
	   	   fecha_reclamo,
		   fecha_siniestro,
		   ajust_interno,
		   ajust_externo,
		   no_documento,
		   cod_asegurado,
		   no_reclamo,
		   cod_reclamante
      INTO _estatus_reclamo,
	       _fecha_reclamo,
		   _fecha_siniestro,
		   _ajust_interno,
		   _ajust_externo,
		   _no_documento,
		   _cod_asegurado,
		   _no_reclamo,
		   _cod_reclamante
   	  FROM recrcmae
     WHERE numrecla = a_numrecla
       AND actualizado = 1;

-- Coberturas por Reclamo
	SELECT SUM(deducible),SUM(estimado)
	  INTO _deducible,
	       _estimado
	  FROM recrccob
	 WHERE no_reclamo = _no_reclamo;

	If _estatus_reclamo = 'A' Then
	 LET estatus = 'ABIERTO';
	ELIF _estatus_reclamo = 'C' Then
	 LET estatus = 'CERRADO';
	ELIF _estatus_reclamo = 'R' Then
	 LET estatus = 'RE-ABIERTO';
	ELIF _estatus_reclamo = 'T' Then
	 LET estatus = 'EN TRAMITE';
	ELIF _estatus_reclamo = 'D' Then
	 LET estatus = 'DECLINADO';
	ELIF _estatus_reclamo = 'N' Then
	 LET estatus = 'NO APLICA';
	END IF
 
-- Seleccion del Nombre del Ajustador Interno y Externo
	SELECT nombre
	  INTO _nombre_interno
	  FROM recajust
	 WHERE cod_ajustador = _ajust_interno;

    SELECT nombre
	  INTO _nombre_externo
	  FROM recajust
	 WHERE cod_ajustador = _ajust_externo;

-- Asegurado de la Poliza
    SELECT nombre
	  INTO _nombre_asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_asegurado;

-- Reclamante
    SELECT nombre
	  INTO _n_reclamante
	  FROM cliclien
	 WHERE cod_cliente = _cod_reclamante;

-- Coberturas por Reclamo
   FOREACH
    SELECT SUM (deducible), SUM(estimado)
      INTO _deducible,
           _estimado
	  FROM recrccob
	 WHERE no_reclamo = _no_reclamo
   END FOREACH

-- Porcentaje de Coaseguro
	SELECT porc_partic_coas
	 INTO  _porc_partic_coas
	 FROM  reccoas
	WHERE  no_reclamo = _no_reclamo
	  AND  cod_coasegur = _cod_coasegur; 

	IF _porc_partic_coas IS NULL THEN
		LET _porc_partic_coas = 0;
	END IF

-- Informacion de Reaseguro

LET _porc_partic_suma = NULL;

FOREACH
 SELECT recreaco.porc_partic_suma
   INTO _porc_partic_suma
   FROM recreaco, reacomae
  WHERE recreaco.no_reclamo    = _no_reclamo
    AND recreaco.cod_contrato  = reacomae.cod_contrato
    AND reacomae.tipo_contrato = 1

	IF _porc_partic_suma IS NULL THEN
		LET _porc_partic_suma = 0;
	END IF;

	EXIT FOREACH;

END FOREACH

	IF _porc_partic_suma IS NULL THEN
		LET _porc_partic_suma = 0;
	END IF;

	SELECT SUM(r.monto)
	  INTO _pagado_tot
	  FROM rectrmae r, rectitra t
	 WHERE r.no_reclamo       = _no_reclamo
	   AND r.cod_tipotran     = t.cod_tipotran
	   AND t.tipo_transaccion = 4
	   AND r.actualizado = 1;

	IF _pagado_tot IS NULL THEN
		LET _pagado_tot = 0.00;
	END IF
	
	SELECT SUM(r.monto)
	  INTO _pagado_recup
	  FROM rectrmae r, rectitra t
	 WHERE r.no_reclamo       = _no_reclamo
	   AND r.cod_tipotran     = t.cod_tipotran
	   AND t.tipo_transaccion IN (5,6,7)	--sal,rec,ded
	   AND r.actualizado = 1;

	IF _pagado_recup IS NULL THEN
		LET _pagado_recup = 0.00;
	ELSE
		LET _pagado_recup = _pagado_recup * -1;
	END IF

FOREACH
 SELECT no_tranrec,
		monto,
		variacion,
		cod_tipotran
   INTO _no_tranrec,
		_monto_tran,
		_variacion,
		_cod_tipotran
   FROM rectrmae
  WHERE no_reclamo  = _no_reclamo
    AND actualizado = 1

	-- Cambio para que refleje el incurrido neto de acuerdo con el
	-- reaseguro a nivel de transaccion

   SELECT tipo_transaccion
	 INTO _tipo_transaccion
	 FROM rectitra
	WHERE cod_tipotran = _cod_tipotran;

	foreach
		select porc_partic_suma
		  into _porc_partic_reas
		  from rectrrea
		 where no_tranrec    = _no_tranrec
		   and tipo_contrato = 1

		if _porc_partic_reas is null then
			let _porc_partic_reas = 0.00;
		end if	
		EXIT FOREACH;		
	end foreach
	
	if _tipo_transaccion = 4 or
	   _tipo_transaccion = 5 or  
	   _tipo_transaccion = 6 or  
	   _tipo_transaccion = 7 then
		let _sumar_incurrido = _monto_tran;
	else
		let _sumar_incurrido = 0.00;
	end if
	
	let _sumar_incurrido = _sumar_incurrido + _variacion;
	let _incurrido_bruto = _sumar_incurrido * _porc_partic_coas / 100;
	let _incurrido_neto  = _incurrido_neto  + (_incurrido_bruto * _porc_partic_reas / 100);

end foreach

--TRANSACCIONES
FOREACH
 SELECT no_tranrec,
 		transaccion,
		fecha,
		monto,
		variacion,
		cod_tipotran,
		cod_cliente,
		cerrar_rec,
		wf_apr_j_fh, 
		wf_apr_jt_fh, 
		wf_apr_jt_2_fh, 
		wf_apr_g_fh,
		anular_nt
   INTO _no_tranrec,
        _transaccion,
		_fecha_tran,
		_monto_tran,
		_variacion,
		_cod_tipotran,
		_cod_cliente,
		_cerrar_rec,
		_wf_apr_j_fh, 
		_wf_apr_jt_fh, 
		_wf_apr_jt_2_fh, 
		_wf_apr_g_fh,
		_anular_nt
   FROM rectrmae
  WHERE no_reclamo  = _no_reclamo
    AND actualizado = 1

  IF _wf_apr_j_fh IS NULL THEN
	LET _wf_apr_j_fh = _fecha_tran;
  END IF

  INSERT INTO tmp_arreglo
     values (
	 _no_tranrec,
	 _transaccion,
	 _fecha_tran,
	 _monto_tran,
	 _variacion,
	 _cod_tipotran,
	 _cod_cliente,
	 _cerrar_rec,
	 _wf_apr_j_fh, 
	 _wf_apr_jt_fh, 
	 _wf_apr_jt_2_fh,
	 _wf_apr_g_fh,
	 _anular_nt
	 );

END FOREACH


FOREACH
 SELECT no_tranrec,
 		transaccion,
		fecha,
		monto,
		variacion,
		cod_tipotran,
		cod_cliente,
		cerrar_rec,
		anular_nt
   INTO _no_tranrec,
        _transaccion,
		_fecha_tran,
		_monto_tran,
		_variacion,
		_cod_tipotran,
		_cod_cliente,
		_cerrar_rec,
		_anular_nt
   FROM tmp_arreglo
  ORDER BY wf_apr_j_fh, wf_apr_jt_fh, wf_apr_jt_2_fh, wf_apr_g_fh, fecha, transaccion
--  WHERE numrecla    = a_numrecla
--    AND actualizado = 1
--  ORDER BY wf_apr_g_fh, wf_apr_jt_2_fh, wf_apr_jt_fh, wf_apr_j_fh, fecha, transaccion

-- Nombre de las Transacciones
	SELECT nombre,
	       tipo_transaccion
	 INTO  _nombre_tran,
	       _tipo_transaccion
	FROM   rectitra
	WHERE  cod_tipotran = _cod_tipotran;

-- Nombre del Cliente
	SELECT nombre
	  INTO _nombre_cliente
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

-- Numero de recupero
	FOREACH
	 SELECT no_recupero
	   INTO _no_recupero
	   FROM recrecup
	  WHERE numrecla = a_numrecla
	EXIT FOREACH;
	END FOREACH

-- Calculos
	
	LET _reserva = _variacion + _reserva;

	{IF _cerrar_rec = 1 AND _reserva < 0 THEN
		LET _reserva = 0;
	END IF}
	let _no_requis = null;
	let _no_remesa = null;
	IF _tipo_transaccion = 4 THEN
		LET _pagado  = _pagado + _monto_tran;

		select no_requis
		  into _no_requis
		  from rectrmae
		 where no_tranrec = _no_tranrec;
        if _no_requis is not null then
			select no_cheque
			  into _no_cheque
			  from chqchmae
			 where no_requis = _no_requis;
            let _no_remesa = _no_cheque;			 
		end if
	ELSE
		LET _pagado_salida = 0.00;
	END IF

	IF _tipo_transaccion = 5 OR   --salvamento
	   _tipo_transaccion = 6 THEN --recupero
		LET _recuperos = (_monto_tran  * -1) + _recuperos;
	ELIF _tipo_transaccion = 7 THEN	--ded
		LET _recuperos = (_monto_tran  * -1) + _recuperos;
	ELSE
		LET _recuperos_salida = 0.00;
	END IF
	IF _tipo_transaccion IN(5,6,7) THEN
		FOREACH
			  SELECT no_remesa
				INTO _no_remesa
				FROM cobredet
			   WHERE no_tranrec = _no_tranrec
			exit foreach;
		END FOREACH
	END IF	

	LET _incurrido = _reserva + _pagado - _recuperos;

-- Numero de recupero
	FOREACH
	 SELECT cod_grupo
	   INTO _cod_grupo
	   FROM emipomae
	  WHERE no_documento = _no_documento
    EXIT FOREACH;
	END FOREACH

	SELECT nombre
	  INTO _grupo
	  FROM cligrupo
	 WHERE cod_grupo = _cod_grupo;

	if _no_remesa is null     and
	   _anular_nt is not null then
		let _no_remesa = _anular_nt;
	end if
	
RETURN  _no_documento,
		a_numrecla,
		estatus,
		_fecha_reclamo,
		_fecha_siniestro,
		_nombre_asegurado,
		_nombre_interno,
		_nombre_externo,
	 	_porc_partic_suma,        
		_porc_partic_coas,
	    _transaccion,
        _fecha_tran,
        _nombre_tran,
        _nombre_cliente,
        _monto_tran,
        _variacion,
        _reserva,
        _pagado,
        _recuperos,
        _incurrido,
        _deducible,
        _estimado,
        _pagado_tot,
		_pagado_recup,
		_no_recupero,
		_no_remesa,
		_grupo,
		v_compania_nombre,
		_incurrido_neto,
		_n_reclamante
        WITH RESUME;

END FOREACH

DROP TABLE tmp_arreglo;

END PROCEDURE;