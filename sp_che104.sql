--********************************************************
-- Procedimiento que Carga las Bonificacion de FF SEGUROS
--********************************************************

-- Creado    : 27/02/2008 - Autor: Armando Moreno M.
-- Modificado: 27/02/2008 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che104;

CREATE PROCEDURE sp_che104
(
a_compania          CHAR(3),
a_sucursal          CHAR(3),
a_periodo		    CHAR(7),
a_usuario           CHAR(8)
)
RETURNING SMALLINT;

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
define _prima_bruta     DEC(16,2);
define _cod_grupo       char(5);
define _cedula_agt      char(30);
define _cedula_paga		char(30);
define _cedula_cont		char(30);
define _cod_pagador     char(10);
define _cod_contratante char(10);
define _estatus_licencia char(1);
define v_nombre_clte     char(100);
define _cod_contr        char(10);
define _error           smallint;
define _monto_m			DEC(16,2);
define _monto_p			DEC(16,2);
define _suc_origen      char(3);
define _beneficios      smallint;
define _contado         smallint;
define _agente_agrupado char(5);

--SET DEBUG FILE TO "sp_che81.trc";
--TRACE ON;

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
let _prima_bruta  = 0;

CREATE TEMP TABLE tmp_ff(
	cod_agente		CHAR(15),
	no_poliza		CHAR(10),
	monto           DEC(16,2),
	prima           DEC(16,2),
	fecha           DATE,
	PRIMARY KEY		(cod_agente, no_poliza)
	) WITH NO LOG;

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
      ORDER BY d.fecha,d.no_recibo,d.no_poliza

	  select cod_grupo, cod_ramo, cod_pagador, cod_contratante,no_documento,sucursal_origen,prima_bruta,cod_subramo
	    into _cod_grupo,_cod_ramo,_cod_pagador,_cod_contratante,_no_documento,_suc_origen,_prima_bruta,_cod_subramo
	    from emipomae
	   where no_poliza = _no_poliza;

	  if _cod_ramo not in ("002","020","015","009","001","003","004","006","005","007","010","018","016") then
		continue foreach;
	  end if

	  {if _cod_ramo = "009" and _cod_subramo <> "004" then --debe ser subramo Maritimo
		continue foreach;
	  end if}

	  if _cod_grupo = "00000" then --excluir estado
		--INSERT INTO bonibita(periodo,poliza,descripcion)	VALUES (a_periodo,_no_documento,'Se excluye Grupo del Estado.');
		continue foreach;
	  end if  	

	  select count(*)
	    into _cnt
	    from emifafac
	   where no_poliza = _no_poliza;

	  if _cnt > 0 then		--los facultativos se excluyen
		continue foreach;
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
			   cedula,
			   agente_agrupado
		  INTO _nombre,
		       _no_licencia,
		       _tipo_pago,
		       _tipo_agente,
			   _estatus_licencia,
			   _cedula_agt,
			   _agente_agrupado
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;


		--Solo para FF SEGUROS
		if _agente_agrupado = "01068" then
		else
			continue foreach;
		end if

		IF _estatus_licencia <> "A" then  --El corredor debe ser activo
			continue foreach;
		END IF

		LET _monto_m = _monto * (_porc_partic / 100);
		LET _monto_p = _prima * (_porc_partic / 100);

		BEGIN

			ON EXCEPTION IN(-239)

			   	UPDATE tmp_ff
				   SET monto      = monto        + _monto_m,
				       prima      = prima        + _monto_p
				 WHERE cod_agente = _cod_agente
				   AND no_poliza  = _no_poliza;

			END EXCEPTION

			INSERT INTO tmp_ff(cod_agente,no_poliza,monto,prima,fecha)
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
	   from tmp_ff
	  group by 1, 2

	 select fecha
	   into	_fecha_hoy
	   from tmp_ff
	  where cod_agente = _cod_agente
	    and no_poliza  = _no_poliza;

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

	  if _monto_m <= 0 then
		 --INSERT INTO bonibita(periodo,poliza,descripcion)	VALUES (a_periodo,_no_documento,'No se perimite montos menores o igual a cero.');
	 	 continue foreach;
	  end if

	SELECT tipo_produccion
	  INTO _tipo_prod
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	-- No Incluye Reaseguro Asumido

	IF _tipo_prod = 4 THEN	--reaseguro asumido
	   --INSERT INTO bonibita(periodo,poliza,descripcion)	VALUES (a_periodo,_no_documento,'Se excluye reaseguro asumido.');
	   CONTINUE FOREACH;
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

	let _prima_r     = 0;
	let _formula_a   = 0;
	let _porc_comis  = 5;

	let _prima_r   = _monto_p;
	let _prima_r   = (_porc_coas_ancon * _prima_r) / 100;
	let _formula_a = _prima_r * (_porc_comis / 100);


    SELECT nombre
      INTO v_nombre_clte
      FROM cliclien
     WHERE cod_cliente = _cod_contr;

		INSERT INTO chqff(
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
		porc_comis,
		cod_ramo,
		cod_subramo,
		nombre_cte,
		cod_origen)
		VALUES (
		_cod_agente,
		_no_poliza,
		_monto_m,
		_monto_p,
		_formula_a,
		_nombre,
		_no_documento,
		_no_licencia,
		0,
		a_periodo,
		current,
		_porc_comis,
		_cod_ramo,
		_cod_subramo,
		v_nombre_clte,
		_cod_origen
		);

END FOREACH

foreach

	SELECT cod_agente
	  INTO _cod_agente
	  FROM chqff
     WHERE periodo = a_periodo
	 GROUP BY cod_agente
	 ORDER BY cod_agente


 	call sp_che105(a_compania,a_sucursal,_cod_agente,a_usuario,'001','001',a_periodo) returning _error;

	if _error <> 0 then
		return _error;
	end if

end foreach	

update parparam
   set ult_per_ff = a_periodo
 where cod_compania = a_compania;


DROP TABLE tmp_ff; 

return 0;
END PROCEDURE;