-- Procedimiento que genera el cambio de plan de pagos (proceso de nueva ley de seguros)
-- 
-- Creado     : 08/01/2013 - Autor: Amado Perez M.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure ap_deducible;

create procedure ap_deducible() returning integer, char(50);

	DEFINE _no_reclamo      CHAR(10); 
	DEFINE _cod_cobertura   CHAR(5);  
	DEFINE _tipo_mov        CHAR(1);  
	DEFINE _renglon         SMALLINT; 
	DEFINE _monto           DEC(16,2);
	DEFINE _cod_tipotran    CHAR(3);  
	DEFINE _cod_tipopago    CHAR(3);  
	DEFINE _cod_cliente     CHAR(10); 
	DEFINE _numrecla        CHAR(18); 
	DEFINE _periodo_rec     CHAR(7);  
	DEFINE _no_tranrec_char CHAR(10); 
	DEFINE _no_tran_char    CHAR(10); 
	DEFINE _version		    CHAR(2);
	DEFINE _valor_parametro CHAR(20);
	DEFINE _valor_parametro2 CHAR(20);
	DEFINE _fecha_no_server  DATE;
	DEFINE _salvamento      DEC(16,2);
	DEFINE _recupero        DEC(16,2);
	DEFINE _deducible       DEC(16,2);
	DEFINE _rec_periodo		CHAR(7);
	define _error			integer;
	define _error_isam		integer;
	define _error_desc		char(50);
	define _mensaje     	char(50);
	define _cod_compania    char(3);
	define _cod_sucursal    char(3);
set isolation to dirty read;
BEGIN WORK;
begin 
on exception set _error, _error_isam, _error_desc
    rollback work; 
	return _error, _error_desc;
end exception

SELECT cod_compania,
	   cod_sucursal
  INTO _cod_compania,
	   _cod_sucursal
  FROM cobremae
 WHERE no_remesa = '689262';

	SELECT rec_periodo
	  INTO _rec_periodo
	  FROM parparam;

	SELECT version
      INTO _version
	  FROM insapli
	 WHERE aplicacion = 'REC';

	SELECT valor_parametro
      INTO _valor_parametro
	  FROM inspaag
	 WHERE codigo_compania  = _cod_compania
	   AND aplicacion       = 'REC'
	   AND version          = _version
	   AND codigo_parametro	= 'fecha_recl_default';

	IF TRIM(_valor_parametro) = '1' THEN   --Toma la fecha del servidor
		IF MONTH(CURRENT) < 10 THEN
			LET _periodo_rec = YEAR(CURRENT) || "-0" || MONTH(CURRENT);
		ELSE
			LET _periodo_rec = YEAR(CURRENT) || "-" || MONTH(CURRENT);
		END IF
	ELSE								   --Toma la fecha de un parametro establecido por computo.
		SELECT valor_parametro			  
	      INTO _valor_parametro2
		  FROM inspaag
		 WHERE codigo_compania  = _cod_compania
		   AND aplicacion       = 'REC'
		   AND version          = _version
		   AND codigo_parametro	= 'fecha_recl_valor';

		   LET _fecha_no_server = DATE(_valor_parametro2);				

		IF MONTH(_fecha_no_server) < 10 THEN
			LET _periodo_rec = YEAR(_fecha_no_server) || "-0" || MONTH(_fecha_no_server);
		ELSE
			LET _periodo_rec = YEAR(_fecha_no_server) || "-" || MONTH(_fecha_no_server);
		END IF

	END IF

