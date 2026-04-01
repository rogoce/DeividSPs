-- Procedimiento que Actualiza la Remesa de Cobros
-- 
-- Creado    : 12/10/2000 - Autor: Demetrio Hurtado Almanza 

-- Modificado: 03/01/2003 - Autor: Armando Moreno 
--             Leer de inspaag parametro para saber de donde se debe leer la fecha 
--			   y periodo(servidor o preestablecida por computo)
--			   para la n/t automtica que se crea para recuperos.

-- Modificado: 14/07/2003 - Autor: Marquelda Valdelamar: 
--             Validacion de los montos para las formas de pago de los
--			   recibos automaticos.

-- Modificado: 15/07/2003 - Autor: Marquelda Valdelamar: 
--             Generar remesa con tipo_mov = B, recibo anulado, cuando se dana 
--			   la impresion del recibo. Y crear la que sigue con los mismos valores.
--
-- Modificado: 18/03/2006 - Autor: Demetrio Hurtado Almanza
--			   Validar que no se puedan generar remesas con fecha menor a la fecha de la ultima comision
--             para evitar que se generen remesas no incluidas en el pago de las comisiones

-- SIS v.2.0 - DEIVID, S.A.

--{
DROP PROCEDURE sp_cob29;		

CREATE PROCEDURE "informix".sp_cob29(a_no_remesa CHAR(10), a_usuario CHAR(8))
RETURNING INTEGER,
		  CHAR(100);
--}

{
DROP PROCEDURE sp_cob29_trace;		

CREATE PROCEDURE "informix".sp_cob29_trace(a_no_remesa CHAR(10), a_usuario CHAR(8))
RETURNING INTEGER,
		  CHAR(100);
}
		  	
DEFINE _tipo_remesa  CHAR(1); 
DEFINE _mensaje      CHAR(100);
DEFINE _cod_compania CHAR(3);
DEFINE _cod_sucursal CHAR(3);
DEFINE _actualizado  SMALLINT;
DEFINE _date_posteo  DATE;
DEFINE _user_posteo  CHAR(8);
DEFINE _periodo      CHAR(7);
DEFINE _cod_coasegur CHAR(3);
DEFINE _cod_banco    CHAR(3);
DEFINE _monto_banco  DEC(16,2);
DEFINE _fecha        DATE;
DEFINE _periodo_par  CHAR(7);
DEFINE _fecha_param  DATE;
DEFINE _cantidad     SMALLINT;
DEFINE _fecha_ul_com DATE;

DEFINE _error        integer;
DEFINE _error_2      integer;
DEFINE _error_desc   char(50);

--SET DEBUG FILE TO "sp_cob29.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error, _error_2, _error_desc 
 	RETURN _error, _error_desc;
END EXCEPTION           

SELECT tipo_remesa,			  
       cod_compania,
	   cod_sucursal,
	   actualizado,
	   date_posteo,
	   user_posteo,
	   periodo,
	   cod_banco,
	   monto_chequeo,
	   fecha
  INTO _tipo_remesa,
       _cod_compania,
	   _cod_sucursal,
	   _actualizado,
	   _date_posteo,
	   _user_posteo,
	   _periodo,
	   _cod_banco,
	   _monto_banco,
	   _fecha
  FROM cobremae
 WHERE no_remesa = a_no_remesa;

IF _actualizado = 1 THEN
	LET _mensaje = "Remesa #: " || a_no_remesa || " Fue Actualizada el Dia " ||
	               _date_posteo || " Por " || _user_posteo;
	RETURN 1, _mensaje; 
END IF

SELECT par_ase_lider,
	   cob_periodo,
	   rec_fecha_prov,
	   agt_fecha_comis	
  INTO _cod_coasegur,
	   _periodo_par,
	   _fecha_param,
	   _fecha_ul_com	
  FROM parparam
 WHERE cod_compania = _cod_compania;

-- Postear en un Periodo Cerrado

IF _periodo < _periodo_par THEN
	RETURN 1, "No Puede Actualizar una Remesa para un Periodo Cerrado ...";
