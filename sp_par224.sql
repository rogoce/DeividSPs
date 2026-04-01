-- Generacion de Registros Contables de la Remesa

-- Creado    : 12/10/2000 - Autor: Demetrio Hurtado Almanza 

-- Modificado: 06/03/2006 - Autor: Demetrio Hurtado Almanza

			 -- Se cambio el proceso de comisiones por pagar para que sea rebajando la provision de comisiones por pagar
			 -- y creando la deduda de comisiones por pagar usando una cuenta que maneja el auxiliar de comisiones por 
			 -- cada corredor	

-- SIS v.2.0 - sp_cob29 -- DEIVID, S.A.

DROP PROCEDURE sp_par224;		

CREATE PROCEDURE "informix".sp_par224(a_no_remesa char(10))
RETURNING INTEGER,
		  CHAR(100);

DEFINE _tipo_mov         	CHAR(1);  
DEFINE _renglon          	SMALLINT; 
DEFINE _cuenta           	CHAR(25); 
DEFINE _debito           	DEC(16,2);
DEFINE _credito          	DEC(16,2);
DEFINE _prima_neta       	DEC(16,2);
DEFINE _cod_tipoprod     	CHAR(3);  
DEFINE _tipo_produccion  	SMALLINT; 
DEFINE _no_poliza        	CHAR(10); 
DEFINE _monto_descontado	DEC(16,2);
DEFINE _no_documento     	CHAR(30);
DEFINE _no_reclamo       	CHAR(10);
DEFINE _porc_partic      	DEC(7,4);
DEFINE _monto			 	DEC(16,2);
DEFINE _cod_origen       	CHAR(3);
define _fecha_param			date;
define _fecha				date;
DEFINE _valor_pago      	DEC(16,2);
DEFINE _cod_banco    		CHAR(3);
DEFINE _cod_compania 		CHAR(3);
DEFINE _cod_sucursal 		CHAR(3);
DEFINE _date_posteo  		DATE;
DEFINE _periodo      		CHAR(7);
DEFINE _monto_banco  		DEC(16,2);
DEFINE _monto_calc  		DEC(16,2);

DEFINE _prima_suscrita     	DEC(16,2);
DEFINE _comis_manual     	DEC(16,2);
define _porc_partic_coas    decimal(7,4);
define _porc_partic_coas2   decimal(7,4);
DEFINE _cod_coasegur 		CHAR(3);
define _cod_lider			char(3);
DEFINE _porc_comis_agt   	DECIMAL(5,2);
DEFINE _porc_partic_agt	 	DECIMAL(5,2);
DEFINE _cod_auxiliar 		CHAR(5);
define _tipo_agente			char(1);
define _cantidad			smallint;

DEFINE _error				integer;
DEFINE _error_2      		integer;
DEFINE _error_desc   		char(50);

SET ISOLATION TO DIRTY READ;

--set debug file to "sp_par203.trc";
--trace on;

BEGIN

ON EXCEPTION SET _error, _error_2, _error_desc 
 	RETURN _error, _error_desc;
END EXCEPTION           

DELETE FROM cobasiau WHERE no_remesa = a_no_remesa;
DELETE FROM cobasien WHERE no_remesa = a_no_remesa;
DELETE FROM cobredet WHERE no_remesa = a_no_remesa and renglon = 0;

SELECT par_ase_lider,
	   rec_fecha_prov	
  INTO _cod_lider,
	   _fecha_param	
  FROM parparam
 WHERE cod_compania = "001";

SELECT cod_banco,
	   cod_compania,
	   cod_sucursal,
	   date_posteo,
	   periodo,
	   monto_chequeo,
	   fecha
  INTO _cod_banco,
	   _cod_compania,
	   _cod_sucursal,
	   _date_posteo,
	   _periodo,
	   _monto_banco,
	   _fecha
  FROM cobremae
 WHERE no_remesa = a_no_remesa;

-- Lectura del Origen del Banco para el Enlace de Cuentas
  	
SELECT cod_origen
  INTO _cod_origen
  FROM chqbanco
 WHERE cod_banco = _cod_banco;

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

	IF _tipo_mov   = 'M' AND
	   _monto_descontado <> 0  THEN
		LET _monto_calc = 0;
	ELSE
		LET _monto_calc = _monto;
	END IF

	LET _monto_banco = _monto - _monto_descontado;

	IF _cod_origen = '001' THEN
		LET _cuenta = sp_sis15('BACHEBL', '02', _cod_banco); -- Chequera Bancos Locales
	ELSE
		LET _cuenta = sp_sis15('BACHEBE', '02', _cod_banco); -- Chequera Bancos Extranjeros
	END IF

	CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _monto_banco, 0);

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

		-- Prima por Cobrar

		IF   _tipo_produccion = 3 THEN 
			LET _cuenta = sp_sis15('PACXCC',  '01', _no_poliza); -- Coaseguro Minoritario
		ELIF _tipo_produccion = 4 THEN 
			LET _cuenta = sp_sis15('PAPXCRA', '01', _no_poliza); -- Reaseguro Asumido
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

