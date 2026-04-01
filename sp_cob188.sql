-- Procedure que permite simular los registros contables
 													   
drop procedure sp_cob188;

create procedure sp_cob188(a_no_remesa char(10));

	DEFINE _tipo_mov         CHAR(1);  
	DEFINE _renglon          SMALLINT; 
	DEFINE _cuenta           CHAR(25); 
	DEFINE _debito           DEC(16,2);
	DEFINE _credito          DEC(16,2);
	DEFINE _prima_neta       DEC(16,2);
	DEFINE _cod_tipoprod     CHAR(3);  
	DEFINE _tipo_produccion  SMALLINT; 
	DEFINE _no_poliza        CHAR(10); 
	DEFINE _monto_descontado DEC(16,2);
	DEFINE _no_documento     CHAR(30);
	DEFINE _no_reclamo       CHAR(10);
	DEFINE _porc_partic      DEC(7,4);
	DEFINE _monto			 DEC(16,2);
	DEFINE _cod_origen       CHAR(3);
	DEFINE _fecha        	 DATE;
	DEFINE _fecha_param  	 DATE;
	DEFINE _cod_coasegur 	 CHAR(3);

	DEFINE _valor_pago       DEC(16,2);

	DELETE FROM cobasien
	 WHERE no_remesa = a_no_remesa;

	SELECT par_ase_lider,
		   rec_fecha_prov	
	  INTO _cod_coasegur,
		   _fecha_param	
	  FROM parparam
	 WHERE cod_compania = "001";

	FOREACH
	 SELECT	tipo_mov,
			prima_neta,
			no_poliza,
			monto_descontado,
			renglon,
			doc_remesa,
			monto,
			no_reclamo
	   INTO	_tipo_mov,
			_prima_neta,
			_no_poliza,
			_monto_descontado,
			_renglon,
			_no_documento,
			_monto,
			_no_reclamo
	   FROM	cobredet
	  WHERE	no_remesa = a_no_remesa

		IF   _tipo_mov = 'P' OR   -- Pago a Prima
			 _tipo_mov = 'N' THEN -- Nota Credito

			SELECT cod_tipoprod
			  INTO _cod_tipoprod
			  FROM emipomae
			 WHERE no_poliza = _no_poliza;

			SELECT tipo_produccion
			  INTO _tipo_produccion
			  FROM emitipro
			 WHERE cod_tipoprod = _cod_tipoprod;

			-- Prima Neta

			IF   _tipo_produccion = 3 THEN 
				LET _cuenta = sp_sis15('PACXCC',  '01', _no_poliza); -- Coaseguro Minoritario
			ELIF _tipo_produccion = 4 THEN 
				LET _cuenta = sp_sis15('PAPXCRA',  '01', _no_poliza); -- Reaseguro Asumido
			ELSE						 
				LET _cuenta = sp_sis15('PAPXCSD', '01', _no_poliza); -- Produccion Directa
			END IF

			IF _tipo_mov = 'P' THEN
				LET _debito  = 0;
				LET _credito = _monto;
			ELSE
				LET _debito  = _monto * -1;
				LET _credito = 0;
			END IF

			CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

			-- Comision Descontada

			IF _monto_descontado <> 0 THEN

				LET _cuenta = sp_sis15('PPCOMXPCO',  '01', _no_poliza); -- Comision por Pagar

				IF _tipo_mov = 'P' THEN
					LET _debito  = _monto_descontado;
					LET _credito = 0;
				ELSE
					LET _debito  = 0;
					LET _credito = _monto_descontado * -1;
				END IF

				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

			END IF

		ELIF _tipo_mov = 'C' THEN -- Comision Descontada

			LET _cuenta  = sp_sis15('PPCOMXPCO',  '03'); -- Comision por Pagar

			IF _monto > 0 THEN
				LET _debito  = 0;
				LET _credito = _monto;
			ELSE
				LET _debito  = _monto * -1;
				LET _credito = 0;
			END IF

			CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

		ELIF _tipo_mov = 'M' THEN -- Afectacion Catalogo

			LET _cuenta = _no_documento;

			IF _monto > 0 THEN

				IF _monto_descontado <> 0 THEN
					LET _debito  = _monto;
					LET _credito = 0;
				ELSE
					LET _debito  = 0;
					LET _credito = _monto;
				END IF

			ELSE

				IF _monto_descontado <> 0 THEN
					LET _debito  = 0;
					LET _credito = _monto * -1;
				ELSE
					LET _debito  = _monto * -1;
					LET _credito = 0;
				END IF

			END IF

			CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

		ELIF _tipo_mov = 'D' THEN -- Pago de Deducible

			SELECT no_poliza
			  INTO _no_poliza
			  FROM recrcmae
			 WHERE no_reclamo = _no_reclamo;

			SELECT cod_tipoprod
			  INTO _cod_tipoprod
			  FROM emipomae
			 WHERE no_poliza = _no_poliza;

			SELECT tipo_produccion
			  INTO _tipo_produccion
			  FROM emitipro
			 WHERE cod_tipoprod = _cod_tipoprod;

			IF   _tipo_produccion = 4 THEN -- Reaseguro Asumido

				LET  _cuenta  = sp_sis15('SGPDDRA',  '01', _no_poliza); 
				LET  _debito  = 0;
				LET  _credito = _monto;
				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

			ELIF _tipo_produccion = 2 THEN -- Coaseguro Mayoritario

				SELECT porc_partic_coas
				  INTO _porc_partic
				  FROM reccoas
				 WHERE no_reclamo   = _no_reclamo
				   AND cod_coasegur = _cod_coasegur;
				 
				IF _porc_partic IS NULL THEN
					LET _porc_partic = 100;
				END IF
				 
				LET _valor_pago = _monto;

				LET  _monto   = _monto / 100 * _porc_partic; 
				LET  _cuenta  = sp_sis15('SGPDDSD',  '01', _no_poliza); 
				LET  _debito  = 0;
				LET  _credito = _monto;
				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
				 

				LET  _monto   = _valor_pago - _monto; 
				LET  _cuenta  = sp_sis15('SARXCC',  '01', _no_poliza); 
				LET  _debito  = 0;
				LET  _credito = _monto;
				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

			ELSE						   -- Sin Coaseguro, Coas. Minoritario

				LET  _cuenta  = sp_sis15('SGPDDSD',  '01', _no_poliza); 
				LET  _debito  = 0;
				LET  _credito = _monto;
				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

			END IF

		ELIF _tipo_mov = 'S' THEN -- Pago de Salvamento

			SELECT no_poliza
			  INTO _no_poliza
			  FROM recrcmae
			 WHERE no_reclamo = _no_reclamo;

			SELECT cod_tipoprod
			  INTO _cod_tipoprod
			  FROM emipomae
			 WHERE no_poliza = _no_poliza;

			SELECT tipo_produccion
			  INTO _tipo_produccion
			  FROM emitipro
			 WHERE cod_tipoprod = _cod_tipoprod;

			IF   _tipo_produccion = 2 THEN -- Coaseguro Mayoritario

				SELECT porc_partic_coas
				  INTO _porc_partic
				  FROM reccoas
				 WHERE no_reclamo   = _no_reclamo
				   AND cod_coasegur = _cod_coasegur;
				 
				IF _porc_partic IS NULL THEN
					LET _porc_partic = 100;
				END IF
				 
				LET _valor_pago = _monto;

				LET  _monto   = _monto / 100 * _porc_partic; 
				LET  _cuenta  = sp_sis15('SISAL',  '01', _no_poliza); 
				LET  _debito  = 0;
				LET  _credito = _monto;
				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
				 
				LET  _monto   = _valor_pago - _monto; 
				LET  _cuenta  = sp_sis15('SARXCC',  '01', _no_poliza); 
				LET  _debito  = 0;
				LET  _credito = _monto;
				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

			ELSE						   -- Sin Coaseguro, Coas. Minoritario

				LET  _cuenta  = sp_sis15('SISAL',  '01', _no_poliza); 
				LET  _debito  = 0;
				LET  _credito = _monto;
				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

			END IF

		ELIF _tipo_mov = 'R' THEN -- Pago de Recupero

			SELECT no_poliza
			  INTO _no_poliza
			  FROM recrcmae
			 WHERE no_reclamo = _no_reclamo;

			SELECT cod_tipoprod
			  INTO _cod_tipoprod
			  FROM emipomae
			 WHERE no_poliza = _no_poliza;

			SELECT tipo_produccion
			  INTO _tipo_produccion
			  FROM emitipro
			 WHERE cod_tipoprod = _cod_tipoprod;

			IF   _tipo_produccion = 2 THEN -- Coaseguro Mayoritario

				SELECT porc_partic_coas
				  INTO _porc_partic
				  FROM reccoas
				 WHERE no_reclamo   = _no_reclamo
				   AND cod_coasegur = _cod_coasegur;
				 
				IF _porc_partic IS NULL THEN
					LET _porc_partic = 100;
				END IF
				 
				LET _valor_pago = _monto;

				LET  _monto   = _monto / 100 * _porc_partic; 
				LET  _cuenta  = sp_sis15('SIREC',  '01', _no_poliza); 
				LET  _debito  = 0;
				LET  _credito = _monto;
				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
				 
				LET  _monto   = _valor_pago - _monto; 
				LET  _cuenta  = sp_sis15('SARXCC',  '01', _no_poliza); 
				LET  _debito  = 0;
				LET  _credito = _monto;
				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

			ELSE						   -- Sin Coaseguro, Coas. Minoritario

				LET  _cuenta  = sp_sis15('SIREC',  '01', _no_poliza); 
				LET  _debito  = 0;
				LET  _credito = _monto;
				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

			END IF

		ELIF _tipo_mov = 'E' THEN -- Crear Prima en Suspenso

			LET  _cuenta  = sp_sis15('CPCPES'); 
			LET  _debito  = 0;
			LET  _credito = _monto;
			CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

		ELIF _tipo_mov = 'A' THEN -- Aplicar Prima en Suspenso

			LET  _cuenta  = sp_sis15('CPAPES'); 
			LET  _debito  = _monto * -1;
			LET  _credito = 0;
			CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

		ELIF _tipo_mov = 'T' THEN -- Aplicar Reclamos

			IF _fecha > _fecha_param THEN
				LET  _cuenta  = sp_sis15('BCXPP'); 
			ELSE
				LET  _cuenta  = sp_sis15('BCXPPV'); 
			END IF

			IF _monto > 0 THEN
				LET  _debito  = _monto;
				LET  _credito = 0;
			ELSE
				LET  _debito  = 0;
				LET  _credito = _monto * -1;
			END IF

			CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

		ELIF _tipo_mov = 'O' THEN -- Deuda Agente

			LET _cuenta  = _no_documento;
			LET _debito  = 0;
			LET _credito = _monto;

			CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

		END IF

	END FOREACH

end procedure