END IF

-- Postear en un periodo de comisiones cerrado

if _fecha <= _fecha_ul_com then
	return 1, "No Puede Actualizar para una Fecha de Comisiones ya Cerrada";
end if


DELETE FROM cobasien
 WHERE no_remesa = a_no_remesa
   AND renglon   = 0;

DELETE FROM cobredet
 WHERE no_remesa = a_no_remesa
   AND renglon   = 0;

IF _tipo_remesa = 'M' THEN	--Recibo Manual

	BEGIN

	DEFINE _contador     SMALLINT;
	DEFINE _no_recibo    CHAR(10);
	DEFINE _no_remesa    CHAR(10);
	DEFINE _renglon      SMALLINT;
	DEFINE _encontrado   SMALLINT;
	DEFINE _recibo1      INTEGER;
	DEFINE _recibo2      INTEGER;
	DEFINE _diferencia   INTEGER;

		-- Verificacion para el Numero de Recibo Duplicado

		FOREACH
		 SELECT	no_recibo
		   INTO	_no_recibo
		   FROM	cobredet
		  WHERE no_remesa = a_no_remesa
		    AND renglon  <> 0 
		  GROUP BY no_recibo 
		  ORDER BY no_recibo 

			LET _encontrado = 0;

		   FOREACH
			SELECT no_remesa, 	renglon 
			  INTO _no_remesa,	_renglon
			  FROM cobredet
			 WHERE no_recibo   = _no_recibo
			   AND actualizado = 1 
			   AND tipo_mov    = 'E' 
			   AND no_remesa   <> a_no_remesa
			 ORDER BY no_remesa, renglon
				LET _encontrado = 1;
				EXIT FOREACH;
			END FOREACH

			IF _encontrado = 0 THEN

			   FOREACH
				SELECT no_remesa, 	renglon 
				  INTO _no_remesa,	_renglon
				  FROM cobredet
				 WHERE no_recibo   = _no_recibo
				   AND actualizado = 1 
				   AND tipo_mov    MATCHES '*' 
				   AND no_remesa   <> a_no_remesa
				 ORDER BY no_remesa, renglon
					LET _encontrado = 1;
					EXIT FOREACH;
				END FOREACH

				IF _encontrado = 1 THEN
					LET _mensaje = "El Recibo #: " || _no_recibo || " Fue Capturado en la Remesa #: " || _no_remesa ||
					               " Renglon #: " || _renglon;
					RETURN 1, _mensaje;
				END IF

			END IF
			
		END FOREACH

		-- Verificacion para la Secuencia de Recibos

		LET _contador = 0;

		FOREACH
		 SELECT	no_recibo
		   INTO	_no_recibo
		   FROM	cobredet
		  WHERE no_remesa = a_no_remesa
		    AND renglon  <> 0 
		  GROUP BY no_recibo 
		  ORDER BY no_recibo 

			LET _contador = _contador + 1;

			IF _contador = 1 THEN
				LET _recibo1 = _no_recibo;
			END IF				

			LET _recibo2 = _no_recibo;

			IF _recibo1 <> _recibo2 THEN
				LET _diferencia = _recibo2 - _recibo1;
				IF _diferencia <> 1 THEN
					LET _mensaje = "El Recibo #: " || _recibo1 + 1 ||
					               " No ha sido Capturado ...";
					RETURN 1, _mensaje;
				END IF
				LET _recibo1 = _no_recibo;
			END IF
		END FOREACH

	END

END IF

-- Verificacion de Aplicacion de Reclamos

BEGIN

	DEFINE _no_tranrec CHAR(10);
	DEFINE _renglon    SMALLINT;
	DEFINE _pagado     INTEGER;

   FOREACH	
	SELECT renglon,
		   no_tranrec	
	  INTO _renglon,
	       _no_tranrec
	  FROM cobredet
	 WHERE no_remesa = a_no_remesa
	   AND tipo_mov  = 'T'

		SELECT pagado
		  INTO _pagado
		  FROM rectrmae
		 WHERE no_tranrec = _no_tranrec;

		IF _pagado = 1 THEN
			LET _mensaje = "La Transaccion de Reclamos del Renglon #: " || _renglon ||
			               " Ya Fue Aplicada";
			RETURN 1, _mensaje;
		END IF

	END FOREACH