--set debug file to "sp_cob253.trc";



   FOREACH	
	SELECT no_reclamo, 
	       cod_cobertura, 
	       tipo_mov, 
	       renglon, 
	       monto,
	       cod_recibi_de 
      INTO _no_reclamo, 
	       _cod_cobertura, 
	       _tipo_mov, 
	       _renglon, 
	       _monto,
		   _cod_cliente
	  FROM cobredet
	 WHERE no_remesa = '689262'
	   and renglon = 53
   --	   AND tipo_mov  IN ('D', 'S', 'R')
       
		LET _salvamento = 0;
		LET _recupero   = 0;
		LET _deducible  = 0;
		
		if _periodo_rec < _rec_periodo then
		    rollback work;
			LET _mensaje = "No Puede Actualizar para un periodo de Reclamos ya Cerrado, Por favor Verifique.";
			RETURN 1, _mensaje;
		end if

		IF _tipo_mov = 'S' THEN   -- Salvamento

			SELECT cod_tipotran
			  INTO _cod_tipotran
			  FROM rectitra
			 WHERE tipo_transaccion = 5;    
			
			LET _cod_tipopago = '004';
			LET _salvamento   = _monto * -1;

		ELIF _tipo_mov = 'R' THEN	-- Recupero

			SELECT cod_tipotran
			  INTO _cod_tipotran
			  FROM rectitra
			 WHERE tipo_transaccion = 6;    

			LET _cod_tipopago = '004';
			LET _recupero     = _monto * -1;

		ELSE						-- Deducible

			SELECT cod_tipotran
			  INTO _cod_tipotran
			  FROM rectitra
			 WHERE tipo_transaccion = 7;    

			LET _cod_tipopago = '003';
			LET _deducible    = _monto * -1;

		END IF

		-- Asignacion del Numero Interno y Externo de Transacciones

		LET _no_tran_char    = sp_sis12(_cod_compania, _cod_sucursal, _no_reclamo);
		LET _no_tranrec_char = sp_sis13(_cod_compania, 'REC', '02', 'par_tran_genera');

		-- Lectura de la Tabla de Reclamos

	    SELECT numrecla
		  INTO _numrecla
		  FROM recrcmae
		 WHERE no_reclamo = _no_reclamo;

		-- Insercion de las Transacciones de Salvamentos, Recuperos, Deducibles

		LET _monto = _monto * -1;

		IF TRIM(_valor_parametro) = '1' THEN

			INSERT INTO rectrmae(
		    no_tranrec,
		    cod_compania,
		    cod_sucursal,
		    no_reclamo,
		    cod_cliente,
		    cod_tipotran,
		    cod_tipopago,
		    no_requis,
		    no_remesa,
		    renglon,
		    numrecla,
		    fecha,
		    impreso,
		    transaccion,
		    perd_total,
		    cerrar_rec,
		    no_impresion,
		    periodo,
		    pagado,
		    monto,
		    variacion,
		    generar_cheque,
		    actualizado,
		    user_added
			)
			VALUES(
		    _no_tranrec_char,
		    _cod_compania,
		    _cod_sucursal,
		    _no_reclamo,
		    _cod_cliente,
		    _cod_tipotran,
		    _cod_tipopago,
		    NULL,
		    '689262',
		    _renglon,
		    _numrecla,
		    CURRENT,
		    0,
		    _no_tran_char,
		    0,
		    0,
		    0,
		    _periodo_rec,
		    1,
		    _monto,
		    0,
		    0,
		    1,
		    'ENILDA'
			);
		ELSE
			INSERT INTO rectrmae(
		    no_tranrec,
		    cod_compania,
		    cod_sucursal,
		    no_reclamo,
		    cod_cliente,
		    cod_tipotran,
		    cod_tipopago,
		    no_requis,
		    no_remesa,
		    renglon,
		    numrecla,
		    fecha,
		    impreso,
		    transaccion,
		    perd_total,
		    cerrar_rec,
		    no_impresion,
		    periodo,
		    pagado,
		    monto,
		    variacion,
		    generar_cheque,
		    actualizado,
		    user_added
			)
			VALUES(
		    _no_tranrec_char,
		    _cod_compania,
		    _cod_sucursal,
		    _no_reclamo,
		    _cod_cliente,
		    _cod_tipotran,
		    _cod_tipopago,
		    NULL,
		    '689262',
		    _renglon,
		    _numrecla,
			_fecha_no_server,
		    0,
		    _no_tran_char,
		    0,
		    0,
		    0,
		    _periodo_rec,
		    1,
		    _monto,
		    0,
		    0,
		    1,
		    'ENILDA'
			);
		END IF

		-- Insercion de las Coberturas (Transacciones)

		INSERT INTO rectrcob(
		no_tranrec,
		cod_cobertura,
		monto,
		variacion
		)
		VALUES(
	    _no_tranrec_char,
		_cod_cobertura,
		_monto,
		0
		);
		-- Actualizacion de los Valores Acumulados de las Coberturas

		update recrccob
		   set salvamento       = salvamento       + _salvamento,
		       recupero         = recupero         + _recupero,
			   deducible_pagado = deducible_pagado + _deducible
		 where no_reclamo       = _no_reclamo
		   and cod_cobertura    = _cod_cobertura;

		-- Actualizacion en la Remesa del Numero de Transaccion Generado

		update cobredet
		   set no_tranrec = _no_tranrec_char
		 where no_remesa  = '689262'
		   and renglon    = _renglon;

		-- Reaseguro a Nivel de Transaccion

		call sp_sis58(_no_tranrec_char) returning _error, _mensaje;

		if _error <> 0 then
			return _error, _mensaje;
		end if

		-- Reaseguro de Reclamos (Nueva Estructura de Asientos)

		call sp_rea008(3, _no_tranrec_char) returning _error, _mensaje;

		if _error <> 0 then
			return _error, _mensaje;
		end if
   end foreach


end
commit work;
return 0, "Actualizacion Exitosa";
end procedure