--{
		-- Provision de Comision y Comision por Pagar (Auxiliar)

		if _tipo_produccion in (1, 2, 3) then
		
			select porc_partic_coas
			  into _porc_partic_coas
			  from emicoama
			 where no_poliza    = _no_poliza
			   and cod_coasegur = _cod_lider;
			
			if _porc_partic_coas is null then
				let _porc_partic_coas = 100;
			end if

			let _prima_suscrita = _prima_neta * _porc_partic_coas / 100;

			foreach
			 Select	porc_comis_agt,
					porc_partic_agt,
					cod_agente,
					monto_man
			   Into	_porc_comis_agt,
					_porc_partic_agt,
					_cod_auxiliar,
					_comis_manual
			   From cobreagt
			  Where	no_remesa = a_no_remesa
			    and renglon   = _renglon
	
				select tipo_agente
				  into _tipo_agente
				  from agtagent
				 where cod_agente = _cod_auxiliar;

				if _tipo_agente = "A" then -- Agentes Normales

					let _cod_auxiliar = "A" || _cod_auxiliar[2,5]; -- En SAC no alcanza para poner los 5 digitos

					Let _monto = _prima_suscrita * (_porc_partic_agt / 100) * (_porc_comis_agt / 100);

					If _monto <> 0.00 Then

						-- Provision de Comision

						Let _debito  = 0.00;
						Let _credito = 0.00;

						IF _tipo_mov = 'P' THEN
							LET _debito  = _monto;
						ELSE
							LET _credito = _monto * -1;
						END IF

						Let _cuenta    = sp_sis15('PPCOMXPCO', '01', _no_poliza); 
						CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

						-- Comisiones por Pagar Auxiliar

						Let _debito  = 0.00;
						Let _credito = 0.00;

						IF _tipo_mov = 'P' THEN
							Let _credito = _monto;
						else
							Let _debito  = _monto * -1;
						end if

						Let _cuenta    = sp_sis15('CPCXPAUX', '01', _no_poliza); 
						CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
						CALL sp_sis86(a_no_remesa, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);

					End If

					-- Comision Descontada 

					If _monto_descontado <> 0.00 Then

						-- Comision por Pagar Auxiliar

						Let _monto = _comis_manual * _porc_partic_coas / 100;

						LET _cuenta = sp_sis15('CPCXPAUX',  '01', _no_poliza); -- Comision por Pagar

						IF _tipo_mov = 'P' THEN
							LET _debito  = _monto;
							LET _credito = 0;
						ELSE
							LET _debito  = 0;
							LET _credito = _monto * -1;
						END IF

						CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
						CALL sp_sis86(a_no_remesa, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);

						-- Coaseguro por Pagar de la Comision Descontada

					   foreach	
						select porc_partic_coas,
						       cod_coasegur
						  into _porc_partic_coas2,
						       _cod_coasegur
						  from emicoama
						 where no_poliza    = _no_poliza
						   and cod_coasegur <> _cod_lider
			
							select cod_auxiliar
							  into _cod_auxiliar
							  from emicoase
							 where cod_coasegur = _cod_coasegur;

							if _cod_auxiliar is null then
								return 1, "La Compania " || _cod_coasegur || " No Tiene Codigo de Auxiliar";
							end if

							let _monto   = _comis_manual * _porc_partic_coas2 / 100;
							Let _debito  = 0.00;
							Let _credito = 0.00;

							IF _tipo_mov = 'P' THEN
								LET _debito  = _monto;
								LET _credito = 0;
							ELSE
								LET _debito  = 0;
								LET _credito = _monto * -1;
							END IF

							Let _cuenta = sp_sis15("PPCOASXP", '01', _no_poliza);   
							CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
							CALL sp_sis86(a_no_remesa, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);

						end foreach

					end if

				elif _tipo_agente = "E" then -- Agentes Especiales

				end if

			end foreach
			
		end if		
--}
--{
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
--}

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
			   AND cod_coasegur = _cod_lider;
			 
			IF _porc_partic IS NULL THEN
				LET _porc_partic = 100;
			END IF
			 
			LET _valor_pago = _monto;

			LET  _monto   = _valor_pago / 100 * _porc_partic; 
			LET  _cuenta  = sp_sis15('SGPDDSD',  '01', _no_poliza); 
			LET  _debito  = 0;
			LET  _credito = _monto;
			CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

		   foreach
			SELECT porc_partic_coas,
				   cod_coasegur
			  INTO _porc_partic,
				   _cod_coasegur
			  FROM reccoas
			 WHERE no_reclamo   =  _no_reclamo
			   AND cod_coasegur <> _cod_lider
			 
				select cod_auxiliar
				  into _cod_auxiliar
				  from emicoase
				 where cod_coasegur = _cod_coasegur;

				if _cod_auxiliar is null then
					return 1, "La Compania " || _cod_coasegur || " No Tiene Codigo de Auxiliar";
				end if

				IF _porc_partic IS NULL THEN
					LET _porc_partic = 100;
				END IF

				LET  _monto   = _valor_pago / 100 * _porc_partic; 

				LET  _cuenta  = sp_sis15('SARXCC',  '01', _no_poliza); 
				LET  _debito  = 0;
				LET  _credito = _monto;
				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
				CALL sp_sis86(a_no_remesa, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);

			end foreach

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
			   AND cod_coasegur = _cod_lider;
			 
			IF _porc_partic IS NULL THEN
				LET _porc_partic = 100;
			END IF
			 
			LET _valor_pago = _monto;

			LET  _monto   = _valor_pago / 100 * _porc_partic; 
			LET  _cuenta  = sp_sis15('SISAL',  '01', _no_poliza); 
			LET  _debito  = 0;
			LET  _credito = _monto;
			CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
			 
		   foreach
			SELECT porc_partic_coas,
				   cod_coasegur
			  INTO _porc_partic,
				   _cod_coasegur
			  FROM reccoas
			 WHERE no_reclamo   =  _no_reclamo
			   AND cod_coasegur <> _cod_lider
			 
				select cod_auxiliar
				  into _cod_auxiliar
				  from emicoase
				 where cod_coasegur = _cod_coasegur;

				if _cod_auxiliar is null then
					return 1, "La Compania " || _cod_coasegur || " No Tiene Codigo de Auxiliar";
				end if

				IF _porc_partic IS NULL THEN
					LET _porc_partic = 100;
				END IF

				LET  _monto   = _valor_pago / 100 * _porc_partic; 

				LET  _cuenta  = sp_sis15('SARXCC',  '01', _no_poliza); 
				LET  _debito  = 0;
				LET  _credito = _monto;
				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
				CALL sp_sis86(a_no_remesa, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);

			end foreach

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
			   AND cod_coasegur = _cod_lider;
			 
			IF _porc_partic IS NULL THEN
				LET _porc_partic = 100;
			END IF
			 
			LET _valor_pago = _monto;

			LET  _monto   = _valor_pago / 100 * _porc_partic; 
			LET  _cuenta  = sp_sis15('SIREC',  '01', _no_poliza); 
			LET  _debito  = 0;
			LET  _credito = _monto;
			CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
			 
		   foreach
			SELECT porc_partic_coas,
				   cod_coasegur
			  INTO _porc_partic,
				   _cod_coasegur
			  FROM reccoas
			 WHERE no_reclamo   =  _no_reclamo
			   AND cod_coasegur <> _cod_lider
			 
				select cod_auxiliar
				  into _cod_auxiliar
				  from emicoase
				 where cod_coasegur = _cod_coasegur;

				if _cod_auxiliar is null then
					return 1, "La Compania " || _cod_coasegur || " No Tiene Codigo de Auxiliar";
				end if

				IF _porc_partic IS NULL THEN
					LET _porc_partic = 100;
				END IF

				LET  _monto   = _valor_pago / 100 * _porc_partic; 

				LET  _cuenta  = sp_sis15('SARXCC',  '01', _no_poliza); 
				LET  _debito  = 0;
				LET  _credito = _monto;
				CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);
				CALL sp_sis86(a_no_remesa, _renglon, _cuenta, _cod_auxiliar, _debito, _credito);

			end foreach

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

