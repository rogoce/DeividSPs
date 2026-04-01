--********************************************************
-- Procedimiento que Carga las Bonificaciones de cobranza
--********************************************************

-- Creado    : 27/02/2008 - Autor: Armando Moreno M.
-- Modificado: 27/02/2008 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_che81a;

CREATE PROCEDURE sp_che81a
(
a_compania          CHAR(3),
a_sucursal          CHAR(3),
a_periodo		    CHAR(7)
)

DEFINE _cod_agente      CHAR(5);  
DEFINE _no_poliza       CHAR(10); 
DEFINE _no_remesa       CHAR(10); 
DEFINE _renglon         SMALLINT; 
DEFINE _monto           DEC(16,2);
DEFINE _gen_cheque      SMALLINT; 
DEFINE _no_recibo       CHAR(10); 
DEFINE _fecha           DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2); 
DEFINE _comision        DEC(16,2);
DEFINE _sobrecomision   DEC(16,2);
DEFINE _nombre          CHAR(50); 
DEFINE _no_documento    CHAR(20); 
DEFINE _no_requis       CHAR(10); 
DEFINE _cod_tipoprod    CHAR(3);  
DEFINE _tipo_prod       SMALLINT; 
DEFINE _monto_vida      DEC(16,2);
DEFINE _monto_danos     DEC(16,2);
DEFINE _monto_fianza    DEC(16,2);
DEFINE _cod_tiporamo    CHAR(3);  
DEFINE _tipo_ramo       SMALLINT; 
DEFINE _cod_ramo        CHAR(3);  
DEFINE _no_licencia     CHAR(10); 
DEFINE _tipo_mov        CHAR(1);  
DEFINE _fecha_ult_comis DATE;     
DEFINE _incobrable		SMALLINT;
DEFINE _tipo_pago     	SMALLINT;
DEFINE _tipo_agente     CHAR(1);
DEFINE _agente_agrupado char(5);
DEFINE _cod_producto	char(5);
DEFINE _cod_formapag    char(3);
DEFINE _tipo_forma      SMALLINT;
DEFINE _no_licencia2    CHAR(10); 
DEFINE _nombre2         CHAR(50); 
define _forma_pag		smallint;
define _fecha_hoy       date;
DEFINE v_prima_orig     DEC(16,2);
DEFINE v_saldo          DEC(16,2);
DEFINE v_por_vencer     DEC(16,2);
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente      DEC(16,2);
DEFINE v_monto_30       DEC(16,2);
DEFINE v_monto_60       DEC(16,2);

	
--SET DEBUG FILE TO "sp_che02a.trc";
--TRACE ON;

let _fecha_hoy = current;
let _forma_pag = 0;

CREATE TEMP TABLE tmp_boni(
	cod_agente		CHAR(15),
	no_poliza		CHAR(10),
	no_recibo		CHAR(10),
	fecha			DATE,
	monto           DEC(16,2),
	prima           DEC(16,2),
	porc_partic		DEC(5,2),
	porc_comis		DEC(5,2),
	comision		DEC(16,2),
	nombre			CHAR(50),
	no_documento    CHAR(20),
	monto_vida      DEC(16,2),
	monto_danos     DEC(16,2),
	monto_fianza    DEC(16,2),
	no_licencia     CHAR(10),
	seleccionado    SMALLINT DEFAULT 1,
	PRIMARY KEY		(cod_agente, no_poliza, no_recibo, fecha)
	) WITH NO LOG;

CREATE TEMP TABLE tmp_morosi(
	no_poliza		CHAR(10),
	corriente       DEC(16,2) default 0,   --0  a 45
	monto_30        DEC(16,2) default 0,   --46 a 90
	monto_60		DEC(5,2)  default 0,   --91 -->
	PRIMARY KEY		(no_poliza)
	) WITH NO LOG;