END 

-- Verificacion de Primas en Suspenso

BEGIN

	DEFINE _doc_remesa     CHAR(30);
	DEFINE _monto_rem      DEC(16,2);
	DEFINE _monto_sus      DEC(16,2);
	DEFINE _no_recibo_otro CHAR(10);
	DEFINE _no_rem_otr     CHAR(10);
	define _no_recibo      CHAR(10);

   FOREACH	
	SELECT doc_remesa, 
		   SUM(monto)
	  INTO _doc_remesa,
	  	   _monto_rem
	  FROM cobredet
	 WHERE no_remesa = a_no_remesa
	   AND tipo_mov  = 'A'
	 GROUP BY doc_remesa

		SELECT monto
		  INTO _monto_sus
		  FROM cobsuspe
		 WHERE doc_suspenso = _doc_remesa
		   AND cod_compania = _cod_compania;

		IF _monto_sus IS NULL THEN
			LET _mensaje = "No Existe Prima en Suspenso para Documento #: " || _doc_remesa;
			RETURN 1, _mensaje;
		END IF
		
		LET _monto_rem = _monto_rem * -1;

		IF _monto_rem > _monto_sus THEN
			LET _mensaje = "Monto a Aplicar es Mayor que lo Pendiente de Aplicar, Documento # " || _doc_remesa;
			RETURN 1, _mensaje;
		END IF

   END FOREACH

   FOREACH	
   	SELECT doc_remesa, 
		   no_recibo
   	  INTO _doc_remesa,
   	  	   _no_recibo
   	  FROM cobredet
   	 WHERE no_remesa = a_no_remesa
   	   AND tipo_mov  = 'A'

	   FOREACH	
	   	SELECT no_recibo,
			   no_remesa
	   	  INTO _no_recibo_otro,
			   _no_rem_otr
	   	  FROM cobredet
	   	 WHERE doc_remesa = _doc_remesa
	   	   AND tipo_mov   = 'E'

		IF _no_recibo <> _no_recibo_otro THEN
			LET _mensaje = "Recibo del Documento # " || trim(_doc_remesa) || " No Coincide, Verifique Remesa # " || _no_rem_otr;
			RETURN 1, _mensaje;
		END IF
				
	   END FOREACH

   END FOREACH

END 

-- Maque.
-- Verificacion del monto de los recibos automaticos
{IF _tipo_remesa = 'A' and _tipo_mov <> 'B' then -- Recibo automatico que no sea anulado
	BEGIN
	  DEFINE _monto_recibo DEC(16,2);
	  DEFINE _diferencia   DEC(16,2);



	  Select sum(importe)
	    Into _monto_recibo
	    From cobrepag
	   Where no_remesa = a_no_remesa
   
   		If  _monto_recibo < _monto_chequeo then

		 		Let _diferencia = _monto_chequeo - _monto_recibo;

				LET _mensaje = "Le falta insertar en las formas de pago de los recibos" || _diferencia;

				RETURN 1, _mensaje;
		END IF

	End If

End

If _tipo_remesa = 'A' then

	LET _mensaje = "Debera ingresar una nueva remesa para poder imprimir en el proximo recibo" ;

	UPDATE cobredet
			   SET tipo_mov     = 'B' 
			 WHERE  }
			     

-- Verificacion para el Numero Interno de Polizas