{
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
}

-- Verificacion de los Registros Contables

{
SELECT SUM(debito - credito)
  INTO _monto
  FROM cobasien
 WHERE no_remesa = a_no_remesa;

IF abs(_monto) >  0.00 and
   abs(_monto) <= 0.02 THEN

   foreach	
	select cuenta,
	       renglon
	  into _cuenta,
	       _renglon
	  from cobasien
	 where no_remesa = a_no_remesa
	   and renglon   <> 0
	   and debito    > 0

		select count(*)
		  into _cantidad
		  from cobasiau
		 WHERE no_remesa = a_no_remesa
		   AND renglon   = _renglon
		   AND cuenta 	 = _cuenta;

		if _cantidad = 0 then
			exit foreach;	
		end if
				
	end foreach
	
	if _monto > 0 then
		LET _debito  = _monto * -1;
		LET _credito = 0;
	else
	end if

	CALL sp_sis16(a_no_remesa, _renglon, _cuenta, _debito, _credito);

END IF
}

SELECT SUM(debito - credito)
  INTO _monto
  FROM cobasien
 WHERE no_remesa = a_no_remesa;

IF _monto <> 0 THEN
	RETURN 1, "Registros Contables No Cuadran ...";
END IF

END

return 0, "Actualizacion Exitosa";

end procedure