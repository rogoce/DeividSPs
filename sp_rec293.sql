-- Procedimiento para generacion de cheques
-- 
-- creado: 20/12/2004 - Autor: Amado Perez.

DROP PROCEDURE sp_rec293;
CREATE PROCEDURE sp_rec293(a_no_tranrec CHAR(10), a_transaccion CHAR(10)) 
			RETURNING SMALLINT, CHAR(100), CHAR(10);  

DEFINE _no_reclamo			CHAR(10);
DEFINE _cod_compania		CHAR(3);
DEFINE _cod_sucursal		CHAR(3);
DEFINE _fecha				DATE;
DEFINE _transaccion			CHAR(10);
DEFINE _periodo			    CHAR(7);
DEFINE _cod_cliente			CHAR(10);
DEFINE _cod_tipotran        CHAR(3);
DEFINE _cod_tipopago		CHAR(3);
DEFINE _no_requis			CHAR(10);
DEFINE _monto				DEC(16,2);
DEFINE _user_added			CHAR(8);
DEFINE _nombre			    VARCHAR(100);  
DEFINE _acreedor		    VARCHAR(100);  
DEFINE _no_requis_n			CHAR(10);
DEFINE _cod_banco		    CHAR(3);
DEFINE _cod_chequera		CHAR(3);
DEFINE _no_poliza			CHAR(10);
DEFINE _cod_ramo			CHAR(3);
DEFINE _ramo_sis            SMALLINT;
DEFINE _cod_ruta			CHAR(2);
DEFINE _wf_pedir_rec        SMALLINT;
DEFINE _genera_incidente    SMALLINT;
DEFINE _numrecla            CHAR(18);
DEFINE _desc_nota           VARCHAR(250);
DEFINE _des_renglon1      	VARCHAR(100);
define _mensaje             varchar(100);
DEFINE _filas               SMALLINT;
DEFINE _firma_electronica  	SMALLINT;
DEFINE _autorizado  	    SMALLINT;
DEFINE _en_firma,_valor     SMALLINT;

DEFINE _fecha_captura       DATE;
DEFINE _nombre_cheq         CHAR(100);
DEFINE _monto_cheq          DEC(16,2);

DEFINE _error   			SMALLINT;
define _tipo_requis         char(1);
define _agrega_acreedor     smallint;
define _periodo_pago        smallint;

define _perd_total_tr       smallint;
define _perd_total_rec      smallint;
define _cont                smallint;
define _finiquito_firmado   smallint;
define _periodo_req         char(7);
define _origen_cheque       char(1);


LET _acreedor = NULL;
LET _no_requis = NULL;
LET _autorizado = 0;
LET _en_firma   = 0;
LET _no_requis_n = NULL;
LET _tipo_requis = "C";
LET _agrega_acreedor = 0;
let _valor  = 0;
let _mensaje  = "";
let _origen_cheque = "3";


SET ISOLATION TO DIRTY READ;

--if a_no_tranrec = '2812852' then
-- set debug file to "sp_rec293.trc";
-- trace on;
--end if

--begin work;

 SELECT no_reclamo,
        cod_compania,
		cod_sucursal,
		fecha,
		transaccion,
		periodo,
		cod_cliente,
		cod_tipotran,
		cod_tipopago,
		monto,
		user_added,
		numrecla,
		no_requis,
		perd_total		
   INTO _no_reclamo,
        _cod_compania,
		_cod_sucursal,
		_fecha,
		_transaccion,
		_periodo,
		_cod_cliente,
		_cod_tipotran,
		_cod_tipopago,
		_monto,
		_user_added,
		_numrecla,
		_no_requis,
		_perd_total_tr
   FROM rectrmae
  WHERE no_tranrec = a_no_tranrec;
  
 --IF _transaccion IS NULL OR TRIM(_transaccion) = "" THEN
  LET _transaccion = a_transaccion;
 --END IF

--Verifica a un cliente o una poliza si es apta para hacerle requis o no, caso 2727 Enilda. 14/03/2022
CALL sp_sis262("",_cod_cliente) RETURNING _valor, _mensaje;
IF _valor = 1 THEN
	RETURN 17, _mensaje, null;
