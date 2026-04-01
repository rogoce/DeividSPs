--********************************************************
-- Procedimiento que Determina si a una Poliza se le Paga
-- las Bonificaciones de cobranza
--********************************************************

-- Creado    : 14/08/2008 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che90;

CREATE PROCEDURE sp_che90
(
a_documento	char(20),
a_periodo	CHAR(7)
)
RETURNING char(200);

DEFINE _cod_agente      CHAR(5);  
DEFINE _no_poliza       CHAR(10);
define _cod_subramo     char(3); 
define _cod_origen      char(3); 
DEFINE _no_remesa       CHAR(10); 
DEFINE _renglon         SMALLINT; 
DEFINE _monto           DEC(16,2);
DEFINE _no_recibo       CHAR(10); 
DEFINE _fecha           DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2);
DEFINE _porc_comis2     DEC(5,2);
DEFINE _porc_coas_ancon DEC(5,2);
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
DEFINE _incobrable		SMALLINT;
DEFINE _tipo_pago     	SMALLINT;
DEFINE _tipo_agente     CHAR(1);
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
define _prima_45        DEC(16,2);
define _prima_90		DEC(16,2);
define _prima_r  		DEC(16,2);
define _prima_rr  		DEC(16,2);
define _formula_a  		DEC(16,2);
define _cnt             integer;
define v_monto_30bk		DEC(16,2);
define v_corr			DEC(16,2);
DEFINE _formula_b       DEC(16,2);
define _comision1       DEC(16,2);
define _comision2       DEC(16,2);
define _cod_grupo       char(5);
define _cedula_agt      char(30);
define _cedula_paga		char(30);
define _cedula_cont		char(30);
define _cod_pagador     char(10);
define _cod_contratante char(10);
define _estatus_licencia char(1);
define v_nombre_clte     char(100);
define _cod_contr        char(10);

--DEFINE _periodo         CHAR(7);
--define _mes_act			smallint;
--define _ano_act			smallint;
--define _mes_ant			smallint;
--define _ano_ant			smallint;
define _error           smallint;
define _monto_m			DEC(16,2);
define _monto_p			DEC(16,2);

define a_compania		char(3);
define a_sucursal		char(3);

--SET DEBUG FILE TO "sp_che81.trc";
--TRACE ON;

{let _ano_act = a_periodo[1,4];
let _mes_act = a_periodo[6,7];

if _mes_act = 1 then
	let _mes_ant = 12;
	let _ano_ant = _ano_act - 1;
else
	let _mes_ant = _mes_act - 1;
	let _ano_ant = _ano_act;
end if

if _mes_ant < 10 then
	let _periodo = _ano_ant || "-0" || _mes_ant;
else
	let _periodo = _ano_ant || "-" || _mes_ant;
end if

CALL sp_sis36(_periodo) RETURNING _fecha_hoy;}

let _error   = 0;
let _porc_coas_ancon = 0;
let _forma_pag    = 0;
let _porc_comis   = 0;
let _porc_comis2  = 0;
let _prima_45     = 0;
let _prima_90     = 0;
let _cnt          = 0;
let _monto_m      = 0;
let _monto_p      = 0;
let a_compania	  = "001";
let a_sucursal	  = "001";

CREATE TEMP TABLE tmp_boni(
	cod_agente		CHAR(15),
	no_poliza		CHAR(10),
	monto           DEC(16,2),
	prima           DEC(16,2),
	fecha           DATE,
	PRIMARY KEY		(cod_agente, no_poliza)
	) WITH NO LOG;