BEGIN

	DEFINE _no_poliza  CHAR(10);
	DEFINE _renglon    SMALLINT; 
	DEFINE _cod_agente CHAR(5);
	DEFINE _encontrado SMALLINT;

   FOREACH	
	SELECT no_poliza,
	       renglon
	  INTO _no_poliza,
	       _renglon
	  FROM cobredet
	 WHERE no_remesa = a_no_remesa
	   AND tipo_mov  IN ('P', 'N')

		IF _no_poliza IS NULL THEN
			LET _mensaje = "El Numero Interno de Poliza del Renglon #: " || _renglon ||
			               " Esta Errado.  Por Favor Verifique ";
			RETURN 1, _mensaje;
		END IF

		LET _encontrado = 0;

	   FOREACH	
		SELECT cod_agente
		  INTO _cod_agente
		  FROM cobreagt
		 WHERE no_remesa    = a_no_remesa
		   AND renglon      = _renglon
			LET _encontrado = 1;
			EXIT FOREACH;
	   END FOREACH

		IF _encontrado = 0 THEN
			LET _mensaje = "No se creo el registro del Renglon #: " || _renglon ||
			               " Para el Corredor(cobreagt).  Por Favor Verifique ";
			RETURN 1, _mensaje;
		END IF

-- Para cuando son las aplicaciones de creditos que son procesos masivos poner esto en comentario
--{	
		foreach
		 select cod_agente
		   into _cod_agente
		   from cobreagt
		  where no_remesa = a_no_remesa
		    and renglon   = _renglon

			 select count(*)
			   into _cantidad
			   from emipoagt
			  where no_poliza  = _no_poliza
			    and cod_agente = _cod_agente;

			if _cantidad = 0 then
				
				select count(*)
				  into _cantidad
				  from endedmae
				 where no_poliza     = _no_poliza
				   and cod_endomov   = "012"
				   and actualizado   = 1
				   and fecha_emision >= _fecha;

				if _cantidad = 0 then

					LET _mensaje = "Corredor No Esta en la Poliza, Renglon #: " || _renglon ||
					               " .Por Favor Verifique ";
					RETURN 1, _mensaje;
	
				end if	

			end if	

		end foreach
--}

	END FOREACH

END	

-- Verificacion para el Numero Interno de Transaccion de Reclamos

BEGIN

	DEFINE _no_tranrec CHAR(10);
	DEFINE _renglon    SMALLINT; 

   FOREACH	
	SELECT no_tranrec,
	       renglon
	  INTO _no_tranrec,
	       _renglon
	  FROM cobredet
	 WHERE no_remesa = a_no_remesa
	   AND tipo_mov  IN ('T')

		IF _no_tranrec IS NULL THEN
			LET _mensaje = "El Numero Interno de Transaccion del Renglon #: " || _renglon ||
			               " Esta Errado.  Por Favor Verifique ";
			RETURN 1, _mensaje;
		END IF

	END FOREACH

END	

-- Verificacion para el Numero Interno de Reclamos

BEGIN

	DEFINE _no_reclamo  CHAR(10);
	DEFINE _cod_cober   CHAR(5);
	DEFINE _renglon     SMALLINT; 
	DEFINE _cod_cliente CHAR(10);

   FOREACH	
	SELECT no_reclamo,
		   cod_cobertura,
	       renglon,
		   cod_recibi_de
	  INTO _no_reclamo,
	       _cod_cober,
	       _renglon,
		   _cod_cliente
	  FROM cobredet
	 WHERE no_remesa = a_no_remesa
	   AND tipo_mov  IN ('S','R','D')

		IF _no_reclamo IS NULL OR
		   _cod_cober  IS NULL THEN
			LET _mensaje = "El Numero de Reclamos del Renglon #: " || _renglon ||
			               " Esta Errado.  Por Favor Verifique ";
			RETURN 1, _mensaje;
		END IF

		IF _cod_cliente IS NULL THEN
			LET _mensaje = "Es Necesario Capturar de Quien se esta Recibiendo el Pago " ||
			               "Renglon #: " || _renglon || " Por Favor Verifique ";
			RETURN 1, _mensaje;
		END IF

	END FOREACH

END	

-- Verificacion de Cuentas de Mayor con Auxliliares