END IF
  
 SELECT nombre, cod_ruta, periodo_pago
   INTO _nombre, _cod_ruta, _periodo_pago
   FROM cliclien
  WHERE cod_cliente = _cod_cliente;

 SELECT no_poliza,
        perd_total 
   INTO _no_poliza,
        _perd_total_rec
   FROM recrcmae
  WHERE no_reclamo = _no_reclamo;

 SELECT cod_ramo
   INTO _cod_ramo
   FROM emipomae
  WHERE no_poliza = _no_poliza;

 SELECT ramo_sis 
   INTO _ramo_sis
   FROM prdramo
  WHERE cod_ramo = _cod_ramo;

 IF _cod_tipotran = "004" AND _cod_tipopago = "003" THEN
 	LET _acreedor = sp_rec100(_no_reclamo);
 END IF
 
 IF _acreedor IS NULL THEN
	LET _acreedor = "";
 END IF

-- Veriificar si el concepto lleva acreedor
IF TRIM(_acreedor) <> "" THEN
	LET _agrega_acreedor = sp_rec198(a_no_tranrec);
	if _agrega_acreedor <> 0 then
		LET _nombre = TRIM(_nombre) || " Y " || TRIM(_acreedor);
	end if
END IF

-- Buscando si se unifica o no...
 IF _ramo_sis = 5 THEN
	IF _cod_tipopago = '001' THEN
		CALL sp_rec277(_cod_cliente, a_no_tranrec) RETURNING _fecha_captura, _no_requis, _nombre_cheq, _monto_cheq;
	ELSE
		CALL sp_rec76(_cod_cliente) RETURNING _fecha_captura, _no_requis, _nombre_cheq, _monto_cheq;
	END IF

	IF _no_requis IS NOT NULL OR TRIM(_no_requis) <> "" THEN --SD 9085 Agrupación de Requisiciones de Salud por Cliente y Periodo -- Amado 23-01-2024
		SELECT periodo
		  INTO _periodo_req
		  FROM chqchmae
		 WHERE no_requis = _no_requis;
   
		IF _periodo <> _periodo_req THEN
			LET _no_requis = NULL;
		END IF
	END IF	
 END IF
 
-- Buscando si se unifica o no -- Accidentes Personales
 IF _ramo_sis = 9 THEN
	IF _cod_tipopago = '001' THEN -- Pago a proveedor
		CALL sp_rec277(_cod_cliente, a_no_tranrec) RETURNING _fecha_captura, _no_requis, _nombre_cheq, _monto_cheq;
	END IF
 END IF
 
 IF _ramo_sis = 1 THEN
 	CALL sp_rec184(_cod_cliente, a_no_tranrec) RETURNING _no_requis;
 END IF
 
 IF _no_requis IS NULL OR TRIM(_no_requis) = "" THEN
    LET _genera_incidente = 1;
 	LET _no_requis_n = sp_sis71(_cod_compania);
--    LET _no_requis_n = "ultimus";
 	IF _no_requis_n IS NULL OR trim(_no_requis_n) = "" OR _no_requis_n = "00000" THEN
	    RETURN 1, "Error al generar requisicion, verifique...", null;
	END IF

	LET _no_requis = _no_requis_n;

 	CALL sp_rec121(_no_reclamo) returning _cod_banco, _cod_chequera;

    LET _tipo_requis = "C";

  -- IF _ramo_sis = 5 or _ramo_sis = 9 or _ramo_sis = 7 or (_ramo_sis = 1 and _cod_tipopago = '003') THEN	--> Solo salud se paga con ACH y ahora automóvil 12-8-2020 -- se cambia hasta que se defina la preautorizacion de ach 28-09-2020 AMADO
{	IF _ramo_sis = 5 or (_ramo_sis = 1 and _cod_tipopago = '003') THEN	--> Solo salud se paga con ACH y ahora automóvil 12-8-2020 
		if _agrega_acreedor = 0 then 		
			CALL sp_rec183 (_cod_compania,_cod_cliente,_cod_banco,_cod_chequera) returning _cod_banco, _cod_chequera, _tipo_requis;
		end if
	END IF
 }
 
    IF _ramo_sis = 5 or _ramo_sis = 9 THEN	--> Solo salud se paga con ACH -- Se agrega Accidentes Personales 17-12-2020
		if _acreedor is null or Trim(_acreedor) = "" then 	
            if _ramo_sis = 5 then		
				CALL sp_rec183 (_cod_compania,_cod_cliente,_cod_banco,_cod_chequera) returning _cod_banco, _cod_chequera, _tipo_requis;
			else 
				if _cod_tipopago in ('003','004','001') then -- Asegurado o Tercero Amado SD 13377 -- 10-04-2025 -- Se agrega proveedor 001 SD 13821 -- Amado 23-05-2025	
					select count(*) -- -00205-REEMBOLSO DE GASTOS POR ACC. // -00210-GASTOS MEDICOS POR ACCIDENTES SD 13377 -- Amado 10-04-2025
					  into _cont
					  from rectrcob
					 where no_tranrec = a_no_tranrec
					   and cod_cobertura in ('00205','00210')
					   and monto > 0;
					   
					if _cont is null then
						let _cont = 0;
					end if
					   
					if _cont > 0 then
						CALL sp_rec183 (_cod_compania,_cod_cliente,_cod_banco,_cod_chequera) returning _cod_banco, _cod_chequera, _tipo_requis;
						--let _origen_cheque = "M";
					end if
				end if