CREATE TEMP TABLE tmp_chqboni(
cod_agente 	CHAR(15), 
no_poliza 	CHAR(10), 
no_recibo 	CHAR(10), 
fecha 		DATE, 
monto DECIMAL(16,2), 
prima DECIMAL(16,2), 
porc_partic DECIMAL(5,2) DEFAULT 0.00, 
porc_comis DECIMAL(16,2) DEFAULT 0.00, 
comision DECIMAL(16,2), 
nombre CHAR(50), 
no_documento CHAR(20), 
no_licencia CHAR(10), 
seleccionado SMALLINT, 
periodo CHAR(7), 
fecha_genera DATE, 
no_requis CHAR(10), 
tipo_requis CHAR(1), 
moro_045 DECIMAL(16,2) DEFAULT 0.00, 
moro_4690 DECIMAL(16,2) DEFAULT 0.00, 
porc_045 DECIMAL(5,2) DEFAULT 0.00, 
porc_4690 DECIMAL(5,2) DEFAULT 0.00, 
corriente DECIMAL(16,2) DEFAULT 0.00, 
monto_30 DECIMAL(16,2) DEFAULT 0.00, 
monto_60 DECIMAL(16,2) DEFAULT 0.00, 
pol_corr DECIMAL(16,2) DEFAULT 0.00, 
pol_0045 DECIMAL(16,2) DEFAULT 0.00, 
pol_4690 DECIMAL(16,2) DEFAULT 0.00, 
cod_ramo CHAR(3), 
cod_subramo CHAR(3), 
cod_origen CHAR(3), 
comis0045 DECIMAL(16,2) DEFAULT 0.00, 
comis4690 DECIMAL(16,2) DEFAULT 0.00
) with no log;

SET ISOLATION TO DIRTY READ;

-- Pagos de Prima y Notas Credito

FOREACH
	 SELECT	d.no_poliza,
	        d.no_remesa,
	        d.renglon,
	        d.no_recibo,
	        d.fecha,
	        d.monto,
	        d.prima_neta,
	        d.tipo_mov
	   INTO	_no_poliza,
		    _no_remesa,
		    _renglon,
		    _no_recibo,
		    _fecha,
		    _monto,
		    _prima,
		    _tipo_mov
	   FROM	cobredet d, cobremae m
	  WHERE	d.cod_compania = a_compania
	    AND d.actualizado  = 1
		AND d.tipo_mov     IN ('P','N')
		AND month(d.fecha) = a_periodo[6,7]
		AND year(d.fecha)  = a_periodo[1,4]
		AND d.no_remesa    = m.no_remesa
		AND m.tipo_remesa  IN ('A', 'M', 'C')
		and d.doc_remesa   = a_documento
      ORDER BY d.fecha,d.no_recibo,d.no_poliza

	  select cod_grupo, cod_ramo, cod_pagador, cod_contratante
	    into _cod_grupo,_cod_ramo,_cod_pagador,_cod_contratante
	    from emipomae
	   where no_poliza = _no_poliza;

	  select cedula
	    into _cedula_paga
	    from cliclien
	   where cod_cliente = _cod_pagador;

	  select cedula
	    into _cedula_cont
	    from cliclien
	   where cod_cliente = _cod_contratante;
	   
	  if _cod_ramo not in ("001","003","014","013","010","011","005","006","017","004","019","018","002","020","008","009") then
		return "No se Paga Bonificacion para el Ramo " || _cod_ramo;
	  end if

	  if _cod_grupo = "00000" then --excluir estado
		return "No se Paga Bonificacion para el Grupo " || _cod_grupo;
	  end if  	

	  select count(*)
	    into _cnt
	    from emifafac
	   where no_poliza = _no_poliza;

	  if _cnt > 0 then		--los facultativos se excluyen
		return "No se Paga Bonificacion para los Facultativos ";
	  end if

	FOREACH
		SELECT cod_agente,
		       porc_partic_agt
		  INTO _cod_agente,
		       _porc_partic
		  FROM cobreagt
		 WHERE no_remesa = _no_remesa
		   AND renglon   = _renglon

		SELECT nombre,
		       no_licencia,
		       tipo_pago,
		       tipo_agente,
			   estatus_licencia,
			   cedula
		  INTO _nombre,
		       _no_licencia,
		       _tipo_pago,
		       _tipo_agente,
			   _estatus_licencia,
			   _cedula_agt
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

		if trim(_cedula_agt) = trim(_cedula_paga) then
			return "No se Paga Bonificacion para Mismo Agente y Pagador " || _cedula_agt || " " || _cedula_paga;
		end if
		
		if trim(_cedula_agt) = trim(_cedula_cont) then
			return "No se Paga Bonificacion para Mismo Agente y Contratante " || _cedula_agt || " " || _cedula_cont;
		end if

		IF _tipo_agente <> "A" then	--solo agentes
			return "No se Paga Bonificacion para los que no son Agentes " || _tipo_agente;
		END IF

		IF _estatus_licencia <> "A" then  --El corredor debe ser activo
			return "No se Paga Bonificacion para los que no estan Activos " || _estatus_licencia with resume;
		END IF	   

		LET _monto_m = _monto * (_porc_partic / 100);
		LET _monto_p = _prima * (_porc_partic / 100);

		BEGIN

			ON EXCEPTION IN(-239)

			   	UPDATE tmp_boni
				   SET monto      = monto        + _monto_m,
				       prima      = prima        + _monto_p
				 WHERE cod_agente = _cod_agente
				   AND no_poliza  = _no_poliza;

			END EXCEPTION

			INSERT INTO tmp_boni(cod_agente,no_poliza,monto,prima,fecha)
		    VALUES(_cod_agente,_no_poliza,_monto_m,_monto_p,_fecha);

		END

	END FOREACH