BEGIN

	DEFINE _doc_remesa  	CHAR(30);
	DEFINE _cod_auxiliar    CHAR(5);
	DEFINE _cta_auxiliar	CHAR(1);
	DEFINE _renglon    		SMALLINT; 

   FOREACH	
	SELECT doc_remesa,
	       cod_auxiliar,
		   renglon
	  INTO _doc_remesa,
	       _cod_auxiliar,
		   _renglon
	  FROM cobredet
	 WHERE no_remesa = a_no_remesa
	   AND tipo_mov  IN ('M')

		select cta_auxiliar
		  into _cta_auxiliar
		  from cglcuentas
		 where cta_cuenta = _doc_remesa;

		IF _cta_auxiliar = "S"   and
		   _cod_auxiliar IS NULL THEN
			LET _mensaje = "Falta Capturar el Codigo del Auxiliar del Renglon #: " || _renglon;
			RETURN 1, _mensaje;
		END IF

	END FOREACH

END	

-- Generacion de Registros Contables de la Remesa

BEGIN

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

	DEFINE _valor_pago       DEC(16,2);

	DELETE FROM cobasien
	 WHERE no_remesa = a_no_remesa;

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

	INSERT INTO cobredet(
    no_remesa,
    renglon,
    cod_compania,
    cod_sucursal,
    no_recibo,
    doc_remesa,
    tipo_mov,
    monto,
    prima_neta,
    impuesto,
    monto_descontado,
    comis_desc,
    desc_remesa,
    saldo,
    periodo,
    fecha,
    actualizado
	)
	VALUES (
    a_no_remesa,
    0,
    _cod_compania,
    _cod_sucursal,
    '00000',
    '00000',
    'B',
    0,
    0,
    0,
    0,
    0,
    'REGISTRO DEL BANCO',
    0,
    _periodo,
    _date_posteo,
    0
	);

	-- Lectura del Origen del Banco para el Enlace de Cuentas
	  	
	SELECT cod_origen
	  INTO _cod_origen
	  FROM chqbanco
	 WHERE cod_banco = _cod_banco;

	IF _cod_origen = '001' THEN
		LET _cuenta = sp_sis15('BACHEBL', '02', _cod_banco); -- Chequera Bancos Locales
	ELSE
		LET _cuenta = sp_sis15('BACHEBE', '02', _cod_banco); -- Chequera Bancos Extranjeros
	END IF

	CALL sp_sis16(a_no_remesa, 0, _cuenta, _monto_banco, 0);

	-- Verificacion de los Registros Contables

	SELECT SUM(debito - credito)
	  INTO _monto
	  FROM cobasien
	 WHERE no_remesa = a_no_remesa;

	IF _monto <> 0 THEN
		LET _mensaje = "Registros Contables No Cuadran ...";
		RETURN 1, _mensaje;
	END IF

END

--LET _mensaje = "Actualizacion Exitosa ...";
--RETURN 0, _mensaje;

----------------------------
-- Procesos de Actualizacion
----------------------------

-- Actualizacion de Deuda de Agentes

call sp_cob191(a_no_remesa) returning _error, _mensaje;

if _error <> 0 then
	return _error, _mensaje;
end if

-- Actualizacion de Creacion de Primas en Suspenso

BEGIN

	DEFINE _doc_remesa CHAR(30);

   FOREACH	
	SELECT doc_remesa
	  INTO _doc_remesa
	  FROM cobredet
	 WHERE no_remesa = a_no_remesa
	   AND tipo_mov  = 'E'
	 GROUP BY doc_remesa

		UPDATE cobsuspe
		   SET actualizado  = 1
		 WHERE doc_suspenso = _doc_remesa 
		   AND cod_compania = _cod_compania;

	END FOREACH

END 

-- Actualizacion de Aplicacion de Primas en Suspenso