--				if _cod_tipopago = '001' then -- Se agrega proveedor 001 SD 13821 -- Amado 23-05-2025
--					CALL sp_rec183 (_cod_compania,_cod_cliente,_cod_banco,_cod_chequera) returning _cod_banco, _cod_chequera, _tipo_requis;
--					let _origen_cheque = "M";
--				end if
			end if
		end if
	ELSE
		if _ramo_sis = 1 then
			if _agrega_acreedor = 0 then
				if _cod_tipopago = '001' then
					CALL sp_rec183 (_cod_compania,_cod_cliente,_cod_banco,_cod_chequera) returning _cod_banco, _cod_chequera, _tipo_requis;
				elif _cod_tipopago = '003' then
					if _perd_total_rec = 0 and _perd_total_tr = 0 then
						CALL sp_rec183 (_cod_compania,_cod_cliente,_cod_banco,_cod_chequera) returning _cod_banco, _cod_chequera, _tipo_requis;
					end if					
                elif _cod_tipopago = '004' then	--> para las subrogaciones
					select count(*)
					  into _cont
					  from rectrcon
					 where no_tranrec = a_no_tranrec
					   and cod_concepto = '063';
					   
					if _cont is null then
						let _cont = 0;
					end if
					   
					if _cont > 0 then
						CALL sp_rec183 (_cod_compania,_cod_cliente,_cod_banco,_cod_chequera) returning _cod_banco, _cod_chequera, _tipo_requis;
					end if
					
					let _cont = 0;
					
					select count(*)
					  into _cont
					  from recrcsxp 
					 where no_reclamo = _no_reclamo
					   and cod_cliente = _cod_cliente
					   and no_procede = 0
					   and (no_requis is null or trim(no_requis) = "");
					   
					if _cont = 1 then
						update recrcsxp
						   set no_requis = _no_requis
						 where no_reclamo = _no_reclamo
						   and cod_cliente = _cod_cliente
						   and no_procede = 0
						   and (no_requis is null or trim(no_requis) = "");
					end if
				end if
			end if
		end if
		if _ramo_sis in (2,8,99,4) then
			CALL sp_rec183 (_cod_compania,_cod_cliente,_cod_banco,_cod_chequera) returning _cod_banco, _cod_chequera, _tipo_requis;
		end if
	END IF
  
	-- Verificar si es BANISI S. A. DRN TBD112 Amado 9-3-2022
	-- Se pone en comentario porque se le pagará con la cuenta de Global Bank ID de la solicitud	# 6592 Amado 19-05-2023
	
	{CALL sp_rec318 (a_no_tranrec,_cod_banco,_cod_chequera,_tipo_requis) returning _cod_banco, _cod_chequera, _tipo_requis;
	
	if _cod_banco = '295' and _cod_chequera = '045' then
		LET _finiquito_firmado = 1;
	end if
    }
	
    CALL sp_rec321 (a_no_tranrec, _tipo_requis, _cod_banco, _cod_chequera) returning _finiquito_firmado, _tipo_requis, _cod_banco, _cod_chequera; 	

	LET _cod_ruta = NULL;
	LET _wf_pedir_rec = NULL;

	IF _ramo_sis = 5  and Trim(_tipo_requis) = "C" THEN
		IF _cod_tipopago = '001' THEN
			LET _wf_pedir_rec = 1;
		END IF
	END IF
	
	IF _cod_ruta IS NULL OR TRIM(_cod_ruta) = "" THEN 
		IF _ramo_sis = 5 THEN
			IF _cod_chequera = "006" THEN
		    	LET _cod_ruta = "09";
			ELSE
		    	LET _cod_ruta = "01";
			END IF
		END IF

		IF _cod_ramo = '015' THEN
			LET _cod_ruta = "06";
		END IF
	END IF


	 BEGIN
		ON EXCEPTION SET _error 
			--rollback work;
		 	RETURN _error, "Error al actualizar REQUISICION", null;         
		END EXCEPTION 
		INSERT INTO chqchmae(
		no_requis,
		monto,
		pagado,
		anulado,
		periodo,
		cobrado,
		cuenta,
		cod_cliente,
		autorizado,
		cod_agente,
		a_nombre_de,
		user_added,
		anulado_por,
		cod_banco,
		cod_chequera,
		cod_compania,
		cod_sucursal,
		no_cheque,
		fecha_cobrado,
		fecha_anulado,
		origen_cheque,
		fecha_captura,
		autorizado_por,
		fecha_impresion,
		cod_ruta,
		wf_pedir_rec,
		tipo_requis,
		periodo_pago
		)
		VALUES(
		_no_requis_n,
		_monto,
		0,
		0,
		_periodo,
		0,
		null,
		_cod_cliente,
		0,
		null,
		_nombre,
		_user_added,
		null,
		_cod_banco,
		_cod_chequera,
		_cod_compania,
		_cod_sucursal,
		0,
		null,
		null,
		_origen_cheque,
		current,
		null,
		current,
		_cod_ruta,
		_wf_pedir_rec,
		_tipo_requis,
		_periodo_pago
		);
	 END

     BEGIN
		ON EXCEPTION SET _error 
			--rollback work;
		 	RETURN _error, "Error al actualizar descripcion de la requisicion", null;         
		END EXCEPTION 
		INSERT INTO chqchdes(
		no_requis,
		renglon,
		desc_cheque
		) 
		SELECT _no_requis_n,
		       renglon,
			   desc_transaccion
		  FROM rectrde2
		 WHERE no_tranrec = a_no_tranrec
		   AND desc_transaccion is not null;
	 END

     BEGIN
		ON EXCEPTION SET _error 
		 --	rollback work;
		 	RETURN _error, "Error al actualizar CHQCHREC", null;         
		END EXCEPTION 
		INSERT INTO chqchrec(
		no_requis,
		transaccion,
		monto,
		numrecla
		) 
		VALUES(
		_no_requis_n,
		_transaccion,
		_monto,
		_numrecla
		);
	 END


     BEGIN
		ON EXCEPTION SET _error 
		  --	rollback work;
		 	RETURN _error, "Error al actualizar descripcion de la requisicion", null;         
		END EXCEPTION 
	--	UPDATE rectrmae
	--	   SET no_requis = _no_requis_n
	--	 WHERE no_tranrec = a_no_tranrec;   
	 END