SET ISOLATION TO DIRTY READ;


		if v_monto_60 > 0 then

			let _prima_r = v_monto_60 - _prima_r;

			if _prima_r <= 0 then	  
				update tmp_moros
				   set monto_60  = 0;
				 where no_poliza = _no_poliza;

				let _prima_r = ABS(_prima_r);
			else
				update tmp_moros
				   set monto_60  = _prima_r;
				 where no_poliza = _no_poliza;

				continue foreach;			 --salir por que no quedo pago
			end if

		end if

		if v_monto_30 > 0 then	  --hay morosidad >45 a 90

			let _prima_rr = _prima_r;

			let _prima_r = v_monto_30 - _prima_r;

			if _prima_r <= 0 then
				update tmp_moros
				   set monto_30  = 0;
				 where no_poliza = _no_poliza;

				let _prima_r  = ABS(_prima_r);

			else
				update tmp_moros
				   set monto_60  = _prima_r;
				 where no_poliza = _no_poliza;

				let _prima_r = _prima_rr;
				
			end if

			if _forma_pag = 0 then	--Pago voluntario y Moro de 46 a 90 dias
				let _porc_comis = 1;
				let _formula_a = _prima_r * (_porc_comis / 100);
			end if

			if _forma_pag = 1  then	--Pago electronico y Moro de 46 a 90 dias
				let _porc_comis = 2;
				let _formula_a = _prima_r * (_porc_comis / 100);
			end if

		end if
		
		if v_corriente >= 0 then	  --hay morosidad 0 a 45

			if _forma_pag = 0 then	--Pago voluntario y Moro de 46 a 90 dias
				let _porc_comis = 2;
				let _formula_a = _prima_r * (_porc_comis / 100);
			end if

			if _forma_pag = 1  then	--Pago electronico y Moro de 46 a 90 dias
				let _porc_comis = 3;
				let _formula_a = _prima_r * (_porc_comis / 100);
			end if

		end if


	else

		select corriente,monto_30,monto_60
		  into v_corriente,v_monto_30,v_monto_60
		  from tmp_morosi
		 where no_poliza = _no_poliza;

		

	end if

	FOREACH
		 SELECT	cod_agente,porc_partic_agt,porc_comis_agt
		   INTO	_cod_agente,_porc_partic,_porc_comis
		   FROM	cobreagt
		  WHERE	no_remesa = _no_remesa
		    AND renglon   = _renglon

		SELECT generar_cheque,nombre,no_licencia,fecha_ult_comis,tipo_pago,tipo_agente,agente_agrupado
		  INTO _gen_cheque,_nombre,_no_licencia,_fecha_ult_comis,_tipo_pago,_tipo_agente,_agente_agrupado
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

		IF _tipo_agente <> "A" then
			continue foreach;
		END IF	   

		LET _comision = _prima * (_porc_partic / 100) * (_porc_comis / 100);

		BEGIN

			ON EXCEPTION IN(-239)

				UPDATE tmp_boni
				   SET monto        = monto        + _monto,
				       prima        = prima        + _prima,
					   comision     = comision     + _comision
				 WHERE cod_agente   = _cod_agente
				   AND no_poliza    = _no_poliza
				   AND no_recibo    = _no_recibo
				   AND fecha        = _fecha;

			END EXCEPTION

			INSERT INTO tmp_boni(cod_agente,no_poliza,no_recibo,fecha,monto,prima,porc_partic,porc_comis,comision,nombre,no_documento,no_licencia)
			VALUES(_cod_agente,_no_poliza,_no_recibo,_fecha,_monto,_prima,_porc_partic,_porc_comis,_comision,_nombre,_no_documento,_no_licencia);

		END

	END FOREACH

END FOREACH

--cargar tabla chqboni

FOREACH
 SELECT	cod_agente,
 		no_poliza,
		no_recibo,
		fecha,
		monto,
		prima,
		porc_partic,
		porc_comis,
		comision,
		nombre,
		no_documento,
		no_licencia
   INTO	_cod_agente,
   		_no_poliza,
		_no_recibo,
		_fecha,
		_monto,
		_prima,
		_porc_partic,
		_porc_comis,
		_comision,
		_nombre,
		_no_documento,
		_no_licencia 
   FROM	tmp_boni
  ORDER BY nombre, fecha, no_recibo, no_documento

   SELECT tipo_pago
     INTO _tipo_pago
	 FROM agtagent
	WHERE cod_agente = v_cod_agente;

	INSERT INTO chqboni(
	     cod_agente,	
		 no_poliza,	
		 no_recibo,	
		 fecha,		
		 monto,       
		 prima,       
		 porc_partic,	
		 porc_comis,	
		 comision,	
		 nombre,		
		 no_documento,
		 no_licencia, 
		 seleccionado,
		 periodo,
		 fecha_genera
		 )
		 VALUES(
		 _cod_agente,
		 _no_poliza,
		 _no_recibo,
		 _fecha,
		 _monto,
		 _prima,
		 _porc_partic,
		 _porc_comis,
		 _comision,
		 _nombre,
		 _no_documento,
		 _no_licencia,
		 0,
		 a_periodo,
		 current 
		 );
END FOREACH

END PROCEDURE;