BEGIN

	DEFINE _doc_remesa CHAR(30);
	DEFINE _monto_rem  DEC(16,2);
	DEFINE _monto_sus  DEC(16,2);

   FOREACH	
	SELECT doc_remesa, 
		   SUM(monto)
	  INTO _doc_remesa,
	  	   _monto_rem
	  FROM cobredet
	 WHERE no_remesa = a_no_remesa
	   AND tipo_mov  = 'A'
	 GROUP BY doc_remesa

		UPDATE cobsuspe
		   SET monto        = monto + _monto_rem 
		 WHERE doc_suspenso = _doc_remesa 
		   AND cod_compania = _cod_compania;

		DELETE FROM cobsuspe
		 WHERE doc_suspenso = _doc_remesa 
		   AND cod_compania = _cod_compania
		   AND monto        = 0;

	END FOREACH

END 

-- Actualizacion de Saldos de Polizas y del Ultimo Pago

BEGIN

	DEFINE _no_poliza  		CHAR(10);
	DEFINE _monto	   		DEC(16,2); 
	define _no_documento	char(20);

	FOREACH	
	 SELECT no_poliza, 
	        monto
	  INTO _no_poliza, 
	       _monto
	  FROM cobredet
	 WHERE no_remesa = a_no_remesa
	   AND tipo_mov  IN ('P', 'N')

		UPDATE emipomae
		   SET saldo     = saldo - _monto
		 WHERE no_poliza = _no_poliza;

	END FOREACH

	FOREACH	
	 SELECT no_poliza,
	        monto,
			doc_remesa
	   INTO _no_poliza,
	        _monto,
		   _no_documento
	   FROM cobredet
	  WHERE no_remesa = a_no_remesa
	    AND tipo_mov  IN ('P')

		call sp_cob192(_no_documento, _fecha, _monto);  -- Polizas con Pronto Pago

		UPDATE emipomae
		   SET fecha_ult_pago = _fecha
		 WHERE no_poliza      = _no_poliza;

	END FOREACH

END

-- Actualizacion de Aplicacion de Reclamos

BEGIN

	DEFINE _no_tranrec CHAR(10);
	DEFINE _renglon    SMALLINT;

   FOREACH	
	SELECT renglon,
		   no_tranrec	
	  INTO _renglon,
	       _no_tranrec
	  FROM cobredet
	 WHERE no_remesa = a_no_remesa
	   AND tipo_mov  = 'T'

		UPDATE rectrmae
		   SET pagado     = 1,
		       no_remesa  = a_no_remesa,
			   renglon    = _renglon
		 WHERE no_tranrec = _no_tranrec;

	END FOREACH

END 

-- Actualizacion de Recuperos, Deducibles y Salvamentos

BEGIN

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
	 WHERE no_remesa = a_no_remesa
	   AND tipo_mov  IN ('D', 'S', 'R')
       
		LET _salvamento = 0;
		LET _recupero   = 0;
		LET _deducible  = 0;
		
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
		    a_no_remesa,
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
		    a_usuario
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
		    a_no_remesa,
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
		    a_usuario
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

		UPDATE recrccob
		   SET salvamento       = salvamento       + _salvamento,
		       recupero         = recupero         + _recupero,
			   deducible_pagado = deducible_pagado + _deducible
		 WHERE no_reclamo       = _no_reclamo
		   AND cod_cobertura    = _cod_cobertura;

		-- Actualizacion en la Remesa del Numero de Transaccion Generado

		UPDATE cobredet
		   SET no_tranrec = _no_tranrec_char
		 WHERE no_remesa  = a_no_remesa
		   AND renglon    = _renglon;

		-- Reaseguro a Nivel de Transaccion

		call sp_sis58(_no_tranrec_char) returning _error, _mensaje;

		if _error <> 0 then
			return _error, _mensaje;
		end if

   END FOREACH

END

-- Actualizacion de los Datos de la Remesa

UPDATE cobremae
   SET user_posteo = a_usuario,
       date_posteo = CURRENT,
	   actualizado = 1
 WHERE no_remesa   = a_no_remesa;

UPDATE cobredet
   SET periodo     = _periodo,
       fecha       = _fecha,
	   actualizado = 1
 WHERE no_remesa   = a_no_remesa;

--COMMIT WORK;

LET _mensaje = "Actualizacion Exitosa ...";
RETURN 0, _mensaje;

END

END PROCEDURE;