{
	 IF _cod_tipopago = "001" THEN
	 	LET _desc_nota = "Requisicion emitida # " || trim(_no_requis_n) || " para pago al Proveedor " || trim(_nombre) || ", transaccion # " || _transaccion;
	 ELIF _cod_tipopago = "002" THEN
	 	LET _desc_nota = "Requisicion emitida # " || trim(_no_requis_n) || " para el Taller " || trim(_nombre) || ", transaccion # " || _transaccion;
	 ELIF _cod_tipopago = "003" THEN
	 	LET _desc_nota = "Requisicion emitida # " || trim(_no_requis_n) || " para el Asegurado " || trim(_nombre) || ", transaccion # " || _transaccion;
	 ELSE
	 	LET _desc_nota = "Requisicion emitida # " || trim(_no_requis_n) || " para el Tercero " || trim(_nombre) || ", transaccion # " || _transaccion;
	 END IF

	 BEGIN
		ON EXCEPTION SET _error 
		--	rollback work;
		 	RETURN _error, "Error al insertar RECNOTAS", 0;         
		END EXCEPTION 
		INSERT INTO recnotas(
		no_reclamo,
		fecha_nota,
		desc_nota,
		user_added
		) 
		VALUES(
		_no_reclamo,
		a_fecha,
	    _desc_nota,
		_user_added
		);
	 END
}	 
--	 SET ISOLATION TO DIRTY READ;

 ELSE
    LET _genera_incidente = 0;

