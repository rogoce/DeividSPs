-- Reporte de las bonificaciones de cobranza por Corredor - Detallado

-- Creado    : 11/03/2008 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 11/03/2008 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_che03_dw1 - DEIVID, S.A.

--DROP PROCEDURE sp_che83c;

CREATE PROCEDURE sp_che83c(a_compania CHAR(3), a_cod_agente CHAR(255) default '*', a_periodo char(7),a_periodo2 char(7),a_tipo_pago smallint)
  RETURNING CHAR(20),	-- Poliza	  
			CHAR(100),	-- Asegurado  
			DEC(16,2),	-- Monto	  
			DEC(16,2),	-- Prima	  
			DEC(16,2),	-- Comision	   
			CHAR(50),  
			CHAR(50),  			   
			DEC(5,2),  			   
			DEC(16,2), 	   
			DEC(5,2),  	   
			DEC(16,2), 	   
			DEC(16,2), 	   
			DEC(16,2), 	   
			DEC(16,2), 	   
			DEC(16,2), 	   
			DEC(16,2),
			smallint;

DEFINE _tipo          CHAR(1);
DEFINE v_cod_agente   CHAR(5);  
DEFINE v_no_poliza    CHAR(10); 
DEFINE v_monto        DEC(16,2);
DEFINE v_no_recibo    CHAR(10); 
DEFINE v_fecha        DATE;     
DEFINE v_prima        DEC(16,2);
DEFINE v_porc_comis   DEC(5,2); 
DEFINE v_comision     DEC(16,2);
DEFINE v_nombre_clte  CHAR(100);
DEFINE v_no_documento CHAR(20);
DEFINE v_nombre_agt   CHAR(50);
DEFINE v_nombre_cia   CHAR(50);
DEFINE _fecha_comis   DATE;
DEFINE _cod_cliente   CHAR(10);
define _moro_045      DEC(16,2); 
define _moro_4690	  DEC(16,2);
define _porc_045	  DEC(5,2);
define _porc_4690	  DEC(5,2);
define _porc_partic   DEC(5,2);
define _045           DEC(16,2);
define _4690		  DEC(16,2);
define _91			  DEC(16,2);
define _pol_corr	  DEC(16,2);
define _pol_0045	  DEC(16,2);
define _pol_4690	  DEC(16,2);
define _comision2	  DEC(16,2);
define _comision1	  DEC(16,2);
define _tipo_pago     smallint;


--SET DEBUG FILE TO "\\sp_che83.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

LET  v_nombre_cia = sp_sis01(a_compania); 

SET ISOLATION TO DIRTY READ;

let	_pol_corr  = 0;
let	_pol_0045  = 0;
let	_pol_4690  = 0;
let _comision1 = 0;
let _comision2 = 0;


	LET _tipo = sp_sis04(a_cod_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		FOREACH
		 SELECT	cod_agente,
		 		no_poliza,
				monto,
				prima,
				comision,
				nombre,
				no_documento,
				moro_045,
				moro_4690,
				porc_045,
				porc_4690,
				pol_corr,
				pol_0045,
				pol_4690,
				comis0045,
				comis4690
		   INTO	v_cod_agente,
		   		v_no_poliza,
				v_monto,
				v_prima,
				v_comision,
				v_nombre_agt,
				v_no_documento,
				_moro_045,
				_moro_4690,
				_porc_045,
				_porc_4690,
				_pol_corr,
				_pol_0045,
				_pol_4690,
		        _comision2,
				_comision1
		   FROM	chqboni
		  WHERE cod_agente IN (SELECT codigo FROM tmp_codigos)
			and periodo  >= a_periodo
			and periodo  <= a_periodo2

			SELECT cod_contratante
		      INTO _cod_cliente
		      FROM emipomae
		     WHERE no_poliza = v_no_poliza;

		    SELECT nombre
		      INTO v_nombre_clte
		      FROM cliclien
		     WHERE cod_cliente = _cod_cliente;

		    SELECT tipo_pago
		      INTO _tipo_pago
		      FROM agtagent
		     WHERE cod_agente = v_cod_agente;

			if a_tipo_pago = 0 then
			elif a_tipo_pago = 1 then
				if _tipo_pago <> 1 then
					continue foreach;
				end if
			else
				if _tipo_pago <> 2 then
					continue foreach;
				end if
			end if
			let _porc_4690 = _porc_4690 - _porc_045;
			RETURN  v_no_documento,
					v_nombre_clte,
					v_monto,
					v_prima,
					v_comision,
					v_nombre_agt,
					v_nombre_cia,
					_porc_045,
					_moro_045,
					_porc_4690,
					_moro_4690,
					_pol_corr,
					_pol_0045,
					_pol_4690,
					_comision2,
					_comision1,
					a_tipo_pago
					WITH RESUME;
			
		END FOREACH

	ELSE		        -- Excluir estos Registros

		FOREACH
		 SELECT	cod_agente,
		 		no_poliza,
				monto,
				prima,
				comision,
				nombre,
				no_documento,
				moro_045,
				moro_4690,
				porc_045,
				porc_4690,
				pol_corr,
				pol_0045,
				pol_4690,
				comis0045,
				comis4690
		   INTO	v_cod_agente,
		   		v_no_poliza,
				v_monto,
				v_prima,
				v_comision,
				v_nombre_agt,
				v_no_documento,
				_moro_045,
				_moro_4690,
				_porc_045,
				_porc_4690,
				_pol_corr,
				_pol_0045,
				_pol_4690,
		        _comision2,
				_comision1
		   FROM	chqboni
		  WHERE cod_agente NOT IN (SELECT codigo FROM tmp_codigos)
			and periodo  >= a_periodo
			and periodo  <= a_periodo2


			SELECT cod_contratante
		      INTO _cod_cliente
		      FROM emipomae
		     WHERE no_poliza = v_no_poliza;

		    SELECT nombre
		      INTO v_nombre_clte
		      FROM cliclien
		     WHERE cod_cliente = _cod_cliente;

		    SELECT tipo_pago
		      INTO _tipo_pago
		      FROM agtagent
		     WHERE cod_agente = v_cod_agente;

			if a_tipo_pago = 0 then
			elif a_tipo_pago = 1 then
				if _tipo_pago <> 1 then
					continue foreach;
				end if
			else
				if _tipo_pago <> 2 then
					continue foreach;
				end if
			end if
			let _porc_4690 = _porc_4690 - _porc_045;
			RETURN  v_no_documento,
					v_nombre_clte,
					v_monto,
					v_prima,
					v_comision,
					v_nombre_agt,
					v_nombre_cia,
					_porc_045,
					_moro_045,
					_porc_4690,
					_moro_4690,
					_pol_corr,
					_pol_0045,
					_pol_4690,
					_comision2,
					_comision1,
					a_tipo_pago
					WITH RESUME;
			
		END FOREACH

	END IF
	DROP TABLE tmp_codigos;

END PROCEDURE;