END FOREACH

FOREACH

	 select cod_agente,
	        no_poliza,
	        sum(monto),
			sum(prima)
	   into _cod_agente,
	        _no_poliza,
			_monto_m,
			_monto_p
	   from tmp_boni
	  group by 1, 2

	 select fecha
	   into	_fecha_hoy
	   from tmp_boni
	  where cod_agente = _cod_agente
	    and no_poliza  = _no_poliza;

	 if _monto_m <= 0 then
			return "No se Paga Bonificacion para montos <= 0 " || _monto_m;
	 end if
	
	SELECT nombre,
	       no_licencia
	  INTO _nombre,
	       _no_licencia
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	 SELECT no_documento,
		    cod_tipoprod,
		    cod_ramo,
		    incobrable,
		    cod_formapag,
			cod_subramo,
			cod_origen,
			cod_contratante
	   INTO _no_documento,
		    _cod_tipoprod,
		    _cod_ramo,	
		    _incobrable,
		    _cod_formapag,
			_cod_subramo,
			_cod_origen,
			_cod_contr
	   FROM emipomae
	  WHERE no_poliza = _no_poliza;

	  IF _incobrable = 1 THEN
			return "No se Paga Bonificacion para incobrables " || _incobrable;
	  END IF

	SELECT tipo_produccion
	  INTO _tipo_prod
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	-- No Incluye Coaseguro Minoritario ni Reaseguro Asumido

	IF _tipo_prod = 4 THEN	--reaseguro asumido
			return "No se Paga Bonificacion para reaseguro asumido " || _tipo_prod;
	END IF

	if _tipo_prod = 2 then  --coas mayoritario
		select porc_partic_coas
		  into _porc_coas_ancon
		  from emicoama
		 where no_poliza = _no_poliza
		   and cod_coasegur = "036";    --ancon
	else
		let _porc_coas_ancon = 100;
	end if
	
	SELECT cod_tiporamo
	  INTO _cod_tiporamo
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo; 	

	SELECT tipo_ramo
	  INTO _tipo_ramo
	  FROM prdtiram
	 WHERE cod_tiporamo = _cod_tiporamo;

	--Buscar forma de pago
	SELECT tipo_forma
	  INTO _tipo_forma
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

	if _tipo_forma <> 2 and _tipo_forma <> 3 and _tipo_forma <> 4 then	--2=visa,3=desc salario,4=ach
		let _forma_pag = 0;		--es voluntario
	else
		let _forma_pag = 1;		--es electronico
	end if

	let _prima_r     = 0;
	let _prima_rr    = 0;
	let _formula_a   = 0;
	let _porc_comis  = 0;
	let _porc_comis2 = 0;
	let _prima_45    = 0;
	let _prima_90    = 0;
	let _formula_b   = 0;
	let v_corriente  = 0;
	let v_monto_30   = 0;
	let v_monto_60   = 0;
	let v_corr       = 0;
	let v_monto_30bk = 0;

	let _prima_r = _monto_p;
	let _prima_r = (_porc_coas_ancon * _prima_r) / 100;

	CALL sp_cob33b(a_compania,a_sucursal,_no_documento,a_periodo,_fecha_hoy) RETURNING v_por_vencer,v_exigible,v_corriente,v_monto_30,v_monto_60,v_saldo;

	let v_corriente = (v_corriente * _porc_coas_ancon) / 100;
	let v_monto_30  = (v_monto_30  * _porc_coas_ancon) / 100;
	let v_monto_60  = (v_monto_60  * _porc_coas_ancon) / 100;

	let v_corr       = v_corriente;
	let v_monto_30bk = v_monto_30;

	if v_monto_60 > 0 then

		let _prima_r = v_monto_60 - _prima_r;  --restarle al pago la morosidad

		if _prima_r <= 0 then	  

			let _prima_r = ABS(_prima_r);

		else

			continue foreach;			       --salir por que no quedo pago

		end if

	end if

	if v_monto_30 > 0 then	  --hay morosidad >45 a 90

		let _prima_rr = _prima_r;
		let _prima_r = v_monto_30 - _prima_r;

		if _prima_r <= 0 then			   --queda pago todavia


			let _prima_r  = ABS(_prima_r);

		else
			                           --se acabo el pago
	   	    let v_monto_30 = _prima_rr;
			let v_corriente = -1;

		end if

		if _forma_pag = 0 then	--Pago voluntario y Moro de 46 a 90 dias
			let _porc_comis2 = 1;
			let _formula_a = v_monto_30 * (_porc_comis2 / 100);
		end if

		if _forma_pag = 1  then	--Pago electronico y Moro de 46 a 90 dias
			let _porc_comis2 = 2;
			let _formula_a = v_monto_30 * (_porc_comis2 / 100);
		end if

		let _prima_90  = v_monto_30;
		let v_monto_30 = v_monto_30bk;
	end if
	
	if v_corriente >= 0 then	  --hay morosidad 0 a 45

		if _forma_pag = 0 then	--Pago voluntario y Moro de 46 a 90 dias
			let _porc_comis = 2;
			let _formula_b = _prima_r * (_porc_comis / 100);
		end if

		if _forma_pag = 1  then	--Pago electronico y Moro de 46 a 90 dias
			let _porc_comis = 3;
			let _formula_b = _prima_r * (_porc_comis / 100);
		end if

		let _prima_45 = _prima_r;
	end if

    SELECT nombre
      INTO v_nombre_clte
      FROM cliclien
     WHERE cod_cliente = _cod_contr;

	let v_corriente = v_corr;

		INSERT INTO tmp_chqboni(
		cod_agente,
		no_poliza,
		monto,
		prima,
		comision,
		nombre,
		no_documento,
		no_licencia,
		seleccionado,
		periodo,
		fecha_genera,
		moro_045,
		moro_4690,
		porc_045,
		porc_4690,
		pol_corr,
		pol_0045,
		pol_4690,
		cod_ramo,
		cod_subramo,
		cod_origen,
		comis0045,
		comis4690,
		nombre_cte)
		VALUES (
		_cod_agente,
		_no_poliza,
		_monto_m,
		_monto_p,
		_formula_a + _formula_b,
		_nombre,
		_no_documento,
		_no_licencia,
		0,
		a_periodo,
		current,
		_prima_45,
		_prima_90,
		_porc_comis,
		_porc_comis2,
		v_corriente,
		v_monto_30,
		v_monto_60,
		_cod_ramo,
		_cod_subramo,
		_cod_origen,
		_formula_b,
		_formula_a,
		v_nombre_clte
		);		   

END FOREACH

DROP TABLE tmp_boni; 

return "Verificacion Completa";

END PROCEDURE;