--    set lock mode to wait 60;

 	BEGIN
		ON EXCEPTION SET _error 
		 --	rollback work;
		 	RETURN _error, "Error al actualizar descripcion de la requisicion", null;         
		END EXCEPTION
	If _ramo_sis in (5, 9) Then 

		delete from chqchdes
		 where no_requis = _no_requis;

		If _cod_tipopago = '001' then	--proveedores
			LET _des_renglon1 = "PAGO POR ATENCION MEDICA DE CLIENTES DE";
		end if
		if _cod_tipopago = '003' Then	--asegurados
			LET _des_renglon1 = "REEMBOLSO POR GASTOS MEDICOS";
		end if

		FOR _filas = 1 TO 2
			if _filas = 2 then
				if _cod_tipopago = '003' Then
					LET _des_renglon1 = "VER DETALLE ADJUNTO";
				else
					LET _des_renglon1 = "ASEGURADORA ANCON, VER DETALLE ADJUNTO";
				end if
			end if
			INSERT INTO chqchdes(
			no_requis,
			renglon,
			desc_cheque
			)
			VALUES(
			_no_requis,
			_filas,
			_des_renglon1
			);
		END FOR

		if _cod_tipopago = '003' Then	--asegurados
			update chqchmae
				set monto     = monto + _monto,
					unificado = 2
			 where no_requis = _no_requis;
		elif _cod_tipopago = '001' Then	--proveedor
			update chqchmae
				set monto     = monto + _monto,
					 unificado = 1
			 where no_requis = _no_requis;
		end if

		INSERT INTO chqchrec(
		no_requis,
		transaccion,
		monto,
		numrecla
		) 
		VALUES(
		_no_requis,
		_transaccion,
		_monto,
		_numrecla
		);

     --   update rectrmae
	--	   set no_requis = _no_requis
	--	 where no_tranrec = a_no_tranrec;


	Elif _ramo_sis = 1 Then
		delete from chqchdes
		 where no_requis = _no_requis;

		                    

		FOR _filas = 1 TO 2
			if _filas = 1 then
				LET _des_renglon1 = "PAGO EN CONCEPTO DE HONORARIOS PROFESIONALES POR ASISTENCIA"; 
			else
				LET _des_renglon1 = "LEGAL EN AUDIENCIAS DE TRANSITOS";
			end if
			INSERT INTO chqchdes(
			no_requis,
			renglon,
			desc_cheque
			)
			VALUES(
			_no_requis,
			_filas,
			_des_renglon1
			);
		END FOR

		if _cod_tipopago = '003' Then	--asegurados
			update chqchmae
				set monto     = monto + _monto,
					unificado = 2
			 where no_requis = _no_requis;
		elif _cod_tipopago = '001' Then	--proveedor
			update chqchmae
				set monto     = monto + _monto,
					unificado = 1
			 where no_requis = _no_requis;
		end if

		INSERT INTO chqchrec(
		no_requis,
		transaccion,
		monto,
		numrecla
		) 
		VALUES(
		_no_requis,
		_transaccion,
		_monto,
		_numrecla
		);

   --     update rectrmae
	--	   set no_requis = _no_requis
	--	 where no_tranrec = a_no_tranrec;

	End If
    
    --set isolation to dirty read;
    	
	END	 
 END IF

IF _no_requis IS NOT NULL AND _no_requis <> "" AND _no_requis <> "00000" THEN	 -->
	CALL sp_rec122(_no_requis, _monto, _user_added, _transaccion) returning _error;
END IF

IF _error <> 0 THEN
	RETURN _error, "Error al actualizar requisicion, verifique...", null;
END IF

--commit work;
--rollback work;


 RETURN 0, "Actualizacion Exitosa", _no_requis;
END PROCEDURE